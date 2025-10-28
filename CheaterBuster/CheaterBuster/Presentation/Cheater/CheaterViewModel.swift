//
//  CheaterViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

final class CheaterViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published private(set) var result: ConversationAnalysis?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorText: String?
    
    private let analyzer: CheaterAnalyzerService
    private var bag = Set<AnyCancellable>()
    
    
    init(analyzer: CheaterAnalyzerService) {
        self.analyzer = analyzer
    }
    
}
