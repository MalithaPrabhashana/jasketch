cl import from react { useState }

cl {
    def:pub Toolbar(props: dict) -> any {
        currentTool = props.currentTool or "freehand";
        currentColor = props.currentColor or "#000000";
        currentStrokeWidth = props.currentStrokeWidth or 2;
        currentFontSize = props.currentFontSize or 24;
        currentFontFamily = props.currentFontFamily or "Virgil";
        
        onToolChange = props.onToolChange;
        onColorChange = props.onColorChange;
        onStrokeWidthChange = props.onStrokeWidthChange;
        onFontSizeChange = props.onFontSizeChange;
        onFontFamilyChange = props.onFontFamilyChange;
        
        tools = [
            {"id": "select", "icon": "⌘", "label": "Select"},
            {"id": "freehand", "icon": "✏", "label": "Freehand"},
            {"id": "line", "icon": "╱", "label": "Line"},
            {"id": "rectangle", "icon": "▢", "label": "Rectangle"},
            {"id": "circle", "icon": "○", "label": "Circle"},
            {"id": "text", "icon": "T", "label": "Text"}
        ];
        
        fonts = [
            {"id": "Virgil", "label": "Handwritten"},
            {"id": "Comic Sans MS", "label": "Comic"},
            {"id": "Georgia", "label": "Serif"},
            {"id": "Arial", "label": "Sans-serif"},
            {"id": "Courier New", "label": "Monospace"}
        ];
        
        presetColors = [
            "#000000", "#ffffff", "#ef4444", "#f97316", "#eab308",
            "#22c55e", "#3b82f6", "#8b5cf6", "#ec4899", "#6b7280"
        ];

        def handleFontSize() -> any {
            fontElement = None;
            if (currentTool == "text") {
                fontElement = <div className="flex flex-col items-center gap-2 mt-2">
                    <div className="w-8 h-px my-2" style={{"backgroundColor": "var(--border-color)"}}></div>
                    <span className="text-xs font-medium" style={{"color": "var(--text-secondary)"}}>Font</span>
                    <div className="flex flex-col gap-1">
                        {[16, 24, 36, 48].map(lambda size: any -> any {
                            buttonClassName = "w-10 h-8 rounded-lg flex items-center justify-center text-xs transition-all ";
                            buttonStyle = {};
                            if (currentFontSize == size) {
                                buttonStyle = {"backgroundColor": "var(--primary-color)", "color": "white"};
                            } else {
                                buttonStyle = {"backgroundColor": "var(--surface-color)", "color": "var(--text-secondary)", "border": "1px solid var(--border-color)"};
                            }
                            return <button
                                key={size}
                                onClick={lambda -> None { onFontSizeChange(size); }}
                                className={buttonClassName}
                                style={buttonStyle}
                            >
                                {size}
                            </button>;
                        })}
                    </div>
                </div>;
            }
            return fontElement;
        }

        return <div className="toolbar w-20 flex flex-col items-center py-6 gap-3">;
            # Tools Section
            <div className="flex flex-col gap-1">
                {tools.map(lambda tool: any -> any {
                    isActive = currentTool == tool.id;
                    buttonClassName = "w-12 h-12 rounded-lg flex items-center justify-center text-lg transition-all duration-200 ";
                    buttonStyle = {};
                    if (isActive) {
                        buttonClassName += "text-white shadow-md";
                        buttonStyle = {"backgroundColor": "var(--primary-color)", "boxShadow": "0 2px 8px rgba(255, 138, 92, 0.3)"};
                    } else {
                        buttonClassName += "hover:shadow-sm";
                        buttonStyle = {"backgroundColor": "var(--background-color)", "color": "var(--text-secondary)", "border": "1px solid var(--border-color)"};
                    }
                    return <button
                        key={tool.id}
                        onClick={lambda -> None { onToolChange(tool.id); }}
                        title={tool.label}
                        className={buttonClassName}
                        style={buttonStyle}
                    >
                        {tool.icon}
                    </button>;
                })}
            </div>
            
            # Divider
            <div className="w-8 h-px my-2" style={{"backgroundColor": "var(--border-color)"}}></div>
            
            # Color Picker
            <div className="flex flex-col items-center gap-2">
                <span className="text-xs font-medium" style={{"color": "var(--text-secondary)"}}>Color</span>
                <input 
                    type="color" 
                    value={currentColor}
                    onChange={lambda e: any -> None { onColorChange(e.target.value); }}
                    className="w-10 h-10 rounded-lg cursor-pointer border-2 transition-colors bg-transparent"
                    style={{"borderColor": "var(--border-color)"}}
                />
                # Preset Colors
                <div className="grid grid-cols-2 gap-1">
                    {presetColors.map(lambda color: any -> any {
                        buttonClassName = "w-5 h-5 rounded border-2 transition-all ";
                        buttonStyle = {};
                        if (currentColor == color) {
                            buttonClassName += "scale-110";
                            buttonStyle = {"backgroundColor": color, "borderColor": "var(--primary-color)", "boxShadow": "0 0 0 2px var(--primary-color-light)"};
                        } else {
                            buttonStyle = {"backgroundColor": color, "borderColor": "var(--border-color)"};
                        }
                        return <button
                            key={color}
                            onClick={lambda -> None { onColorChange(color); }}
                            className={buttonClassName}
                            style={buttonStyle}
                        />;
                    })}
                </div>
            </div>
            
            # Divider
            <div className="w-8 h-px my-2" style={{"backgroundColor": "var(--border-color)"}}></div>
            
            # Stroke Width
            <div className="flex flex-col items-center gap-2">
                <span className="text-xs font-medium" style={{"color": "var(--text-secondary)"}}>Stroke</span>
                <div className="flex flex-col gap-1">
                    {[2, 4, 8].map(lambda size: any -> any {
                        buttonClassName = "w-10 h-8 rounded-lg flex items-center justify-center transition-all ";
                        buttonStyle = {};
                        if (currentStrokeWidth == size) {
                            buttonStyle = {"backgroundColor": "var(--primary-color)", "color": "white"};
                        } else {
                            buttonStyle = {"backgroundColor": "var(--surface-color)", "color": "var(--text-secondary)", "border": "1px solid var(--border-color)"};
                        }
                        return <button
                            key={size}
                            onClick={lambda -> None { onStrokeWidthChange(size); }}
                            className={buttonClassName}
                            style={buttonStyle}
                        >
                            <div 
                                className="rounded-full"
                                style={{"width": (size * 2) + "px", "height": (size * 2) + "px", "backgroundColor": "currentColor"}}
                            />
                        </button>;
                    })}
                </div>
            </div>
            
            # Font Options (shown when text tool is selected)
            {handleFontSize()}
        </div>;
    }
}
