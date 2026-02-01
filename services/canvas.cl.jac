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
