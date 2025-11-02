import Foundation

struct GeneratorSettings: Equatable {
    enum SizePreset: String, CaseIterable, Identifiable {
        case s512 = "512 x 512"
        case s1024 = "1024 x 1024"
        case s2048 = "2048 x 2048"

        var id: String { rawValue }
        var width: Int { intPair.width }
        var height: Int { intPair.height }

        private var intPair: (width: Int, height: Int) {
            switch self {
            case .s512: return (512, 512)
            case .s1024: return (1024, 1024)
            case .s2048: return (2048, 2048)
            }
        }
    }

    enum ColorVariant: String, CaseIterable, Identifiable {
        case grayscale
        case terrain
        case ocean
        case fire
        case desert
        case forest
        case ice
        case sunset
        case custom

        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    var width: Int
    var height: Int
    var scale: Double
    var octaves: Int
    var persistence: Double
    var lacunarity: Double
    var seed: UInt64
    var colorVariant: ColorVariant

    static let maxPixels: Int = 4096 * 4096 // hard safety cap

    static func defaults(preset: SizePreset = .s1024) -> GeneratorSettings {
        GeneratorSettings(
            width: preset.width,
            height: preset.height,
            scale: 0.008, // lower = zoomed out
            octaves: 5,
            persistence: 0.5,
            lacunarity: 2.0,
            seed: UInt64.random(in: 0...UInt64.max),
            colorVariant: .terrain
        )
    }

    mutating func applyPreset(_ preset: SizePreset) {
        width = preset.width
        height = preset.height
    }

    func validated() -> GeneratorSettings {
        var v = self
        v.width = max(8, min(v.width, 4096))
        v.height = max(8, min(v.height, 4096))
        v.scale = max(0.0001, min(v.scale, 0.1))
        v.octaves = max(1, min(v.octaves, 8))
        v.persistence = max(0.1, min(v.persistence, 1.0))
        v.lacunarity = max(1.0, min(v.lacunarity, 4.0))
        if v.width * v.height > GeneratorSettings.maxPixels {
            // downscale preserving aspect
            let aspect = Double(v.width) / Double(v.height)
            let newH = Int(sqrt(Double(GeneratorSettings.maxPixels) / aspect))
            let newW = Int(Double(newH) * aspect)
            v.width = max(8, newW)
            v.height = max(8, newH)
        }
        return v
    }
}


