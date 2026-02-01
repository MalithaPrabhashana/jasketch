import from "..constants.tools" { TOOLS }
import from "..constants.colors" { PRESET_COLORS }
import from "..constants.fonts" { FONTS, FONT_SIZES }
import from "..constants.canvas" { STROKE_WIDTHS }

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

    tools = TOOLS();
    presetColors = PRESET_COLORS();
    strokeWidths = STROKE_WIDTHS();
    fontSizes = FONT_SIZES();

    return <div className="toolbar flex flex-col items-center py-4 px-2 gap-3 bg-white/80 dark:bg-gray-800/80 backdrop-blur-xl rounded-2xl shadow-2xl border border-gray-200/50 dark:border-gray-700/50">
        # Tools Section
        <div className="flex flex-col gap-1.5">
            <span className="text-[10px] font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400 text-center mb-1">Tools</span>
            {tools.map(lambda tool: any -> any {
                isActive = currentTool == tool.id;
                return <button
                    key={tool.id}
                    onClick={lambda -> None { onToolChange(tool.id); }}
                    title={tool.label}
                    className={"w-11 h-11 rounded-xl flex items-center justify-center text-lg font-medium transition-all duration-200 " + (isActive and "bg-gradient-to-br from-violet-500 to-purple-600 text-white shadow-lg shadow-violet-500/30 scale-105" or "bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600 hover:scale-105")}
                >
                    {tool.icon}
                </button>;
            })}
        </div>

        # Divider
        <div className="w-full h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-600 to-transparent"></div>

        # Color Picker Section
        <div className="flex flex-col items-center gap-2">
            <span className="text-[10px] font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400">Color</span>
            <div className="relative group">
                <input
                    type="color"
                    value={currentColor}
                    onChange={lambda e: any -> None { onColorChange(e.target.value); }}
                    className="w-11 h-11 rounded-xl cursor-pointer border-2 border-gray-300 dark:border-gray-600 transition-all hover:scale-105 hover:border-violet-500"
                    style={{"backgroundColor": currentColor}}
                />
                <div className="absolute inset-0 rounded-xl bg-gradient-to-br from-white/20 to-transparent pointer-events-none"></div>
            </div>

            # Preset Colors
            <div className="grid grid-cols-2 gap-1.5">
                {presetColors.map(lambda color: any -> any {
                    isSelected = currentColor == color;
                    return <button
                        key={color}
                        onClick={lambda -> None { onColorChange(color); }}
                        className={"w-6 h-6 rounded-lg border-2 transition-all duration-200 " + (isSelected and "scale-110 border-violet-500 shadow-md ring-2 ring-violet-500/30" or "border-gray-300 dark:border-gray-600 hover:scale-110")}
                        style={{"backgroundColor": color}}
                    />;
                })}
            </div>
        </div>

        # Divider
        <div className="w-full h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-600 to-transparent"></div>

        # Stroke Width Section
        <div className="flex flex-col items-center gap-2">
            <span className="text-[10px] font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400">Stroke</span>
            <div className="flex flex-col gap-1.5">
                {strokeWidths.map(lambda size: any -> any {
                    isActive = currentStrokeWidth == size;
                    circleSize = String(size * 2) + "px";
                    return <button
                        key={size}
                        onClick={lambda -> None { onStrokeWidthChange(size); }}
                        className={"w-11 h-9 rounded-lg flex items-center justify-center transition-all duration-200 " + (isActive and "bg-gradient-to-br from-violet-500 to-purple-600 text-white shadow-md" or "bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600")}
                    >
                        <div
                            className={"rounded-full " + (isActive and "bg-white" or "bg-gray-600 dark:bg-gray-300")}
                            style={{"width": circleSize, "height": circleSize}}
                        />
                    </button>;
                })}
            </div>
        </div>

        # Font Options (shown when text tool is selected)
        {currentTool == "text" and <div>
            <div className="w-full h-px bg-gradient-to-r from-transparent via-gray-300 dark:via-gray-600 to-transparent my-2"></div>
            <div className="flex flex-col items-center gap-2">
                <span className="text-[10px] font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-400">Font Size</span>
                <div className="flex flex-col gap-1.5">
                    {fontSizes.map(lambda size: any -> any {
                        isActive = currentFontSize == size;
                        return <button
                            key={size}
                            onClick={lambda -> None { onFontSizeChange(size); }}
                            className={"w-11 h-9 rounded-lg flex items-center justify-center text-xs font-semibold transition-all duration-200 " + (isActive and "bg-gradient-to-br from-violet-500 to-purple-600 text-white shadow-md" or "bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600")}
                        >
                            {size}
                        </button>;
                    })}
                </div>
            </div>
        </div> or None}
    </div>;
}
