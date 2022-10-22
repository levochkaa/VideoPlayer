// MainViewModel+Folder.swift

import SwiftUI

extension MainViewModel {
    func openCurrentFolder() {
        guard let url = settings.currentFolder else { return }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }

    func selectFolder() {
        let panel = NSOpenPanel()

        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true

        switch panel.runModal() {
            case .OK:
                guard let url = panel.url else {
                    return print("Error getting url")
                }

                settings = Config(
                    backward: settings.backward,
                    forward: settings.forward,
                    currentFolder: url,
                    currentVideoIndex: 0,
                    currentTime: 0,
                    currentRate: settings.currentRate,
                    videoOverlayOn: settings.videoOverlayOn,
                    videoOverlayCharactersCount: settings.videoOverlayCharactersCount
                )
                bookmarks.store(url: url)

                do {
                    try loadVideos(from: url)
                } catch {
                    print("Error loading videos: \(error.localizedDescription)")
                }
            default:
                break
        }
    }
}
