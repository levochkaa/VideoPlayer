// ContentView.swift

import SwiftUI
import AVKit
import SwiftUIKeyPress

struct ContentView: View {

    @ObservedObject var viewModel: MainViewModel

    @State private var showVideos = false
    @State private var keys = [UIKey]()

    var body: some View {
        VStack {
            CustomVideoPlayer(player: viewModel.player)
                .overlay(alignment: .top) {
                    Group {
                        if showVideos {
                            videosScroll()
                                .transition(.move(edge: .top))
                        } else {
                            videosScroll()
                                .offset(x: 0, y: -100)
                                .transition(.move(edge: .top))
                        }
                    }
                    .animation(.default, value: showVideos)
                    .onContinuousHover { phase in
                        switch phase {
                            case .active(_):
                                showVideos = true
                            case .ended:
                                showVideos = false
                        }
                    }
                }
        }
        .navigationTitle(viewModel.videos[viewModel.currentVideo].url.lastPathComponent)
        .onChange(of: viewModel.currentVideo) { id in
            viewModel.setVideo(for: id)
        }
        .onKeyPress($keys)
        .onChange(of: keys) { newValue in
            viewModel.keyPressed(newValue.last!)
        }
    }

    @ViewBuilder func controlButtons() -> some View {
        HStack {
            Button {
                viewModel.skipBackward()
            } label: {
                Image(systemName: "gobackward.\(viewModel.settings.backward.rawValue)")
            }

            Button {
                viewModel.isPlaying ? viewModel.pause() : viewModel.play()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                    .animation(.default, value: viewModel.isPlaying)
            }

            Button {
                viewModel.skipForward()
            } label: {
                Image(systemName: "goforward.\(viewModel.settings.forward.rawValue)")
            }
        }
        .font(.system(.title, design: .rounded, weight: .bold))
        .buttonStyle(ScaleButtonStyle())
    }

    @ViewBuilder func videosScroll() -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.videos) { video in
                        video.thumbnail
                            .resizable()
                            .id(video.id)
                            .scaledToFit()
                            .frame(width: 115, height: 64)
                            .cornerRadius(20)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(video.id == viewModel.currentVideo ? .red : .white, lineWidth: 2)
                            }
                            .overlay {
                                Text(video.url.lastPathComponent[0..<3])
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                            }
                            .onTapGesture {
                                viewModel.currentVideo = video.id
                            }
                    }
                }
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo(viewModel.currentVideo, anchor: .center)
                }
            }
            .onChange(of: viewModel.currentVideo) { currentVideo in
                withAnimation {
                    proxy.scrollTo(currentVideo, anchor: .center)
                }
            }
        }
        .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }
}
