// ContentViewVM.swift

import SwiftUI
import AVKit

class ContentViewVM: ObservableObject {
    @Published var player = AVPlayer() {
        willSet {
            self.pause()
        }
        didSet {
            self.play()
        }
    }
    @Published var videos = [Video]()
    @Published var isPlaying = false
    @Published var currentVideo: Int = 0 {
        didSet {
            self.settings.currentVideoIndex = currentVideo
        }
    }
    @Published var settings: Config {
        didSet {
            self.save()
        }
    }

    let bookmarks = BookMarks.restore() ?? BookMarks(data: [:])
    var timeObserverToken: Any?
    let group = DispatchGroup()
    var videosCount = 0
    var tempVideos = [Video]()

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
            currentVideo = settings.currentVideoIndex

            if let folder = settings.currentFolder {
                try loadVideos(from: folder)
            } else {
                selectFolder()
            }

            return
        } catch {
            print(error.localizedDescription)
        }

        settings = Config()
        selectFolder()
    }

    func onAppear() {
        videos = tempVideos.sorted(by: { $0.id < $1.id })
        player = AVPlayer(url: videos.first(where: { $0.id == settings.currentVideoIndex })!.url)
        player.seek(to: CMTime(seconds: settings.currentTime, preferredTimescale: 1))

        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { _ in
            self.settings.currentTime = self.player.currentTime().seconds
        }
    }

    func addVideo(with id: Int, from url: URL) {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 100)

        assetImgGenerate.generateCGImageAsynchronously(for: time) { cgImage, time, error in
            guard let cgImage else {
                DispatchQueue.main.async {
                    self.tempVideos.append(
                        Video(id: id, url: url, thumbnail: Image(systemName: "exclamationmark.circle"))
                    )
                }
                return print("Error loading thumbnail")
            }

            let nsImage = NSImage(cgImage: cgImage, size: .zero)
            let image = Image(nsImage: nsImage)

            self.tempVideos.append(Video(id: id, url: url, thumbnail: image))

            if self.videosCount == self.tempVideos.count {
                self.group.leave()
            }
        }
    }

    func skipForward() {
        player.seek(to: player.currentTime() + CMTime(seconds: Double(settings.forward.rawValue),
                                                      preferredTimescale: CMTimeScale(1)))
    }

    func skipBackward() {
        player.seek(to: player.currentTime() - CMTime(seconds: Double(settings.backward.rawValue),
                                                      preferredTimescale: CMTimeScale(1)))
    }

    func setVideo(for id: Int) {
        guard let video = videos.first(where: { $0.id == id} ) else {
            return print("Did't find a video")
        }

        player = AVPlayer(url: video.url)
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: "settings")
        } catch {
            print(error.localizedDescription)
        }
    }

    func play() {
        player.play()
        isPlaying = true
    }

    func pause() {
        player.pause()
        isPlaying = false
    }

    func loadVideos(from folder: URL) throws {
        let folderContents = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        )

        videos.removeAll()
        tempVideos.removeAll()

        let folderVideos = folderContents.compactMap { url in
            if url.isFileURL && url.isVideo {
                return url
            }
            return nil
        }
        videosCount = folderVideos.count

        group.enter()

        folderVideos
            .sorted(by: {
                $0.lastPathComponent < $1.lastPathComponent
            })
            .enumerated()
            .forEach { index, url in
            addVideo(with: index, from: url)
        }

        group.wait()

        onAppear()
    }

    func selectFolder() {
        let panel = NSOpenPanel()

        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true

        switch panel.runModal() {
            case .OK:
                guard let url = panel.url else { return print("Error getting url") }

                settings = Config(
                    backward: settings.backward,
                    forward: settings.forward,
                    currentFolder: url,
                    currentVideoIndex: 0,
                    currentTime: 0
                )
                bookmarks.store(url: url)

                do {
                    try loadVideos(from: url)
                } catch {
                    print(error.localizedDescription)
                }
            default:
                break
        }
    }
}
