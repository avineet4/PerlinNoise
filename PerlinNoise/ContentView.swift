//
//  ContentView.swift
//  PerlinNoise
//
//  Created by Avineet Singh on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = GeneratorViewModel()
    @State private var step: Int = 0
    @State private var selectedPresetCategory: PresetCategory = .square
    @State private var selectedPreset: PresetOption = .square1024
    @State private var customWidth: Int = 1024
    @State private var customHeight: Int = 1024
    @State private var useMidColor: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                StepHeader(step: step)
                Group {
                    switch step {
                    case 0: sizeStep
                    case 1: paletteStep
                    case 2: previewStep
                    default: advancedStep
                    }
                }
                stepperBar
            }
            .padding()
            .navigationTitle("Perlin Noise")
            .onAppear { vm.regenerateImmediately() }
        }
    }
}

private extension ContentView {
    var preview: some View {
        ZStack {
            if let cg = vm.image {
                let img = Image(uiImage: UIImage(cgImage: cg))
                img
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
                    .overlay { RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)) }
            } else {
                Rectangle()
                    .fill(.secondary.opacity(0.1))
                    .overlay { Text(vm.isGenerating ? "Generating…" : "No Image").foregroundStyle(.secondary) }
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 320)
    }

    // Step 0: Size
    var sizeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose size").font(.headline)
            Picker("Category", selection: $selectedPresetCategory) {
                ForEach(PresetCategory.allCases) { c in Text(c.title).tag(c) }
            }
            .pickerStyle(.segmented)
            Picker("Preset", selection: $selectedPreset) {
                ForEach(selectedPresetCategory.options) { o in Text(o.title).tag(o) }
            }
            .onChange(of: selectedPreset) { _ in
                var s = vm.settings
                s.width = selectedPreset.size.width
                s.height = selectedPreset.size.height
                vm.settings = s
            }

            Divider()
            Text("Or custom").font(.subheadline)
            HStack {
                Stepper("Width: \(customWidth)", value: $customWidth, in: 8...4096, step: 8)
                Stepper("Height: \(customHeight)", value: $customHeight, in: 8...4096, step: 8)
            }
            Button("Apply Custom") {
                var s = vm.settings
                s.width = customWidth
                s.height = customHeight
                vm.settings = s
            }
        Text("Size preview")
        sizePreview(width: vm.settings.width, height: vm.settings.height)
            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 160)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.2)))
            .cornerRadius(8)
        }
    }

    // Step 3: Advanced
    var advancedStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced").font(.headline)
            HStack {
                Text("Seed: \(vm.settings.seed)").font(.caption).lineLimit(1).truncationMode(.middle)
                Spacer()
                Button("Randomize") { vm.randomizeSeed() }
            }
            VStack(alignment: .leading) {
                HStack { Text("Scale"); Spacer(); Text(String(format: "%.4f", vm.settings.scale)).monospacedDigit() }
                Slider(value: Binding(
                    get: { vm.settings.scale },
                    set: { vm.settings.scale = $0; vm.regenerateDebounced() }
                ), in: 0.0005...0.02)
            }
            VStack(alignment: .leading) {
                HStack { Text("Octaves"); Spacer(); Text("\(vm.settings.octaves)") }
                Slider(value: Binding(
                    get: { Double(vm.settings.octaves) },
                    set: { vm.settings.octaves = Int($0.rounded()); vm.regenerateDebounced() }
                ), in: 1...8, step: 1)
            }
            VStack(alignment: .leading) {
                HStack { Text("Persistence"); Spacer(); Text(String(format: "%.2f", vm.settings.persistence)).monospacedDigit() }
                Slider(value: Binding(
                    get: { vm.settings.persistence },
                    set: { vm.settings.persistence = $0; vm.regenerateDebounced() }
                ), in: 0.1...1.0)
            }
            VStack(alignment: .leading) {
                HStack { Text("Lacunarity"); Spacer(); Text(String(format: "%.2f", vm.settings.lacunarity)).monospacedDigit() }
                Slider(value: Binding(
                    get: { vm.settings.lacunarity },
                    set: { vm.settings.lacunarity = $0; vm.regenerateDebounced() }
                ), in: 1.0...4.0)
            }
            if vm.settings.colorVariant == .custom {
                Divider()
                Text("Custom gradient")
                Toggle("Use mid color", isOn: $useMidColor)
                ColorPicker("Start", selection: Binding(get: { Color(uiColor: .black) }, set: { c in
                    let rgb = c.rgb255()
                    var stops = vm.customStops
                    if stops.isEmpty { stops = [(0.0,(rgb.r,rgb.g,rgb.b)), (1.0,(255,255,255))] }
                    else { stops[0] = (0.0,(rgb.r,rgb.g,rgb.b)) }
                    vm.customStops = stops
                    vm.regenerateDebounced()
                }))
                if useMidColor {
                    ColorPicker("Middle", selection: Binding(get: { Color(uiColor: .gray) }, set: { c in
                        let rgb = c.rgb255()
                        var stops = vm.customStops
                        if stops.count < 3 { stops.insert((0.5,(rgb.r,rgb.g,rgb.b)), at: min(1, stops.count)) }
                        else { stops[1] = (0.5,(rgb.r,rgb.g,rgb.b)) }
                        vm.customStops = stops
                        vm.regenerateDebounced()
                    }))
                }
                ColorPicker("End", selection: Binding(get: { Color(uiColor: .white) }, set: { c in
                    let rgb = c.rgb255()
                    var stops = vm.customStops
                    if stops.isEmpty { stops = [(0.0,(0,0,0)), (1.0,(rgb.r,rgb.g,rgb.b))] }
                    else if let last = stops.indices.last { stops[last] = (1.0,(rgb.r,rgb.g,rgb.b)) }
                    vm.customStops = stops
                    vm.regenerateDebounced()
                }))
            }
        }
    }

    // Step 1: Palette (basic)
    var paletteStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color palette").font(.headline)
            Picker("Variant", selection: $vm.settings.colorVariant) {
                ForEach(GeneratorSettings.ColorVariant.allCases) { v in
                    HStack {
                        palettePreview(for: v)
                            .frame(height: 12)
                            .cornerRadius(3)
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(.secondary.opacity(0.2)))
                        Text(v.displayName)
                    }
                    .tag(v)
                }
            }
            .onChange(of: vm.settings.colorVariant) { _ in vm.regenerateDebounced() }

            if vm.settings.colorVariant == .custom {
                Button("Customize Gradient…") { step = 3 }
                    .buttonStyle(.bordered)
            }

            Divider()
            Text("Preview")
            preview

            HStack {
                Spacer()
                Button("Regenerate") { vm.regenerateImmediately() }
                    .disabled(vm.isGenerating)
            }
        }
    }

    // Step 3: Preview/Export
    var previewStep: some View {
        VStack(spacing: 12) {
            preview
            actions
        }
    }

    var stepperBar: some View {
        HStack {
            Button("Back") { if step > 0 { step -= 1 } }
                .disabled(step == 0)
            Spacer()
            Button(step < 3 ? "Next" : "Done") {
                if step < 3 { step += 1 } else { step = 3 }
            }
        }
    }

    var actions: some View {
        HStack {
            Button(role: .none) {
                vm.regenerateImmediately()
            } label: {
                Label("Regenerate", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.isGenerating)

            Spacer()

            if let cg = vm.image {
                let ui = UIImage(cgImage: cg)
                ShareLink(item: ImageShareItem(image: ui), preview: SharePreview("Perlin Noise", image: Image(uiImage: ui))) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            } else {
                Label("Share", systemImage: "square.and.arrow.up")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// Transferable wrapper for ShareLink
import UniformTypeIdentifiers
import SwiftUI
import UIKit

struct ImageShareItem: Transferable {
    let image: UIImage
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.image.pngData() ?? Data()
        }
    }
}
#Preview { ContentView() }
/// Step header
struct StepHeader: View {
    let step: Int
    var body: some View {
        HStack {
            ForEach(0..<4, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 4)
                    .fill(idx <= step ? Color.accentColor : Color.secondary.opacity(0.2))
                    .frame(height: 4)
            }
        }
    }
}

// Preset definitions
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
        case .wallpaper: return [.iphone13, .iphone15pro, .ipadPro12, .uhdPortrait]
        case .photo: return [.hd1080, .uhd4k]
        }
    }
}

