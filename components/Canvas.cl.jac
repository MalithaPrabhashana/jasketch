import from react { useRef, useEffect }
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

    can with [elementsHook.elements, canvasHook.canvasSize] entry {
        canvas = canvasRef.current;
        if canvas {
            canvas.width = canvasHook.canvasSize.width;
            canvas.height = canvasHook.canvasSize.height;
            canvasHook.redrawCanvas(elementsHook.elements);
        }
    }

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

        if currentTool == "select" {
            elementInfo = selectionHook.findElementAtPoint(pos, elementsHook.elements);
            if elementInfo {
                selectionHook.startDragging(elementInfo, pos);
            } else {
                selectionHook.clearSelection();
                viewportHook.startPanning();
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

        if selectionHook.isDragging and selectionHook.selectedElement and currentTool == "select" {
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

        if viewportHook.isPanning and currentTool == "select" {
            viewportHook.handlePan(e.movementX, e.movementY);
            return;
        }

        if not drawingState.isDrawing {
            return;
        }

        if currentTool == "freehand" {
            newPath = drawingState.currentPath.concat([pos]);
            drawingState.setCurrentPath(newPath);

            canvas = canvasRef.current;
            ctx = canvas.getContext("2d");
            canvasHook.redrawCanvas(elementsHook.elements);

            ctx.strokeStyle = currentColor;
            ctx.lineWidth = currentStrokeWidth;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.beginPath();

            if drawingState.currentPath.length > 0 {
                lastPoint = drawingState.currentPath[drawingState.currentPath.length - 1];
                ctx.moveTo(lastPoint.x, lastPoint.y);
                ctx.lineTo(pos.x, pos.y);
                ctx.stroke();
            }
        } else {
            canvas = canvasRef.current;
            ctx = canvas.getContext("2d");
            canvasHook.redrawCanvas(elementsHook.elements);
            drawPreview(ctx, currentTool, drawingState.startPoint, pos, currentColor, currentStrokeWidth);
        }
    }

    def handleMouseUp(e: dict) -> None {
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

    def handleWheel(e: dict) -> None {
        e.preventDefault();
        viewportHook.handleZoom(e.deltaY);
    }

    cursorClass = "cursor-crosshair";
    if currentTool == "text" {
        cursorClass = "cursor-text";
    } elif currentTool == "select" {
        cursorClass = "cursor-default";
    }

    return (
        <div ref={containerRef} className="relative w-full h-full flex items-center justify-center overflow-hidden bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800">
            <CanvasRenderer
                canvasRef={canvasRef}
                canvasSize={canvasHook.canvasSize}
                cursorClass={cursorClass}
                zoom={viewportHook.zoom}
                panOffset={viewportHook.panOffset}
                onClick={handleCanvasClick}
                onMouseDown={handleMouseDown}
                onMouseMove={handleMouseMove}
                onMouseUp={handleMouseUp}
                onMouseLeave={handleMouseLeave}
                onWheel={handleWheel}
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
