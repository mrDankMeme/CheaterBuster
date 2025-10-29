//
//  TaskStatus.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//


import Foundation

enum TaskStatus: String, Codable { case queued, running, completed, failed }

struct TaskResult: Codable {
    let risk_score: Int
    let red_flags: [String]
    let recommendations: [String]
}

struct TaskReadDTO: Codable {
    let id: UUID
    let status: TaskStatus
    let result: TaskResult?
    let error: String?
}
