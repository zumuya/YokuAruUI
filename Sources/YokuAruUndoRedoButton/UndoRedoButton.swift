/**
# YokuAruUndoRedoButton: UndoRedoButton.swift
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
import Combine

public struct UndoRedoButton: View
{
	var undoManager: UndoManager
	@State private var changeThisToCauseReload = UUID()
	@Binding var isCompact: Bool
	
	public init(undoManager: UndoManager, isCompact: Binding<Bool>)
	{
		self.undoManager = undoManager
		_isCompact = isCompact
	}
	
	public var body: some View
	{
		HStack(spacing: 4) {
			if isCompact {
				if undoManager.canUndo {
					Menu {
						undoMenuContent(undoManager: undoManager)
					} label: {
						Image(systemName: "arrow.uturn.backward.circle")
					} primaryAction: {
						withAnimation(.easeOut(duration: 0.2)) {
							undoManager.undo()
						}
					}
				} else {
					Menu {
						undoMenuContent(undoManager: undoManager)
					} label: {
						Image(systemName: "arrow.uturn.backward.circle")
					}
					.disabled([undoManager.canUndo, undoManager.canRedo].allSatisfy { $0 == false })
				}
			} else {
				Button {
					withAnimation(.easeOut(duration: 0.2)) {
						undoManager.undo()
					}
				} label: { Image(systemName: "arrow.uturn.backward") }
				.disabled(!undoManager.canUndo)
			
				Button {
					withAnimation(.easeOut(duration: 0.2)) {
						undoManager.redo()
					}
				} label: { Image(systemName: "arrow.uturn.forward") }
				.disabled(!undoManager.canRedo)
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidUndoChange, object: undoManager)) { _ in
			changeThisToCauseReload = .init()
		}
		.onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerDidRedoChange, object: undoManager)) { _ in
			changeThisToCauseReload = .init()
		}
	}
	
	@ViewBuilder func undoMenuContent(undoManager: UndoManager) -> some View
	{
		Button {
			withAnimation(.easeOut(duration: 0.2)) {
				undoManager.undo()
				changeThisToCauseReload = .init()
			}
		} label: {
			Label((undoManager.undoMenuItemTitle), systemImage: "arrow.uturn.backward")
		}
		.disabled(!undoManager.canUndo)
		
		Button {
			withAnimation(.easeOut(duration: 0.2)) {
				undoManager.redo()
				changeThisToCauseReload = .init()
			}
		} label: {
			Label((undoManager.redoMenuItemTitle), systemImage: "arrow.uturn.forward")
		}
		.disabled(!undoManager.canRedo)
	}
}
