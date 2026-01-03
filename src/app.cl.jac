"""Main entry point for the Jac client application."""

# Client-side imports
import from react { useState }
import from ".components/toolbar" { Toolbar }
import from ".components/canvas" { Canvas }
import ".styles.css";

def:pub app() -> any {
    [currentTool, setCurrentTool] = useState("freehand");
    [currentColor, setCurrentColor] = useState("#000000");
    [currentStrokeWidth, setCurrentStrokeWidth] = useState(2);
    [currentFontSize, setCurrentFontSize] = useState(24);
    [currentFontFamily, setCurrentFontFamily] = useState("Virgil");

    return <div className="h-screen flex flex-col overflow-hidden" style={{"backgroundColor": "var(--surface-secondary)"}}>
        # Header
        <header className="header backdrop-blur-sm flex-shrink-0">
            <div className="px-4 py-2 flex items-center justify-between">
                <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{"backgroundColor": "var(--primary-color)", "boxShadow": "0 2px 8px rgba(255, 138, 92, 0.2)"}}>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z" fill="white"/>
                        </svg>
                    </div>
                    <div>
                        <h1 className="text-lg font-bold" style={{"color": "var(--text-color)"}}>
                            JaSketch
                        </h1>
                        <p className="text-xs" style={{"color": "var(--text-secondary)"}}>Professional Whiteboard</p>
                    </div>
                </div>
                <div className="hidden md:flex items-center gap-4">
                    <span className="text-xs" style={{"color": "var(--text-secondary)"}}>Ready to create</span>
                </div>
            </div>
        </header>
        
        # Main Content
        <div className="flex flex-1 overflow-hidden">
            # Left Toolbar
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
            
            # Canvas Container
            <div className="flex-1 p-6 overflow-auto">
                <div className="canvas-container backdrop-blur-sm rounded-2xl p-3 shadow-xl h-full">
                    <Canvas 
                        currentTool={currentTool}
                        currentColor={currentColor}
                        currentStrokeWidth={currentStrokeWidth}
                        currentFontSize={currentFontSize}
                        currentFontFamily={currentFontFamily}
                    />
                </div>
            </div>
        </div>
    </div>;
}