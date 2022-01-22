/**
# YokuAruImagePresenter: ImagePresenter.swift
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
import SwiftUI
import UIKit
import InlineLocalizationUI

fileprivate class ImagePresenterViewController: UIViewController, UIScrollViewDelegate
{
	public var image: UIImage?
	{
		didSet {
			guard (image != oldValue) else { return }
			
			imageView.image = image
			imageView.frame = .init(origin: .zero, size: image?.size ?? .zero)
			view.setNeedsLayout()
		}
	}
	let imageView = UIImageView()
	let scrollView = UIScrollView()
	
	init()
	{
		super.init(nibName: nil, bundle: nil)
		
		imageView.translatesAutoresizingMaskIntoConstraints = true
		
		scrollView.delegate = self
		scrollView.maximumZoomScale = 20
		scrollView.minimumZoomScale = 1
		scrollView.bouncesZoom = true
		scrollView.contentInset = .init(top: 20, left: 20, bottom: 20, right: 20)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.overrideUserInterfaceStyle = .light

		self.view = scrollView

		let recognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewDidDoubleTap(_:)))
		recognizer.numberOfTapsRequired = 2
		scrollView.addGestureRecognizer(recognizer)
		
		scrollView.addSubview(imageView)
	}
	required init?(coder: NSCoder) { fatalError() }
	
	//MARK: - Scroll View Delegate
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
	
	func scrollViewDidZoom(_ scrollView: UIScrollView)
	{
		updateContentInset()
	}
	
	//MARK: - Gesture
	
	@objc func imageViewDidDoubleTap(_ sender: UITapGestureRecognizer)
	{
		let imageBounds = imageView.bounds
		let scrollViewBounds = scrollView.bounds
		guard (imageBounds.width > 0), (scrollViewBounds.width > 0) else { return }
		
		if (scrollView.zoomScale == scrollView.minimumZoomScale) {
			let tapPoint = sender.location(in: imageView)
			
			let size = CGSize(
				width: (imageBounds.width / 3),
				height: (imageBounds.height / 3)
			)
			scrollView.zoom(to: .init(
				x: (tapPoint.x - (size.width * 0.5)),
				y: (tapPoint.y - (size.height * 0.5)),
				width: size.width,
				height: size.height
			), animated: true)
		} else {
			scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
		}
	}
	
	//MARK: - Layout
	
	var lastLayoutCondition: LayoutCondition?
	struct LayoutCondition: Equatable
	{
		var imageSize: CGSize
		var scrollViewSize: CGSize
	}
	
	let preferredContentInset: CGFloat = 20
	override func viewWillLayoutSubviews()
	{
		super.viewWillLayoutSubviews()
		
		let scrollViewBounds = scrollView.bounds
		let imageSize = image?.size ?? .zero
		let layoutCondition = LayoutCondition(
			imageSize: imageSize,
			scrollViewSize: scrollViewBounds.size
		)
		guard (lastLayoutCondition != layoutCondition) else { return }
		lastLayoutCondition = layoutCondition
		
		scrollView.contentSize = imageSize
		
		guard
			(scrollViewBounds.width > (preferredContentInset * 2)),
			(scrollViewBounds.height > (preferredContentInset * 2))
		else { return }
		
		let scrollContentAreaRect = scrollViewBounds.insetBy(dx: preferredContentInset, dy: preferredContentInset)
		
		if (imageSize.width > 0), (imageSize.height > 0) {
			if ((imageSize.width / imageSize.height) > (scrollViewBounds.width / scrollViewBounds.height)) {
				//yoko-naga
				scrollView.minimumZoomScale = (scrollContentAreaRect.width / max(1, imageSize.width))
			} else {
				scrollView.minimumZoomScale = (scrollContentAreaRect.height / max(1, imageSize.height))
			}
		} else {
			scrollView.minimumZoomScale = 1
		}
		scrollView.zoomScale = scrollView.minimumZoomScale
		
		updateContentInset()
	}
	func updateContentInset()
	{
		let imageSize = image?.size ?? .zero
		let scrollViewBounds = scrollView.bounds
		let scrollContentAreaRect = scrollViewBounds.insetBy(dx: preferredContentInset, dy: preferredContentInset)
		guard !scrollContentAreaRect.isNull else {
			scrollView.contentInset = .zero
			return
		}
		let scaledImageSize = CGSize(
			width: (imageSize.width * scrollView.zoomScale),
			height: (imageSize.height * scrollView.zoomScale)
		)
		scrollView.contentInset = {
			let horizontal = max(0, (preferredContentInset + ((scrollContentAreaRect.width - scaledImageSize.width) * 0.5)))
			let vertical = max(0, (preferredContentInset + ((scrollContentAreaRect.height - scaledImageSize.height) * 0.5)))
			return .init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
		}()
	}
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		
		scrollView.zoomScale = scrollView.minimumZoomScale
	}
}

fileprivate struct ImagePresenterWrapping: UIViewControllerRepresentable
{
	@Binding var image: UIImage?
	
	func makeUIViewController(context: Context) -> ImagePresenterViewController { .init() }
	
	func updateUIViewController(_ controller: ImagePresenterViewController, context: Context)
	{
		controller.image = image
	}
}
public struct ImagePresenter: View
{
	@Environment(\.dismiss) private var dismiss
	@Binding var image: UIImage?
	
	public init(image: Binding<UIImage?>)
	{
		_image = image
	}
	
	public var body: some View
	{
		ImagePresenterWrapping(image: $image)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						dismiss()
					} label: {
						Text(localizedIn: [.japanese: "閉じる", .english: "Close"])
					}
				}
			}
	}
}
