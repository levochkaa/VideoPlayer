// URL+isSmth.swift

import Foundation

extension URL {
    var isVideo: Bool {
        return self.pathExtension == "mp4"
    }
    var isDirectory: Bool {
        return !self.isFileURL
    }
}
