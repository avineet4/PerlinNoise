# Architecture Documentation

## 🏗 Application Architecture

The app follows a clean **MVVM (Model-View-ViewModel)** architecture pattern with SwiftUI.

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         SwiftUI Views                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │              ContentView (Main UI)                  │    │
│  │  - Preview Card                                     │    │
│  │  - Quick Actions                                    │    │
│  │  - Tabbed Interface                                 │    │
│  └────────────────────────────────────────────────────┘    │
│           │                    │                    │        │
│           ▼                    ▼                    ▼        │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐  │
│  │ SizePicker   │   │ ExportSheet  │   │ GradientEdit │  │
│  │   Sheet      │   │              │   │              │  │
│  └──────────────┘   └──────────────┘   └──────────────┘  │
│           │                    │                    │        │
└───────────┼────────────────────┼────────────────────┼────────┘
            │                    │                    │
            └────────────────────┼────────────────────┘
                                 │
                                 ▼
        ┌─────────────────────────────────────────────────┐
        │           GeneratorViewModel                     │
        │  @Published settings: GeneratorSettings          │
        │  @Published image: CGImage?                      │
        │  @Published isGenerating: Bool                   │
        │  @Published generationProgress: Double           │
        │  @Published customStops: [(Double, RGB)]         │
        │                                                  │
        │  + regenerateDebounced()                         │
        │  + regenerateImmediately()                       │
        │  + randomizeSeed()                               │
        └─────────────────────────────────────────────────┘
                                 │
                ┌────────────────┼────────────────┐
                │                │                │
                ▼                ▼                ▼
        ┌──────────┐    ┌──────────────┐  ┌──────────┐
        │  Model   │    │   Rendering   │  │  Color   │
        │          │    │               │  │          │
        │ Settings │    │ PerlinNoise   │  │ ColorMap │
        │          │    │ ImageRenderer │  │          │
        └──────────┘    └──────────────┘  └──────────┘
```

## 🗂 Layer Breakdown

### 1. View Layer (SwiftUI)

**Purpose**: User interface and interaction

**Components**:
- `ContentView.swift` - Main application UI
- `CustomGradientEditor.swift` - Custom gradient creation
- `PaletteCard` - Palette selection component
- `ParameterSlider` - Parameter adjustment component
- `CardView` - Reusable card container
- `SizePickerSheet` - Size selection modal
- `ExportOptionsSheet` - Export interface

**Responsibilities**:
- Display data from ViewModel
- Handle user interactions
- Navigate between screens
- Show loading states
- Provide haptic feedback

### 2. ViewModel Layer

**Purpose**: Business logic and state management

**Component**: `GeneratorViewModel.swift`

**Published Properties**:
```swift
@Published var settings: GeneratorSettings
@Published private(set) var image: CGImage?
@Published private(set) var isGenerating: Bool
@Published private(set) var generationProgress: Double
@Published var customStops: [(Double, (Int, Int, Int))]
```

**Key Methods**:
- `regenerateDebounced()` - Debounced regeneration
- `regenerateImmediately()` - Immediate regeneration
- `randomizeSeed()` - Generate new random seed
- `generateImage()` - Background image generation

**Responsibilities**:
- Manage application state
- Handle user actions
- Coordinate model and rendering
- Manage async tasks
- Progress tracking

### 3. Model Layer

**Purpose**: Data structures and business entities

**Component**: `GeneratorSettings.swift`

**Structure**:
```swift
struct GeneratorSettings: Equatable {
    var width: Int
    var height: Int
    var scale: Double
    var octaves: Int
    var persistence: Double
    var lacunarity: Double
    var seed: UInt64
    var colorVariant: ColorVariant
}
```

**Enums**:
- `ColorVariant` - Available color palettes
- `PresetCategory` - Size preset categories
- `PresetOption` - Specific size presets

**Responsibilities**:
- Define data structures
- Provide validation
- Supply default values
- Type safety

### 4. Service Layer

**Purpose**: Core functionality and utilities

**Components**:

#### Noise Generation
`PerlinNoise.swift`
```swift
class PerlinNoiseGenerator {
    func generate(width: Int, height: Int, 
                  scale: Double, octaves: Int,
                  persistence: Double, 
                  lacunarity: Double) -> [Float]
}
```

#### Image Rendering
`ImageRenderer.swift`
```swift
enum ImageRenderer {
    static func makeImage(noise: [Float], 
                         width: Int, height: Int,
                         lut: [UInt8]) -> CGImage?
}
```

#### Color Mapping
`ColorMaps.swift`
```swift
enum ColorMaps {
    static func lut(for variant: ColorVariant) -> [UInt8]
    static func gradientLUT(stops: [...]) -> [UInt8]
}
```

**Responsibilities**:
- Perlin noise algorithm
- Image generation
- Color mapping
- Utility functions

## 🔄 Data Flow

### Image Generation Flow

```
User Interaction
       │
       ▼
ContentView (User taps Generate)
       │
       ▼
GeneratorViewModel.regenerateImmediately()
       │
       ├─► Cancel previous task
       ├─► Increment generation counter
       └─► Start new Task
               │
               ▼
       generateImage(generationId)
               │
               ├─► Set isGenerating = true
               ├─► Validate settings
               └─► Background Task Group
                       │
                       ├─► PerlinNoiseGenerator.generate()
                       │   └─► Returns [Float] noise field
                       │
                       ├─► ColorMaps.lut()
                       │   └─► Returns color lookup table
                       │
                       └─► ImageRenderer.makeImage()
                           └─► Returns CGImage?
                               │
                               ▼
                       Update @Published image
                               │
                               ▼
                       Set isGenerating = false
                               │
                               ▼
                       ContentView updates automatically
