//
//  CreatingTodoListView.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI

struct CreatingTodoListView: View {
  @Environment(\.firebaseManager) var firebaseManager
  var body: some View {
    Button("Add New ToDoList") {
      let element = ToDoList.samples.randomElement()
      Task {
        try? await firebaseManager.addToDoList(element!)
      }
    }
    }
}

#Preview {
    CreatingTodoListView()
}
