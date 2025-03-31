//
//  ToDoListDetailView.swift
//  ToDo
//
//  Created by David Záruba on 18.03.2025.
//

import SwiftUI

struct ToDoListDetailView: View {
  @State var toDoList: ToDoList
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  
  var updateToDoList: (ToDoList) -> Void
  @State var toDoItemtoDelete: ToDoItem?
  @State var deleteAllItems = false
  
  var body: some View {
    VStack {
      List {
        ForEach($toDoList.items) { $item in
          Text(item.title)
        }
        .onDelete(perform: { item in
          `throw`.try {
            guard let itemToDelete = item.first else { throw SimpleError("Unable to delete Task")}
            toDoItemtoDelete = toDoList.items[itemToDelete]
          }
        })
        .onMove(perform: moveItem)
        .refreshable {
          fetchToDoList()
        }
        .onAppear {
          fetchToDoList()
        }
        .alert(item: $toDoItemtoDelete) { toDoItemtoDelete in
          Alert(title: Text("Delete Task"), message: Text("Are you sure you want to delete \(toDoItemtoDelete.title)?"), primaryButton: .destructive(Text("Delete")) {
            onDelete(toDoItemToDelete: toDoItemtoDelete)
          }, secondaryButton: .cancel())
        }
        .alert(isPresented:  $deleteAllItems) {
          Alert(title: Text("Delete all tasks"), message: Text("Are you sure you want to delete all tasks?"), primaryButton: .destructive(Text("Delete")) {
            deleteAllToDoItems()
          }, secondaryButton: .cancel())
        }
      }
      .navigationTitle(toDoList.name)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            EditButton()
            NavigationLink("Add Task", destination: CreatingToDoItemView())
            Divider()
            Button("Smazat vše", role: .destructive, action: { deleteAllItems = true})
          } label: {
            Image(systemName: "ellipsis.circle") // Tři tečky
          }
        }
      }
    }
  }
  
  func onDelete(toDoItemToDelete: ToDoItem) {
    var temp = toDoList
    `throw`.try {
      guard let index = temp.items.firstIndex(of: toDoItemToDelete)
      else { throw SimpleError("Unable to delete Task")}
      temp.items.remove(at: index)
      try firebaseManager.updateToDoList(toDoList: temp)
      toDoList = temp
    }
  }
  
  func deleteAllToDoItems() {
    var temp = toDoList
    temp.items.removeAll()
    `throw`.try {
      try firebaseManager.updateToDoList(toDoList: temp)
      toDoList = temp
    }
  }
  
  func fetchToDoList() {
    updateToDoList(toDoList)
  }
  
  func moveItem(from source: IndexSet, to destination: Int) {
    toDoList.items.move(fromOffsets: source, toOffset: destination)
    
    for i in 0..<toDoList.items.count {
      toDoList.items[i].order = i
    }
    `throw`.try {
      try firebaseManager.updateToDoList(toDoList: toDoList)
    }
  }
}

#Preview {
  ToDoListDetailView(toDoList: .sample, updateToDoList: {_ in})
}
