//
//  SourcePickerOverlay.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI

struct SourcePickerOverlay: View {
    let onFiles: () -> Void
    let onLibrary: () -> Void
    let onDismiss: () -> Void

    @State private var shown = false
    @GestureState private var dragY: CGFloat = 0
    @State private var isDismissing = false
    @State private var endDragY: CGFloat = 0

    // Все размеры применяются с .scale
    private let containerCorner: CGFloat = 32
    private let rowCorner: CGFloat = 22
    private let rowHeight: CGFloat = 52
    private let hPadding: CGFloat = 16
    private let gapRows: CGFloat = 12
    private let titleTop: CGFloat = 12      // заголовок ближе к верху
    private let titleToFirstRow: CGFloat = 16
    private let iconSize: CGFloat = 24

    private var dismissThreshold: CGFloat { 140.scale }
    private var dismissTravel: CGFloat { 260.scale }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Диммер: на весь экран; НЕ участвует в переходе
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture { dismissThen(from: 0) }
                .animation(.easeOut(duration: 0.22), value: backgroundOpacity)

            // Панель: анимируем появление/скрытие только её
            sheet
                .offset(y: sheetOffset)
                .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.9), value: dragY)
                .animation(.easeOut(duration: 0.22), value: isDismissing)
                .animation(.easeOut(duration: 0.20), value: shown)
                .transition(.move(edge: .bottom).combined(with: .opacity)) // MARK: - Added (только для панели)
                .gesture(
                    DragGesture(minimumDistance: 3.scale, coordinateSpace: .local)
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
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: Helpers

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

    // MARK: Sheet

    private var sheet: some View {
        VStack(spacing: 0) {
            // Хэндл сверху
            RoundedRectangle(cornerRadius: 2.scale, style: .continuous)
                .fill(Tokens.Color.textSecondary.opacity(0.30))
                .frame(width: 56.scale, height: 4.scale)
                .padding(.top, 8.scale)

            // Контент
            VStack(alignment: .leading, spacing: 0) {
                Text("Select a photo or file")
                    .font(Tokens.Font.title)
                    .foregroundColor(Tokens.Color.textPrimary)
                    .padding(.top, titleTop.scale)

                SourceRow(
                    title: "Files",
                    imageName: "ic_files_outline",
                    iconSize: iconSize.scale,
                    rowHeight: rowHeight.scale,
                    rowCorner: rowCorner.scale
                ) {
                    dismissThen(from: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { onFiles() }
                }
                .padding(.top, titleToFirstRow.scale)

                SourceRow(
                    title: "Library",
                    imageName: "ic_library_outline",
                    iconSize: iconSize.scale,
                    rowHeight: rowHeight.scale,
                    rowCorner: rowCorner.scale
                ) {
                    dismissThen(from: 0)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { onLibrary() }
                }
                .padding(.top, gapRows.scale)
            }
            .padding(.horizontal, hPadding.scale)
            .padding(.bottom, 16.scale)
        }
        .frame(maxWidth: .infinity, alignment: .bottom)
        .background(
            RoundedRectangle(cornerRadius: containerCorner.scale, style: .continuous)
                .fill(Tokens.Color.backgroundMain) // без бордера
        )
        .apply(Tokens.Shadow.card)
        .padding(.horizontal, 12.scale) // как в исходной версии — не на всю ширину
        .padding(.bottom, 8.scale)
    }
}

// MARK: Row

private struct SourceRow: View {
    let title: String
    let imageName: String
    let iconSize: CGFloat
    let rowHeight: CGFloat
    let rowCorner: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12.scale) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)

                Text(title)
                    .font(Tokens.Font.bodyMedium18)
                    .foregroundColor(Tokens.Color.textPrimary)

                Spacer()
            }
            .frame(height: rowHeight)
            .padding(.horizontal, 16.scale)
            .background(
                RoundedRectangle(cornerRadius: rowCorner, style: .continuous)
                    .fill(Tokens.Color.surfaceCard)
                    .shadow(color: Color.black.opacity(0.10), radius: 5.scale, x: 0, y: 2.scale)
                    .shadow(color: Color.black.opacity(0.09), radius: 9.scale, x: 0, y: 9.scale)
            )
        }
        .buttonStyle(.plain)
    }
}
