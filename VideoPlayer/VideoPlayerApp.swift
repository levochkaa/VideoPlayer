// VideoPlayerApp.swift

import SwiftUI

@main
struct VideoPlayerApp: App {
    @StateObject var viewModel = ContentViewVM()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .background(
                    KeyEventHandling(viewModel: viewModel)
                )
        }
    }
}
