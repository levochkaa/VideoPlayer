// SettingsView.swift

import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel: MainViewModel
    @State private var replacedAbsoluteString = ""

    var body: some View {
        List {
            indexSection

            timeSection

            playbackSection

            overlaySection

            otherSection
        }
        .navigationTitle(replacedAbsoluteString)
        .onAppear {
            let absoluteString = viewModel.settings.currentFolder?.lastPathComponent ?? "Not Found"
            replacedAbsoluteString = absoluteString
                .replacingOccurrences(of: "%20", with: " ")
                .replacingOccurrences(of: "%5B", with: "[")
                .replacingOccurrences(of: "%5D", with: "]")
        }
    }

    @ViewBuilder var indexSection: some View {
        Section {
            HStack {
                TextField("New video index",
                          value: $viewModel.settings.currentVideoIndex,
                          format: .number)
                Text("index")
            }
        } header: {
            HStack {
                Text("Video")
                Toggle("Next video on the end", isOn: $viewModel.settings.newVideoOnTheEnd)
            }
        }
    }

    @ViewBuilder var timeSection: some View {
        Section {
            HStack {
                TextField("New time",
                          value: $viewModel.settings.currentTime,
                          format: .number)
                Text("seconds")
            }
        } header: {
            HStack {
                Text("Time")
                Toggle("Video time played", isOn: $viewModel.settings.videoTimePlayedOn)
            }
        }
    }

    @ViewBuilder var playbackSection: some View {
        Section {
            Stepper("Rate: \(viewModel.settings.currentRate.formatted())",
                    value: $viewModel.settings.currentRate,
                    step: 0.25,
                    onEditingChanged: { _ in
                viewModel.changeRate(to: viewModel.settings.currentRate)
            })

            HStack(spacing: 0) {
                Text("Backward for")

                TextField("time",
                          value: $viewModel.settings.backward,
                          format: .number
                )
                .padding(.trailing, 10)

                Text("seconds")
            }

            HStack(spacing: 0) {
                Text("Forward for")

                TextField("time",
                          value: $viewModel.settings.forward,
                          format: .number
                )
                .padding(.trailing, 10)

                Text("seconds")
            }
        } header: {
            Text("Video playback")
        }
    }

    @ViewBuilder var overlaySection: some View {
        Section {
            Stepper("Characters count: \(viewModel.settings.videoOverlayCharactersCount)",
                    value: $viewModel.settings.videoOverlayCharactersCount,
                    in: 1...10,
                    step: 1)
        } header: {
            HStack {
                Text("Video Overlay")
                Toggle("Overlay every video with its title first characters", isOn: $viewModel.settings.videoOverlayOn)
            }
        }
    }

    @ViewBuilder var otherSection: some View {
        Section {
            Button("Open current folder") {
                viewModel.openCurrentFolder()
            }
            .buttonStyle(.link)
            
            Button("Select a new folder") {
                viewModel.selectFolder()
            }
            .buttonStyle(.link)

            Spacer()

            Button {
                viewModel.settings = Config()
                viewModel.selectFolder()
            } label: {
                Text("Delete all settings")
                    .foregroundColor(.red)
            }
            .buttonStyle(.link)
        } header: {
            Text("Other")
        }
    }
}
