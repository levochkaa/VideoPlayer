// MainViewModel+Video.swift

import SwiftUI
import AVKit

extension MainViewModel {
    func loadVideos(from folder: URL) throws {
        let folderContents = try FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: nil
        )

        videos.removeAll()
        tempVideos.removeAll()

        let folderVideos = folderContents.compactMap { url in
            return url.isFileURL && url.isVideo ? url : nil
        }
        videosCount = folderVideos.count

        group.enter()

        folderVideos
            .sorted {
                $0.lastPathComponent < $1.lastPathComponent
            }
            .enumerated()
            .forEach { index, url in
                addVideo(with: index, from: url)
            }

        group.wait()

        onAppear()
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
}
