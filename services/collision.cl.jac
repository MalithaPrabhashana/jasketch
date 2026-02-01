import from .geometry { calculateDistance, calculateCircleRadius, getTextDimensions, distanceFromPointToLine }

def:pub isPointInRectangle(point: dict, rect: dict) -> bool {
    return (
        point.x >= rect.x and
        point.x <= rect.x + rect.width and
        point.y >= rect.y and
        point.y <= rect.y + rect.height
    );
}

def:pub isPointInCircle(point: dict, circle: dict) -> bool {
    centerX = circle.x + circle.width / 2;
    centerY = circle.y + circle.height / 2;
    radius = calculateCircleRadius(circle.width, circle.height);
    distance = calculateDistance(point, {"x": centerX, "y": centerY});
    return distance <= radius;
}

def:pub isPointNearLine(point: dict, line: dict, tolerance: float = 5.0) -> bool {
    distance = distanceFromPointToLine(point, line);
    return distance <= tolerance;
}

def:pub isPointInText(point: dict, textElement: dict) -> bool {
    dimensions = getTextDimensions(textElement.text, textElement.fontSize);
    return (
        point.x >= textElement.x and
        point.x <= textElement.x + dimensions.width and
        point.y >= textElement.y and
        point.y <= textElement.y + dimensions.height
    );
}

def:pub isPointInFreehandPath(point: dict, path: list, tolerance: float = 10.0) -> bool {
    for pathPoint in path {
        distance = calculateDistance(point, pathPoint);
        if distance <= tolerance {
            return True;
        }
    }
    return False;
}

def:pub isPointInElement(point: dict, element: dict) -> bool {
    if element.type == "text" {
        return isPointInText(point, element);
    } elif element.type == "rectangle" {
        return isPointInRectangle(point, element);
    } elif element.type == "circle" {
        return isPointInCircle(point, element);
    } elif element.type == "line" {
        return isPointNearLine(point, element);
    } elif element.type == "freehand" {
        return isPointInFreehandPath(point, element.points);
    }
    return False;
}
