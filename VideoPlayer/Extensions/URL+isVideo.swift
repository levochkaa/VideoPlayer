// URL+isVideo.swift

import Foundation

extension URL {
    var isVideo: Bool {
        return self.pathExtension == "mp4"
    }
}
