import from react { useState }
import from "..services.collision" { isPointInElement }

def:pub useSelection() -> dict {
    [selectedElement, setSelectedElement] = useState(None);
    [selectedElements, setSelectedElements] = useState([]);
    [isDragging, setIsDragging] = useState(False);
    [dragOffset, setDragOffset] = useState({"x": 0, "y": 0});
    [isBoxSelecting, setIsBoxSelecting] = useState(False);
    [boxStart, setBoxStart] = useState(None);
    [boxEnd, setBoxEnd] = useState(None);

    def findElementAtPoint(point: dict, elements: list) -> dict {
        i = elements.length - 1;
        while i >= 0 {
            if isPointInElement(point, elements[i]) {
                return {"element": elements[i], "index": i};
            }
            i = i - 1;
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
        setSelectedElements([]);
        setIsDragging(False);
    }

    def startBoxSelection(point: dict) -> None {
        setIsBoxSelecting(True);
        setBoxStart(point);
        setBoxEnd(point);
    }

    def updateBoxSelection(point: dict) -> None {
        setBoxEnd(point);
    }

    def finishBoxSelection(elements: list) -> None {
        if boxStart and boxEnd {
            minX = Math.min(boxStart.x, boxEnd.x);
            minY = Math.min(boxStart.y, boxEnd.y);
            maxX = Math.max(boxStart.x, boxEnd.x);
            maxY = Math.max(boxStart.y, boxEnd.y);

            selected = [];
            i = 0;
            while i < elements.length {
                element = elements[i];
                if isElementInBox(element, minX, minY, maxX, maxY) {
                    selected.push({"element": element, "index": i});
                }
                i = i + 1;
            }

            setSelectedElements(selected);
            if selected.length == 1 {
                setSelectedElement(selected[0]);
            } elif selected.length == 0 {
                setSelectedElement(None);
            } else {
                setSelectedElement(None);
            }
        }

        setIsBoxSelecting(False);
        setBoxStart(None);
        setBoxEnd(None);
    }

    def isElementInBox(element: dict, minX: float, minY: float, maxX: float, maxY: float) -> bool {
        if element.type == "text" or element.type == "rectangle" or element.type == "circle" {
            elemX = element.x;
            elemY = element.y;
            return elemX >= minX and elemX <= maxX and elemY >= minY and elemY <= maxY;
        } elif element.type == "line" {
            x1InBox = element.x1 >= minX and element.x1 <= maxX and element.y1 >= minY and element.y1 <= maxY;
            x2InBox = element.x2 >= minX and element.x2 <= maxX and element.y2 >= minY and element.y2 <= maxY;
            return x1InBox or x2InBox;
        } elif element.type == "freehand" {
            i = 0;
            while i < element.points.length {
                point = element.points[i];
                if point.x >= minX and point.x <= maxX and point.y >= minY and point.y <= maxY {
                    return True;
                }
                i = i + 1;
            }
            return False;
        }
        return False;
    }

    return {
        "selectedElement": selectedElement,
        "selectedElements": selectedElements,
        "isDragging": isDragging,
        "dragOffset": dragOffset,
        "isBoxSelecting": isBoxSelecting,
        "boxStart": boxStart,
        "boxEnd": boxEnd,
        "setSelectedElement": setSelectedElement,
        "setSelectedElements": setSelectedElements,
        "setIsDragging": setIsDragging,
        "findElementAtPoint": findElementAtPoint,
        "startDragging": startDragging,
        "stopDragging": stopDragging,
        "clearSelection": clearSelection,
        "startBoxSelection": startBoxSelection,
        "updateBoxSelection": updateBoxSelection,
        "finishBoxSelection": finishBoxSelection
    };
}
