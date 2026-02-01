def:pub CANVAS_DEFAULTS() -> dict {
    return {
        "width": 2000,
        "height": 1500,
        "backgroundColor": "#ffffff",
        "minZoom": 0.1,
        "maxZoom": 5.0,
        "zoomFactor": 0.1
    };
}

def:pub STROKE_WIDTHS() -> list {
    return [2, 4, 8];
}

def:pub DEFAULT_TOOL_SETTINGS() -> dict {
    return {
        "currentTool": "freehand",
        "currentColor": "#000000",
        "currentStrokeWidth": 2,
        "currentFontSize": 24,
        "currentFontFamily": "Virgil"
    };
}
