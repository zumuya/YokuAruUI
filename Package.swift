// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "YokuAruUI",
	platforms: [
		.macOS(.v11),
		.iOS(.v15),
	],
	products: [
		.library(
			name: "YokuAruUI",
			targets: [
				"YokuAruHelpView",
				"YokuAruDocumentPicker",
				"YokuAruShowcaseVideoPlayer",
				"YokuAruUndoRedoButton",
				"YokuAruImagePresenter",
				"AlertStack",
				"LegacyImagePicker",
				"WorkaroundFilePicker",
				"YokuAruUIExtensions",
			]
		),
	],
	dependencies: [
		.package(url: "https://github.com/zumuya/InlineLocalization", from: "1.0.0"),
	],
	targets: [
		.target(
			name: "YokuAruHelpView",
			dependencies: [
				.product(name: "InlineLocalization", package: "InlineLocalization"),
			]
		),
		.target(
			name: "YokuAruDocumentPicker",
			dependencies: [
				.product(name: "InlineLocalization", package: "InlineLocalization"),
			]
		),
		.target(
			name: "YokuAruShowcaseVideoPlayer",
			dependencies: [
				.product(name: "InlineLocalization", package: "InlineLocalization"),
			]
		),
		.target(
			name: "YokuAruImagePresenter",
			dependencies: [
				.product(name: "InlineLocalization", package: "InlineLocalization"),
			]
		),
		.target(
			name: "AlertStack",
			dependencies: [
				.product(name: "InlineLocalization", package: "InlineLocalization"),
			]
		),
		.target(name: "YokuAruUndoRedoButton"),
		
		.target(name: "LegacyImagePicker"),
		.target(name: "WorkaroundFilePicker"),
		.target(name: "YokuAruUIExtensions"),
	]
)
