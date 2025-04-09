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
  @State private var isFilterPresented = false
  @State private var sortingType: SortingType = .priorityIncreasing
  @State private var editMode: EditMode = .inactive
  @State private var activeFilter: Filter?
  
  var body: some View {
    list
      .onAppear {
        fetchToDoLists()
      }
      .sheet(isPresented: $isFilterPresented, content: {
        FilterView(toDoLists: toDoLists, boundaries: Filter(toDoLists: toDoLists), activeFilter: $activeFilter, currentFilter: activeFilter ?? Filter(toDoLists: toDoLists))
      })
      .onChange(of: sortingType) {
        withAnimation {
          sort()
        }
      }
      .toolbar {
        if editMode == .active {
          ToolbarItem(placement: .navigationBarTrailing)
          {
            Button("Done") {
              withAnimation {
                editMode = .inactive
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
          editMode = .active
        }
      }
      NavigationLink("Add To-Do List", destination: CreatingTodoListView())
    } label: {
      Image(systemName: "ellipsis.circle")
    }
  }
  
  @ViewBuilder
  private var list: some View {
    List {
      ForEach(filterToDoLists()) { toDoList in
        NavigationLink(destination: ToDoListDetailView(toDoList: toDoList, updateToDoList: {_ in fetchToDoLists() }), label: {
            ToDoItemView(ToDoListItem: toDoList)
        })
      }
      .onDelete(perform: { index in
        `throw`.try {
          guard let itemToDelete = index.first else { throw SimpleError("Unable to delete ToDoList")}
          deleteToDoList(toDoListToDelete: toDoLists[itemToDelete])
        }
      })
    
    }
    .refreshable {
      fetchToDoLists()
    }
    .environment(\.editMode, $editMode)
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
  
  func sort() {
      switch sortingType {
      case .priorityIncreasing:
        toDoLists.sort { $0.priority < $1.priority }
      case .priorityDecreasing:
        toDoLists.sort { $0.priority > $1.priority }
      case .createdAtIncreasing:
        toDoLists.sort { $0.createdAt < $1.createdAt }
      case .createdAtDecreasing:
        toDoLists.sort { $0.createdAt > $1.createdAt }
      case .dueDateIncreasing:
        toDoLists.sort {
          let dueDate1 = $0.dueDate ?? Date.distantFuture
          let dueDate2 = $1.dueDate ?? Date.distantFuture
          return dueDate1 < dueDate2
        }
      case .dueDateDecreasing:
        toDoLists.sort {
          let dueDate1 = $0.dueDate ?? Date.distantPast
          let dueDate2 = $1.dueDate ?? Date.distantPast
          return dueDate1 > dueDate2
        }
      case .updatedAtIncreasing:
        toDoLists.sort { $0.updatedAt < $1.updatedAt }
      case .updatedAtDecreasing:
        toDoLists.sort { $0.updatedAt > $1.updatedAt }
      }
  }
  
  func fetchToDoLists() {
    let _ = `throw`.task {
      toDoLists = try await firebaseManager.fetchToDoLists(userID: user.id)
      sort()
    }
  }
  
  func filterToDoLists() -> [ToDoList] {
    if activeFilter != nil  {
      return activeFilter!.filterToDoList(toDoLists: toDoLists)
    }
    return toDoLists
  }
  
  func deleteToDoList(toDoListToDelete: ToDoList?) {
    let _ = `throw`.task {
      guard let toDoListToDelete else { throw SimpleError("Unable to delete ToDoList") }
      try firebaseManager.deleteToDoList(toDoList: toDoListToDelete)
      await MainActor.run {
        withAnimation {
          toDoLists.removeAll { $0.id == toDoListToDelete.id }
        }
      }
    }
  }
}
#Preview {
  ToDoListsView(toDoLists: ToDoList.samples)
}


extension ToDoListsView {
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


