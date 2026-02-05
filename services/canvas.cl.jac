import from .geometry { calculateCircleRadius }

def:pub drawElement(ctx: any, element: dict) -> None {
    if element.type == "text" {
        drawTextElement(ctx, element);
    } else {
        drawShapeElement(ctx, element);
    }
}

def:pub drawTextElement(ctx: any, element: dict) -> None {
    ctx.font = element.fontSize + "px " + element.fontFamily;
    ctx.fillStyle = element.color;
    ctx.textBaseline = "top";

    lines = element.text.split("\n");
    lines.forEach(lambda line: any, index: any -> None {
        ctx.fillText(line, element.x, element.y + (index * element.fontSize * 1.2));
    });
}

def:pub drawShapeElement(ctx: any, element: dict) -> None {
    ctx.strokeStyle = element.color;
    ctx.lineWidth = element.strokeWidth;
    ctx.fillStyle = element.fillColor or "transparent";
    ctx.lineCap = "round";
    ctx.lineJoin = "round";

    if element.type == "freehand" {
        drawFreehand(ctx, element);
    } elif element.type == "rectangle" {
        drawRectangle(ctx, element);
    } elif element.type == "circle" {
        drawCircle(ctx, element);
    } elif element.type == "line" {
        drawLine(ctx, element);
    }
}

def:pub drawFreehand(ctx: any, element: dict) -> None {
    ctx.beginPath();
    points = element.points;
    if points.length > 0 {
        ctx.moveTo(points[0].x, points[0].y);
        for i=1 to i < points.length by i+=1 {
            ctx.lineTo(points[i].x, points[i].y);
        }
    }
    ctx.stroke();
}

def:pub drawRectangle(ctx: any, element: dict) -> None {
    ctx.beginPath();
    ctx.rect(element.x, element.y, element.width, element.height);
    ctx.stroke();
    if element.fillColor and element.fillColor != "transparent" {
        ctx.fill();
    }
}

def:pub drawCircle(ctx: any, element: dict) -> None {
    ctx.beginPath();
    radius = calculateCircleRadius(element.width, element.height);
    ctx.arc(element.x + element.width/2, element.y + element.height/2, radius, 0, 2 * Math.PI);
    ctx.stroke();
    if element.fillColor and element.fillColor != "transparent" {
        ctx.fill();
    }
}

def:pub drawLine(ctx: any, element: dict) -> None {
    ctx.beginPath();
    ctx.moveTo(element.x1, element.y1);
    ctx.lineTo(element.x2, element.y2);
    ctx.stroke();
}

def:pub drawPreview(ctx: any, tool: str, startPoint: dict, currentPoint: dict, color: str, strokeWidth: float) -> None {
    ctx.strokeStyle = color;
    ctx.lineWidth = strokeWidth;
    ctx.setLineDash([5, 5]);

    if tool == "rectangle" {
        w = currentPoint.x - startPoint.x;
        h = currentPoint.y - startPoint.y;
        ctx.strokeRect(startPoint.x, startPoint.y, w, h);
    } elif tool == "circle" {
        w = currentPoint.x - startPoint.x;
        h = currentPoint.y - startPoint.y;
        radius = calculateCircleRadius(w, h);
        ctx.beginPath();
        ctx.arc(startPoint.x + w/2, startPoint.y + h/2, radius, 0, 2 * Math.PI);
        ctx.stroke();
    } elif tool == "line" {
        ctx.beginPath();
        ctx.moveTo(startPoint.x, startPoint.y);
        ctx.lineTo(currentPoint.x, currentPoint.y);
        ctx.stroke();
    }

    ctx.setLineDash([]);
}

def:pub clearCanvas(ctx: any, width: float, height: float) -> None {
    ctx.clearRect(0, 0, width, height);
}

