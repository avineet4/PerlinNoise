import CoreGraphics
import Foundation

enum ColorMaps {
    static func lut(for variant: GeneratorSettings.ColorVariant) -> [UInt8] {
        switch variant {
        case .grayscale:
            return gradientLUT(stops: [
                (0.0, (0, 0, 0)),
                (1.0, (255, 255, 255))
            ])
        case .terrain:
            return gradientLUT(stops: [
                (0.00, (  0,  10,  40)), // deep water
                (0.35, (  0,  70, 160)), // shallow
                (0.45, (240, 220, 170)), // sand
                (0.60, ( 50, 160,  80)), // grass
                (0.80, (110, 110, 110)), // rock
                (0.95, (250, 250, 250))  // snow
            ])
        case .ocean:
            return gradientLUT(stops: [
                (0.0, (0, 5, 25)),
                (0.4, (0, 45, 120)),
                (0.8, (0, 140, 220)),
                (1.0, (180, 230, 255))
            ])
        case .fire:
            return gradientLUT(stops: [
                (0.0, (0, 0, 0)),
                (0.2, (120, 0, 0)),
                (0.4, (200, 40, 0)),
                (0.6, (240, 140, 0)),
                (0.8, (255, 220, 0)),
                (1.0, (255, 255, 255))
            ])
        case .desert:
            return gradientLUT(stops: [
                (0.0, (210, 180, 140)),
                (0.4, (222, 184, 135)),
                (0.7, (205, 133, 63  )),
                (1.0, (139, 69,  19 ))
            ])
        case .forest:
            return gradientLUT(stops: [
                (0.0, (10, 30, 10)),
                (0.4, (30, 80, 30)),
                (0.7, (60, 120, 60)),
                (1.0, (160, 200, 140))
            ])
        case .ice:
            return gradientLUT(stops: [
                (0.0, (0, 10, 30)),
                (0.5, (120, 180, 220)),
                (0.8, (200, 230, 255)),
                (1.0, (255, 255, 255))
            ])
        case .sunset:
            return gradientLUT(stops: [
                (0.0, (0, 0, 30)),
                (0.3, (80, 0, 80)),
                (0.6, (220, 60, 0)),
                (0.8, (255, 140, 0)),
                (1.0, (255, 220, 150))
            ])
        case .custom:
            // Placeholder, UI should call gradientLUT directly with custom stops
            return gradientLUT(stops: [ (0.0, (0,0,0)), (1.0, (255,255,255)) ])
        }
    }

    // stops: array of (t in [0,1], (r,g,b) 0-255)
    static func gradientLUT(stops: [(Double, (Int, Int, Int))], size: Int = 256) -> [UInt8] {
        precondition(stops.count >= 2)
        let sorted = stops.sorted { $0.0 < $1.0 }
        var lut = [UInt8](repeating: 0, count: size * 4)
        var si = 0
        for i in 0..<size {
            let t = Double(i) / Double(size - 1)
            while si < sorted.count - 2 && t > sorted[si + 1].0 { si += 1 }
            let (t0, c0) = sorted[si]
            let (t1, c1) = sorted[si + 1]
            let local = clamp((t - t0) / max(1e-6, (t1 - t0)), 0, 1)
            let r = lerp(Double(c0.0), Double(c1.0), local)
            let g = lerp(Double(c0.1), Double(c1.1), local)
            let b = lerp(Double(c0.2), Double(c1.2), local)
            let idx = i * 4
            lut[idx + 0] = UInt8(max(0, min(255, Int(r))))
            lut[idx + 1] = UInt8(max(0, min(255, Int(g))))
            lut[idx + 2] = UInt8(max(0, min(255, Int(b))))
            lut[idx + 3] = 255
        }
        return lut
    }

    private static func clamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double { max(lo, min(hi, v)) }
    private static func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + t * (b - a) }
}


