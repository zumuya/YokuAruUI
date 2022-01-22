/**
# AlertStack: AlertStack.swift
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

import Combine
import SwiftUI
import InlineLocalization
import InlineLocalizationUI

public class AlertStack: ObservableObject
{
	public enum Item: Identifiable
	{
		case titledError(title: [Language: String], error: Error)
		case error(_ error: Error)
		
		public var id: String
		{
			switch self {
			case .titledError(title: let title, error: let error):
				return ((String(localizedIn: title) ?? "") + "error(\(error))")
			case .error(let error):
				return "error(\(error))"
			}
		}
	}
	
	public init() { }
	
	public func present(_ item: Item)
	{
		waitingItems.append(item)
		setNeedsUpdateCurrentItem()
	}
	public func present(_ items: [Item])
	{
		waitingItems.append(contentsOf: items)
		setNeedsUpdateCurrentItem()
	}
	
	var waitingItems: [Item] = []
	@Published var currentItem: Item? //this may be modified by `alert()` modifier.
	{
		didSet {
			if !isUpdatingCurrentItem {
				DispatchQueue.main.async {
					self.setNeedsUpdateCurrentItem()
				}
			}
		}
	}
	private var isUpdatingCurrentItem = false
	
	func setNeedsUpdateCurrentItem()
	{
		guard (currentItem == nil) else {
			return
		}
		isUpdatingCurrentItem = true
		defer { isUpdatingCurrentItem = false }
		
		currentItem = waitingItems.popLast()
	}
}
struct AlertStackModifier: ViewModifier
{
	/// To display, append the new item to last.
	/// Frontmost alert is the first item.
	//@Binding var alertItems: [AlertStack.Item]
	
	@StateObject private var alertStack: AlertStack
	public init(alertStack: AlertStack)
	{
		_alertStack = .init(wrappedValue: alertStack)
	}
	
	func body(content: Content) -> some View
	{
		content.alert(item: $alertStack.currentItem) { alertItem in
			switch alertItem {
			case .titledError(title: let title, error: let error):
				let texts: (title: Text, message: Text); do {
					if let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion {
						texts.title = (.init(localizedIn: title) + .init(verbatim: ("\n" + error.localizedDescription)))
						texts.message = .init(verbatim: recoverySuggestion)
					} else {
						texts.title = .init(localizedIn: title)
						texts.message = .init(verbatim: error.localizedDescription)
					}
				}
				return Alert(
					title: texts.title,
					message: texts.message,
					dismissButton: .default(Text("OK"))
				)
			case .error(let error):
				return Alert(
					title: Text(error.localizedDescription),
					message: (error as? LocalizedError)?.recoverySuggestion.map { Text($0) },
					dismissButton: .default(Text("OK"))
				)
			}
		}
	}
}

public extension View
{
	func alert(_ alertStack: AlertStack) -> some View
	{
		modifier(AlertStackModifier(alertStack: alertStack))
	}
}
