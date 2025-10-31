//
//  SourcePickerOverlay.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


// Presentation/Cheater/Overlays/SourcePickerOverlay.swift
import SwiftUI

struct SourcePickerOverlay: View {
    let onFiles: () -> Void
    let onLibrary: () -> Void
    let onDismiss: () -> Void

    @State private var shown = false
    @GestureState private var dragY: CGFloat = 0

    @State private var isDismissing = false
    @State private var endDragY: CGFloat = 0

    private var dismissThreshold: CGFloat { 140.scale }
    private var dismissTravel: CGFloat { 260.scale }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture { dismissThen(from: 0) }
                .animation(.easeOut(duration: 0.22), value: backgroundOpacity)

            sheet
                .offset(y: sheetOffset)
                .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: dragY)
                .animation(.easeOut(duration: 0.22), value: isDismissing)
                .animation(.easeOut(duration: 0.20), value: shown)
                .gesture(
                    DragGesture(minimumDistance: 3, coordinateSpace: .local)
                        .updating($dragY) { value, state, _ in
                            state = max(0, value.translation.height)
                        }
                        .onEnded { value in
                            let dy = max(0, value.translation.height)
                            let predicted = max(0, value.predictedEndLocation.y - value.location.y)
                            if dy > dismissThreshold || predicted > dismissThreshold {
                                dismissThen(from: dy)
                            } else {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                    shown = true
                                    isDismissing = false
                                }
                            }
                        }
                )
        }
        .onAppear { shown = true }
    }

    // MARK: layout helpers
    private var sheetOffset: CGFloat {
        isDismissing ? (endDragY + dismissTravel) : ((shown ? 0 : 40.scale) + max(0, dragY))
    }
    private var backgroundOpacity: Double {
        if isDismissing { return 0 }
        let base: Double = 0.35
        let progress = max(0, 1 - Double(dragY / (dismissThreshold * 1.5)))
        return shown ? (base * progress) : 0
    }
    private func dismissThen(from currentDrag: CGFloat) {
        endDragY = currentDrag
        isDismissing = true
        shown = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { onDismiss() }
    }

    private var sheet: some View {
        VStack(spacing: 16.scale) {
            RoundedRectangle(cornerRadius: 3.scale)
                .fill(Tokens.Color.borderNeutral.opacity(0.6))
                .frame(width: 40.scale, height: 4.scale)
                .padding(.top, 8.scale)

            Text("Select a photo or file")
                .font(.system(size: 20, weight: .medium))
                .tracking(-0.20)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8.scale)

            VStack(spacing: 12.scale) {
                SourceRow(systemImage: "folder", title: "Files") {
                    dismissThen(from: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { onFiles() }
                }
                SourceRow(systemImage: "photo.on.rectangle.angled", title: "Library") {
                    dismissThen(from: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { onLibrary() }
                }
            }
            .padding(.horizontal, 16.scale)
            .padding(.bottom, 16.scale)
        }
        .frame(maxWidth: .infinity)
        .background(Tokens.Color.surfaceCard,
                    in: RoundedRectangle(cornerRadius: 28.scale, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28.scale, style: .continuous)
                .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
        )
        .apply(Tokens.Shadow.card)
        .padding(.horizontal, 8.scale)
        .padding(.bottom, 8.scale)
    }
}

struct SourceRow: View {
    let systemImage: String
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12.scale) {
                ZStack {
                    Tokens.Color.backgroundMain
                    Image(systemName: systemImage)
                        .font(.system(size: 18.scale, weight: .semibold))
                        .foregroundStyle(Tokens.Color.accent)
                }
                .frame(width: 44.scale, height: 44.scale)
                .clipShape(RoundedRectangle(cornerRadius: 14.scale, style: .continuous))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(-0.16)

                Spacer()
            }
            .padding(.vertical, 12.scale)
            .padding(.horizontal, 12.scale)
            .background(
                Tokens.Color.surfaceCard,
                in: RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                    .stroke(Tokens.Color.borderNeutral, lineWidth: 1)
            )
            .apply(Tokens.Shadow.card)
        }
        .buttonStyle(.plain)
    }
}
