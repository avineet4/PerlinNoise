//
//  ContentView.swift
//  PerlinNoise
//
//  Created by Avineet Singh on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = GeneratorViewModel()
    @State private var selectedTab: Int = 0
    @State private var showingShareSheet = false
    @State private var showingSizeSheet = false
    @State private var showingExportOptions = false
    @State private var showingCustomGradient = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(uiColor: .systemBackground), Color(uiColor: .secondarySystemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Main preview card
                        previewCard
                        
                        // Quick action buttons
                        quickActionsRow
                        
                        // Tabbed content
                        tabbedContent
                    }
                    .padding()
                }
            }
            .navigationTitle("Perlin Noise")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingSizeSheet = true }) {
                            Label("Canvas Size", systemImage: "square.resize")
                        }
                        Button(action: { vm.randomizeSeed() }) {
                            Label("Random Seed", systemImage: "shuffle")
                        }
                        Divider()
                        Button(action: { showingExportOptions = true }) {
                            Label("Export Options", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingSizeSheet) {
                SizePickerSheet(vm: vm)
            }
            .sheet(isPresented: $showingExportOptions) {
                ExportOptionsSheet(vm: vm)
            }
            .sheet(isPresented: $showingCustomGradient) {
                CustomGradientEditor(vm: vm)
            }
            .onAppear {
                vm.regenerateImmediately()
            }
        }
    }
    
    // MARK: - Main Preview Card
    
    private var previewCard: some View {
        VStack(spacing: 0) {
            if let cgImage = vm.image {
                Image(uiImage: UIImage(cgImage: cgImage))
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemBackground))
                        .frame(height: 350)
                    
                    VStack(spacing: 16) {
                        if vm.isGenerating {
                            VStack(spacing: 12) {
                                ProgressView(value: vm.generationProgress)
                                    .progressViewStyle(.linear)
                                    .tint(.accentColor)
                                    .frame(width: 120)
                                
                                Text("Generating...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundStyle(.tertiary)
                            Text("No Image")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.05), radius: 20, y: 10)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.image != nil)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsRow: some View {
        HStack(spacing: 12) {
            // Regenerate button
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                vm.regenerateImmediately()
            }) {
                Label("Generate", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(vm.isGenerating)
            
            // Share button
            if let cgImage = vm.image {
                ShareLink(item: ImageShareItem(image: UIImage(cgImage: cgImage)), 
                         preview: SharePreview("Perlin Noise", image: Image(uiImage: UIImage(cgImage: cgImage)))) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                        .frame(width: 50, height: 50)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            } else {
                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.tertiary)
                    .frame(width: 50, height: 50)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
    
    // MARK: - Tabbed Content
    
    private var tabbedContent: some View {
        VStack(spacing: 16) {
            // Custom tab selector
            Picker("", selection: $selectedTab.animation(.spring(response: 0.3))) {
                Text("Colors").tag(0)
                Text("Advanced").tag(1)
                Text("Info").tag(2)
            }
            .pickerStyle(.segmented)
            
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    colorPalettesView
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case 1:
                    advancedParametersView
                        .transition(.opacity)
                case 2:
                    infoView
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                default:
                    EmptyView()
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
        }
    }
    
    // MARK: - Color Palettes View
    
    private var colorPalettesView: some View {
        VStack(spacing: 12) {
            ForEach(GeneratorSettings.ColorVariant.allCases) { variant in
                PaletteCard(
                    variant: variant,
                    isSelected: vm.settings.colorVariant == variant,
                    action: {
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                        
                        if variant == .custom {
                            showingCustomGradient = true
                        } else {
                            vm.settings.colorVariant = variant
                            vm.regenerateDebounced()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Advanced Parameters View
    
    private var advancedParametersView: some View {
        VStack(spacing: 16) {
            // Seed card
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Seed", systemImage: "number")
                            .font(.headline)
                        Spacer()
                        Button("Shuffle") {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            vm.randomizeSeed()
                        }
                        .font(.subheadline)
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                    }
                    Text("\(vm.settings.seed)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            
            // Scale
            ParameterSlider(
                icon: "ruler",
                title: "Scale",
                value: $vm.settings.scale,
                range: 0.0005...0.02,
                format: "%.4f",
                onChange: { vm.regenerateDebounced() }
            )
            
            // Octaves
            ParameterSlider(
                icon: "waveform.path",
                title: "Octaves",
                value: Binding(
                    get: { Double(vm.settings.octaves) },
                    set: { vm.settings.octaves = Int($0.rounded()) }
                ),
                range: 1...8,
                step: 1,
                format: "%.0f",
                onChange: { vm.regenerateDebounced() }
            )
            
            // Persistence
            ParameterSlider(
                icon: "chart.line.uptrend.xyaxis",
                title: "Persistence",
                value: $vm.settings.persistence,
                range: 0.1...1.0,
                format: "%.2f",
                onChange: { vm.regenerateDebounced() }
            )
            
            // Lacunarity
            ParameterSlider(
                icon: "triangle",
                title: "Lacunarity",
                value: $vm.settings.lacunarity,
                range: 1.0...4.0,
                format: "%.2f",
                onChange: { vm.regenerateDebounced() }
            )
        }
    }
    
    // MARK: - Info View
    
    private var infoView: some View {
        VStack(spacing: 16) {
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Canvas Size", systemImage: "square.resize")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Width")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(vm.settings.width) px")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Height")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(vm.settings.height) px")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Button(action: { showingSizeSheet = true }) {
                        Text("Change Size")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
            
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    Label("About Perlin Noise", systemImage: "info.circle")
                        .font(.headline)
                    
                    Text("Perlin noise is a type of gradient noise used in computer graphics to create natural-looking textures and patterns. It's commonly used for terrain generation, cloud effects, and procedural textures.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct PaletteCard: View {
    let variant: GeneratorSettings.ColorVariant
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Palette preview
                let lut = ColorMaps.lut(for: variant)
                let colors = stride(from: 0, through: 255, by: 20).map { i -> Color in
                    let idx = i * 4
                    let r = Double(lut[idx + 0]) / 255.0
                    let g = Double(lut[idx + 1]) / 255.0
                    let b = Double(lut[idx + 2]) / 255.0
                    return Color(red: r, green: g, blue: b)
                }
                
                HStack(spacing: 0) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                        color
                    }
                }
                .frame(width: 100, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )
                
                Text(variant.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.accent)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct ParameterSlider: View {
    let icon: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double? = nil
    let format: String
    let onChange: () -> Void
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(title, systemImage: icon)
                        .font(.headline)
                    Spacer()
                    Text(String(format: format, value))
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                
                Slider(
                    value: Binding(
                        get: { value },
                        set: { newValue in
                            value = newValue
                            onChange()
                        }
                    ),
                    in: range,
                    step: step ?? 0.0001
                )
                .tint(.accentColor)
            }
        }
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
    }
}

// MARK: - Size Picker Sheet

struct SizePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: GeneratorViewModel
    @State private var selectedCategory: PresetCategory = .square
    @State private var selectedPreset: PresetOption = .square1024
    @State private var customWidth: String = "1024"
    @State private var customHeight: String = "1024"
    @State private var useCustom: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(PresetCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Preset", selection: $selectedPreset) {
                        ForEach(selectedCategory.options) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .disabled(useCustom)
                } header: {
                    Text("Presets")
                }
                
                Section {
                    Toggle("Use Custom Size", isOn: $useCustom)
                    
                    if useCustom {
                        HStack {
                            Text("Width")
                            Spacer()
                            TextField("1024", text: $customWidth)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("Height")
                            Spacer()
                            TextField("1024", text: $customHeight)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                } header: {
                    Text("Custom Size")
                } footer: {
                    Text("Valid range: 8 to 4096 pixels. Very large sizes may take longer to generate.")
                }
            }
            .navigationTitle("Canvas Size")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applySize()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func applySize() {
        var settings = vm.settings
        
        if useCustom {
            if let width = Int(customWidth), let height = Int(customHeight) {
                settings.width = max(8, min(width, 4096))
                settings.height = max(8, min(height, 4096))
            }
        } else {
            settings.width = selectedPreset.size.width
            settings.height = selectedPreset.size.height
        }
        
        vm.settings = settings
        vm.regenerateImmediately()
    }
}

// MARK: - Export Options Sheet

struct ExportOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: GeneratorViewModel
    @State private var showingSaveSuccess = false
    @State private var saveErrorMessage: String?
    
    var body: some View {
        NavigationStack {
            List {
                if let cgImage = vm.image {
                    let uiImage = UIImage(cgImage: cgImage)
                    
                    Section {
                        ShareLink(
                            item: ImageShareItem(image: uiImage),
                            preview: SharePreview("Perlin Noise", image: Image(uiImage: uiImage))
                        ) {
                            Label("Share Image", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    Section {
                        Button(action: {
                            saveToPhotos(uiImage)
                        }) {
                            Label("Save to Photos", systemImage: "photo.on.rectangle.angled")
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("Size")
                            Spacer()
                            Text("\(vm.settings.width) × \(vm.settings.height)")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Color Palette")
                            Spacer()
                            Text(vm.settings.colorVariant.displayName)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Seed")
                            Spacer()
                            Text("\(vm.settings.seed)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    } header: {
                        Text("Image Info")
                    }
                } else {
                    ContentUnavailableView(
                        "No Image",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Generate an image first to export it")
                    )
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Saved!", isPresented: $showingSaveSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Image saved to Photos successfully")
            }
            .alert("Error", isPresented: .constant(saveErrorMessage != nil)) {
                Button("OK") { saveErrorMessage = nil }
            } message: {
                if let message = saveErrorMessage {
                    Text(message)
                }
            }
        }
    }
    
    private func saveToPhotos(_ image: UIImage) {
        // Create a custom completion handler class
        class SaveHandler: NSObject {
            var onComplete: ((Error?) -> Void)?
            
            @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
                onComplete?(error)
            }
        }
        
        let handler = SaveHandler()
        handler.onComplete = { error in
            if let error = error {
                saveErrorMessage = error.localizedDescription
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                showingSaveSuccess = true
            }
        }
        
        UIImageWriteToSavedPhotosAlbum(image, handler, #selector(SaveHandler.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
}

// MARK: - Preset Definitions

enum PresetCategory: String, CaseIterable, Identifiable {
    case square, wallpaper, photo
    var id: String { rawValue }
    var title: String {
        switch self {
        case .square: return "Square"
        case .wallpaper: return "Wallpaper"
        case .photo: return "Photo"
        }
    }
    var options: [PresetOption] {
        switch self {
        case .square: return [.square512, .square1024, .square2048]
        case .wallpaper: return [.iphone13, .iphone15pro, .ipadPro12]
        case .photo: return [.hd1080, .uhd4k]
        }
    }
}

enum PresetOption: String, CaseIterable, Identifiable {
    case square512, square1024, square2048
    case iphone13, iphone15pro, ipadPro12
    case hd1080, uhd4k
    
    var id: String { rawValue }
    var title: String {
        switch self {
        case .square512: return "512 × 512"
        case .square1024: return "1024 × 1024"
        case .square2048: return "2048 × 2048"
        case .iphone13: return "iPhone 13/14"
        case .iphone15pro: return "iPhone 15 Pro"
        case .ipadPro12: return "iPad Pro 12.9\""
        case .hd1080: return "1920 × 1080"
        case .uhd4k: return "3840 × 2160"
        }
    }
    var size: (width: Int, height: Int) {
        switch self {
        case .square512: return (512, 512)
        case .square1024: return (1024, 1024)
        case .square2048: return (2048, 2048)
        case .iphone13: return (1170, 2532)
        case .iphone15pro: return (1290, 2796)
        case .ipadPro12: return (2048, 2732)
        case .hd1080: return (1920, 1080)
        case .uhd4k: return (3840, 2160)
        }
    }
}

// MARK: - Image Share Item

import UniformTypeIdentifiers

struct ImageShareItem: Transferable {
    let image: UIImage
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.image.pngData() ?? Data()
        }
    }
}

#Preview {
    ContentView()
}
