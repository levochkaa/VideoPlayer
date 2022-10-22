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
            Text("Video")
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
            Text("Time")
        }
    }

    @ViewBuilder var playbackSection: some View {
        Section {
            Stepper("Rate: \(viewModel.settings.currentRate.formatted())",
                    value: $viewModel.settings.currentRate,
                    step: 0.25,
                    onEditingChanged: { bool in
                viewModel.changeRate(to: viewModel.settings.currentRate)
            })

            Stepper("Backward: -\(viewModel.settings.backward.rawValue) seconds",
                    onIncrement: {
                viewModel.settings.backward = viewModel.settings.backward.nextCase()
            },
                    onDecrement: {
                viewModel.settings.backward = viewModel.settings.backward.prevCase()
            })

            Stepper("Forward: +\(viewModel.settings.forward.rawValue) seconds",
                    onIncrement: {
                viewModel.settings.forward = viewModel.settings.forward.nextCase()
            },
                    onDecrement: {
                viewModel.settings.forward = viewModel.settings.forward.prevCase()
            })
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
                Toggle("", isOn: $viewModel.settings.videoOverlayOn)
            }
        }
    }

    @ViewBuilder var otherSection: some View {
        Section {
            Button {
                viewModel.openCurrentFolder()
            } label: {
                Text("Open current folder")
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
