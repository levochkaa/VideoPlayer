// ContentView.swift

import SwiftUI
import SwiftUIKeyPress

struct ContentView: View {

    @ObservedObject var viewModel: MainViewModel

    @State private var showVideos = false
    @State private var showNextVideo = false
    @State private var showPrevVideo = false
    @State private var keys = [UIKey]()

    var body: some View {
        VStack {
            CustomVideoPlayer(player: viewModel.player)
                .overlay(alignment: .top) {
                    Group {
                        if showVideos {
                            videosScroll
                                .transition(.move(edge: .top))
                        } else {
                            videosScroll
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
                .overlay(alignment: .trailing) {
                    Group {
                        if showNextVideo {
                            changeVideo(next: true)
                                .transition(.opacity)
                                .opacity(1)
                        } else {
                            changeVideo(next: true)
                                .transition(.opacity)
                                .opacity(0)
                        }
                    }
                    .animation(.default, value: showNextVideo)
                    .onContinuousHover { phase in
                        switch phase {
                            case .active(_):
                                showNextVideo = true
                            case .ended:
                                showNextVideo = false
                        }
                    }
                }
                .overlay(alignment: .leading) {
                    Group {
                        if showPrevVideo {
                            changeVideo(next: false)
                                .transition(.opacity)
                                .opacity(1)
                        } else {
                            changeVideo(next: false)
                                .transition(.opacity)
                                .opacity(0)
                        }
                    }
                    .animation(.default, value: showPrevVideo)
                    .onContinuousHover { phase in
                        switch phase {
                            case .active(_):
                                showPrevVideo = true
                            case .ended:
                                showPrevVideo = false
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    if viewModel.settings.videoTimePlayedOn {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(.gray)
                            HStack {
                                Rectangle()
                                    .frame(width: 500 * viewModel.videoPosition, height: 10)
                                    .foregroundColor(.white)
                                Spacer(minLength: 0)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .frame(width: 500, height: 10)
                        .padding(.bottom, 20)
                    }
                }
        }
        .navigationTitle(viewModel.videos[viewModel.settings.currentVideoIndex].url.lastPathComponent)
        .onKeyPress($keys)
        .onChange(of: keys) { newKeys in
            viewModel.keyPressed(newKeys.last!)
        }
        .onChange(of: viewModel.settings.currentVideoIndex) { id in
            viewModel.setVideo(for: id)
        }
        .onChange(of: viewModel.player.rate) { newRate in
            if newRate == 1 {
                viewModel.player.rate = viewModel.settings.currentRate
            }
        }
    }

    @ViewBuilder func changeVideo(next: Bool) -> some View {
        Color.clear
            .frame(width: 150)
            .frame(maxHeight: .infinity)
            .background(.black)
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.gray, .clear]),
                    startPoint: next ? .trailing : .leading,
                    endPoint: next ? .leading : .trailing)
            )
            .overlay {
                Image(systemName: next ? "forward.fill" : "backward.fill")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
            }
            .onTapGesture {
                viewModel.settings.currentVideoIndex += next ? 1 : -1
            }
    }

    // Not used 'cause i hate control buttons and love hotkeys
    @ViewBuilder var controlButtons: some View {
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

    @ViewBuilder var videosScroll: some View {
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
                                    .stroke(video.id == viewModel.settings.currentVideoIndex
                                            ? .red
                                            : .white,
                                            lineWidth: 2)
                            }
                            .overlay {
                                if viewModel.settings.videoOverlayOn {
                                    Text(video.url.lastPathComponent[0..<viewModel.settings.videoOverlayCharactersCount])
                                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                }
                            }
                            .onTapGesture {
                                viewModel.settings.currentVideoIndex = video.id
                            }
                    }
                }
            }
            .onAppear {
                withAnimation {
                    proxy.scrollTo(viewModel.settings.currentVideoIndex, anchor: .center)
                }
            }
            .onChange(of: viewModel.settings.currentVideoIndex) { video in
                withAnimation {
                    proxy.scrollTo(video, anchor: .center)
                }
            }
        }
        .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
        .padding(.vertical)
        .background(.ultraThinMaterial)
    }
}
