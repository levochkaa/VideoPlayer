// SettingsView.swift

import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel: MainViewModel

    @State private var replacedAbsoluteString = ""

    var body: some View {
        Form {
            Text("Video Index: \(viewModel.settings.currentVideoIndex)")

            Text("Time: \(viewModel.settings.currentTime)")

            Text("Rate: \(viewModel.settings.currentRate)")

            Text("Backward: -\(viewModel.settings.backward.rawValue) seconds")
            Text("Forward: +\(viewModel.settings.backward.rawValue) seconds")

            Button {
                viewModel.openCurrentFolder()
            } label: {
                Text("Open current folder")
            }
            .buttonStyle(.link)
        }
        .frame(width: 800, height: 500)
        .navigationTitle(replacedAbsoluteString)
        .onAppear {
            let absoluteString = viewModel.settings.currentFolder?.lastPathComponent ?? "Not Found"
            replacedAbsoluteString = absoluteString
                .replacingOccurrences(of: "%20", with: " ")
                .replacingOccurrences(of: "%5B", with: "[")
                .replacingOccurrences(of: "%5D", with: "]")
        }
    }
}
