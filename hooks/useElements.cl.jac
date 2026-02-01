import from react { useState }

def:pub useElements() -> dict {
    [elements, setElements] = useState([]);

    def addElement(element: dict) -> None {
        setElements(elements.concat([element]));
    }

    def updateElement(index: int, newElement: dict) -> None {
        newElements = elements.slice();
        newElements[index] = newElement;
        setElements(newElements);
    }

    def removeElement(index: int) -> None {
        newElements = elements.filter(lambda _: any, i: any -> bool {
            return i != index;
        });
        setElements(newElements);
    }

    def clearElements() -> None {
        setElements([]);
    }

    return {
        "elements": elements,
        "setElements": setElements,
        "addElement": addElement,
        "updateElement": updateElement,
        "removeElement": removeElement,
        "clearElements": clearElements
    };
}
