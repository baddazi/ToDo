//
//  RecentlyDeleted.swift
//  ToDo
//
//  Created by David Záruba on 28.06.2025.
//

import SwiftUI

struct RecentlyDeletedView: View {
  @Environment(\.user) var user
  @Environment(\.editMode) private var editMode
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  
  @State private var todoLists: [TodoList] = []
  @State private var selection = Set<TodoList.ID>()
  @State private var isTodoListDeleted = false
  @State private var isTodoListRestored = false
  @State private var todoListToDelete: TodoList?
  @State private var todoListToRestore: TodoList?
  @State private var searchText: String = ""
  
  //  @State private var editMode: EditMode = .inactive
  var body: some View {
    VStack {
      list
    }
    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    .onAppear {
      fetchTodoLists()
    }
  }
  
  func searchedTodoLists() -> [TodoList] {
    if searchText.isEmpty {
      return todoLists
    } else {
      return todoLists.filter {
        $0.name.lowercased().contains(searchText.lowercased())
      }
    }
  }
  
  private var list: some View {
    List(selection: $selection) {
      Section {
        Text("todoList are kept for 30 days. After that, they will be permanently deleted.")
          .font(.footnote)
          .foregroundColor(.gray)
          .listRowBackground(Color.clear) // žádné pozadí
          .listRowInsets(EdgeInsets())
      }
      
      ForEach(searchedTodoLists()) { list in
        NavigationLink(destination: TodoListDetailView(todoList: list), label: {
            TodoListItemView(todoListItem: list)
        })
          .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
              withAnimation {
                todoListToRestore = list
                isTodoListRestored = true
              }
            } label: {
              Label("Restore", systemImage: "folder")
            }
            .tint(.blue)
            
            Button(role: .destructive) {
              todoListToDelete = list
              isTodoListDeleted = true
            } label: {
              Label("Delete", systemImage: "trash")
            }
          }
      }
    }
    .navigationTitle("Recently Deleted")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        EditButton()
      }
    }
    .overlay(
      editingButtons,
      alignment: .bottom
    )
    .confirmationDialog("Are you sure you want to restore selected todoLists?",
                        isPresented: $isTodoListRestored,
                        titleVisibility: .visible) {
      Button("Restore") {
        if let todoListToRestore: TodoList = todoListToRestore {
          restore(todoListsToRestore: [todoListToRestore])
        } else {
          restoreSelected()
        }
      }
      Button("Cancel", role: .cancel) {}
    }
    .confirmationDialog("Are you sure you want to delete the selected todoLists permanently?",
                        isPresented: $isTodoListDeleted,
                        titleVisibility: .visible) {
      Button("Delete", role: .destructive) {
        if let todoListToDelete: TodoList = todoListToDelete {
          delete(todoListsToDelete: [todoListToDelete])
        } else {
          deleteSelected()
        }
      }
      Button("Cancel", role: .cancel) {}
    }
    
  }
  
  private var editingButtons: some View {
    return HStack {
      if editMode?.wrappedValue.isEditing == true {
        Button("Restore") {
          isTodoListRestored = true
        }
        .disabled(selection.isEmpty)
        .padding()
        Spacer()
        Button("Delete", role: .destructive) {
          isTodoListDeleted = true
        }
        .disabled(selection.isEmpty)
        .padding()
      }
    }
  }
  
  private func fetchTodoLists() {
    let _ = `throw`.task {
      todoLists = try await firebaseManager.fetchTodoListRecentlyDeleted(userID: user.id)
    }
  }
  
  private func delete(todoListsToDelete: [TodoList]) {
    let _ = `throw`.task {
      try await firebaseManager.batchDeleteTodoLists(todoLists: todoListsToDelete)
      todoListToDelete = nil
      selection.removeAll()
      fetchTodoLists()
    }
  }
  
  private func restore(todoListsToRestore: [TodoList]) {
    let _ = `throw`.task {
      let todoLists = todoListsToRestore.map({
        var todoList = $0
        todoList.markedToDelete = nil
        return todoList
      })
      try await firebaseManager.batchUpadteTodoLists(todoLists: todoLists)
      todoListToRestore = nil
      selection.removeAll()
      fetchTodoLists()
    }
  }
  
  private func deleteSelected() {
    let selectedTodoLists = todoLists.filter({ selection.contains($0.id) })
    delete(todoListsToDelete: selectedTodoLists)
  }
  
  private func restoreSelected() {
    let selectedTodoList = todoLists.filter({
      selection.contains($0.id) })
    restore(todoListsToRestore: selectedTodoList)
    }
}

#Preview {
  RecentlyDeletedView()
}
