/**
# YokuAruHelpView: HelpAboutPage.swift
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

struct HelpAboutPage<PageSet: HelpPageSet>: View
{
	@Environment(\.openURL) private var openURL
	@Environment(\.pixelLength) private var pixelLength
	@EnvironmentObject private var helpViewModel: HelpViewModel<PageSet>
	
	var body: some View
	{
		let bundle = Bundle.main
		let appName = (bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? bundle.bundleURL.deletingPathExtension().lastPathComponent
		let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
		GeometryReader { geometryProxy in
			let _ = { print(geometryProxy.size) }()
			VStack(spacing: 8) {
				helpViewModel.helpPageSet.appIcon
					.resizable()
					.frame(width: 128, height: 128)
					.clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
					.shadow(color: .init(white: 0, opacity: 0.1), radius: 20, x: 0, y: 2)
					.background {
						RoundedRectangle(cornerRadius: 28, style: .continuous)
							.inset(by: -pixelLength)
							.fill(Color.black.opacity(0.2))
					}
					.padding(.bottom, 20)
				Text(verbatim: ([appName, version] as [String?]).compactMap { $0 }.joined(separator: " "))
					.font(.title)
				if let copyright = bundle.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String {
					Text(verbatim: copyright)
						.font(.body)
				}
				if let url = helpViewModel.helpPageSet.appWebsiteUrl {
					Spacer(minLength: 20)
					Button(url.absoluteString) {
						openURL(url)
					}
				}
			}
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: geometryProxy.size.width)
		}
		.padding(.top, 120)
		.padding(.bottom, 40)
	}
}
