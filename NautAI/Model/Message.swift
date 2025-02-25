//
//  Message.swift
//  NautAI
//
//  Created by Ben Stacy on 12/7/24.
//

import Foundation

struct Message: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
}
