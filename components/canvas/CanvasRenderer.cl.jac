def:pub CanvasRenderer(props: dict) -> any {
    canvasRef = props.canvasRef;
    canvasSize = props.canvasSize;
    cursorClass = props.cursorClass or "cursor-crosshair";
    zoom = props.zoom or 1;
    panOffset = props.panOffset or {"x": 0, "y": 0};

    onClick = props.onClick;
    onMouseDown = props.onMouseDown;
    onMouseMove = props.onMouseMove;
    onMouseUp = props.onMouseUp;
    onMouseLeave = props.onMouseLeave;
    onWheel = props.onWheel;

    can with canvasSize entry {
        canvas = canvasRef.current;
        if canvas {
            canvas.width = canvasSize.width;
            canvas.height = canvasSize.height;
        }
    }

    return <div style={{
        "transform": "scale(" + zoom + ") translate(" + panOffset.x + "px, " + panOffset.y + "px)",
        "transformOrigin": "0 0"
    }}>
        <canvas
            ref={canvasRef}
            className={"rounded-xl shadow-2xl " + cursorClass}
            style={{
                "backgroundColor": "#ffffff",
                "minWidth": canvasSize.width + "px",
                "minHeight": canvasSize.height + "px"
            }}
            onClick={onClick}
            onMouseDown={onMouseDown}
            onMouseMove={onMouseMove}
            onMouseUp={onMouseUp}
            onMouseLeave={onMouseLeave}
            onWheel={onWheel}
        />
    </div>;
}
