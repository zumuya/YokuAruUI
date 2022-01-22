/**
# YokuAruDocumentPicker: PickableDocument.swift
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

import Foundation
import UniformTypeIdentifiers
import UIKit
import InlineLocalization

@MainActor
public protocol PickableDocument
{
	//MARK: - UIDocument Methods
	
	init(fileUrl: URL)
	var fileURL: URL { get }
	@discardableResult func open() async -> Bool
	@discardableResult func autosave() async -> Bool
	@discardableResult func close() async -> Bool
	@discardableResult func save(to fileUrl: URL, for purpose: UIDocument.SaveOperation) async -> Bool
	func presentedItemDidMove(to fileUrl: URL)
	
	//MARK: - Informational Methods
	
	nonisolated static var utType: UTType { get }
	static var pickerTitle: [Language: String] { get }
	static func previewUrl(forFileUrl: URL) -> URL?
	static var previewPlaceholderWidthPerHeight: CGFloat { get }
	
	/// Returns file content is empty.
	/// When this method returns `true`, file will be deleted without user confirmation.
	static func isEmptyDocument(at fileUrl: URL) -> Bool
	
	//MARK: - Optional Methods
	
	static func makeNewDocument() -> Self
	nonisolated static var newFileUrl: URL { get }
	nonisolated static var newFileBaseName: [Language: String] { get }
}
extension PickableDocument
{
	public static func makeNewDocument() -> Self
	{
		let document = Self(fileUrl: newFileUrl)
		Task {
			let isSaveSuccessed = await document.save(to: document.fileURL, for: .forCreating)
			print("firstSave: \(isSaveSuccessed)")
		}
		return document
	}
	
	public nonisolated static var newFileBaseName: [Language: String] { [.japanese: "名称未設定", .english: "Untitled"] }
	public nonisolated static var newFileUrl: URL
	{
		let fileManager = FileManager.default
		let documentFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		
		let untitled = String(localizedIn: newFileBaseName)!
		
		var i = 1
		while true {
			let url = documentFolder
				.appendingPathComponent(untitled + " \(i)")
				.appendingPathExtension(for: Self.utType)
			if !fileManager.fileExists(atPath: url.path) {
				return url
			}
			i += 1
		}
	}
}

@MainActor
public protocol PickableDocumentHolder: ObservableObject
{
	var document: Document { get set }
	
	associatedtype Document: PickableDocument
}
