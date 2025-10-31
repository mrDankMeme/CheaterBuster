//  HistoryView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import SwiftUI
import UIKit
import Swinject // MARK: - Added

struct HistoryView: View {
    @StateObject private var vm: HistoryViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.resolver) private var resolver // MARK: - Added
    @State private var goResults = false
    @State private var showPaywall = false // MARK: - Added

    init(vm: HistoryViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            content
                .background(Tokens.Color.backgroundMain.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    vm.reload()
                    vm.segment = router.historyPreferredSegment
                }
                .onChange(of: router.historyPreferredSegment) { _, seg in
                    vm.segment = seg
                }
                .onChange(of: vm.rerunResults) { _, hits in
                    if !hits.isEmpty { goResults = true }
                }
                // Было: mode: .name — меняем на .face, т.к. теперь доступен только поиск по фото
                .navigationDestination(isPresented: $goResults) {
                    SearchResultsView(results: vm.rerunResults, mode: .face)
                }
                .navigationDestination(item: $vm.selectedCheater) { rec in
                    CheaterResultView(
                        result: rec.asTaskResult,
                        onBack: { vm.selectedCheater = nil },
                        onSelectMessage: {} // из истории выбирать новое не нужно
                    )
                }
        }
        // Paywall (как и было добавлено ранее)
        .fullScreenCover(isPresented: $showPaywall) {
            let paywallVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: paywallVM)
                .presentationDetents([.large])
        }
    }

    private var content: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("History")
                    .font(Tokens.Font.title)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x16)

            SegmentCapsule(selected: $vm.segment, router: router)
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x12)

            Group {
                if vm.segment == .search {
                    topBarClear(isHidden: vm.items.isEmpty) { vm.clearSearch() }
                    SearchList(items: vm.items) { rec in
                        // Если запись текстового поиска — не перезапускаем (функции нет).
                        guard rec.kind == .face else {
                            // Мягко ничего не делаем; можно подсветить тостом в будущем.
                            return
                        }

                        // Premium-гейт оставляем без изменений:
                        let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                        if isPremium {
                            vm.onTapSearch(rec)
                        } else {
                            showPaywall = true
                        }
                    }
                    .padding(.horizontal, Tokens.Spacing.x16)
                    .padding(.top, Tokens.Spacing.x16)
                } else {
                    topBarClear(isHidden: vm.cheaterItems.isEmpty) { vm.clearCheater() }
                    CheaterList(items: vm.cheaterItems) { rec in vm.onTapCheater(rec) }
                        .padding(.horizontal, Tokens.Spacing.x16)
                        .padding(.top, Tokens.Spacing.x16)
                }
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func topBarClear(isHidden: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Spacer()
            if !isHidden {
                Button("Clear") { action() }
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.accent)
            }
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x8)
    }
}

// MARK: - Search list (как было)
import SwiftUI

private struct SearchList: View {
    let items: [HistoryRecord]
    let onTap: (HistoryRecord) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: Tokens.Spacing.x12) {
                ForEach(items) { rec in
                    Button { onTap(rec) } label: {
                        SearchRow(rec: rec)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, Tokens.Spacing.x24)
        }
    }
}

private struct SearchRow: View {
    let rec: HistoryRecord

    private var titleText: String {
        if let t = rec.titlePreview, !t.isEmpty { return t }
        switch rec.kind {
        case .name:
            // Текстовый поиск убран — показываем нейтральную подпись, если в истории внезапно окажется запись старого формата
            return rec.query?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? (rec.query ?? "Name search")
                : "Name search"
        case .face:
            return "Face search"
        }
    }

    private var subtitleText: String {
        if let s = rec.sourcePreview, !s.isEmpty { return s }
        return DateFormatter.historyDate.string(from: rec.createdAt)
    }

    var body: some View {
        HStack(spacing: Tokens.Spacing.x12) {
            ZStack {
                Tokens.Color.backgroundMain
                Image(systemName: rec.kind == .name ? "text.magnifyingglass" : "face.smiling")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Tokens.Color.accent)
            }
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
                    .fill(Tokens.Color.surfaceCard)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(Tokens.Font.body)
                    .foregroundStyle(Tokens.Color.textPrimary)

                Text(subtitleText)
                    .font(Tokens.Font.captionRegular)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.vertical, Tokens.Spacing.x12)
        .padding(.horizontal, Tokens.Spacing.x12)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
        )
        .apply(Tokens.Shadow.card)
    }
}

// MARK: - Cheater list (без изменений)
private struct CheaterList: View {
    let items: [CheaterRecord]
    let onTap: (CheaterRecord) -> Void

    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "No cheater items yet",
                systemImage: "text.magnifyingglass",
                description: Text("Analyze a chat to see it here.")
            )
            .padding(.top, Tokens.Spacing.x24)
        } else {
            ScrollView {
                LazyVStack(spacing: Tokens.Spacing.x12) {
                    ForEach(items) { rec in
                        Button { onTap(rec) } label: {
                            CheaterRow(rec: rec)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, Tokens.Spacing.x24)
            }
        }
    }
}

private struct CheaterRow: View {
    let rec: CheaterRecord

    var body: some View {
        HStack(spacing: Tokens.Spacing.x12) {
            ZStack {
                Tokens.Color.backgroundMain
                Image(systemName: rec.kind == .file ? "folder" : "photo")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Tokens.Color.accent)
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("High risk level")
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                if let note = rec.note, !note.isEmpty {
                    Text(note)
                        .font(Tokens.Font.captionRegular)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("\(rec.riskScore)%")
                .font(Tokens.Font.caption)
                .foregroundStyle(Tokens.Color.textPrimary)
        }
        .padding(.vertical, Tokens.Spacing.x12)
        .padding(.horizontal, Tokens.Spacing.x12)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
        )
        .apply(Tokens.Shadow.card)
    }
}

// MARK: - DateFormatter
private extension DateFormatter {
    static let historyDate: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}

// MARK: - Segment (без изменений)
private struct SegmentCapsule: View {
    @Binding var selected: HistoryViewModel.Segment
    @ObservedObject var router: AppRouter

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .apply(Tokens.Shadow.card)

            HStack(spacing: 0) {
                seg("Search", .search)
                seg("Cheater", .cheater)
            }
        }
        .frame(height: 44)
    }

    private func seg(_ title: String, _ seg: HistoryViewModel.Segment) -> some View {
        Button {
            selected = seg
            router.rememberHistorySegment(seg)
        } label: {
            Text(title)
                .font(Tokens.Font.caption)
                .foregroundStyle(selected == seg ? .white : Tokens.Color.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Group {
                        if selected == seg {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Tokens.Color.accent)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Added: адаптер CheaterRecord -> TaskResult
private extension CheaterRecord {
    var asTaskResult: TaskResult {
        .init(
            risk_score: self.riskScore,
            red_flags: self.redFlags,
            recommendations: self.recommendations
        )
    }
}
