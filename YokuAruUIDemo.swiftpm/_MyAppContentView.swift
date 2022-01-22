import SwiftUI
import InlineLocalization
import InlineLocalizationUI
import YokuAruHelpView
import YokuAruDocumentPicker

import YokuAruShowcaseVideoPlayer
import YokuAruImagePresenter
import AlertStack
import LegacyImagePicker
import WorkaroundFilePicker
import YokuAruUIExtensions

struct MyAppContentView: View
{
	@StateObject private var welcomeViewModel = WelcomeViewModel(pageSet: MyWelcomePageSet())
	@StateObject private var helpViewModel = HelpViewModel(pageSet: MyHelpPageSet())
	
	@State private var isPresentingWelcome = false
	@State private var isPresentingHelp = false
	
	enum Destination: Int
	{
		case undo
	}
	@State private var currentDestination: Destination? = .undo
	
	var body: some View
	{
		NavigationView {
			Form {
				Section {
					Button {
						isPresentingWelcome = true
					} label: {
						Text("Welcome")
					}
					
					Button {
						isPresentingHelp = true
					} label: {
						Text("Help")
					}
					
					NavigationLink(tag: .undo, selection: $currentDestination) {
						UndoDemoView()
					} label: {
						Text("Undo Redo Button")
					}
				}
			}
			.navigationTitle("Demo")
			.listStyle(.insetGrouped)
		}
		.fullScreenCover(isPresented: $isPresentingWelcome) {
			WelcomeView(welcomeViewModel: welcomeViewModel)
		}
		.sheet(isPresented: $isPresentingHelp) {
			HelpView(helpViewModel: helpViewModel)
		}
	}
}
