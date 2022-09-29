// PlayerView.swift

import SwiftUI
import AVKit

struct CustomVideoPlayer: NSViewRepresentable {
    var player: AVPlayer

    func makeNSView(context: NSViewRepresentableContext<CustomVideoPlayer>) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .none
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: NSViewRepresentableContext<CustomVideoPlayer>) {
        nsView.player = player
    }
}
