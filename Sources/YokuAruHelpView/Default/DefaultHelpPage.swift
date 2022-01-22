/**
# YokuAruHelpView: DefaultHelpPage.swift
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
import InlineLocalization

enum DefaultHelpPage<PageSet: HelpPageSet>: String, HelpPage, CaseIterable
{
	case aboutApp
	case acknowledgments
	
	var title: [Language : String]
	{
		switch self {
		case .aboutApp:
			return [.japanese: "このAppについて", .english: "About This App"]
		case .acknowledgments:
			return [.japanese: "謝辞", .english: "Acknowledgments"]
		}
	}
	var systemImageName: String? { nil }
	@MainActor @ViewBuilder var view: some View
	{
		switch self {
		case .aboutApp:
			HelpAboutPage<PageSet>()
		case .acknowledgments:
			HelpAcknowledgmentsPage<PageSet>()
		}
	}
}
