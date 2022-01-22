/**
# YokuAruHelpView: HelpPageSet.swift
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

public protocol AnyHelpPage
{
	var identifier: String { get }
	var title: [Language: String] { get }
	var systemImageName: String? { get }
	@MainActor var view_any: AnyView { get }
}
extension AnyHelpPage where Self: RawRepresentable, RawValue == String
{
	public var identifier: String { rawValue }
}
public protocol HelpPage: AnyHelpPage
{
	associatedtype PageView: View
	@MainActor var view: PageView { get }
}
extension HelpPage
{
	@MainActor public var view_any: AnyView { .init(view) }
}

@MainActor public protocol HelpPageSet
{
	associatedtype Page: HelpPage
	associatedtype TableOfContents: View
	func tableOfContents(helpViewModel: HelpViewModel<Self>) -> TableOfContents
	var initialPage: Page { get }
	
	var acknowledgmentItems: [HelpAcknowledgmentItem] { get }
	var appIcon: Image { get }
	var appWebsiteUrl: URL? { get }
}
extension HelpPageSet
{
	public var acknowledgmentItems: [HelpAcknowledgmentItem] { [] }
	public var appIcon: Image { .init(systemName: "app") }
	public var appWebsiteUrl: URL? { (Bundle.main.object(forInfoDictionaryKey: "About_WebButtonUrl") as? String).flatMap { URL(string: $0) } }
}

public struct HelpAcknowledgmentItem
{
	public init(name: String, text: String)
	{
		self.name = name
		self.text = text
	}
	
	public var name: String
	public var text: String
}
