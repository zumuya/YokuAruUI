import Foundation
import SwiftUI
import InlineLocalization
import YokuAruHelpView

@MainActor struct MyHelpPageSet: HelpPageSet
{	
	enum Page: String, HelpPage, CaseIterable
	{
		case top
		case mainScreen
		
		var title: [Language : String]
		{
			switch self {
			case .top:
				return [.japanese: "基本的な使い方", .english: "Basic Usage"]
				
			case .mainScreen:
				return [.japanese: "メイン画面", .english: "Main Screen"]
			}
		}
		var systemImageName: String?
		{
			switch self {
			case .mainScreen:
				return "sidebar.left"
			default:
				return nil
			}
		}
		@ViewBuilder var view: some View
		{
			switch self {
			case .top:
				TopHelpPage()
			case .mainScreen:
				MainScreenHelpPage()
			}
		}
	}
	
	var initialPage: Page { .top }
	
	@ViewBuilder func tableOfContents(helpViewModel: HelpViewModel<Self>) -> some View
	{
		Section(String(localizedIn: [.japanese: "基本", .english: "General"])!) {
			ForEach([.top] as [Page], id: \.identifier) { page in
				helpViewModel.button(for: page)
			}
		}
		Section(String(localizedIn: [.japanese: "ユーザインターフェイス", .english: "User Interface"])!) {
			ForEach([.mainScreen] as [Page], id: \.identifier) { page in
				helpViewModel.button(for: page)
			}
		}
	}
	
	var acknowledgmentItems: [HelpAcknowledgmentItem] { [
		.init(name: "YokuAruUI", text: """
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
""")
	] }
}

struct TopHelpPage: View
{
	@EnvironmentObject private var helpViewModel: HelpViewModel<MyHelpPageSet>
	
	var body: some View
	{
		VStack {
			StepsDescriptionFigure(steps: [
				.init(systemName: "hand.tap", description: [.japanese: "タップ", .english: "Tap"]),
				.init(systemName: "hand.draw", description: [.japanese: "ドラッグ", .english: "Draw"]),
				.init(systemName: "cup.and.saucer", description: [.japanese: "ティータイム", .english: "Tea Time"]),
			])
			
			helpViewModel.helpStyle.p {
				Text(verbatim: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
""")
			}
		}
	}
}
struct MainScreenHelpPage: View
{
	@EnvironmentObject private var helpViewModel: HelpViewModel<MyHelpPageSet>
	
	var body: some View
	{
		VStack {
			helpViewModel.helpStyle.p {
				Text(verbatim: """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
""")
			}
		}
	}
}

