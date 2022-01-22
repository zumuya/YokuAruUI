/**
# YokuAruDocumentPicker: DocumentPicker.swift
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
import UniformTypeIdentifiers
import InlineLocalizationUI

struct DocumentPickerFileItem: Identifiable
{
	var name: String { url.deletingPathExtension().lastPathComponent }
	var url: URL
	var modificationDate: Date?
	var isEmpty: Bool
	var previewUrl: URL?
	
	var id: String { name }
}

@MainActor class DocumentPickerState<Document: PickableDocument>: ObservableObject
{
	@Published var fileItems: [DocumentPickerFileItem] = []
	func reloadFileItems()
	{
		let fileManager = FileManager.default
		let documentFolderUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		do {
			let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey]
			fileItems = try fileManager.contentsOfDirectory(at: documentFolderUrl, includingPropertiesForKeys: Array(resourceKeys), options: [])
				.filter {
					$0.pathExtension.lowercased() == Document.utType.preferredFilenameExtension!.lowercased()
				}
				.compactMap { fileUrl in
					let resourceValues = try? fileUrl.resourceValues(forKeys: resourceKeys)
					return .init(
						url: fileUrl,
						modificationDate: resourceValues?.contentModificationDate,
						isEmpty: Document.isEmptyDocument(at: fileUrl),
						previewUrl: Document.previewUrl(forFileUrl: fileUrl)
					)
				}
				.sorted { ($0.modificationDate ?? .distantPast) > ($1.modificationDate ?? .distantPast) }
		} catch {
			fileItems = []
		}
	}
	
	@Published var isRunningHeavyTask = false
	@Published var renamingFileItem: DocumentPickerFileItem?
	
	@discardableResult func performHeavyOperationIfPossible(_ operation: @escaping () async -> Void) -> Bool
	{
		if isRunningHeavyTask { return false }
		
		isRunningHeavyTask = true
		Task {
			await operation()
			isRunningHeavyTask = false
		}
		return true
	}
}

public struct DocumentPicker<Document, DocumentHolder: PickableDocumentHolder>: View where DocumentHolder.Document == Document
{
	@ObservedObject public var documentHolder: DocumentHolder

	@StateObject private var state = DocumentPickerState<Document>()
	
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.dismiss) private var dismiss
	
	public init(documentHolder: DocumentHolder)
	{
		self.documentHolder = documentHolder
	}
	
	public var body: some View
	{
		NavigationView {
			ScrollView {
				LazyVGrid(columns: [.init(.adaptive(minimum: 110, maximum: 250))], alignment: .center, spacing: 20) {
					FileButtonBase(
						content: .constant(.new),
						isOpened: .constant(false),
						placeholderWidthPerHeight: Document.previewPlaceholderWidthPerHeight
					) {
						state.performHeavyOperationIfPossible {
							await documentHolder.document.close()
							
							let newDocument = Document.makeNewDocument()
							
							var transaction = Transaction()
							transaction.disablesAnimations = true
							withTransaction(transaction) {
								documentHolder.document = newDocument
							}
							dismiss()
						}
					}
					.id("_____new")
					
					ForEach(state.fileItems, id: \.name) { item in
						let isOpened = (documentHolder.document.fileURL.standardizedFileURL == item.url.standardizedFileURL)
						
						FileButton(
							item: .constant(item),
							isOpened: .constant(isOpened),
							documentPickerState: state,
							documentHolder: documentHolder,
							dismiss: dismiss
						)
					}
				}
				.padding()
				.sheet(item: $state.renamingFileItem) { item in
					DocumentPickerRenamingView(item: item, in: state.fileItems) { (item, name) in
						let isOpened = (documentHolder.document.fileURL.standardizedFileURL == item.url.standardizedFileURL)
						
						let fileManager = FileManager.default
						let movedUrl = item.url
							.deletingLastPathComponent()
							.appendingPathComponent(name)
							.appendingPathExtension(Document.utType.preferredFilenameExtension!)
						try fileManager.moveItem(at: item.url, to: movedUrl)
						if isOpened {
							documentHolder.document.presentedItemDidMove(to: movedUrl)
						}
						state.reloadFileItems()
					}
				}
			}
			.background(Color(uiColor: (colorScheme == .light) ? .systemGroupedBackground : .systemBackground))
			.navigationTitle(Text(localizedIn: Document.pickerTitle))
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button(String(localizedIn: [.japanese: "完了", .english: "Done"])!) {
						dismiss()
					}
				}
			}
			.interactiveDismissDisabled(state.isRunningHeavyTask)
		}
		.task {
			state.isRunningHeavyTask = true
			
			await documentHolder.document.autosave()
			state.reloadFileItems()
			
			state.isRunningHeavyTask = false
		}
		.disabled(state.isRunningHeavyTask)
	}
}
