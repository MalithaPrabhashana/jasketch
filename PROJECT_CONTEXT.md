# JaSketch Project Context

I'm working on **JaSketch**, a modern online whiteboard drawing application similar to Excalidraw, built using **Jaclang** and **jac-client**.

## Project Structure
```
jasketch/
├── main.jac                    # Entry point with app() function
├── constants/                  # Configuration (tools, colors, fonts, canvas)
│   ├── tools.cl.jac
│   ├── colors.cl.jac
│   ├── fonts.cl.jac
│   └── canvas.cl.jac
├── hooks/                      # Custom React-style hooks
│   ├── useCanvas.cl.jac
│   ├── useDrawingState.cl.jac
│   ├── useElements.cl.jac
│   ├── useSelection.cl.jac
│   ├── useViewport.cl.jac
│   └── useTextInput.cl.jac
├── services/                   # Business logic
│   ├── geometry.cl.jac
│   ├── collision.cl.jac
│   └── canvas.cl.jac
├── components/
│   ├── Canvas.cl.jac          # Main canvas component
│   ├── Toolbar.cl.jac         # Floating toolbar
│   ├── layout/
│   │   └── Header.cl.jac
│   ├── canvas/
│   │   ├── CanvasRenderer.cl.jac
│   │   └── TextInput.cl.jac
│   └── common/
│       └── Button.cl.jac
└── styles.css                  # Premium CSS with gradients
```

## Key Architecture Decisions

### File Extensions
- `.cl.jac` = Client-side only (runs in browser)
- `.jac` = Can contain both server and client code (client code in `cl { }` blocks)
- **No docstrings in `.cl.jac` files** - keep them clean

### Jaclang Patterns
- `has variable: type = value;` = useState (reactive state)
- Regular variable assignment = just `variable = value;` (like Python, no `let`/`const`)
- Use `String()`, not `str()` for JavaScript string conversion
- Lambda functions: `lambda arg: type -> returnType { body }`
- Effects: `can with dependency entry { code }`

### Design
- Modern premium UI with violet/purple gradient theme
- Glassmorphism effects (backdrop-blur)
- Floating toolbar with smooth animations
- Tailwind CSS v4 with custom CSS variables

### Drawing Features
- ✏️ Freehand drawing
- ▢ Rectangle, ○ Circle, ╱ Line
- T Text tool with customizable fonts
- ⌘ Select & drag elements
- Zoom/pan viewport
- Color picker with presets
- Adjustable stroke widths

## Important Code Patterns

### Component Structure
```jac
def:pub ComponentName(props: dict) -> any {
    propValue = props.propName or "default";
    has stateVar: type = useState(initialValue);

    return <div>...</div>;
}
```

### Running the App
```bash
cd /home/malitha/programming/jac-apps
source venv/bin/activate
cd jasketch
jac start
```

## Reference Project
Based on patterns from `/home/malitha/programming/jac-client-playground/jac_playground` which demonstrates proper component separation and Jaclang best practices.

## Common Issues & Solutions

### String Conversion
- ❌ Don't use: `str(value)`
- ✅ Use instead: `String(value)`

### State Management
- ❌ Don't use: `[state, setState] = useState(value);` in function body
- ✅ Use instead: `has state: type = value;` (Jaclang's useState equivalent)

### File Types
- Components, hooks, services: Use `.cl.jac` (client-side only)
- Entry points with both client/server: Use `.jac` with `cl { }` blocks
- No empty `import from react { }` - either import something or remove it

## Project Evolution
This project was refactored from a single 481-line Canvas component into a well-organized architecture with:
- 6 custom hooks for state management
- 3 service layers for business logic
- 4 constant files for configuration
- Properly separated components
- Modern, premium design with glassmorphism

Following best practices from the jac-playground reference project.
