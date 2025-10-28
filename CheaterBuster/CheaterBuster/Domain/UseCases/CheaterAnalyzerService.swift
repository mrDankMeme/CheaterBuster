//
//  CheaterAnalyzerService.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine

public protocol CheaterAnalyzerService {
    func analyze(text: String) -> AnyPublisher<ConversationAnalysis,Error>
}
 
