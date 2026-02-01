import from react { useState }
import from "..services.collision" { isPointInElement }

def:pub useSelection() -> dict {
    [selectedElement, setSelectedElement] = useState(None);
    [isDragging, setIsDragging] = useState(False);
    [dragOffset, setDragOffset] = useState({"x": 0, "y": 0});

    def findElementAtPoint(point: dict, elements: list) -> dict {
        for i in range(elements.length - 1, -1, -1) {
            if isPointInElement(point, elements[i]) {
                return {"element": elements[i], "index": i};
            }
        }
        return None;
    }

    def startDragging(elementInfo: dict, mousePos: dict) -> None {
        setSelectedElement(elementInfo);
        setIsDragging(True);

        element = elementInfo.element;
        offsetX = mousePos.x - (element.x or element.x1 or element.points[0].x);
        offsetY = mousePos.y - (element.y or element.y1 or element.points[0].y);

        setDragOffset({"x": offsetX, "y": offsetY});
    }

    def stopDragging() -> None {
        setIsDragging(False);
    }

    def clearSelection() -> None {
        setSelectedElement(None);
        setIsDragging(False);
    }

    return {
        "selectedElement": selectedElement,
        "isDragging": isDragging,
        "dragOffset": dragOffset,
        "setSelectedElement": setSelectedElement,
        "setIsDragging": setIsDragging,
        "findElementAtPoint": findElementAtPoint,
        "startDragging": startDragging,
        "stopDragging": stopDragging,
        "clearSelection": clearSelection
    };
}
