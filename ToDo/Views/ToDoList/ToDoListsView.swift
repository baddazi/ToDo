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
  @State private var toDoListToDelete: ToDoList?
  var body: some View {
    VStack {
      HStack {
        List {
          ForEach(toDoLists) { toDoList in
            NavigationLink(destination: ToDoListDetailView(toDoList: toDoList, updateToDoList: {_ in fetchToDoLists() }), label: {
              ToDoItemView(ToDoListItem: toDoList)} )
          }
          .onDelete(perform: { item in
            `throw`.try {
              guard let itemToDelete = item.first else { throw SimpleError("Unable to delete ToDoList")}
              toDoListToDelete = self.toDoLists[itemToDelete]
            }
          })
        }
        .refreshable {
           fetchToDoLists()
        }
      }
      .onAppear {
          fetchToDoLists()
      }
      .alert(item: $toDoListToDelete) { toDoListToDelete in
        Alert(title: Text("Delete ToDoList"), message: Text("Are you sure you want to delete \(toDoListToDelete.name)?"), primaryButton: .destructive(Text("Delete")) {
          onDelete(toDoListToDelete: toDoListToDelete)
        }, secondaryButton: .cancel())
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {} ) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
              .padding(.vertical)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            EditButton()
            NavigationLink("Add Task", destination: CreatingTodoListView())
//            Divider()
//            Button("Smazat vše", role: .destructive, action: { deleteAllItems = true})
          } label: {
            Image(systemName: "ellipsis.circle") // Tři tečky
          }
        }
      }
    }
  }
  
  func fetchToDoLists() {
    let _ = `throw`.task {
      toDoLists = try await firebaseManager.fetchToDoLists(userID: user.id)
    }
  }
  
  func onDelete(toDoListToDelete: ToDoList?) {
    let _ = `throw`.task {
      guard let toDoListToDelete else { throw SimpleError("Unable to delete ToDoList") }
      try firebaseManager.deleteToDoList(toDoList: toDoListToDelete)
      toDoLists = try await firebaseManager.fetchToDoLists(userID: user.id)
    }
  }
}
#Preview {
  ToDoListsView(toDoLists: ToDoList.samples)
}
