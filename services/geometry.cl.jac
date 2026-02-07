def:pub getMousePosition(e: dict, canvas: any, panOffset: dict, zoom: float) -> dict {
    rect = canvas.getBoundingClientRect();
    screenX = e.clientX - rect.left;
    screenY = e.clientY - rect.top;
    return {
        "x": (screenX - panOffset.x) / zoom,
        "y": (screenY - panOffset.y) / zoom
    };
}

def:pub calculateDistance(point1: dict, point2: dict) -> float {
    return Math.sqrt(
        Math.pow(point2.x - point1.x, 2) +
        Math.pow(point2.y - point1.y, 2)
    );
}

def:pub calculateCircleRadius(width: float, height: float) -> float {
    return Math.sqrt(Math.pow(width, 2) + Math.pow(height, 2)) / 2;
}

def:pub getTextDimensions(text: str, fontSize: float) -> dict {
    textWidth = fontSize * text.length * 0.6;
    textHeight = fontSize * 1.2;
    return {
        "width": textWidth,
        "height": textHeight
    };
}

