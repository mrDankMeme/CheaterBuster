//
//  HistoryView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import SwiftUI
import UIKit

struct HistoryView: View {
    @StateObject private var vm: HistoryViewModel
    @State private var goResults = false

    // Важно: init для @StateObject, когда VM приходит из DI
    init(vm: HistoryViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            content
                .background(Tokens.Color.backgroundMain.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .onAppear { vm.reload() }
                .onChange(of: vm.rerunResults) { _, hits in
                    if !hits.isEmpty { goResults = true }
                }
                // Навигация в результаты поиска (реплей)
                .navigationDestination(isPresented: $goResults) {
                    SearchResultsView(results: vm.rerunResults, mode: .name)
                }
                // Навигация в результат Cheater
                .navigationDestination(item: $vm.selectedCheater) { rec in
                    CheaterResultView(record: rec)
                }
        }
    }

    // MARK: - UI

    private var content: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("History")
                    .font(Tokens.Font.title)
                    .foregroundStyle(Tokens.Color.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x16)

            // Твой компонент сегмента — оставляю имя, которое у тебя в проекте
            SegmentCapsule(selected: $vm.segment)
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x12)

            Group {
                if vm.segment == .search {
                    topBarClear(isHidden: vm.items.isEmpty) { vm.clearSearch() }
                    SearchList(items: vm.items) { rec in
                        vm.onTapSearch(rec)
                    }
                    .padding(.horizontal, Tokens.Spacing.x16)
                    .padding(.top, Tokens.Spacing.x16)
                } else {
                    topBarClear(isHidden: vm.cheaterItems.isEmpty) { vm.clearCheater() }
                    CheaterList(items: vm.cheaterItems) { rec in
                        vm.onTapCheater(rec)
                    }
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

// MARK: - Search list (исправлено под HistoryRecord)

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
        // приоритет: titlePreview -> query (для .name) -> дефолт по типу
        if let t = rec.titlePreview, !t.isEmpty { return t }
        switch rec.kind {
        case .name:
            return rec.query?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? (rec.query ?? "Name search")
                : "Name search"
        case .face:
            return "Face search"
        }
    }

    private var subtitleText: String {
        // приоритет: sourcePreview -> дата
        if let s = rec.sourcePreview, !s.isEmpty { return s }
        return DateFormatter.historyDate.string(from: rec.createdAt)
    }

    var body: some View {
        HStack(spacing: Tokens.Spacing.x12) {
            // левая иконка по типу запроса
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

// MARK: - DateFormatter (локальный)

private extension DateFormatter {
    static let historyDate: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}

// MARK: - Segment

private struct SegmentCapsule: View {
    @Binding var selected: HistoryViewModel.Segment
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
        Button { selected = seg } label: {
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
