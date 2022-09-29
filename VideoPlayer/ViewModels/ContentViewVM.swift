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
    @Published var currentVideo: Int = 0
    @Published var settings: Config {
        didSet {
            self.save()
        }
    }

    let bookmarks = BookMarks.restore() ?? BookMarks(data: [:])

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
            print(error.localizedDescription)
        }

        settings = Config()
        selectFolder()
    }

    func addVideo(with id: Int, from url: URL) {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 100)

        assetImgGenerate.generateCGImageAsynchronously(for: time) { cgImage, time, error in
            guard let cgImage else {
                DispatchQueue.main.async {
                    self.videos.append(
                        Video(id: id, url: url, thumbnail: Image(systemName: "exclamationmark.circle"))
                    )
                    self.videos.sort(by: { $0.id > $1.id })
                }
                return print("Error loading thumbnail")
            }

            let nsImage = NSImage(cgImage: cgImage, size: .zero)
            let image = Image(nsImage: nsImage)

            DispatchQueue.main.async {
                self.videos.append(Video(id: id, url: url, thumbnail: image))
                self.videos.sort(by: { $0.id < $1.id })
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

        folderContents.enumerated().forEach { index, url in
            guard url.isFileURL && url.isVideo else { return }
            addVideo(with: index, from: url)
        }

        guard let url = folderContents.first(where: { $0.isFileURL && $0.isVideo }) else {
            return print("Error getting first video")
        }

        player = AVPlayer(url: url)
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
                    currentFolder: url
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
