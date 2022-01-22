/**
# YokuAruDocumentPicker: DocumentPickerRenamingView.swift
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

struct DocumentPickerRenamingView: View
{
	typealias FileItem = DocumentPickerFileItem
	
	var item: FileItem
	var items: [FileItem]
	var renameAction: (FileItem, String) throws -> Void
	
	init(item: FileItem, in items: [FileItem], renameAction: @escaping (FileItem, String) throws -> Void)
	{
		self.item = item
		self.items = items
		self.renameAction = renameAction
		_name = .init(initialValue: item.name)
	}
	
	@State private var name: String
	
	enum ValidationError
	{
		case containsUnsupportedCharacter(String)
		case fileAlreadyExists(String)
		
		var description: [Language: String]
		{
			switch self {
			case .containsUnsupportedCharacter(let character):
				return [
					.japanese: "記号  \(character)  はファイル名に使用できません。",
					.english: "Character  \(character)  can not be used for filenames.",
				]
			case .fileAlreadyExists(let filename):
				return [
					.japanese: "ファイル“\(filename)”はすでに存在します。",
					.english: "File “\(filename)” already exists.",
				]
			}
		}
	}
	@State private var validationErrors: [ValidationError] = []
	
	enum FocusedField
	{
		case name
	}
	@FocusState var focusedField: FocusedField?
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View
	{
		NavigationView {
			Form {
				HStack {
					TextField(text: $name) {
						Text(localizedIn: [.japanese: "名称", .english: "Name"])
					}
					.font(.title2)
					.focused($focusedField, equals: .name)
					.onSubmit {
						performRenameAndDismissOrShowError()
					}
					if !name.isEmpty {
						Button {
							name = ""
							focusedField = .name
						} label: {
							Image(systemName: "xmark.circle.fill")
								.foregroundColor(.secondary)
						}
						.buttonStyle(.plain)
					}
				}
				
				Section {
					if let firstError = validationErrors.first {
						HStack {
							ZStack {
								Image(systemName: "exclamationmark.triangle.fill")
									.symbolRenderingMode(.multicolor)
								Image(systemName: "paintpalette").hidden()
							}
							Text(localizedIn: firstError.description)
						}
					}
				}
			}
			.navigationTitle(Text(localizedIn: [.japanese: "名称変更", .english: "Rename"]))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button(String(localizedIn: [.japanese: "キャンセル", .english: "Cancel"])!) {
						dismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button(String(localizedIn: [.japanese: "完了", .english: "Done"])!) {
						performRenameAndDismissOrShowError()
					}
					.disabled(!canDone)
				}
			}
			.onAppear {
				Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
					focusedField = .name
				}
			}
		}
		.modifier(ShowErrorModifier(error: $currentError))
		.onChange(of: name) { value in
			validationErrors = validationErrors(with: name)
		}
		.navigationViewStyle(.stack)
	}
	struct ShowErrorModifier: ViewModifier
	{
		@Binding var error: NSError?
		func body(content: Content) -> some View
		{
			content.alert(
				Text(error?.localizedDescription ?? ""),
				isPresented: .init { error != nil } set: { if !$0 { error = nil } }
			) { /*default button*/ } message: {
				Text(error?.localizedRecoverySuggestion ?? "")
			}
		}
	}
	var canDone: Bool { (name != item.name) && !name.isEmpty && validationErrors.isEmpty }
	func validationErrors(with name: String) -> [ValidationError]
	{
		guard name != item.name else {
			return []
		}
		
		var validationErrors: [ValidationError] = []
		if name.contains("/") {
			validationErrors.append(.containsUnsupportedCharacter("/"))
		}
		if let sameNameItem = items.first(where: { $0.name.lowercased() == name.lowercased() }) {
			validationErrors.append(.fileAlreadyExists(sameNameItem.name))
		}
		return validationErrors
	}
	
	@State private var currentError: NSError?
	func performRenameAndDismissOrShowError()
	{
		guard canDone else { return }
		do {
			try renameAction(item, name)
			dismiss()
		} catch let error as NSError {
			currentError = error
		}
	}
}
