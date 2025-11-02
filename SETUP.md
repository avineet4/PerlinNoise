# Setup Instructions

## Required Configuration

Before running the app, you need to add privacy permissions for photo library access.

### Adding Photo Library Permission

1. **Open the project in Xcode**
   ```bash
   open PerlinNoise.xcodeproj
   ```

2. **Select the PerlinNoise target**
   - In the Project Navigator, click on the blue PerlinNoise project file at the top
   - Select the "PerlinNoise" target under TARGETS

3. **Go to the Info tab**
   - Click on the "Info" tab in the main editor area

4. **Add Privacy Description**
   - Right-click in the "Custom iOS Target Properties" section
   - Select "Add Row"
   - From the dropdown, select: **"Privacy - Photo Library Additions Usage Description"**
     (Or manually enter: `NSPhotoLibraryAddUsageDescription`)
   - In the Value field, enter:
     ```
     This app needs access to save generated Perlin noise images to your photo library.
     ```

5. **Build and Run**
   - Press ⌘R or click the Run button
   - The app will now properly request photo library permissions when needed

### Alternative: Edit Info.plist Directly

If you prefer to edit the Info.plist file directly:

1. Find or create an Info.plist file in your project
2. Add this entry:
   ```xml
   <key>NSPhotoLibraryAddUsageDescription</key>
   <string>This app needs access to save generated Perlin noise images to your photo library.</string>
   ```

## Project Structure

Ensure all files are properly added to the Xcode project:

- ✅ `PerlinNoiseApp.swift`
- ✅ `ContentView.swift`
- ✅ `Views/CustomGradientEditor.swift`
- ✅ `ViewModels/GeneratorViewModel.swift`
- ✅ `Model/GeneratorSettings.swift`
- ✅ `Noise/PerlinNoise.swift`
- ✅ `Rendering/ImageRenderer.swift`
- ✅ `Color/ColorMaps.swift`

## Build Settings

The app requires:
- **Minimum iOS Version**: 17.0
- **Swift Version**: 5.9 or later
- **Frameworks**: SwiftUI, UIKit, CoreGraphics, UniformTypeIdentifiers

## Troubleshooting

### "Failed to save image" Error
- Check that the privacy description is properly added
- Make sure the app has permission to access Photos (Settings > Privacy > Photos)

### Build Errors
- Clean build folder: ⌘⇧K
- Delete derived data: Xcode > Preferences > Locations > Derived Data > Delete
- Restart Xcode

### File Not Found Errors
- Make sure all Swift files are added to the target
- Check Target Membership in File Inspector (⌘⌥1)

### Performance Issues
- Large image sizes (>2048×2048) may take longer to generate
- Consider using smaller sizes for real-time parameter adjustments
- The app automatically validates and caps sizes at 4096×4096

## Running on Device

To run on a physical device:

1. Connect your iPhone/iPad via USB or WiFi
2. Select your device from the device menu
3. You may need to:
   - Sign the app with your Apple ID (Signing & Capabilities tab)
   - Trust the developer certificate on your device (Settings > General > VPN & Device Management)

## Questions?

If you encounter any issues, check:
- Xcode version is 15.0 or later
- iOS deployment target is 17.0 or later
- All files are properly included in the target
- Privacy permissions are properly configured

