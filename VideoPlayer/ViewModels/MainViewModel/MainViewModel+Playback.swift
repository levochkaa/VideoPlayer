// MainViewModel+Playback.swift

import Foundation
import AVKit

extension MainViewModel {
    @objc func playerDidFinishPlaying() {
        if settings.newVideoOnTheEnd && settings.currentVideoIndex + 1 < videosCount {
            settings.currentVideoIndex += 1
        }
    }

    func removeObservers() {
        if let didPlayToEndObserver {
            NotificationCenter.default.removeObserver(didPlayToEndObserver)
        }

        if let timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    func addObservers() {
        didPlayToEndObserver = NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 1),
            queue: .main) { [self] time in
                guard let item = self.player.currentItem else { return }
                if item.duration.seconds.isNaN { return }
                self.videoPosition = time.seconds / item.duration.seconds
        }
    }
    
    func setVideo(for id: Int) {
        removeObservers()
        player = AVPlayer(url: videos[id].url)
        player.defaultRate = settings.currentRate
        player.rate = settings.currentRate
        addObservers()
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
            + CMTime(seconds: settings.forward, preferredTimescale: 1)
        )
        play()
        player.rate = settings.currentRate
    }

    func skipBackward() {
        player.seek(
            to: player.currentTime()
            - CMTime(seconds: settings.backward, preferredTimescale: 1)
        )
        play()
        player.rate = settings.currentRate
    }

    func changeRate(to rate: Float) {
        player.defaultRate = rate
        player.rate = rate
        settings.currentRate = rate
    }
}
