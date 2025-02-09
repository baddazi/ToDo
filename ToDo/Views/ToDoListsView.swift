//
//  ToDoListsView.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.

import Foundation
import SwiftUI


struct ToDoListsView: View {
  @Environment(\.user) var user
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  @State var toDoLists: [ToDoList] = []
  var body: some View {
    VStack {
      HStack {
        Spacer()
        NavigationLink(destination: CreatingTodoListView(),
             label: {
          Image(systemName: "plus")
            .padding()
        })
      }
      List(toDoLists) { toDoList in
        ToDoListItem(ToDoListItem: toDoList)
      }
    }
    .onAppear {
      let _ = `throw`.task {
        toDoLists = try await firebaseManager.fetchToDoLists(user.id)
      }
    }
  }
}

#Preview {
  ToDoListsView(toDoLists: ToDoList.samples)
}
