//
//  UserReadDTO.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//



import Foundation

struct UserReadDTO: Codable {
    let id: UUID
    let apphud_id: String
    let tokens: Int
}

struct CreateUserDTO: Codable { let apphud_id: String }
struct AuthorizeUserDTO: Codable { let user_id: UUID }
struct TokenResponseDTO: Codable { let access_token: String; let token_type: String }