enum PresetOption: String, CaseIterable, Identifiable {
    case square512, square1024, square2048
    case iphone13, iphone15pro, ipadPro12, uhdPortrait
    case hd1080, uhd4k
    var id: String { rawValue }
    var title: String {
        switch self {
        case .square512: return "512 × 512"
        case .square1024: return "1024 × 1024"
        case .square2048: return "2048 × 2048"
        case .iphone13: return "iPhone 13/14 (1170×2532)"
        case .iphone15pro: return "iPhone 15 Pro (1290×2796)"
        case .ipadPro12: return "iPad Pro 12.9 (2048×2732)"
        case .uhdPortrait: return "UHD Portrait (2160×3840)"
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
        case .uhdPortrait: return (2160, 3840)
        case .hd1080: return (1920, 1080)
        case .uhd4k: return (3840, 2160)
        }
    }
}

private extension Color {
    func rgb255() -> (r: Int, g: Int, b: Int) {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if let cg = self.cgColor {
            UIColor(cgColor: cg).getRed(&r, green: &g, blue: &b, alpha: &a)
        }
        return (Int(r * 255.0), Int(g * 255.0), Int(b * 255.0))
        #else
        return (0,0,0)
        #endif
    }
}

// Helpers
private extension ContentView {
    func palettePreview(for variant: GeneratorSettings.ColorVariant) -> some View {
        let lut = ColorMaps.lut(for: variant)
        // sample 12 colors from LUT to build a gradient-like bar
        let samples = stride(from: 0, through: 255, by: 23).map { i -> Color in
            let idx = i * 4
            let r = Double(lut[idx + 0]) / 255.0
            let g = Double(lut[idx + 1]) / 255.0
            let b = Double(lut[idx + 2]) / 255.0
            return Color(red: r, green: g, blue: b)
        }
        return HStack(spacing: 0) {
            ForEach(Array(samples.enumerated()), id: \.offset) { _, c in
                c
            }
        }
    }

    func sizePreview(width: Int, height: Int) -> some View {
        GeometryReader { geo in
            let container = geo.size
            let maxW = container.width - 16
            let maxH = container.height - 16
            let aspect = CGFloat(width) / CGFloat(height)
            let w = min(maxW, maxH * aspect)
            let h = w / aspect
            ZStack {
                Color.secondary.opacity(0.06)
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.secondary.opacity(0.15))
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.08))
                    .frame(width: w, height: h)
                    .overlay {
                        Text("\\(width) × \\(height)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
            }
        }
    }
}
