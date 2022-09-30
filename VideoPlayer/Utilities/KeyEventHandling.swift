// KeyEventHandling.swift

import SwiftUI

struct KeyEventHandling: NSViewRepresentable {

    var viewModel: ContentViewVM

    class KeyView: NSView {

        var viewModel: ContentViewVM?

        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            guard let viewModel else { return }
            switch event.keyCode {
                case 126: // up arrow
                    viewModel.selectFolder()
                case 124: // right arrow
                    viewModel.skipForward()
                case 123: // left arrow
                    viewModel.skipBackward()
                case 49: // space
                    viewModel.isPlaying ? viewModel.pause() : viewModel.play()
                default:
                    break
            }
        }
    }

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.viewModel = viewModel
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        //
    }
}
