// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import AppleProductTypes

let package = Package(
	name: "YokuAruUIDemo",
	platforms: [
		.iOS(.v15)
	],
	products: [
		.iOSApplication(
			name: "YokuAruUIDemo",
			targets: ["YokuAruUIDemo"],
			bundleIdentifier: "com.zumuya.YokuAruUIDemo",
			displayVersion: "1.0",
			bundleVersion: "1",
			appIcon: .placeholder(icon: .box),
			accentColor: .presetColor(.indigo),
			supportedDeviceFamilies: [
				.pad, .phone, .mac,
			],
			supportedInterfaceOrientations: [
				.portrait,
				.landscapeRight,
				.landscapeLeft,
				.portraitUpsideDown(.when(deviceFamilies: [.pad])),
			]
		),
	],
	dependencies: [
		.package(name: "YokuAruUI", path: "../"),
	],
	targets: [
		.executableTarget(
			name: "YokuAruUIDemo",
			dependencies: ["YokuAruUI"],
			path: "."
		),
	]
)
