/**
# YokuAruDocumentPicker: DocumentPickerFileButton.swift
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

enum FileButtonContent
{
	case new
	case file(DocumentPickerFileItem)
}

struct FileButtonBase: View
{
	static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .none
		return dateFormatter
	}()
	
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.colorSchemeContrast) private var colorSchemeContrast
	@Environment(\.pixelLength) private var pixelLength
	
	@Binding var content: FileButtonContent
	@Binding var isOpened: Bool
	var placeholderWidthPerHeight: CGFloat
	var action: () -> Void
	
	var body: some View
	{
		Button { action() } label: {
			VStack(spacing: 4) {
				//Color.gray
				Group {
					let cornerRadius: CGFloat = 6
					switch content {
					case .file(let item):
						AsyncImage(url: item.previewUrl) { image in
							image
								.interpolation(.high)
								.resizable()
								.scaledToFit()
						} placeholder: {
							Color.gray
								.aspectRatio(placeholderWidthPerHeight, contentMode: .fit)
						}
						.cornerRadius(cornerRadius)
						.brightness(isOpened ? ((colorScheme == .light) ? -0.2 : -0.3) : 0)
						.shadow(color: .init(white: 0, opacity: 0.2), radius: 4, x: 0, y: 1)
						.background {
							RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
								.inset(by: -pixelLength).fill(Color.black.opacity(0.2))
						}
						.overlay {
							if (colorScheme == .light) {
								let isHighContrast = (colorSchemeContrast == .increased)
								if isOpened || isHighContrast {
									RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
										.strokeBorder(lineWidth: (isOpened ? 4 : isHighContrast ? 1 : pixelLength))
										.foregroundColor(Color(white: 0, opacity: (isOpened ? 1 : isHighContrast ? 1 : 0.2)))
								}
							}
						}
					case .new:
						RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
							.fill(Color.primary.opacity(0.05))
							.aspectRatio(placeholderWidthPerHeight, contentMode: .fit)
							.overlay {
								GeometryReader { geometryProxy in
									Image(systemName: "plus")
										.resizable()
										.scaledToFit()
										.frame(width: min(geometryProxy.size.width, geometryProxy.size.height) * 0.5)
										.frame(width: geometryProxy.size.width, height: geometryProxy.size.height)
								}
							}
					}
				}
				.padding(.horizontal, 4)
				.frame(alignment: .bottom)
				.padding(.bottom, 4)
				
				Group {
					switch content {
					case .file(let item):
						Text(item.name)
							.tint(isOpened ? Color(UIColor.systemBackground) : .primary)
					case .new:
						Text(localizedIn: [.japanese: "新規", .english: "New"])
					}
				}
					.minimumScaleFactor(0.5)
					.background {
						RoundedRectangle(cornerRadius: 6, style: .continuous)
							.fill(isOpened ? Color.primary : .clear)
							.padding(.horizontal, -6)
							.padding(.vertical, -2)
					}
				let date: Date? = {
					switch content {
					case .file(let item):
						return item.modificationDate
					case .new:
						return nil
					}
				}()
				Text(date.map { Self.dateFormatter.string(from: $0) } ?? " ")
					.font(.caption)
					.tint(.secondary)
			}
		}
		.alignmentGuide(VerticalAlignment.center) { dimensions in
			dimensions[VerticalAlignment.firstTextBaseline]
		}
	}
}
struct FileButton<Document, DocumentHolder: PickableDocumentHolder>: View where DocumentHolder.Document == Document
{
	@Binding var item: DocumentPickerFileItem
	@Binding var isOpened: Bool
	@State private var isAskingDelete = false
	
	@ObservedObject var documentPickerState: DocumentPickerState<Document>
	@ObservedObject var documentHolder: DocumentHolder
	
	var dismiss: DismissAction
	
	var body: some View
	{
		FileButtonBase(
			content: .constant(.file(item)),
			isOpened: $isOpened,
			placeholderWidthPerHeight: Document.previewPlaceholderWidthPerHeight,
			action: {
				documentPickerState.performHeavyOperationIfPossible {
					if !isOpened {
						await documentHolder.document.close()
						
						let newDocument = Document(fileUrl: item.url)
						await newDocument.open()
						
						var transaction = Transaction()
						transaction.disablesAnimations = true
						withTransaction(transaction) {
							documentHolder.document = newDocument
						}
					}
					dismiss()
				}
			}
		)
			.contextMenu {
				Section {
					Button {
						documentPickerState.renamingFileItem = item
					} label: {
						Label(
							String(localizedIn: [.japanese: "名称変更…", .english: "Rename…"])!,
							systemImage: "pencil"
						)
					}
					Button {
						documentPickerState.performHeavyOperationIfPossible {
							do {
								let fileManager = FileManager.default
								let filenameWithoutExtension = item.url.deletingPathExtension().lastPathComponent
								var i = 0
								while true {
									let duplicatedUrl = item.url.deletingLastPathComponent()
										.appendingPathComponent("\(filenameWithoutExtension) \(i + 2)")
										.appendingPathExtension(Document.utType.preferredFilenameExtension!)
									
									if !fileManager.fileExists(atPath: duplicatedUrl.path) {
										try fileManager.copyItem(at: item.url, to: duplicatedUrl)
										
										await documentHolder.document.close()
										let document = Document(fileUrl: duplicatedUrl)
										await document.open()
										
										documentHolder.document = document
										documentPickerState.reloadFileItems()
										break //while loop
									}
									i += 1
								}
							} catch { }
						}
					} label: {
						Label(
							String(localizedIn: [.japanese: "複製", .english: "Duplicate"])!,
							systemImage: "plus.square.on.square"
						)
					}
				}
				Section {
					Button(role: .destructive) {
						if item.isEmpty {
							documentPickerState.performHeavyOperationIfPossible {
								//wait context menu animation ends
								try? await Task.sleep(nanoseconds: .init(0.5 * 1_000_000_000))
								
								await delete()
							}
						} else {
							isAskingDelete = true
						}
					} label: {
						Label(
							String(localizedIn: [.japanese: "削除", .english: "Delete"])! + (item.isEmpty ? "" : "…"),
							systemImage: "trash"
						)
					}
					.disabled(documentPickerState.fileItems.count <= 1)
				}
			}
			.transition(.opacity)
			.alert(
				Text(localizedIn: [
					.japanese: "作業状態“\(item.name)”を削除してもよろしいですか?",
					.english: "Are you sure you want to delete workspace “\(item.name)”?"
				]), isPresented: $isAskingDelete) {
					Button(role: .destructive) {
						documentPickerState.performHeavyOperationIfPossible {
							await delete()
						}
					} label: {
						Text(localizedIn: [
							.japanese: "削除",
							.english: "Delete"
						])
					}
				} message: {
					Text(localizedIn: [
						.japanese: "この操作は取り消しできません。",
						.english: "You can not undo this operation."
					])
				}
	}
	@MainActor func delete() async
	{
		let fileManager = FileManager.default
		do {
			if isOpened {
				guard let i = documentPickerState.fileItems.firstIndex(where: { $0.url == item.url }) else { return }
				
				await documentHolder.document.close()
				
				let newDocument: Document
				if (documentPickerState.fileItems.count > 1) {
					switch i {
					case (documentPickerState.fileItems.count - 1):
						newDocument = .init(fileUrl: documentPickerState.fileItems[i - 1].url)
						await newDocument.open()
					default:
						newDocument = .init(fileUrl: documentPickerState.fileItems[i + 1].url)
						await newDocument.open()
					}
				} else {
					return
				}
				documentHolder.document = newDocument
			}
			try fileManager.removeItem(at: item.url)
			withAnimation {
				if let i = documentPickerState.fileItems.firstIndex(where: { $0.url == item.url }) {
					documentPickerState.fileItems.remove(at: i)
				}
			}
		} catch {
			
		}
	}
}
