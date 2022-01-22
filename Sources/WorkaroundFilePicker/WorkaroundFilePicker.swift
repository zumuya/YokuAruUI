/**
# WorkaroundFilePicker: WorkaroundFilePicker.swift
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

import UIKit
import SwiftUI
import UniformTypeIdentifiers

/// View to select files
///
/// This is a WORKAROUND.
/// `.fileImporter()` modifier provides same function.
/// However, it stops working when user dismiss with swipe gesuture or tapping outside on iOS 15.
/// https://stackoverflow.com/questions/66965471/swiftui-fileimporter-modifier-not-updating-binding-when-dismissed-by-tapping

public struct FilePicker: UIViewControllerRepresentable
{
	var allowedContentTypes: [UTType]
	var allowsMultipleSelection: Bool
	var action: ([URL]) -> Void
	
	public init(allowedContentTypes: [UTType], allowsMultipleSelection: Bool, action: @escaping ([URL]) -> Void)
	{
		self.allowedContentTypes = allowedContentTypes
		self.allowsMultipleSelection = allowsMultipleSelection
		self.action = action
	}
	
	public class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate
	{
		var representable: FilePicker
		
		init(representable: FilePicker)
		{
			self.representable = representable
		}
		
		public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL])
		{
			representable.action(urls)
		}
	}
	
	public func makeCoordinator() -> Coordinator { Coordinator(representable: self) }
	
	public func makeUIViewController(context: UIViewControllerRepresentableContext<FilePicker>) -> UIDocumentPickerViewController
	{
		let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
		picker.delegate = context.coordinator
		picker.allowsMultipleSelection = allowsMultipleSelection
		return picker
	}
	
	public func updateUIViewController(_ viewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePicker>)
	{
		context.coordinator.representable = self
	}
}
