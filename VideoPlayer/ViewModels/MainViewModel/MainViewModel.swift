// MainViewModel.swift

import SwiftUI
import AVKit

class MainViewModel: ObservableObject {
    @Published var player = AVPlayer() {
        willSet { self.pause() }
        didSet { self.play() }
    }
    @Published var videos = [Video]()
    @Published var isPlaying = false
    @Published var videoPosition: Double = 0
    @Published var videoDuration: Double = 0
    @Published var settings: Config {
        didSet { self.save() }
    }

    let bookmarks = BookMarks.restore() ?? BookMarks(data: [:])
    let group = DispatchGroup()
    var videosCount = 0
    var tempVideos = [Video]()
    var didPlayToEndObserver: Any?
    var timeObserver: Any?

    init() {
        do {
            guard let data = UserDefaults.standard.data(
                forKey: "settings"
            ) else {
                settings = Config()
                selectFolder()
                return
            }
            settings = try JSONDecoder().decode(Config.self, from: data)

            if let folder = settings.currentFolder {
                try loadVideos(from: folder)
            } else {
                selectFolder()
            }

            return
        } catch {
            print("Error loading settings: \(error.localizedDescription)")
        }

        settings = Config()
        selectFolder()
    }

    func onAppear() {
        videos = tempVideos.sorted(by: { $0.id < $1.id })
        player = AVPlayer(url: videos[settings.currentVideoIndex].url)
        player.rate = settings.currentRate
        player.seek(to: CMTime(seconds: settings.currentTime, preferredTimescale: 1))

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main) { _ in
            self.settings.currentTime = self.player.currentTime().seconds
        }

        addObservers()
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: "settings")
        } catch {
            print("Error saving settings: \(error.localizedDescription)")
        }
    }
}
