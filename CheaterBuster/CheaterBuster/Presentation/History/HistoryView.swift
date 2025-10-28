//
//  HistoryView.swift
//  CheaterBuster
//

import SwiftUI

struct HistoryView: View {
    @StateObject var vm: HistoryViewModel
    @State private var goResults = false
    
    var body: some View {
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
            
            // Segment
            SegmentCapsule(selected: $vm.segment)
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x12)
            
            // Content
            Group {
                if vm.segment == .search {
                    topBarClear(isHidden: vm.items.isEmpty) { vm.clearSearch() }
                    HistoryGrid(items: vm.items) { rec in
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
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.reload()
        }
        .onChange(of: vm.rerunResults) { _, hits in
            if !hits.isEmpty { goResults = true }
        }
        .navigationDestination(isPresented: $goResults) {
            SearchResultsView(results: vm.rerunResults, mode: .name)
        }
    }
    
    // small helper
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

// MARK: - Search grid (как раньше)

private struct HistoryGrid: View {
    let items: [HistoryRecord]
    let onTap: (HistoryRecord) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: Tokens.Spacing.x16),
        GridItem(.flexible(), spacing: Tokens.Spacing.x16)
    ]
    
    var body: some View {
        if items.isEmpty {
            ContentUnavailableView("No history yet",
                                   systemImage: "clock.arrow.circlepath",
                                   description: Text("Your last 10 searches will appear here."))
            .padding(.top, Tokens.Spacing.x24)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: Tokens.Spacing.x16) {
                    ForEach(items) { rec in
                        Button { onTap(rec) } label: {
                            HistoryCard(rec: rec)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, Tokens.Spacing.x24)
            }
        }
    }
}

private struct HistoryCard: View {
    let rec: HistoryRecord
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.x8) {
            if rec.kind == .face, let d = rec.imageJPEG, let img = UIImage(data: d) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                ZStack {
                    Tokens.Color.backgroundMain
                    Image(systemName: "person.text.rectangle")
                        .font(.system(size: 28))
                        .foregroundStyle(Tokens.Color.textSecondary)
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            if let q = rec.query {
                Text(q).font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .lineLimit(1)
            }
            if let s = rec.sourcePreview {
                Text(s).font(Tokens.Font.captionRegular)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(Tokens.Spacing.x12)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
        )
        .apply(Tokens.Shadow.card)
    }
}

// MARK: - Cheater list

private struct CheaterList: View {
    let items: [CheaterRecord]
    let onTap: (CheaterRecord) -> Void
    
    var body: some View {
        if items.isEmpty {
            ContentUnavailableView("No cheater items yet",
                                   systemImage: "text.magnifyingglass",
                                   description: Text("Analyze a chat to see it here."))
            .padding(.top, Tokens.Spacing.x24)
        } else {
            ScrollView {
                VStack(spacing: Tokens.Spacing.x12) {
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
            // Левая иконка (как в макете)
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
            
            // % справа
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
