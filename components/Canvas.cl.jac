import from react { useRef, useEffect, useState }
import from "..hooks.useCanvas" { useCanvas }
import from "..hooks.useDrawingState" { useDrawingState }
import from "..hooks.useElements" { useElements }
import from "..hooks.useSelection" { useSelection }
import from "..hooks.useViewport" { useViewport }
import from "..hooks.useTextInput" { useTextInput }
import from "..services.geometry" { getMousePosition }
import from "..services.canvas" { drawPreview }
import from .canvas.CanvasRenderer { CanvasRenderer }
import from .canvas.TextInput { TextInput }

def:pub Canvas(props: dict) -> any {
    currentTool = props.currentTool or "freehand";
    currentColor = props.currentColor or "#000000";
    currentStrokeWidth = props.currentStrokeWidth or 2;
    currentFontSize = props.currentFontSize or 24;
    currentFontFamily = props.currentFontFamily or "Virgil";

    canvasHook = useCanvas();
    drawingState = useDrawingState();
    elementsHook = useElements();
    selectionHook = useSelection();
    viewportHook = useViewport();
    textInputHook = useTextInput();

    canvasRef = canvasHook.canvasRef;
    containerRef = canvasHook.containerRef;
    textInputRef = useRef(None);
    [spacePressed, setSpacePressed] = useState(False);

    can with [elementsHook.elements, canvasHook.canvasSize, viewportHook.zoom, viewportHook.panOffset, selectionHook.selectedElement, selectionHook.selectedElements, selectionHook.isBoxSelecting, selectionHook.boxStart, selectionHook.boxEnd] entry {
        canvas = canvasRef.current;
        if canvas {
            canvas.width = canvasHook.canvasSize.width;
            canvas.height = canvasHook.canvasSize.height;
            canvasHook.redrawCanvas(elementsHook.elements, viewportHook.zoom, viewportHook.panOffset, selectionHook.selectedElement, selectionHook.selectedElements, selectionHook.isBoxSelecting, selectionHook.boxStart, selectionHook.boxEnd);
        }
    }

    useEffect(lambda -> any {
        def handleKeyDown(e: dict) -> None {
            if e.key == " " and not textInputHook.textInput {
                e.preventDefault();
                setSpacePressed(True);
            }
            if not textInputHook.textInput and (e.key == "Delete" or e.key == "Backspace") {
                if selectionHook.selectedElements.length > 0 {
                    indices = [];
                    i = 0;
                    while i < selectionHook.selectedElements.length {
                        indices.push(selectionHook.selectedElements[i].index);
                        i = i + 1;
                    }
                    indices.sort(lambda a: int, b: int -> int { return b - a; });
                    j = 0;
                    while j < indices.length {
                        elementsHook.removeElement(indices[j]);
                        j = j + 1;
                    }
                    selectionHook.clearSelection();
                    e.preventDefault();
                } elif selectionHook.selectedElement {
                    elementsHook.removeElement(selectionHook.selectedElement.index);
                    selectionHook.clearSelection();
                    e.preventDefault();
                }
            }
        }

        def handleKeyUp(e: dict) -> None {
            if e.key == " " {
                setSpacePressed(False);
            }
        }

        window.addEventListener("keydown", handleKeyDown);
        window.addEventListener("keyup", handleKeyUp);
        return lambda -> None {
            window.removeEventListener("keydown", handleKeyDown);
            window.removeEventListener("keyup", handleKeyUp);
        };
    }, [selectionHook.selectedElement, selectionHook.selectedElements, textInputHook.textInput]);

    useEffect(lambda -> any {
        canvas = canvasRef.current;
        if not canvas {
            return None;
        }

        def handleWheel(e: dict) -> None {
            e.preventDefault();
            viewportHook.handleZoom(e.deltaY, e.clientX, e.clientY, canvas);
        }

        canvas.addEventListener("wheel", handleWheel, {"passive": False});
        return lambda -> None {
            canvas.removeEventListener("wheel", handleWheel);
        };
    }, [viewportHook.zoom, viewportHook.panOffset]);

    def handleCanvasClick(e: dict) -> None {
        if currentTool == "text" {
            pos = getMousePosition(e, canvasRef.current, viewportHook.panOffset, viewportHook.zoom);
            textInputHook.startTextInput(pos.x, pos.y);
            setTimeout(lambda -> None {
                if textInputRef.current {
                    textInputRef.current.focus();
                }
            }, 10);
        }
    }

    def handleCanvasDoubleClick(e: dict) -> None {
        if currentTool == "select" {
            pos = getMousePosition(e, canvasRef.current, viewportHook.panOffset, viewportHook.zoom);
            elementInfo = selectionHook.findElementAtPoint(pos, elementsHook.elements);

            if elementInfo and elementInfo.element.type == "text" {
                element = elementInfo.element;
                textInputHook.startTextInput(element.x, element.y, element.text);
                elementsHook.removeElement(elementInfo.index);
                selectionHook.clearSelection();

                setTimeout(lambda -> None {
                    if textInputRef.current {
                        textInputRef.current.focus();
                        textInputRef.current.select();
                    }
                }, 10);
            }
        }
    }

    def handleTextSubmit() -> None {
        if textInputHook.textInput and textInputHook.hasContent() {
            newElement = {
                "type": "text",
                "x": textInputHook.textInput.x,
                "y": textInputHook.textInput.y,
                "text": textInputHook.textInput.text,
                "color": currentColor,
                "fontSize": currentFontSize,
                "fontFamily": currentFontFamily
            };
            elementsHook.addElement(newElement);
        }
        textInputHook.cancelTextInput();
    }

    def handleTextKeyDown(e: dict) -> None {
        if e.key == "Escape" {
            textInputHook.cancelTextInput();
        } elif e.key == "Enter" and not e.shiftKey {
            e.preventDefault();
            handleTextSubmit();
        }
    }

    def handleMouseDown(e: dict) -> None {
        pos = getMousePosition(e, canvasRef.current, viewportHook.panOffset, viewportHook.zoom);

        if spacePressed or e.button == 1 {
            viewportHook.startPanning();
            e.preventDefault();
            return;
        }

        if currentTool == "select" {
            if e.button == 2 or e.metaKey or e.ctrlKey {
                viewportHook.startPanning();
                e.preventDefault();
                return;
            }

            elementInfo = selectionHook.findElementAtPoint(pos, elementsHook.elements);
            if elementInfo {
                isInSelection = False;
                if selectionHook.selectedElements.length > 0 {
                    i = 0;
                    while i < selectionHook.selectedElements.length {
                        if selectionHook.selectedElements[i].index == elementInfo.index {
                            isInSelection = True;
                        }
                        i = i + 1;
                    }
                }

                if isInSelection {
                    selectionHook.setIsDragging(True);
                    selectionHook.setDragStartPos(pos);
                } else {
                    selectionHook.startDragging(elementInfo, pos);
                }
            } else {
                selectionHook.clearSelection();
                selectionHook.startBoxSelection(pos);
            }
            return;
        }

        if currentTool == "text" {
            return;
        }

        drawingState.setIsDrawing(True);
        drawingState.setStartPoint(pos);

        if currentTool == "freehand" {
            drawingState.setCurrentPath([pos]);
        }
    }

    def handleMouseMove(e: dict) -> None {
        pos = getMousePosition(e, canvasRef.current, viewportHook.panOffset, viewportHook.zoom);

        if viewportHook.isPanning {
            viewportHook.handlePan(e.movementX, e.movementY);
            return;
        }

        if selectionHook.isBoxSelecting and currentTool == "select" {
            selectionHook.updateBoxSelection(pos);
            return;
        }

        if selectionHook.isDragging and currentTool == "select" {
            if selectionHook.selectedElements.length > 1 and selectionHook.dragStartPos {
                deltaX = pos.x - selectionHook.dragStartPos.x;
                deltaY = pos.y - selectionHook.dragStartPos.y;

                updates = [];
                i = 0;
                while i < selectionHook.selectedElements.length {
                    selectedInfo = selectionHook.selectedElements[i];
                    originalElement = selectedInfo.element;
                    newElement = Object.assign({}, originalElement);

                    if originalElement.type == "text" or originalElement.type == "rectangle" or originalElement.type == "circle" {
                        newElement.x = originalElement.x + deltaX;
                        newElement.y = originalElement.y + deltaY;
                    } elif originalElement.type == "line" {
                        newElement.x1 = originalElement.x1 + deltaX;
                        newElement.y1 = originalElement.y1 + deltaY;
                        newElement.x2 = originalElement.x2 + deltaX;
                        newElement.y2 = originalElement.y2 + deltaY;
                    } elif originalElement.type == "freehand" {
                        newElement.points = originalElement.points.map(lambda point: dict -> dict {
                            return {"x": point.x + deltaX, "y": point.y + deltaY};
                        });
                    }

                    updates.push({"index": selectedInfo.index, "element": newElement});
                    i = i + 1;
                }
                elementsHook.updateMultipleElements(updates);
                return;
            } elif selectionHook.selectedElement {
                element = selectionHook.selectedElement.element;
                newElement = Object.assign({}, element);

                if element.type == "text" or element.type == "rectangle" or element.type == "circle" {
                    newElement.x = pos.x - selectionHook.dragOffset.x;
                    newElement.y = pos.y - selectionHook.dragOffset.y;
                } elif element.type == "line" {
                    deltaX = pos.x - selectionHook.dragOffset.x - element.x1;
                    deltaY = pos.y - selectionHook.dragOffset.y - element.y1;
                    newElement.x1 = element.x1 + deltaX;
                    newElement.y1 = element.y1 + deltaY;
                    newElement.x2 = element.x2 + deltaX;
                    newElement.y2 = element.y2 + deltaY;
                } elif element.type == "freehand" {
                    deltaX = pos.x - selectionHook.dragOffset.x - element.points[0].x;
                    deltaY = pos.y - selectionHook.dragOffset.y - element.points[0].y;
                    newElement.points = element.points.map(lambda point: dict -> dict {
                        return {"x": point.x + deltaX, "y": point.y + deltaY};
                    });
                }

                elementsHook.updateElement(selectionHook.selectedElement.index, newElement);
                return;
            }
        }

        if not drawingState.isDrawing {
            return;
        }

        if currentTool == "freehand" {
            newPath = drawingState.currentPath.concat([pos]);
            drawingState.setCurrentPath(newPath);

            canvas = canvasRef.current;
            ctx = canvas.getContext("2d");

            ctx.save();
            ctx.translate(viewportHook.panOffset.x, viewportHook.panOffset.y);
            ctx.scale(viewportHook.zoom, viewportHook.zoom);

            ctx.strokeStyle = currentColor;
            ctx.lineWidth = currentStrokeWidth;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.beginPath();

            pathLen = drawingState.currentPath.length;
            if pathLen >= 2 {
                prev = drawingState.currentPath[pathLen - 2];
                last = drawingState.currentPath[pathLen - 1];
                midX = (last.x + pos.x) / 2;
                midY = (last.y + pos.y) / 2;
                ctx.moveTo(last.x, last.y);
                ctx.quadraticCurveTo(last.x, last.y, midX, midY);
                ctx.stroke();
            } elif pathLen == 1 {
                ctx.moveTo(drawingState.currentPath[0].x, drawingState.currentPath[0].y);
                ctx.lineTo(pos.x, pos.y);
                ctx.stroke();
            }

            ctx.restore();
        } else {
            canvas = canvasRef.current;
            ctx = canvas.getContext("2d");
            canvasHook.redrawCanvas(elementsHook.elements, viewportHook.zoom, viewportHook.panOffset, selectionHook.selectedElement, selectionHook.selectedElements, selectionHook.isBoxSelecting, selectionHook.boxStart, selectionHook.boxEnd);

            ctx.save();
            ctx.translate(viewportHook.panOffset.x, viewportHook.panOffset.y);
            ctx.scale(viewportHook.zoom, viewportHook.zoom);
            drawPreview(ctx, currentTool, drawingState.startPoint, pos, currentColor, currentStrokeWidth);
            ctx.restore();
        }
    }

    def handleMouseUp(e: dict) -> None {
        if selectionHook.isBoxSelecting and currentTool == "select" {
            selectionHook.finishBoxSelection(elementsHook.elements);
            return;
        }

        selectionHook.stopDragging();
        viewportHook.stopPanning();

        if not drawingState.isDrawing {
            return;
        }

        drawingState.setIsDrawing(False);
        pos = getMousePosition(e, canvasRef.current, viewportHook.panOffset, viewportHook.zoom);

        newElement = None;

        if currentTool == "freehand" {
            if drawingState.currentPath.length > 0 {
                newElement = {
                    "type": "freehand",
                    "points": drawingState.currentPath,
                    "color": currentColor,
                    "strokeWidth": currentStrokeWidth
                };
            }
            drawingState.setCurrentPath([]);
        } elif currentTool == "rectangle" {
            w = pos.x - drawingState.startPoint.x;
            h = pos.y - drawingState.startPoint.y;
            newElement = {
                "type": "rectangle",
                "x": drawingState.startPoint.x,
                "y": drawingState.startPoint.y,
                "width": w,
                "height": h,
                "color": currentColor,
                "strokeWidth": currentStrokeWidth,
                "fillColor": "transparent"
            };
        } elif currentTool == "circle" {
            w = pos.x - drawingState.startPoint.x;
            h = pos.y - drawingState.startPoint.y;
            newElement = {
                "type": "circle",
                "x": drawingState.startPoint.x,
                "y": drawingState.startPoint.y,
                "width": w,
                "height": h,
                "color": currentColor,
                "strokeWidth": currentStrokeWidth,
                "fillColor": "transparent"
            };
        } elif currentTool == "line" {
            newElement = {
                "type": "line",
                "x1": drawingState.startPoint.x,
                "y1": drawingState.startPoint.y,
                "x2": pos.x,
                "y2": pos.y,
                "color": currentColor,
                "strokeWidth": currentStrokeWidth
            };
        }

        if newElement {
            elementsHook.addElement(newElement);
        }
    }

    def handleMouseLeave() -> None {
        drawingState.setIsDrawing(False);
        selectionHook.stopDragging();
        viewportHook.stopPanning();
    }

    cursorClass = "cursor-crosshair";
    if spacePressed or viewportHook.isPanning {
        cursorClass = "cursor-grab";
    } elif currentTool == "text" {
        cursorClass = "cursor-text";
    } elif currentTool == "select" {
        if selectionHook.isDragging {
            cursorClass = "cursor-grabbing";
        } else {
            cursorClass = "cursor-default";
        }
    }

    return (
        <div ref={containerRef} className="relative w-full h-full flex items-center justify-center overflow-hidden bg-white">
            <CanvasRenderer
                canvasRef={canvasRef}
                canvasSize={canvasHook.canvasSize}
                cursorClass={cursorClass}
                onClick={handleCanvasClick}
                onDoubleClick={handleCanvasDoubleClick}
                onMouseDown={handleMouseDown}
                onMouseMove={handleMouseMove}
                onMouseUp={handleMouseUp}
                onMouseLeave={handleMouseLeave}
            />

            <TextInput
                textInput={textInputHook.textInput}
                textInputRef={textInputRef}
                currentColor={currentColor}
                currentFontSize={currentFontSize}
                currentFontFamily={currentFontFamily}
                onTextChange={lambda e: any -> None {
                    textInputHook.updateTextContent(e.target.value);
                }}
                onKeyDown={handleTextKeyDown}
                onBlur={handleTextSubmit}
            />
        </div>
    );
}
