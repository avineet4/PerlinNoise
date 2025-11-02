//
//  CustomGradientEditor.swift
//  PerlinNoise
//
//  Created by Avineet Singh on 30/10/25.
//

import SwiftUI

struct CustomGradientEditor: View {
    @ObservedObject var vm: GeneratorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var startColor: Color = .black
    @State private var endColor: Color = .white
    @State private var useMidColor: Bool = false
    @State private var midColor: Color = .gray
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Gradient preview
                    gradientPreview
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } header: {
                    Text("Preview")
                }
                
                Section {
                    ColorPicker("Start Color", selection: $startColor)
                        .onChange(of: startColor) { _ in updateGradient() }
                    
                    Toggle("Add Middle Color", isOn: $useMidColor)
                        .onChange(of: useMidColor) { _ in updateGradient() }
                    
                    if useMidColor {
                        ColorPicker("Middle Color", selection: $midColor)
                            .onChange(of: midColor) { _ in updateGradient() }
                    }
                    
                    ColorPicker("End Color", selection: $endColor)
                        .onChange(of: endColor) { _ in updateGradient() }
                } header: {
                    Text("Colors")
                } footer: {
                    Text("Create a custom gradient by selecting start, middle (optional), and end colors.")
                }
                
                Section {
                    Button("Apply Gradient") {
                        vm.settings.colorVariant = .custom
                        updateGradient()
                        vm.regenerateImmediately()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("Custom Gradient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                loadCurrentGradient()
            }
        }
    }
    
    private var gradientPreview: some View {
        LinearGradient(
            stops: useMidColor ? [
                .init(color: startColor, location: 0),
                .init(color: midColor, location: 0.5),
                .init(color: endColor, location: 1)
            ] : [
                .init(color: startColor, location: 0),
                .init(color: endColor, location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private func loadCurrentGradient() {
        // Load existing gradient if custom variant is selected
        if vm.settings.colorVariant == .custom && !vm.customStops.isEmpty {
            if vm.customStops.count >= 2 {
                let first = vm.customStops[0].1
                startColor = Color(
                    red: Double(first.0) / 255.0,
                    green: Double(first.1) / 255.0,
                    blue: Double(first.2) / 255.0
                )
                
                let last = vm.customStops[vm.customStops.count - 1].1
                endColor = Color(
                    red: Double(last.0) / 255.0,
                    green: Double(last.1) / 255.0,
                    blue: Double(last.2) / 255.0
                )
                
                if vm.customStops.count >= 3 {
                    useMidColor = true
                    let mid = vm.customStops[1].1
                    midColor = Color(
                        red: Double(mid.0) / 255.0,
                        green: Double(mid.1) / 255.0,
                        blue: Double(mid.2) / 255.0
                    )
                }
            }
        }
    }
    
    private func updateGradient() {
        let startRGB = startColor.rgb255()
        let endRGB = endColor.rgb255()
        
        if useMidColor {
            let midRGB = midColor.rgb255()
            vm.customStops = [
                (0.0, (startRGB.r, startRGB.g, startRGB.b)),
                (0.5, (midRGB.r, midRGB.g, midRGB.b)),
                (1.0, (endRGB.r, endRGB.g, endRGB.b))
            ]
        } else {
            vm.customStops = [
                (0.0, (startRGB.r, startRGB.g, startRGB.b)),
                (1.0, (endRGB.r, endRGB.g, endRGB.b))
            ]
        }
    }
}

extension Color {
    func rgb255() -> (r: Int, g: Int, b: Int) {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if let cgColor = self.cgColor {
            UIColor(cgColor: cgColor).getRed(&r, green: &g, blue: &b, alpha: &a)
        }
        return (Int(r * 255.0), Int(g * 255.0), Int(b * 255.0))
        #else
        return (0, 0, 0)
        #endif
    }
}

#Preview {
    CustomGradientEditor(vm: GeneratorViewModel())
}

