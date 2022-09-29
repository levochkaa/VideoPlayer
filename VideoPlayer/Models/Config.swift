// Config.swift

import Foundation

struct Config: Codable {
    var backward: GoWard = .five
    var forward: GoWard = .five
    var currentFolder: URL? = nil
    var currentVideoIndex: Int = 0
    var currentTime: Double = 0

    enum GoWard: Int, Codable {
        case five = 5
        case ten = 10
        case fifteen = 15
        case thirty = 30
        case fourtyfive = 45
        case sixty = 60
        case seventyfive = 75
        case ninety = 90
    }
}
