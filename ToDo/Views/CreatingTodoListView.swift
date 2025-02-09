//
//  CreatingTodoListView.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI

struct CreatingTodoListView: View {
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  var body: some View {
    Button("Add New ToDoList") {
      let element = ToDoList.samples.randomElement()
      let _ = `throw`.task {
        try await firebaseManager.addToDoList(element!)
      }
    }
  }
}

#Preview {
  CreatingTodoListView()
}
