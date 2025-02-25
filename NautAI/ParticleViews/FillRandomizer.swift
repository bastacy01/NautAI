//
//  FillRandomizer.swift
//  NautAI
//
//  Created by Ben Stacy on 12/19/24.
//

import Foundation

// enum to encapsulate the particle assets

enum Fill: String, CaseIterable {
    case white
}

struct FillRandomiser {
    static func getRandomFill() -> Fill {
        let randomValue = Int.random(in: 0 ..< Fill.allCases.count)
        return Fill.allCases[randomValue]
    }
}
