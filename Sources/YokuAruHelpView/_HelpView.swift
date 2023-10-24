/**
# YokuAruHelpView: _HelpView.swift
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

@MainActor public class HelpViewModel<PageSet: HelpPageSet>: ObservableObject
{
	public init(pageSet: PageSet)
	{
		helpPageSet = pageSet
	}
	
	@Published public var isShowingTableOfContents = false
	@Published public var helpPageSet: PageSet
	@Published public var currentPage: (any HelpPage)?
	@Published public var helpStyle = HelpStyle()
	
	public func showPage(_ page: some HelpPage)
	{
		currentPage = page
		isShowingTableOfContents = false
	}
	@ViewBuilder public func button(for page: some HelpPage) -> some View
	{
		Button {
			self.showPage(page)
		} label: {
			HStack {
				if let systemImageName = page.systemImageName {
					ZStack {
						Image(systemName: systemImageName)
						Image(systemName: "paintpalette").hidden()
					}
				}
				Text(localizedIn: page.title)
				Spacer()
				if (currentPage?.identifier == page.identifier) {
					Image(systemName: "checkmark")
				}
			}
		}
	}
}

public struct HelpView<PageSet: HelpPageSet>: View
{
	@ObservedObject public var helpViewModel: HelpViewModel<PageSet>

	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.dismiss) private var dismiss
	
	public init(helpViewModel: HelpViewModel<PageSet>)
	{
		self.helpViewModel = helpViewModel
	}
	
	public var body: some View
	{
		NavigationView {
			Group {
				if helpViewModel.isShowingTableOfContents {
					List {
						helpViewModel.helpPageSet.tableOfContents(helpViewModel: helpViewModel)
						Section(String(localizedIn: [.japanese: "App情報", .english: "About App"])!) {
							ForEach(DefaultHelpPage<PageSet>.allCases, id: \.identifier) { page in
								helpViewModel.button(for: page)
							}
						}
					}
					.tint(.primary)
					.navigationTitle(String(localizedIn: [.japanese: "目次", .english: "Table of Contents"])!)
					.navigationBarTitleDisplayMode(.inline)
				} else {
					if let currentPage = helpViewModel.currentPage {
						ScrollView {
							VStack(alignment: .leading, spacing: 0) {
								currentPage.view_any
									.environmentObject(helpViewModel)
							}
							.padding(.horizontal, 20)
							.fixedSize(horizontal: false, vertical: true)
							.frame(maxWidth: .infinity, alignment: .leading)
						}
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.navigationTitle(Text(localizedIn: currentPage.title))
						.navigationBarTitleDisplayMode(.large)
					} else {
						Color.gray
					}
				}
			}
			.frame(maxWidth: 800)
			.toolbar {
				ToolbarItemGroup(placement: .confirmationAction) {
					Button() {
						dismiss()
					} label: {
						Text(localizedIn: [.japanese: "完了", .english: "Done"])
					}
				}
				ToolbarItemGroup(placement: .navigation) {
					Toggle(isOn: $helpViewModel.isShowingTableOfContents) {
						Label(String(localizedIn: [.japanese: "目次", .english: "Table of Contents"])!, systemImage: "menucard")
					}
					.toggleStyle(.button)
					.labelsHidden()
				}
			}
		}
		.onAppear {
			guard (helpViewModel.currentPage == nil) else { return }
			helpViewModel.currentPage = helpViewModel.helpPageSet.initialPage
		}
	}
}
