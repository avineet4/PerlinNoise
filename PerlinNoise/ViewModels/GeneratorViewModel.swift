import Combine
import SwiftUI

@MainActor
final class GeneratorViewModel: ObservableObject {
    @Published var settings: GeneratorSettings {
        didSet {
            if oldValue != settings {
                // Auto-regenerate on settings change (except for immediate changes)
                if oldValue.colorVariant != settings.colorVariant ||
                   oldValue.width != settings.width ||
                   oldValue.height != settings.height {
                    // Immediate regeneration for major changes
                }
            }
        }
    }
    @Published private(set) var image: CGImage?
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var generationProgress: Double = 0.0
    @Published var customStops: [(Double, (Int, Int, Int))] = [
        (0.0, (0, 0, 0)), (1.0, (255, 255, 255))
    ] {
        didSet {
            if settings.colorVariant == .custom {
                regenerateDebounced()
            }
        }
    }

    private var generationTask: Task<Void, Never>? = nil
    private var generationCounter: UInt64 = 0

    init(settings: GeneratorSettings = .defaults()) {
        self.settings = settings
    }

    func randomizeSeed() {
        settings.seed = UInt64.random(in: 0...UInt64.max)
        regenerateImmediately()
    }

    func regenerateDebounced(delay: Duration = .milliseconds(300)) {
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
        generationProgress = 0.0
        let s = settings.validated()

        let (w, h, scale, octaves, persistence, lacunarity, seed, variant) =
            (s.width, s.height, s.scale, s.octaves, s.persistence, s.lacunarity, s.seed, s.colorVariant)

        let customStopsCopy = self.customStops
        
        // Simulate progress for better UX
        let progressTask = Task { [weak self] in
            for i in 1...8 {
                try? await Task.sleep(for: .milliseconds(100))
                await MainActor.run {
                    self?.generationProgress = Double(i) / 10.0
                }
            }
        }
        
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

        progressTask.cancel()
        
        guard generationId == generationCounter else { return }
        self.generationProgress = 1.0
        self.image = imageResult
        
        // Small delay before resetting generating state for better UX
        try? await Task.sleep(for: .milliseconds(150))
        self.isGenerating = false
    }
    
    // Helper for getting UIImage
    var uiImage: UIImage? {
        guard let cgImage = image else { return nil }
        return UIImage(cgImage: cgImage)
    }
}


