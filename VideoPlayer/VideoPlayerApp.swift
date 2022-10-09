// VideoPlayerApp.swift

import SwiftUI

@main
struct VideoPlayerApp: App {

    @StateObject var viewModel = MainViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }
}
