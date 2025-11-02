# Feature Guide

## 🎨 User Interface Tour

### Main Screen

The main screen features a clean, card-based design with three main sections:

#### 1. Preview Card
- **Large image preview** at the top showing your generated noise
- **Shadow effects** for depth and visual hierarchy
- **Rounded corners** for modern iOS aesthetic
- **Loading state** with progress bar during generation
- **Empty state** with icon when no image is present

#### 2. Quick Actions
- **Generate Button** (Primary)
  - Prominent gradient button
  - Haptic feedback on tap
  - Disabled during generation
  - Generates new pattern with current settings
  
- **Share Button**
  - Quick access to sharing
  - Native iOS share sheet
  - Disabled when no image exists

#### 3. Tabbed Content
Three tabs for different functionalities:

##### Colors Tab
- **Palette Cards**: Visual preview of each color scheme
- **Interactive Selection**: Tap to apply
- **Selection Indicator**: Checkmark on selected palette
- **9 Built-in Palettes**:
  1. Grayscale - Classic monochrome
  2. Terrain - Natural landscapes
  3. Ocean - Deep sea blues
  4. Fire - Hot flames
  5. Desert - Sandy browns
  6. Forest - Lush greens
  7. Ice - Cool winters
  8. Sunset - Warm evenings
  9. Custom - Your own gradient

##### Advanced Tab
- **Seed Card**: Current seed with shuffle button
- **Parameter Sliders**: Real-time adjustable parameters
  - Scale: Zoom level
  - Octaves: Layer count
  - Persistence: Amplitude control
  - Lacunarity: Frequency control
- **Live Values**: Current values displayed
- **Debounced Updates**: Smooth, efficient regeneration

##### Info Tab
- **Canvas Size Card**: Current dimensions with change button
- **About Section**: Information about Perlin noise
- **Educational Content**: Learn while you create

## 🎯 Feature Deep Dive

### Custom Gradient Editor

Access by tapping the "Custom" palette option.

**Features:**
- **Start Color Picker**: Beginning of gradient
- **Middle Color Toggle**: Optional middle stop
- **End Color Picker**: End of gradient
- **Live Preview**: See changes in real-time
- **Apply Button**: Confirm and generate

**Use Cases:**
- Brand colors for designs
- Matching existing color schemes
- Creative experimentation
- Unique artistic effects

### Size Picker

Access via menu (•••) → Canvas Size, or Info tab.

**Preset Categories:**
- **Square**: Perfect for social media avatars, tiles
- **Wallpaper**: Device-specific wallpapers
- **Photo**: Standard photo ratios

**Custom Size:**
- Toggle "Use Custom Size"
- Enter width and height
- Auto-validation (8-4096 px)
- Preserves aspect ratio intent

**Smart Limits:**
- Minimum: 8×8 pixels
- Maximum: 4096×4096 pixels
- Total pixels: ≤ 16,777,216

### Export Options

Access via menu (•••) → Export Options.

**Share Features:**
- Native iOS share sheet
- All system share destinations
- PNG format with full quality

**Save to Photos:**
- Direct photo library integration
- Haptic success feedback
- Error handling with alerts
- Requires privacy permission

**Image Information:**
- Exact dimensions
- Selected color palette
- Generation seed (reproducibility)

## 🎮 Interactions

### Gestures
- **Tap**: Select palettes, buttons
- **Drag**: Adjust sliders
- **Long Press**: (Standard iOS context menus)

### Haptic Feedback
- **Selection**: Changing palettes
- **Impact**: Generating, randomizing
- **Success**: Saving to photos
- **Light**: Minor interactions

### Animations
- **Spring**: Tab transitions, state changes
- **Fade**: Content appearing/disappearing
- **Scale**: Button press feedback
- **Progress**: Generation indicator

## 🔧 Advanced Usage

### Reproducible Patterns

1. Generate a pattern you like
2. Go to Info tab or Export sheet
3. Note the seed value
4. Share or save the seed
5. Enter the same seed later to regenerate

### Parameter Combinations

**Natural Terrain:**
- Scale: 0.005-0.008
- Octaves: 5-6
- Persistence: 0.5-0.6
- Lacunarity: 2.0
- Palette: Terrain

**Abstract Art:**
- Scale: 0.01-0.02
- Octaves: 3-4
- Persistence: 0.4-0.5
- Lacunarity: 2.5-3.0
- Palette: Custom or Fire

**Smooth Clouds:**
- Scale: 0.003-0.005
- Octaves: 4-5
- Persistence: 0.6-0.8
- Lacunarity: 2.0
- Palette: Grayscale or Ice

**Fine Detail:**
- Scale: 0.008-0.015
- Octaves: 6-8
- Persistence: 0.5
- Lacunarity: 2.5-3.5
- Palette: Any

### Performance Tips

**For Real-time Adjustments:**
- Use smaller sizes (512-1024)
- Fewer octaves (1-4)
- Parameter changes are debounced

**For Final Export:**
- Increase to desired size
- Add more octaves for detail
- Adjust other parameters
- Generate final version
- Export immediately

**Battery Considerations:**
- Large sizes use more power
- More octaves = more computation
- Use WiFi for large exports

## 🎨 Creative Workflows

### Wallpaper Creation
1. Select device preset from Size Picker
2. Choose Sunset, Ocean, or Custom palette
3. Adjust scale for desired detail
4. Randomize until satisfied
5. Save to Photos
6. Set as wallpaper in Settings

### Social Media Assets
1. Select Square 1024×1024
2. Choose brand colors in Custom Gradient
3. Adjust parameters for variety
4. Generate multiple versions
5. Share directly or save

### Background Textures
1. Select appropriate size
2. Use Grayscale or subtle colors
3. Higher octaves for more detail
4. Lower persistence for subtlety
5. Export and use in design tools

### Artistic Exploration
1. Start with random seed
2. Try different palettes
3. Experiment with extreme values
4. Combine in photo editing apps
5. Create unique compositions

## 🔐 Privacy

**Photo Library Access:**
- Only requested when saving
- Only "Add Photos" permission needed
- No reading of existing photos
- No tracking or analytics
- All processing is local

**Data Storage:**
- No cloud storage
- No user accounts
- Settings stored locally
- Seeds are just numbers
- Complete privacy

## 💡 Tips & Tricks

1. **Quick Variations**: Use shuffle seed for instant variety
2. **Systematic Exploration**: Change one parameter at a time
3. **Save Seeds**: Note seeds of favorites for recreation
4. **Layer in Apps**: Export and composite in photo apps
5. **Batch Creation**: Generate multiple at once by shuffling
6. **Performance**: Smaller sizes respond faster
7. **Color Matching**: Use Custom Gradient for brand colors
8. **Wallpaper Testing**: Preview before setting
9. **Export Quality**: Always maximum PNG quality
10. **Experimentation**: No wrong answers in art!

## 🆘 Troubleshooting

**Slow Generation:**
- Reduce image size
- Decrease octaves
- Check device isn't hot
- Close other apps

**Can't Save to Photos:**
- Check Settings > Privacy > Photos
- Ensure permission granted
- Try restarting app

**App Feels Sluggish:**
- Restart app
- Restart device
- Check for iOS updates
- Free up storage space

**Colors Look Wrong:**
- Check display settings
- Try different palette
- Regenerate with different seed
- Verify in Photos app

---

**Enjoy creating beautiful procedural art! 🎨✨**