def:pub drawInfiniteGrid(ctx: any, width: float, height: float, zoom: float, panOffset: dict) -> None {
    ctx.save();

    gridSize = 40;

    if zoom < 0.25 {
        ctx.restore();
        return;
    }

    ctx.strokeStyle = "rgba(200, 200, 200, 0.3)";
    ctx.lineWidth = 1;

    startX = Math.floor((-panOffset.x) / (gridSize * zoom)) * gridSize;
    startY = Math.floor((-panOffset.y) / (gridSize * zoom)) * gridSize;
    endX = Math.ceil((width - panOffset.x) / (gridSize * zoom)) * gridSize;
    endY = Math.ceil((height - panOffset.y) / (gridSize * zoom)) * gridSize;

    ctx.beginPath();
    x = startX;
    while x <= endX {
        screenX = x * zoom + panOffset.x;
        if screenX >= 0 and screenX <= width {
            ctx.moveTo(screenX, 0);
            ctx.lineTo(screenX, height);
        }
        x = x + gridSize;
    }

    y = startY;
    while y <= endY {
        screenY = y * zoom + panOffset.y;
        if screenY >= 0 and screenY <= height {
            ctx.moveTo(0, screenY);
            ctx.lineTo(width, screenY);
        }
        y = y + gridSize;
    }
    ctx.stroke();

    ctx.strokeStyle = "rgba(150, 150, 150, 0.5)";
    ctx.lineWidth = 2;
    ctx.beginPath();

    originScreenX = 0 * zoom + panOffset.x;
    originScreenY = 0 * zoom + panOffset.y;

    if originScreenX >= 0 and originScreenX <= width {
        ctx.moveTo(originScreenX, 0);
        ctx.lineTo(originScreenX, height);
    }

    if originScreenY >= 0 and originScreenY <= height {
        ctx.moveTo(0, originScreenY);
        ctx.lineTo(width, originScreenY);
    }

    ctx.stroke();

    ctx.restore();
}

def:pub applyViewportTransform(ctx: any, zoom: float, panOffset: dict) -> None {
    ctx.translate(panOffset.x, panOffset.y);
    ctx.scale(zoom, zoom);
}

def:pub drawBoxSelectionRect(ctx: any, boxStart: dict, boxEnd: dict) -> None {
    ctx.save();
    ctx.strokeStyle = "#6366f1";
    ctx.fillStyle = "rgba(99, 102, 241, 0.1)";
    ctx.lineWidth = 2;
    ctx.setLineDash([5, 5]);

    x = Math.min(boxStart.x, boxEnd.x);
    y = Math.min(boxStart.y, boxEnd.y);
    width = Math.abs(boxEnd.x - boxStart.x);
    height = Math.abs(boxEnd.y - boxStart.y);

    ctx.fillRect(x, y, width, height);
    ctx.strokeRect(x, y, width, height);

    ctx.setLineDash([]);
    ctx.restore();
}

def:pub drawSelectionBox(ctx: any, element: dict) -> None {
    ctx.save();
    ctx.strokeStyle = "#6366f1";
    ctx.lineWidth = 2;
    ctx.setLineDash([5, 5]);

    padding = 5;

    if element.type == "text" {
        ctx.font = element.fontSize + "px " + element.fontFamily;
        metrics = ctx.measureText(element.text);
        lines = element.text.split("\n");
        textHeight = lines.length * element.fontSize * 1.2;
        ctx.strokeRect(
            element.x - padding,
            element.y - padding,
            metrics.width + padding * 2,
            textHeight + padding * 2
        );
    } elif element.type == "rectangle" {
        ctx.strokeRect(
            element.x - padding,
            element.y - padding,
            element.width + padding * 2,
            element.height + padding * 2
        );
    } elif element.type == "circle" {
        ctx.strokeRect(
            element.x - padding,
            element.y - padding,
            element.width + padding * 2,
            element.height + padding * 2
        );
    } elif element.type == "line" {
        minX = Math.min(element.x1, element.x2);
        minY = Math.min(element.y1, element.y2);
        maxX = Math.max(element.x1, element.x2);
        maxY = Math.max(element.y1, element.y2);
        ctx.strokeRect(
            minX - padding,
            minY - padding,
            (maxX - minX) + padding * 2,
            (maxY - minY) + padding * 2
        );
    } elif element.type == "freehand" {
        if element.points.length > 0 {
            minX = element.points[0].x;
            minY = element.points[0].y;
            maxX = element.points[0].x;
            maxY = element.points[0].y;

            element.points.forEach(lambda point: dict -> None {
                if point.x < minX {
                    minX = point.x;
                }
                if point.y < minY {
                    minY = point.y;
                }
                if point.x > maxX {
                    maxX = point.x;
                }
                if point.y > maxY {
                    maxY = point.y;
                }
            });

            ctx.strokeRect(
                minX - padding,
                minY - padding,
                (maxX - minX) + padding * 2,
                (maxY - minY) + padding * 2
            );
        }
    }

    ctx.setLineDash([]);
    ctx.restore();
}
