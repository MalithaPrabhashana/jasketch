cl import from react { useState, useEffect, useRef }

cl {
    def:pub Canvas(props: dict) -> any {
        canvasRef = useRef(None);
        containerRef = useRef(None);
        textInputRef = useRef(None);
        [isDrawing, setIsDrawing] = useState(False);
        [elements, setElements] = useState([]);
        [startPoint, setStartPoint] = useState(None);
        [currentPath, setCurrentPath] = useState([]);
        [textInput, setTextInput] = useState(None);
        [canvasSize, setCanvasSize] = useState({"width": 2000, "height": 1500});
        [selectedElement, setSelectedElement] = useState(None);
        [isDragging, setIsDragging] = useState(False);
        [dragOffset, setDragOffset] = useState({"x": 0, "y": 0});
        [zoom, setZoom] = useState(1);
        [panOffset, setPanOffset] = useState({"x": 0, "y": 0});
        [isPanning, setIsPanning] = useState(False);
        
        # Get props with defaults
        currentTool = props.currentTool or "freehand";
        currentColor = props.currentColor or "#000000";
        currentStrokeWidth = props.currentStrokeWidth or 2;
        currentFontSize = props.currentFontSize or 24;
        currentFontFamily = props.currentFontFamily or "Virgil";

        # Resize canvas to fit container
        useEffect(lambda -> None {
            def handleResize() -> None {
                if containerRef.current {
                    # Keep the canvas at a fixed large size for infinite canvas
                    setCanvasSize({
                        "width": 2000,
                        "height": 1500
                    });
                }
            }
            handleResize();
            window.addEventListener("resize", handleResize);
            return lambda -> None { window.removeEventListener("resize", handleResize); };
        }, []);

        useEffect(lambda -> None {
            canvas = canvasRef.current;
            if canvas {
                canvas.width = canvasSize.width;
                canvas.height = canvasSize.height;
                redrawCanvas();
            }
        }, [elements, canvasSize]);

        def redrawCanvas() -> None {
            canvas = canvasRef.current;
            if not canvas {
                return;
            }
            
            ctx = canvas.getContext("2d");
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            
            # Draw all elements
            elements.forEach(lambda element: any -> None {
                if element.type == "text" {
                    ctx.font = element.fontSize + "px " + element.fontFamily;
                    ctx.fillStyle = element.color;
                    ctx.textBaseline = "top";
                    # Draw each line of text
                    lines = element.text.split("\n");
                    lines.forEach(lambda line: any, index: any -> None {
                        ctx.fillText(line, element.x, element.y + (index * element.fontSize * 1.2));
                    });
                } else {
                    ctx.strokeStyle = element.color;
                    ctx.lineWidth = element.strokeWidth;
                    ctx.fillStyle = element.fillColor or "transparent";
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    
                    if element.type == "freehand" {
                        ctx.beginPath();
                        points = element.points;
                        if points.length > 0 {
                            ctx.moveTo(points[0].x, points[0].y);
                            for i=1 to i < points.length by i+=1 {
                                ctx.lineTo(points[i].x, points[i].y);
                            }
                        }
                        ctx.stroke();
                    } elif element.type == "rectangle" {
                        ctx.beginPath();
                        ctx.rect(element.x, element.y, element.width, element.height);
                        ctx.stroke();
                        if element.fillColor and element.fillColor != "transparent" {
                            ctx.fill();
                        }
                    } elif element.type == "circle" {
                        ctx.beginPath();
                        radius = Math.sqrt(Math.pow(element.width, 2) + Math.pow(element.height, 2)) / 2;
                        ctx.arc(element.x + element.width/2, element.y + element.height/2, radius, 0, 2 * Math.PI);
                        ctx.stroke();
                        if element.fillColor and element.fillColor != "transparent" {
                            ctx.fill();
                        }
                    } elif element.type == "line" {
                        ctx.beginPath();
                        ctx.moveTo(element.x1, element.y1);
                        ctx.lineTo(element.x2, element.y2);
                        ctx.stroke();
                    }
                }
            });
        }

        def getMousePos(e: dict) -> dict {
            canvas = canvasRef.current;
            rect = canvas.getBoundingClientRect();
            return {
                "x": (e.clientX - rect.left - panOffset.x) / zoom,
                "y": (e.clientY - rect.top - panOffset.y) / zoom
            };
        }

        def isPointInElement(point: dict, element: dict) -> bool {
            if element.type == "text" {
                # Simple bounding box for text
                textWidth = element.fontSize * element.text.length * 0.6;
                textHeight = element.fontSize * 1.2;
                return point.x >= element.x and point.x <= element.x + textWidth and point.y >= element.y and point.y <= element.y + textHeight;
            } elif element.type == "rectangle" {
                return point.x >= element.x and point.x <= element.x + element.width and point.y >= element.y and point.y <= element.y + element.height;
            } elif element.type == "circle" {
                centerX = element.x + element.width / 2;
                centerY = element.y + element.height / 2;
                radius = Math.sqrt(Math.pow(element.width, 2) + Math.pow(element.height, 2)) / 2;
                distance = Math.sqrt(Math.pow(point.x - centerX, 2) + Math.pow(point.y - centerY, 2));
                return distance <= radius;
            } elif element.type == "line" {
                # Distance from point to line
                A = point.y - element.y1;
                B = element.x1 - point.x;
                C = element.y2 * element.x1 - element.x2 * element.y1;
                distance = Math.abs(A * element.x2 + B * element.y2 + C) / Math.sqrt(Math.pow(A, 2) + Math.pow(B, 2));
                return distance <= 5; # 5px tolerance for line selection
            } elif element.type == "freehand" {
                # Check if point is near any point in the path
                tolerance = 10;
                for point_in_path in element.points {
                    distance = Math.sqrt(Math.pow(point.x - point_in_path.x, 2) + Math.pow(point.y - point_in_path.y, 2));
                    if distance <= tolerance {
                        return True;
                    }
                }
                return False;
            }
            return False;
        }

        def findElementAtPoint(point: dict) -> dict {
            # Search in reverse order (top elements first)
            for i in range(elements.length - 1, -1, -1) {
                if isPointInElement(point, elements[i]) {
                    return {"element": elements[i], "index": i};
                }
            }
            return None;
        }

        def handleCanvasClick(e: dict) -> None {
            if currentTool == "text" {
                pos = getMousePos(e);
                setTextInput({
                    "x": pos.x,
                    "y": pos.y,
                    "text": ""
                });
                # Focus input after render
                setTimeout(lambda -> None {
                    if textInputRef.current {
                        textInputRef.current.focus();
                    }
                }, 10);
            }
        }

        def handleTextSubmit() -> None {
            if textInput {
                if textInput.text and textInput.text.trim() {
                    newElement = {
                        "type": "text",
                        "x": textInput.x,
                        "y": textInput.y,
                        "text": textInput.text,
                        "color": currentColor,
                        "fontSize": currentFontSize,
                        "fontFamily": currentFontFamily
                    };
                    setElements(elements.concat([newElement]));
                }
                setTextInput(None);
            }
        }

        def handleTextKeyDown(e: dict) -> None {
            if e.key == "Escape" {
                setTextInput(None);
            } elif e.key == "Enter" and not e.shiftKey {
                e.preventDefault();
                handleTextSubmit();
            }
        }

        def handleMouseDown(e: dict) -> None {
            pos = getMousePos(e);
            
            if currentTool == "select" {
                elementInfo = findElementAtPoint(pos);
                if elementInfo {
                    setSelectedElement(elementInfo);
                    setIsDragging(True);
                    setDragOffset({
                        "x": pos.x - (elementInfo.element.x or elementInfo.element.x1 or elementInfo.element.points[0].x),
                        "y": pos.y - (elementInfo.element.y or elementInfo.element.y1 or elementInfo.element.points[0].y)
                    });
                } else {
                    setSelectedElement(None);
                    setIsPanning(True);
                }
                return;
            }
            
            if currentTool == "text" {
                return;
            }
            
            setIsDrawing(True);
            setStartPoint(pos);
            
            if currentTool == "freehand" {
                setCurrentPath([pos]);
            }
        }

        def handleMouseMove(e: dict) -> None {
            pos = getMousePos(e);
            
            if isDragging and selectedElement and currentTool == "select" {
                # Move the selected element
                newElements = elements.slice();
                element = selectedElement.element;
                newElement = Object.assign({}, element);
                
                if element.type == "text" or element.type == "rectangle" or element.type == "circle" {
                    newElement.x = pos.x - dragOffset.x;
                    newElement.y = pos.y - dragOffset.y;
                } elif element.type == "line" {
                    deltaX = pos.x - dragOffset.x - element.x1;
                    deltaY = pos.y - dragOffset.y - element.y1;
                    newElement.x1 = element.x1 + deltaX;
                    newElement.y1 = element.y1 + deltaY;
                    newElement.x2 = element.x2 + deltaX;
                    newElement.y2 = element.y2 + deltaY;
                } elif element.type == "freehand" {
                    deltaX = pos.x - dragOffset.x - element.points[0].x;
                    deltaY = pos.y - dragOffset.y - element.points[0].y;
                    newElement.points = element.points.map(lambda point: dict -> dict {
                        return {"x": point.x + deltaX, "y": point.y + deltaY};
                    });
                }
                
                newElements[selectedElement.index] = newElement;
                setElements(newElements);
                return;
            }
            
            if isPanning and currentTool == "select" {
                deltaX = e.movementX;
                deltaY = e.movementY;
                setPanOffset({
                    "x": panOffset.x + deltaX,
                    "y": panOffset.y + deltaY
                });
                return;
            }
            
            if not isDrawing {
                return;
            }
            
            if currentTool == "freehand" {
                newPath = currentPath.concat([pos]);
                setCurrentPath(newPath);
                
                # Draw preview
                canvas = canvasRef.current;
                ctx = canvas.getContext("2d");
                redrawCanvas();
                ctx.strokeStyle = currentColor;
                ctx.lineWidth = currentStrokeWidth;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";
                ctx.beginPath();
                if currentPath.length > 0 {
                    lastPoint = currentPath[currentPath.length - 1];
                    ctx.moveTo(lastPoint.x, lastPoint.y);
                    ctx.lineTo(pos.x, pos.y);
                    ctx.stroke();
                }
            } else {
                # Draw preview for shapes
                canvas = canvasRef.current;
                ctx = canvas.getContext("2d");
                redrawCanvas();
                ctx.strokeStyle = currentColor;
                ctx.lineWidth = currentStrokeWidth;
                ctx.setLineDash([5, 5]);
                
                if currentTool == "rectangle" {
                    w = pos.x - startPoint.x;
                    h = pos.y - startPoint.y;
                    ctx.strokeRect(startPoint.x, startPoint.y, w, h);
                } elif currentTool == "circle" {
                    w = pos.x - startPoint.x;
                    h = pos.y - startPoint.y;
                    radius = Math.sqrt(Math.pow(w, 2) + Math.pow(h, 2)) / 2;
                    ctx.beginPath();
                    ctx.arc(startPoint.x + w/2, startPoint.y + h/2, radius, 0, 2 * Math.PI);
                    ctx.stroke();
                } elif currentTool == "line" {
                    ctx.beginPath();
                    ctx.moveTo(startPoint.x, startPoint.y);
                    ctx.lineTo(pos.x, pos.y);
                    ctx.stroke();
                }
                
                ctx.setLineDash([]);
            }
        }

        def handleMouseUp(e: dict) -> None {
            setIsDragging(False);
            setIsPanning(False);
            
            if not isDrawing {
                return;
            }
            
            setIsDrawing(False);
            pos = getMousePos(e);
            
            newElement = None;
            
            if currentTool == "freehand" {
                if currentPath.length > 0 {
                    newElement = {
                        "type": "freehand",
                        "points": currentPath,
                        "color": currentColor,
                        "strokeWidth": currentStrokeWidth
                    };
                }
                setCurrentPath([]);
            } elif currentTool == "rectangle" {
                w = pos.x - startPoint.x;
                h = pos.y - startPoint.y;
                newElement = {
                    "type": "rectangle",
                    "x": startPoint.x,
                    "y": startPoint.y,
                    "width": w,
                    "height": h,
                    "color": currentColor,
                    "strokeWidth": currentStrokeWidth,
                    "fillColor": "transparent"
                };
            } elif currentTool == "circle" {
                w = pos.x - startPoint.x;
                h = pos.y - startPoint.y;
                newElement = {
                    "type": "circle",
                    "x": startPoint.x,
                    "y": startPoint.y,
                    "width": w,
                    "height": h,
                    "color": currentColor,
                    "strokeWidth": currentStrokeWidth,
                    "fillColor": "transparent"
                };
            } elif currentTool == "line" {
                newElement = {
                    "type": "line",
                    "x1": startPoint.x,
                    "y1": startPoint.y,
                    "x2": pos.x,
                    "y2": pos.y,
                    "color": currentColor,
                    "strokeWidth": currentStrokeWidth
                };
            }
            
            if newElement {
                setElements(elements.concat([newElement]));
            }
        }

        def handleWheel(e: dict) -> None {
            e.preventDefault();
            zoomFactor = 1;
            if e.deltaY > 0 {
                zoomFactor = 0.9;
            } else {
                zoomFactor = 1.1;
            }
            newZoom = zoom * zoomFactor;
            if newZoom >= 0.1 and newZoom <= 5 {
                setZoom(newZoom);
            }
        }

        # Determine cursor based on tool
        cursorClass = "cursor-crosshair";
        if currentTool == "text" {
            cursorClass = "cursor-text";
        } elif currentTool == "select" {
            cursorClass = "cursor-default";
        }

        textInputElement = None;
        if (textInput) {
            textInputElement = <textarea
                ref={textInputRef}
                value={textInput.text or ""}
                onChange={lambda e: any -> None { 
                    if (textInput) {
                        setTextInput({
                            "x": textInput.x,
                            "y": textInput.y,
                            "text": e.target.value
                        });
                    }
                }}
                onKeyDown={handleTextKeyDown}
                onBlur={handleTextSubmit}
                className="absolute bg-transparent border-2 border-violet-500 rounded-lg p-2 outline-none resize-none"
                style={{
                    "left": (textInput.x or 0) + "px",
                    "top": (textInput.y or 0) + "px",
                    "color": currentColor,
                    "fontSize": currentFontSize + "px",
                    "fontFamily": currentFontFamily,
                    "minWidth": "100px",
                    "minHeight": "40px"
                }}
                placeholder="Type here..."
            />;
        }

        return <div ref={containerRef} className="relative w-full h-full flex items-center justify-center overflow-hidden">
        <div style={{"transform": "scale(" + zoom + ") translate(" + panOffset.x + "px, " + panOffset.y + "px)", "transformOrigin": "0 0"}}>
            <canvas
                ref={canvasRef}
                className={"rounded-xl shadow-2xl " + cursorClass}
                style={{
                    "backgroundColor": "#ffffff",
                    "minWidth": "2000px",
                    "minHeight": "1500px"
                }}
                onClick={handleCanvasClick}
                onMouseDown={handleMouseDown}
                onMouseMove={handleMouseMove}
                onMouseUp={handleMouseUp}
                onMouseLeave={lambda -> None { setIsDrawing(False); setIsDragging(False); setIsPanning(False); }}
                onWheel={handleWheel}
            />
        </div>
        
        {textInputElement}
    </div>;
}
}