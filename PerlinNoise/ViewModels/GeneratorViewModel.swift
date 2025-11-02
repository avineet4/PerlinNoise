import Combine
import SwiftUI

@MainActor
final class GeneratorViewModel: ObservableObject {
    @Published var settings: GeneratorSettings
    @Published private(set) var image: CGImage?
    @Published private(set) var isGenerating: Bool = false
    @Published var customStops: [(Double, (Int, Int, Int))] = [
        (0.0, (0, 0, 0)), (1.0, (255, 255, 255))
    ]

    private var generationTask: Task<Void, Never>? = nil
    private var generationCounter: UInt64 = 0

    init(settings: GeneratorSettings = .defaults()) {
        self.settings = settings
    }

    func randomizeSeed() {
        settings.seed = UInt64.random(in: 0...UInt64.max)
        regenerateDebounced()
    }

    func regenerateDebounced(delay: Duration = .milliseconds(250)) {
        generationTask?.cancel()
        let currentId = nextGenerationId()
        generationTask = Task { [weak self] in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await self?.generateImage(generationId: currentId)
        }
    }

    func regenerateImmediately() {
        generationTask?.cancel()
        let currentId = nextGenerationId()
        generationTask = Task { [weak self] in
            await self?.generateImage(generationId: currentId)
        }
    }

    private func nextGenerationId() -> UInt64 {
        generationCounter &+= 1
        return generationCounter
    }

    private func generateImage(generationId: UInt64) async {
        isGenerating = true
        let s = settings.validated()

        let (w, h, scale, octaves, persistence, lacunarity, seed, variant) =
            (s.width, s.height, s.scale, s.octaves, s.persistence, s.lacunarity, s.seed, s.colorVariant)

        let customStopsCopy = self.customStops
        let imageResult = await withTaskGroup(of: CGImage?.self) { group -> CGImage? in
            group.addTask {
                let generator = PerlinNoiseGenerator(seed: seed)
                let field = generator.generate(
                    width: w,
                    height: h,
                    scale: scale,
                    octaves: octaves,
                    persistence: persistence,
                    lacunarity: lacunarity
                )
                let lut: [UInt8]
                if variant == .custom {
                    lut = ColorMaps.gradientLUT(stops: customStopsCopy)
                } else {
                    lut = ColorMaps.lut(for: variant)
                }
                return ImageRenderer.makeImage(noise: field, width: w, height: h, lut: lut)
            }
            return await group.next() ?? nil
        }

        guard generationId == generationCounter else { return }
        self.image = imageResult
        self.isGenerating = false
    }
}


