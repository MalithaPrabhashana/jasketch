import from react { useState }
import from "..constants.canvas" { CANVAS_DEFAULTS }

def:pub useViewport() -> dict {
    canvasDefaults = CANVAS_DEFAULTS();
    [zoom, setZoom] = useState(1);
    [panOffset, setPanOffset] = useState({"x": 0, "y": 0});
    [isPanning, setIsPanning] = useState(False);

    def handleZoom(deltaY: float) -> None {
        zoomFactor = 1;
        if deltaY > 0 {
            zoomFactor = 0.9;
        } else {
            zoomFactor = 1.1;
        }

        newZoom = zoom * zoomFactor;
        if newZoom >= canvasDefaults.minZoom and newZoom <= canvasDefaults.maxZoom {
            setZoom(newZoom);
        }
    }

    def handlePan(deltaX: float, deltaY: float) -> None {
        setPanOffset({
            "x": panOffset.x + deltaX,
            "y": panOffset.y + deltaY
        });
    }

    def startPanning() -> None {
        setIsPanning(True);
    }

    def stopPanning() -> None {
        setIsPanning(False);
    }

    def resetViewport() -> None {
        setZoom(1);
        setPanOffset({"x": 0, "y": 0});
    }

    return {
        "zoom": zoom,
        "panOffset": panOffset,
        "isPanning": isPanning,
        "setZoom": setZoom,
        "setPanOffset": setPanOffset,
        "setIsPanning": setIsPanning,
        "handleZoom": handleZoom,
        "handlePan": handlePan,
        "startPanning": startPanning,
        "stopPanning": stopPanning,
        "resetViewport": resetViewport
    };
}
