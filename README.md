# Perlin Noise Generator

A beautiful, premium iOS app for generating stunning Perlin noise patterns with customizable parameters and color palettes.

## Features

### 🎨 Premium iOS Design
- Modern card-based interface following iOS design guidelines
- Smooth animations and haptic feedback throughout
- Adaptive color schemes with dynamic backgrounds
- SF Symbols integration for consistency

### 🌈 Rich Color Palettes
- **Grayscale**: Classic black and white gradient
- **Terrain**: Natural landscape colors (water, sand, grass, rock, snow)
- **Ocean**: Deep blue to light cyan ocean depths
- **Fire**: Hot colors from black through red, orange, yellow to white
- **Desert**: Sandy browns and warm earth tones
- **Forest**: Deep greens to light vegetation
- **Ice**: Cool blues and whites
- **Sunset**: Purple, orange, and warm evening colors
- **Custom**: Create your own gradient with 2-3 color stops

### ⚙️ Advanced Parameters
- **Scale**: Control zoom level (0.0005 - 0.02)
- **Octaves**: Layer multiple noise frequencies (1-8)
- **Persistence**: Control amplitude falloff (0.1 - 1.0)
- **Lacunarity**: Control frequency multiplier (1.0 - 4.0)
- **Seed**: Reproducible random patterns

### 📐 Flexible Canvas Sizes

**Square Presets:**
- 512 × 512
- 1024 × 1024
- 2048 × 2048

**Wallpaper Presets:**
- iPhone 13/14 (1170 × 2532)
- iPhone 15 Pro (1290 × 2796)
- iPad Pro 12.9" (2048 × 2732)

**Photo Presets:**
- HD 1080p (1920 × 1080)
- 4K UHD (3840 × 2160)

**Custom Sizes:**
- Any size from 8 × 8 to 4096 × 4096 pixels

### 📤 Export Options
- **Share**: Share directly to any app
- **Save to Photos**: Save directly to your photo library
- **Image Info**: View size, palette, and seed details

## Setup Instructions

### Requirements
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9+

### Building the App

1. Open the project in Xcode:
   ```bash
   open PerlinNoise.xcodeproj
   ```

2. **Important**: Add Privacy Permissions
   - Select the project in Xcode
   - Go to the "Info" tab
   - Add the following key:
     - Key: `Privacy - Photo Library Additions Usage Description`
     - Value: `This app needs access to save generated Perlin noise images to your photo library.`

3. Select your target device or simulator

4. Build and run (⌘R)

## Architecture

The app follows a clean MVVM architecture:

```
PerlinNoise/
├── PerlinNoiseApp.swift          # App entry point
├── ContentView.swift              # Main UI with premium iOS design
├── Views/
│   └── CustomGradientEditor.swift # Custom gradient creation UI
├── ViewModels/
│   └── GeneratorViewModel.swift   # Business logic and state management
├── Model/
│   └── GeneratorSettings.swift    # Data models and settings
├── Noise/
│   └── PerlinNoise.swift         # Core Perlin noise algorithm
├── Rendering/
│   └── ImageRenderer.swift       # Image generation from noise data
└── Color/
    └── ColorMaps.swift           # Color palette definitions
```

## How It Works

### Perlin Noise Algorithm
Perlin noise is a gradient noise function that creates natural-looking patterns. The implementation uses:
- **Permutation table**: Shuffled array based on seed for reproducibility
- **Gradient vectors**: 8 directional gradients for smooth interpolation
- **Fade function**: Smoothstep interpolation (6t⁵ - 15t⁴ + 10t³)
- **Octaves**: Multiple noise layers at different frequencies
- **Persistence**: Controls amplitude reduction per octave
- **Lacunarity**: Controls frequency increase per octave

### Image Generation Pipeline
1. Generate noise field using Perlin algorithm
2. Normalize values to [0, 1] range
3. Apply color lookup table (LUT) for gradient mapping
4. Convert to CGImage with RGB color space
5. Display in SwiftUI with animations

## Performance Optimizations

- **Async generation**: All noise generation runs on background threads
- **Debounced updates**: Parameter changes are debounced to prevent excessive regeneration
- **Task cancellation**: Previous generation tasks are cancelled when new ones start
- **Memory efficient**: Direct pixel buffer manipulation without intermediate allocations
- **Progress tracking**: Visual feedback during generation

## UI Components

### Reusable Components
- **CardView**: Consistent card styling with rounded corners
- **PaletteCard**: Interactive color palette selector with preview
- **ParameterSlider**: Labeled slider with value display
- **SizePickerSheet**: Modal size selection interface
- **ExportOptionsSheet**: Export and info modal
- **CustomGradientEditor**: Interactive gradient creation tool

### Interactions
- **Haptic Feedback**: Selection and impact feedback on interactions
- **Smooth Animations**: Spring-based animations for state changes
- **Gesture Support**: Native iOS gestures throughout

## Future Enhancements

Potential features for future versions:
- [ ] 3D Perlin noise support
- [ ] Animation export (GIF/video)
- [ ] More color palette presets
- [ ] Noise type selection (Simplex, Worley, etc.)
- [ ] Batch generation
- [ ] Favorites system
- [ ] iCloud sync for settings

## Credits

Created by Avineet Singh

## License

This project is available for personal and educational use.

---

**Enjoy creating beautiful procedural patterns! 🎨**

