// Config.swift

import Foundation

struct Config: Codable {
    var backward: GoWard = .five
    var forward: GoWard = .five
    var currentFolder: URL? = nil
    var currentVideoIndex: Int = 0
    var currentTime: Double = 0
    var currentRate: Float = 1
    var videoOverlayOn: Bool = false
    var videoOverlayCharactersCount: Int = 3
}

enum GoWard: Int, CaseIterable, Codable {
    case five = 5
    case ten = 10
    case fifteen = 15
    case thirty = 30
    case fourtyfive = 45
    case sixty = 60
    case seventyfive = 75
    case ninety = 90

    func nextCase() -> GoWard {
        if self != .ninety,
           let currentIndex = GoWard.allCases.firstIndex(of: self) {
            return .allCases[currentIndex + 1]
        }
        return .ninety
    }

    func prevCase() -> GoWard {
        if self != .five,
           let currentIndex = GoWard.allCases.firstIndex(of: self) {
            return .allCases[currentIndex - 1]
        }
        return .five
    }
}
