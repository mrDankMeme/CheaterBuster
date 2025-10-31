import SwiftUI

struct ProgressBar: View {
    let progress: Double // 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Фон
                Capsule(style: .continuous)
                    .fill(Tokens.Color.borderNeutral.opacity(0.35))

                // Прогресс (заполняется пропорционально ширине)
                Capsule(style: .continuous)
                    .fill(Tokens.Color.accent)
                    .frame(width: geo.size.width * CGFloat(clampedProgress))
                    .animation(.easeOut(duration: 0.25), value: progress)
            }
        }
        .frame(height: 8.scale)
        .clipShape(Capsule(style: .continuous))
    }

    // MARK: - Helper
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}
