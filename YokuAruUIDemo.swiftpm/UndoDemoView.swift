import SwiftUI
import YokuAruUndoRedoButton
import UIKit

class UndoableModel: ObservableObject
{
	let undoManager = UndoManager()
	
	@Published var value = 0.5
	{
		didSet {
			if !undoManager.isUndoing {
				undoManager.setActionName("Changing Value")
			}
			
			undoManager.registerUndo(withTarget: self) {
				$0.value = oldValue
			}
		}
	}
}

struct UndoDemoView: View
{
	@StateObject private var undoableModel = UndoableModel()
	@State private var undoRedoButtonIsCompact = false
	
	var body: some View
	{
		Form {
			Section("Values") {
				Slider(value: $undoableModel.value, in: 0...1) { isEditing in
					if isEditing {
						undoableModel.undoManager.beginUndoGrouping()
					} else {
						undoableModel.undoManager.endUndoGrouping()
					}
				}
			}
			Section("Options") {
				Toggle(isOn: $undoRedoButtonIsCompact) {
					Text("Compact Undo Button")
				}
			}
		}
		.navigationTitle("Undo Redo Button")
		.toolbar {
			ToolbarItem {
				UndoRedoButton(
					undoManager: undoableModel.undoManager,
					isCompact: $undoRedoButtonIsCompact
				)
			}
		}
	}
}
