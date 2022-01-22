/**
# LegacyImagePicker: LegacyImagePicker.swift
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
import PhotosUI

@available(iOS, introduced: 15, deprecated: 16, message: "Use PhotosPicker instead")
public struct LegacyImagePicker: UIViewControllerRepresentable
{
	var configuration: PHPickerConfiguration
	var action: ([PHPickerResult]) -> Void
	
	public init(configuration: PHPickerConfiguration, action: @escaping ([PHPickerResult]) -> Void)
	{
		self.configuration = configuration
		self.action = action
	}
	
	public class Coordinator: NSObject, PHPickerViewControllerDelegate, UINavigationControllerDelegate
	{
		var representable: LegacyImagePicker
		
		init(representable: LegacyImagePicker)
		{
			self.representable = representable
		}
		
		public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
		{
			representable.action(results)
		}
	}
	
	public func makeCoordinator() -> Coordinator { Coordinator(representable: self) }
	
	public func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> PHPickerViewController
	{
		let picker = PHPickerViewController(configuration: configuration)
		picker.delegate = context.coordinator
		return picker
	}
	
	public func updateUIViewController(_ viewController: PHPickerViewController, context: UIViewControllerRepresentableContext<Self>)
	{
		context.coordinator.representable = self
	}
}
