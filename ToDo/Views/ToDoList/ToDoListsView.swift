//
//  todoListsView.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.

import Foundation
import SwiftUI

struct TodoListsView: View {
  @Environment(\.user) var user
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  @Environment(\.editMode) private var editMode
  @Environment(\.scenePhase) private var scenePhase
  
  @State var todoLists: [TodoList] = []
  @State private var isFilterPresented = false
  @State private var sortingType: SortingType = .priorityIncreasing
  @State private var edit: EditMode = .inactive
  @State private var activeFilter: Filter?
  @State private var completedTodoList: CompletedTodoList = .both
  @State private var searchText: String = ""
  @State private var isLoading: Bool = true
  
  var body: some View {
    VStack {
        list
    }
    .navigationTitle("Todo lists")
    .searchable(text: $searchText)
    .onAppear {
      deleteTodoListMarkToDelete()
      edit = .inactive
      fetchTodoLists()
      isLoading = false
    }
    .sheet(isPresented: $isFilterPresented, content: {
      FilterView(todoLists: todoLists, boundaries: Filter(todoLists: todoLists), activeFilter: $activeFilter, currentFilter: activeFilter ?? Filter(todoLists: todoLists), completedTodoListActive: $completedTodoList, completedTodoList: completedTodoList)
    })
    .onChange(of: sortingType) {
        withAnimation {
          sort()
        }
      }
      .toolbar {
        if edit == .active {
          ToolbarItem(placement: .navigationBarTrailing)
          {
            Button("Done") {
              withAnimation {
                edit = .inactive
              }
            }
          }
        }
        else {
          ToolbarItem(placement: .topBarTrailing) {
            sortingMenu
          }
          ToolbarItem(placement: .topBarTrailing) {
            Button(action: { isFilterPresented = true } ) {
              Image(systemName: activeFilter != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .padding(.vertical)
            }
          }
          ToolbarItem(placement: .topBarTrailing) {
            moreMenu
          }
        }
      }
  }
  
  private var moreMenu: some View {
    Menu {
      Button("Edit") {
        withAnimation {
          edit = .active
        }
      }
      NavigationLink("Add Todo List", destination:
                      CreatingTodoListView()
        .environment(\.user, user)
        .environment(\.throw, `throw`))
      NavigationLink("Recently deleted", destination:
                      RecentlyDeletedView()
       .environment(\.user, user)
       .environment(\.throw, `throw`))
      NavigationLink("Settings", destination:
                      SettingsView()
        .environment(\.throw, `throw`))
    } label: {
      Image(systemName: "ellipsis.circle")
    }
  }
  
  @ViewBuilder
  private var list: some View {
    List {
      ForEach(searchedTodoLists(todoLists: filterTodoLists())) { todoList in
        NavigationLink(destination: TodoListDetailView(todoList: todoList), label: {
            TodoListItemView(todoListItem: todoList)
        })
      }
      .onDelete(perform: { index in
        `throw`.try {
          guard let itemToDelete = index.first else { throw SimpleError("Unable to delete todoList")}
          deleteTodoList(todoListToDelete: todoLists[itemToDelete])
        }
      })
    }
    .refreshable {
      fetchTodoLists()
    }
    .environment(\.editMode, $edit)
  }
  
  private var sortingMenu: some View {
    Menu {
      sortingButton(title: "Sort by Priority (Ascending)", type: .priorityIncreasing)
      sortingButton(title: "Sort by Priority (Descending)", type: .priorityDecreasing)
      sortingButton(title: "Sort by Creation Date (Oldest First)", type: .createdAtIncreasing)
      sortingButton(title: "Sort by Creation Date (Newest First)", type: .createdAtDecreasing)
      sortingButton(title: "Sort by Due Date (Earliest First)", type: .dueDateIncreasing)
      sortingButton(title: "Sort by Due Date (Latest First)", type: .dueDateDecreasing)
      sortingButton(title: "Sort by Last Updated (Oldest First)", type: .updatedAtIncreasing)
      sortingButton(title: "Sort by Last Updated (Newest First)", type: .updatedAtDecreasing)
    } label: {
      Image(systemName: "arrow.up.arrow.down")
        .padding(.vertical)
    }
  }
  
  @ViewBuilder
  private func sortingButton(title: String, type: SortingType) -> some View {
    Button(action: { sortingType = type }) {
      HStack {
        Text(title)
        Spacer()
        if sortingType == type {
          Image(systemName: "checkmark")
        }
      }
    }
  }
  
  private func deleteTodoListMarkToDelete() {
    let _ = `throw`.task {
     try await firebaseManager.deleteTodoListAfterXDays(userID: user.id, days: countOfDayToDeleteTodoList)
    }
  }
  
  func sort() {
      switch sortingType {
      case .priorityIncreasing:
        todoLists.sort { $0.priority < $1.priority }
      case .priorityDecreasing:
        todoLists.sort { $0.priority > $1.priority }
      case .createdAtIncreasing:
        todoLists.sort { $0.createdAt < $1.createdAt }
      case .createdAtDecreasing:
        todoLists.sort { $0.createdAt > $1.createdAt }
      case .dueDateIncreasing:
        todoLists.sort {
          let dueDate1 = $0.dueDate ?? Date.distantFuture
          let dueDate2 = $1.dueDate ?? Date.distantFuture
          return dueDate1 < dueDate2
        }
      case .dueDateDecreasing:
        todoLists.sort {
          let dueDate1 = $0.dueDate ?? Date.distantPast
          let dueDate2 = $1.dueDate ?? Date.distantPast
          return dueDate1 > dueDate2
        }
      case .updatedAtIncreasing:
        todoLists.sort { $0.updatedAt < $1.updatedAt }
      case .updatedAtDecreasing:
        todoLists.sort { $0.updatedAt > $1.updatedAt }
      }
  }
  
  func fetchTodoLists() {
    let _ = `throw`.task {
      todoLists = try await firebaseManager.fetchTodoLists(userID: user.id)
      sort()
    }
  }
  
  func filterTodoLists() -> [TodoList] {
    if activeFilter != nil {
      return activeFilter!.filterTodoList(todoLists: todoLists, state: completedTodoList)
    }
    return todoLists
  }
  
  func searchedTodoLists(todoLists: [TodoList]) -> [TodoList] {
    if searchText.isEmpty {
        return todoLists
    } else {
        return todoLists.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
  }
  
  func updateTodoList(todoList: TodoList) {
    let _ = `throw`.task {
      try firebaseManager.updateTodoList(todoList: todoList)
     todoLists = try await firebaseManager.fetchTodoLists(userID: user.id)
     sort()
    }
  }
  func deleteTodoList(todoListToDelete: TodoList?) {
    let _ = `throw`.task {
      guard var todoListToDelete else { throw SimpleError("Unable to delete todoList") }
      todoListToDelete.markedToDelete = Date()
      try firebaseManager.updateTodoList(todoList: todoListToDelete)
      fetchTodoLists()
    }
  }
  
//  func deleteTodoList(todoListToDelete: todoList?) {
//    let _ = `throw`.task {
//      guard let todoListToDelete else { throw SimpleError("Unable to delete todoList") }
//      try firebaseManager.deleteTodoList(todoList: todoListToDelete)
//      await MainActor.run {
//        withAnimation {
//          todoLists.removeAll { $0.id == todoListToDelete.id }
//        }
//      }
//    }
//  }
}
//#Preview {
//  todoListsView(todoLists: todoList.samples)
//}


extension TodoListsView {
  private enum SortingType {
    case priorityIncreasing
    case priorityDecreasing
    case createdAtIncreasing
    case createdAtDecreasing
    case dueDateIncreasing
    case dueDateDecreasing
    case updatedAtIncreasing
    case updatedAtDecreasing
  }
}


