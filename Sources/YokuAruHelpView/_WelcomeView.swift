/**
# YokuAruHelpView: _WelcomeView.swift
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

public class WelcomeViewModel<PageSet: WelcomePageSet>: ObservableObject
{
	public init(pageSet: PageSet)
	{
		welcomePageSet = pageSet
	}
	@Published public var welcomePageSet: PageSet
	@Published public var helpStyle = HelpStyle()
	@Published public var currentPage: PageSet.Page?
	
	public func showPage(_ page: PageSet.Page)
	{
		currentPage = page
	}
}

public struct WelcomeView<PageSet: WelcomePageSet>: View
{
	@ObservedObject public var welcomeViewModel: WelcomeViewModel<PageSet>
	@Environment(\.dismiss) var dismiss
	
	public init(welcomeViewModel: WelcomeViewModel<PageSet>)
	{
		self.welcomeViewModel = welcomeViewModel
	}
	
	public var body: some View
	{
		VStack {
			let pages = Array(PageSet.Page.allCases)
			if let currentPage = welcomeViewModel.currentPage, let i = pages.firstIndex(of: currentPage) {
				ScrollView {
					VStack(alignment: .leading, spacing: 0) {
						currentPage.view
							.environmentObject(welcomeViewModel)
						HStack {
							if (i > 0) {
								Button {
									welcomeViewModel.currentPage = pages[i - 1]
								} label: {
									Spacer()
									Text(localizedIn: [.japanese: "戻る", .english: "Back"])
									Spacer()
								}
							}
							let isLastPage = (i == (pages.count - 1))
							Button {
								if isLastPage {
									dismiss()
								} else {
									welcomeViewModel.currentPage = pages[i + 1]
								}
							} label: {
								Spacer()
								if let customNextButtonTitle = currentPage.customNextButtonTitle {
									Text(localizedIn: customNextButtonTitle)
								} else {
									if isLastPage {
										Text(localizedIn: [.japanese: "始める", .english: "Continue"])
									} else {
										Text(localizedIn: [.japanese: "次へ", .english: "Continue"])
									}
								}
								Spacer()
							}
						}
						.controlSize(.large)
						.buttonStyle(.bordered)
					}
					.padding(.horizontal, 20)
					.padding(.bottom, 20)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.id(currentPage.id)
			}
		}
		.frame(maxWidth: 800)
		.onAppear {
			welcomeViewModel.currentPage = PageSet.Page.allCases.first
		}
		.onDisappear {
			welcomeViewModel.currentPage = nil
		}
	}
}