```

### Parameter Change Flow

```
User Adjusts Slider
       │
       ▼
Binding updates ViewModel.settings
       │
       ▼
onChange closure triggers
       │
       ▼
ViewModel.regenerateDebounced()
       │
       ├─► Cancel previous debounce task
       ├─► Wait 300ms
       └─► If not cancelled:
           └─► Generate new image
```

### Color Palette Selection Flow

```
User Taps Palette Card
       │
       ▼
If Custom:
│  └─► Show CustomGradientEditor
│      └─► User picks colors
│          └─► Apply and regenerate
│
Else:
└─► Update settings.colorVariant
    └─► Regenerate with new colors
```

## 🧩 Component Relationships

### View Hierarchy

```
ContentView
├── Preview Card
│   └── Image or Loading State
├── Quick Actions Row
│   ├── Generate Button
│   └── Share Button
├── Tab Selector
│   └── Segmented Picker
└── Tab Content
    ├── Colors Tab
    │   └── ForEach(PaletteCard)
    ├── Advanced Tab
    │   ├── Seed Card
    │   └── ParameterSliders
    └── Info Tab
        ├── Size Card
        └── About Card

Sheets (Presented Modally)
├── SizePickerSheet
├── ExportOptionsSheet
└── CustomGradientEditor
```

### State Management

```
@StateObject vm (ContentView)
       │
       └─► Single source of truth
           │
           ├─► @ObservedObject vm (SizePickerSheet)
           ├─► @ObservedObject vm (ExportOptionsSheet)
           └─► @ObservedObject vm (CustomGradientEditor)
```

## 🎯 Design Patterns

### 1. MVVM (Model-View-ViewModel)
- **Model**: `GeneratorSettings`, data structures
- **View**: SwiftUI views
- **ViewModel**: `GeneratorViewModel`, business logic

### 2. Observer Pattern
- Uses Combine's `@Published` properties
- Views observe ViewModel changes
- Automatic UI updates

### 3. Dependency Injection
- ViewModel passed to child views
- Loose coupling between components
- Easy testing

### 4. Strategy Pattern
- `ColorVariant` enum for different palettes
- Swappable noise parameters
- Flexible rendering pipeline

### 5. Builder Pattern
- `GeneratorSettings.defaults()`
- Fluent API for settings

### 6. Singleton (Static Methods)
- `ImageRenderer.makeImage()`
- `ColorMaps.lut()`
- Pure functions, no state

## 🔐 Concurrency Model

### Task Management

```swift
private var generationTask: Task<Void, Never>?
private var generationCounter: UInt64 = 0

func regenerateDebounced() {
    generationTask?.cancel()  // Cancel old task
    let currentId = nextGenerationId()
    generationTask = Task {
        try? await Task.sleep(...)
        guard !Task.isCancelled else { return }
        await generateImage(generationId: currentId)
    }
}
```

**Benefits**:
- No race conditions
- Automatic cancellation
- Generation ID prevents stale updates
- Main actor for UI updates

## 📱 SwiftUI Integration

### State Management
```swift
@StateObject - ViewModel (owned by view)
@ObservedObject - ViewModel (passed to child)
@State - Local view state
@Binding - Two-way binding
@Environment - Environment values
```

### Modifiers Used
- `.sheet()` - Modal presentations
- `.toolbar()` - Navigation bar items
- `.onChange()` - State change reactions
- `.animation()` - Animated transitions
- `.task()` - Lifecycle async work

## 🎨 UI Component Architecture

### Reusable Components

```
CardView<Content>
├── Generic content container
├── Consistent styling
└── Reused everywhere

PaletteCard
├── Palette preview rendering
├── Selection state
└── Tap action

ParameterSlider
├── Icon + Title + Value
├── Slider binding
└── Change callback

Sheet Views
├── Navigation stack
├── Form-based UI
└── Proper dismiss handling
```

## 🚀 Performance Considerations

### Debouncing
- 300ms delay on parameter changes
- Prevents excessive regeneration
- Better UX and performance

### Task Cancellation
- Cancel old tasks immediately
- Prevent wasted computation
- Clean resource management

### Background Processing
- All generation on background threads
- UI stays responsive
- Progress feedback

### Memory Management
- Weak self in closures
- Proper Task cleanup
- Efficient image creation

## 🧪 Testability

### Easy to Test
- ViewModel is independent
- Pure functions in services
- Mock-friendly architecture
- Predictable state changes

### Test Points
- ViewModel logic
- Settings validation
- Noise generation
- Color mapping
- Image rendering

## 📚 Best Practices Implemented

✅ Single Responsibility Principle
✅ Separation of Concerns
✅ Dependency Injection
✅ Immutable Data Structures
✅ Functional Programming (where appropriate)
✅ Swift Concurrency (async/await)
✅ Type Safety
✅ Error Handling
✅ Memory Safety
✅ Performance Optimization

## 🎓 Key Takeaways

1. **Clean Architecture**: Clear separation between layers
2. **SwiftUI Best Practices**: Proper state management
3. **Modern Swift**: async/await, structured concurrency
4. **Performance**: Optimized for smooth UX
5. **Maintainability**: Easy to understand and extend
6. **Scalability**: Ready for future features

---

This architecture provides a solid foundation for a premium iOS app that's both beautiful and performant! 🏗✨

