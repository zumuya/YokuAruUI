/**
# YokuAruHelpView: StepsDescriptionFigure.swift
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

public struct StepsDescriptionFigure: View
{
	public struct Step: Identifiable
	{
		public init(systemName: String, description: [Language : String])
		{
			self.systemName = systemName
			self.description = description
		}
		
		public var systemName: String
		public var description: [Language: String]
		
		public var id: String { systemName }
	}
	
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	var isCompact: Bool { horizontalSizeClass == .compact }
	
	var steps: [Step]
	
	public init(steps: [StepsDescriptionFigure.Step])
	{
		self.steps = steps
	}
	
	@ViewBuilder func stepView(for step: Step) -> some View
	{
		VStack(spacing: (isCompact ? 12 : 16)) {
			Image(systemName: step.systemName)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(.accentColor)
				.frame(width: (isCompact ? 42 : 60), height: (isCompact ? 42 : 60))
			
			Text(localizedIn: step.description)
				.multilineTextAlignment(.center)
		}
		.frame(minWidth: (isCompact ? 90 : 140))
	}
	
	public var body: some View
	{
		HStack(alignment: .firstTextBaseline) {
			ForEach(steps) {
				stepView(for: $0)
			}
		}
		.frame(width: 200, alignment: .center)
		.padding(.vertical, 20)
		.padding(.horizontal, 8) //sometime it has background
	}
}
