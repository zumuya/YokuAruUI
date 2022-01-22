/**
# YokuAruShowcaseVideoPlayer: ShowcaseVideoPlayer.swift
Copyright © 2020-2022 zumuya
Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
APARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

import SwiftUI
import AVFoundation
import AVKit
import InlineLocalizationUI

public struct ShowcaseVideoPlayer: View
{
	var player: AVPlayer
	@State private var isPlaying = false
	
	public init(player: AVPlayer)
	{
		self.player = player
	}
	
	public var body: some View
	{
		VideoPlayerWrapper(player: player)
			.brightness(isPlaying ? 0 : 0.2)
			.overlay {
				if !isPlaying {
					Button {
						Task {
							await player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
							player.play()
						}
					} label: {
						HStack {
							Image(systemName: "arrow.clockwise")
							Text(localizedIn: [
								.japanese: "もう一度見る",
								.english: "Play Again",
							])
						}
						.padding()
					}
					.controlSize(.large)
					.background(.thinMaterial, in: Capsule())
				}
			}
			.onAppear() {
				player.play()
			}
			.onDisappear() {
				player.pause()
			}
			.onReceive(player.publisher(for: \.rate)) { newValue in
				if (newValue > 0) {
					isPlaying = true
				} else { //willPause
					withAnimation {
						isPlaying = false
					}
				}
				
			}
			.environment(\.colorScheme, .light)
	}
}
struct VideoPlayerWrapper: UIViewControllerRepresentable
{
	var player: AVPlayer
	
	func makeUIViewController(context: Self.Context) -> AVPlayerViewController
	{
		let viewController = AVPlayerViewController(); do {
			viewController.player = player
			viewController.allowsPictureInPicturePlayback = false
			viewController.showsPlaybackControls = false
		}
		return viewController
	}
	func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Self.Context)
	{

	}
	class Coordinator
	{
		
	}
	func makeCoordinator() -> Coordinator
	{
		.init()
	}
}
