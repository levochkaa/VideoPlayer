// MainViewModel+Playback.swift

import Foundation
import AVKit

extension MainViewModel {
    func setVideo(for id: Int) {
        player = AVPlayer(url: videos[id].url)
        player.rate = settings.currentRate
    }
    
    func play() {
        player.play()
        player.rate = settings.currentRate
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func skipForward() {
        player.seek(
            to: player.currentTime()
            + CMTime(seconds: Double(settings.forward.rawValue), preferredTimescale: 1)
        )
        play()
    }

    func skipBackward() {
        player.seek(
            to: player.currentTime()
            - CMTime(seconds: Double(settings.backward.rawValue), preferredTimescale: 1)
        )
        play()
    }

    func changeRate(to rate: Float) {
        player.rate = rate
        settings.currentRate = rate
    }
}
