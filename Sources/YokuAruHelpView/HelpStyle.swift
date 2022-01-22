/**
# YokuAruHelpView: HelpStyle.swift
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
import InlineLocalizationUI

public class HelpStyle
{
	public init() {}
	
	open func h1(@ViewBuilder _ contents: () -> Text) -> some View
	{
		HStack {
			Spacer()
			
			contents()
				.font(.system(size: 32))
				.padding(.vertical, 20)
			
			Spacer()
		}
	}
	open func h2(@ViewBuilder _ contents: () -> Text) -> some View
	{
		contents()
			.fontWeight(SwiftUI.Font.Weight.bold)
			.font(.system(size: 22))
			.padding(.top, 36)
			.padding(.bottom, 16)
	}
	open func p<V: View>(@ViewBuilder _ contents: () -> V) -> some View
	{
		Group {
			contents()
		}
		.font(.body)
		.padding(.vertical, 8)
	}
	
	@ViewBuilder open func ul(texts: [[Language: String]]) -> some View
	{
		VStack(alignment: .leading, spacing: 8) {
			ForEach(0..<texts.count, id: \.self) { i in
				let text = texts[i]
				HStack(spacing: 0) {
					Text(verbatim: "・")
					Text(localizedIn: text)
				}
				.font(.body)
			}
		}
		.padding(.top, 20)
		.padding(.leading, 20)
		.padding(.bottom, 20)
	}
}
