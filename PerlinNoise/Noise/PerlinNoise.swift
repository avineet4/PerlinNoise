import Foundation

final class PerlinNoiseGenerator {
    private let permutation: [Int]

    init(seed: UInt64) {
        var p = Array(0...255)
        var rng = LCG(seed: seed)
        // Fisher–Yates shuffle with deterministic RNG
        for i in stride(from: p.count - 1, through: 1, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            if i != j { p.swapAt(i, j) }
        }
        self.permutation = p + p // duplicate for overflow
    }

    func generate(width: Int, height: Int,
                  scale: Double,
                  octaves: Int,
                  persistence: Double,
                  lacunarity: Double) -> [Float] {
        let w = max(1, width)
        let h = max(1, height)
        var output = [Float](repeating: 0, count: w * h)
        var amplitude = 1.0
        var frequency = 1.0
        var maxValue = 0.0

        for _ in 0..<octaves {
            let freqScale = scale * frequency
            for y in 0..<h {
                let yf = Double(y) * freqScale
                for x in 0..<w {
                    let xf = Double(x) * freqScale
                    let n = noise(x: xf, y: yf)
                    output[y * w + x] += Float(n * amplitude)
                }
            }
            maxValue += amplitude
            amplitude *= persistence
            frequency *= lacunarity
        }

        if maxValue > 0 {
            let inv = Float(1.0 / maxValue)
            for i in 0..<output.count { output[i] *= inv }
        }
        // Map from [-1,1] to [0,1]
        for i in 0..<output.count { output[i] = output[i] * 0.5 + 0.5 }
        return output
    }

    private func noise(x: Double, y: Double) -> Double {
        let xi0 = Int(floor(x)) & 255
        let yi0 = Int(floor(y)) & 255
        let xf = x - floor(x)
        let yf = y - floor(y)

        let u = fade(xf)
        let v = fade(yf)

        let aa = permutation[permutation[xi0] + yi0]
        let ab = permutation[permutation[xi0] + yi0 + 1]
        let ba = permutation[permutation[xi0 + 1] + yi0]
        let bb = permutation[permutation[xi0 + 1] + yi0 + 1]

        let x1 = lerp(grad(hash: aa, x: xf, y: yf),
                      grad(hash: ba, x: xf - 1, y: yf),
                      u)
        let x2 = lerp(grad(hash: ab, x: xf, y: yf - 1),
                      grad(hash: bb, x: xf - 1, y: yf - 1),
                      u)
        return lerp(x1, x2, v)
    }

    private func fade(_ t: Double) -> Double {
        t * t * t * (t * (t * 6 - 15) + 10)
    }

    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + t * (b - a)
    }

    private func grad(hash: Int, x: Double, y: Double) -> Double {
        // 8 gradient directions
        switch hash & 7 {
        case 0: return  x + y
        case 1: return  x - y
        case 2: return -x + y
        case 3: return -x - y
        case 4: return  x
        case 5: return -x
        case 6: return  y
        default: return -y
        }
    }
}

// Simple LCG for deterministic shuffling
private struct LCG {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed != 0 ? seed : 0xdead_beef_cafe_babe }
    mutating func next() -> UInt64 {
        // Constants from Numerical Recipes
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}


