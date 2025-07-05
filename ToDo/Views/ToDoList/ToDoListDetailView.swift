//
//  todoListDetailView.swift
//  ToDo
//
//  Created by David Záruba on 18.03.2025.
//

import SwiftUI

struct TodoListDetailView: View {
  @State var todoList: TodoList
  @State var tasks: [ToDoTask] = []
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  @Environment(\.dismiss) var dismiss
  @State private var editMode: EditMode = .inactive
  
  var body: some View {
    VStack {
      list
    }
    .onAppear {
      fetchTasks()
      fetchTodoList()
    }
    .environment(\.editMode, $editMode)
    .navigationTitle(todoList.name)
    .toolbar {
      if editMode == .active {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done", action: { editMode = .inactive })
        }
      } else {
        if todoList.state == .completed {
          ToolbarItem(placement: .topBarTrailing) {
            Text("Completed")
              .foregroundStyle(.secondary)
          }
        }
          ToolbarItem(placement: .topBarTrailing) {
            VStack {
              toolBarMenu
            }
          }
        }
    }
  }
  
  private var list: some View {
    List {
      ForEach($tasks) { $task in
        HStack {
          Button {
          toggleFinishItem(task: $task)
          } label: {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
              .foregroundStyle(getColor(task: task))
              .padding(.trailing, 4)
          }
          .buttonStyle(.plain)
          NavigationLink {
            ToDoTaskDetailView(task: task, todoList: todoList)
          } label: {
            Text(task.title)
              .strikethrough(task.isCompleted, color: .secondary)
              .foregroundStyle(getColor(task: task))
          }
        }
      }
      .onDelete(perform: { task in
        `throw`.try {
          guard let task = task.first else { throw SimpleError("Unable to delete Task")}
          todoList.updatedAt = Date()
          try firebaseManager.updateTodoList(todoList: todoList)
          onDelete(task: tasks[task])
        }
      })
      .onMove(perform: moveItem)
      .refreshable {
        fetchTasks()
      }
    }
  }
  private func fetchTodoList(){
    let _ = `throw`.task {
      todoList = try await firebaseManager.fetchTodoList(todoList: todoList)
    }
  }
  
  private func getColor(task: ToDoTask) -> HierarchicalShapeStyle {
    if task.isCompleted || todoList.state == .completed {
      return .secondary
    }
    return .primary
  }
  private var toolBarMenu: some View {
    Menu {
      Button("Edit") {
        withAnimation {
          editMode = .active
        }
      }
      NavigationLink("Add Task", destination: CreatingToDoTaskView(todoList: todoList))
      completeButton
      NavigationLink("Info", destination: TodoListDetailInfoView(todoListInfo: todoList, todoListNewValues: todoList, update: { list in
        `throw`.try {
          try firebaseManager.updateTodoList(todoList: list)
          todoList = list
        }
      }))
      Divider()
      Button("Delete Todo list", role: .destructive) {
        deleteTodoList()
      }
    } label: {
      Image(systemName: "ellipsis.circle")
    }
  }
  
  var completeButton: some View {
    Button(todoList.state == .completed ? "Change to In Progress" : "Change to Completed", action: {
      `throw`.try {
        todoList.state = todoList.state == .completed ? .inProgress : .completed
        updateDate()
        try firebaseManager.updateTodoList(todoList: todoList)
      }
    })
  }
  
  func toggleFinishItem(task: Binding<ToDoTask>) {
    task.wrappedValue.isCompleted.toggle()
    `throw`.try {
      todoList.updatedAt = Date()
      try firebaseManager.updateTodoList(todoList: todoList)
      try firebaseManager.updateTask(task: task.wrappedValue)
    }
     
  }
  
  func onDelete(task: ToDoTask) {
    `throw`.try {
      try firebaseManager.deleteTask(task: task, todoList: todoList)
    }
  }
  
  func deleteTodoList() {
    `throw`.try {
      todoList.markedToDelete = Date()
      todoList.updatedAt = Date()
      try firebaseManager.updateTodoList(todoList: todoList)
    }
      dismiss()
  }
  
  func fetchTasks() {
    let _ = `throw`.task{
      var temp = try await firebaseManager.fetchTasks(todoList: todoList)
      temp.sort()
      tasks = temp
    }
  }
  
  func updateDate() {
    todoList.updatedAt = Date()
  }
  
  func moveItem(from source: IndexSet, to destination: Int) {
    tasks.move(fromOffsets: source, toOffset: destination)
    
    for i in 0..<tasks.count {
      tasks[i].order = i
    }
    let _ = `throw`.task {
      try await firebaseManager.batchUpdateTasksOrders(tasks: tasks)
      todoList.updatedAt = Date()
      try firebaseManager.updateTodoList(todoList: todoList)
    }
  }
}


