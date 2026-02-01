"""Main entry point for JaSketch - Modern Whiteboard Application."""

cl {
    # Client-side imports
    import from react { useState }
    import from .components.layout.Header { Header }
    import from .components.Toolbar { Toolbar }
    import from .components.Canvas { Canvas }
    import ".styles.css";

    def:pub app() -> any {
        # Drawing tool state
        [currentTool, setCurrentTool] = useState("freehand");
        [currentColor, setCurrentColor] = useState("#000000");
        [currentStrokeWidth, setCurrentStrokeWidth] = useState(2);
        [currentFontSize, setCurrentFontSize] = useState(24);
        [currentFontFamily, setCurrentFontFamily] = useState("Virgil");

        return <div className="h-screen flex flex-col overflow-hidden bg-gradient-to-br from-gray-50 via-white to-gray-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
            # Modern Header
            <Header />

            # Main Content with Floating Toolbar
            <div className="flex flex-1 overflow-hidden relative">
                # Floating Left Toolbar
                <div className="absolute left-4 top-1/2 -translate-y-1/2 z-10">
                    <Toolbar
                        currentTool={currentTool}
                        currentColor={currentColor}
                        currentStrokeWidth={currentStrokeWidth}
                        currentFontSize={currentFontSize}
                        currentFontFamily={currentFontFamily}
                        onToolChange={lambda tool: any -> None { setCurrentTool(tool); }}
                        onColorChange={lambda color: any -> None { setCurrentColor(color); }}
                        onStrokeWidthChange={lambda width: any -> None { setCurrentStrokeWidth(width); }}
                        onFontSizeChange={lambda size: any -> None { setCurrentFontSize(size); }}
                        onFontFamilyChange={lambda font: any -> None { setCurrentFontFamily(font); }}
                    />
                </div>

                # Canvas Container - Full Screen
                <div className="flex-1 flex items-center justify-center p-4">
                    <Canvas
                        currentTool={currentTool}
                        currentColor={currentColor}
                        currentStrokeWidth={currentStrokeWidth}
                        currentFontSize={currentFontSize}
                        currentFontFamily={currentFontFamily}
                    />
                </div>
            </div>
        </div>;
    }
}
