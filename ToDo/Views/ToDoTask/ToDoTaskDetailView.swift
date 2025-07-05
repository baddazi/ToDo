//
//  ToDoItemDetailView.swift
//  ToDo
//
//  Created by David Záruba on 15.04.2025.
//

import SwiftUI

struct ToDoTaskDetailView: View {
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  @Environment(\.dismiss) var dismiss
  @State var task: ToDoTask
  @State var todoList: TodoList
  
  var body: some View {
    VStack{
      HStack{
        Text("Title: ")
        TextField("", text: $task.title)
          .textFieldStyle(.roundedBorder)
      }
      HStack{
        Text("Description:")
        Spacer()
      }
      TextEditor(text: Binding<String> {
        task.text ?? ""
      } set: {
        task.text = $0
      })
      .padding(8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .stroke(.secondary.opacity(0.5), lineWidth: 1)
      )
    }
    .foregroundStyle(task.isCompleted ? Color.secondary : .primary)
    .toolbar {
      if task.isCompleted {
        ToolbarItem(placement: .topBarTrailing){
          Text("Completed")
            .foregroundStyle(.secondary)
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        menu
      }
    }
    .padding()
    .navigationTitle(task.title)
    .onChange(of: task) {
      `throw`.try {
        try firebaseManager.updateTask(task: task)
        todoList.updatedAt = Date()
        try firebaseManager.updateTodoList(todoList: todoList)
      }
    }
  }
  
  private var menu: some View {
    Menu {
      Button(task.isCompleted ? "Reopen" : " Complete") {
        task.isCompleted.toggle()
      }
      Divider()
      Button("Delete", role: .destructive) {
        `throw`.try {
          todoList.updatedAt = Date()
          try firebaseManager.updateTodoList(todoList: todoList)
          try firebaseManager.deleteTask(task: task, todoList: todoList)
        }
        dismiss()
      }
    } label: {
      Image(systemName: "ellipsis.circle")
    }
  }
}

#Preview {
  ToDoTaskDetailView(task: ToDoTask.sample, todoList: TodoList.sample)
}
