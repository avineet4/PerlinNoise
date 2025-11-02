import CoreGraphics
import UIKit

enum ImageRenderer {
    static func makeImage(noise: [Float], width: Int, height: Int, lut: [UInt8]) -> CGImage? {
        guard noise.count == width * height, lut.count == 256 * 4 else { return nil }
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        for i in 0..<(width * height) {
            let n = max(0.0, min(1.0, Double(noise[i])))
            let idx = Int(n * 255.0 + 0.5)
            let li = idx * 4
            let pi = i * 4
            pixels[pi + 0] = lut[li + 0]
            pixels[pi + 1] = lut[li + 1]
            pixels[pi + 2] = lut[li + 2]
            pixels[pi + 3] = 255
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }
        return CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }

    static func uiImage(from cgImage: CGImage) -> UIImage {
        UIImage(cgImage: cgImage)
    }
}


