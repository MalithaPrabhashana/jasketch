import from react { useRef, useEffect, useState }
import from "..services.canvas" { drawElement, clearCanvas }
import from "..constants.canvas" { CANVAS_DEFAULTS }

def:pub useCanvas() -> dict {
    canvasRef = useRef(None);
    containerRef = useRef(None);
    canvasDefaults = CANVAS_DEFAULTS();
    [canvasSize, setCanvasSize] = useState({
        "width": canvasDefaults.width,
        "height": canvasDefaults.height
    });

    def redrawCanvas(elements: list) -> None {
        canvas = canvasRef.current;
        if not canvas {
            return;
        }

        ctx = canvas.getContext("2d");
        clearCanvas(ctx, canvas.width, canvas.height);

        elements.forEach(lambda element: any -> None {
            drawElement(ctx, element);
        });
    }

    def getContext() -> any {
        canvas = canvasRef.current;
        if canvas {
            return canvas.getContext("2d");
        }
        return None;
    }

    def initializeCanvas() -> None {
        if containerRef.current {
            setCanvasSize({
                "width": canvasDefaults.width,
                "height": canvasDefaults.height
            });
        }
    }

    useEffect(lambda -> None {
        def handleResize() -> None {
            initializeCanvas();
        }

        handleResize();
        window.addEventListener("resize", handleResize);
        return lambda -> None {
            window.removeEventListener("resize", handleResize);
        };
    }, []);

    return {
        "canvasRef": canvasRef,
        "containerRef": containerRef,
        "canvasSize": canvasSize,
        "setCanvasSize": setCanvasSize,
        "redrawCanvas": redrawCanvas,
        "getContext": getContext,
        "initializeCanvas": initializeCanvas
    };
}
