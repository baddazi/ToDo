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
          HStack {
            Button {
              toggleFinishItem(item: item)
            } label: {
              Image(systemName: item.isCompleted ? "circle.fill" : "circle")
                .foregroundStyle(item.isCompleted ? .gray : .primary)
            }
            Text(item.title)
              .strikethrough(item.isCompleted, color: .gray)
              .foregroundStyle(item.isCompleted ? .gray : .primary)
          }
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
        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            EditButton()
            NavigationLink("Add Task", destination: CreatingToDoItemView())
            Divider()
            Button("Delete all", role: .destructive, action: { deleteAllItems = true})
          } label: {
            Image(systemName: "ellipsis.circle") // Tři tečky
          }
        }
      }
    }
  }
  
  func toggleFinishItem(item: ToDoItem) {
    `throw`.try {
      guard let index = toDoList.items.firstIndex(of: item)
      else { throw SimpleError("Unable update Task")}
      var item = item
      item.isCompleted.toggle()
      try firebaseManager.toggleFinishToDoItem(toDoList: toDoList, toDoItem: item)
      toDoList.items[index] = item
    }
  }
  
  func onDelete(toDoItemToDelete: ToDoItem) {
    `throw`.try {
      guard let index = toDoList.items.firstIndex(of: toDoItemToDelete)
      else { throw SimpleError("Unable to delete Task")}
      toDoList.items.remove(at: index)
      try firebaseManager.updateToDoList(toDoList: toDoList)
    }
  }
  
  func deleteAllToDoItems() {
    `throw`.try {
      try firebaseManager.updateToDoList(toDoList: toDoList)
      toDoList.items.removeAll()
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
