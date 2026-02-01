def:pub getMousePosition(e: dict, canvas: any, panOffset: dict, zoom: float) -> dict {
    rect = canvas.getBoundingClientRect();
    return {
        "x": (e.clientX - rect.left - panOffset.x) / zoom,
        "y": (e.clientY - rect.top - panOffset.y) / zoom
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

def:pub distanceFromPointToLine(point: dict, line: dict) -> float {
    A = point.y - line.y1;
    B = line.x1 - point.x;
    C = line.y2 * line.x1 - line.x2 * line.y1;
    distance = Math.abs(A * line.x2 + B * line.y2 + C) / Math.sqrt(Math.pow(A, 2) + Math.pow(B, 2));
    return distance;
}
