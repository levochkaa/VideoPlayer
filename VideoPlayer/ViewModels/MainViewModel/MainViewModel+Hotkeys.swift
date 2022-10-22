// MainViewModel+Hotkeys.swift

import Foundation
import SwiftUIKeyPress

extension MainViewModel {
    func keyPressed(_ key: UIKey) {
        print("Key pressed: \(key.event.keyCode)")
        switch key.event.keyCode {
            case 126: // up arrow
                changeRate(to: settings.currentRate + 0.25)
            case 125: // down arrow
                changeRate(to: settings.currentRate - 0.25)
            case 124: // right arrow
                skipForward()
            case 123: // left arrow
                skipBackward()
            case 49: // space
                isPlaying ? pause() : play()
            case 44: // right slash
                selectFolder()
            default:
                break
        }
    }
}
