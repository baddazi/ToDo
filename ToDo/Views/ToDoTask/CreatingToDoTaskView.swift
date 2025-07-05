//
//  CreatingToDoItemView.swift
//  ToDo
//
//  Created by David Záruba on 26.03.2025.
//

import SwiftUI

struct CreatingToDoTaskView: View {
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  @Environment(\.dismiss) var dismiss
  @State var todoList: TodoList
  @State private var title: String = ""
  @State private var text: String = ""
  @State private var message: AlertMessage?
  
  var body: some View {
    VStack{
      HStack{
        Text("Title: ")
        TextField("", text: $title)
          .textFieldStyle(.roundedBorder)
      }
      HStack{
        Text("Description:")
        Spacer()
      }
      TextEditor(text: $text)
        .padding(8)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .stroke(.secondary.opacity(0.5), lineWidth: 1)
      )
      Button() {
        createTask()
      } label: {
        Text("Create Task")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
    }
    .navigationTitle("Add Task")
    .padding()
    .alert(item:  $message) {_ in
      Alert(title: Text("Wrong input"), message: Text(message?.message ?? ""), dismissButton: .default(Text("OK")))
    }
  }
  
  func createTask() {
    if title.isEmpty {
      message = AlertMessage(message: "Title cannot be empty")
      return
    }
    let _ = `throw`.task {
      try await firebaseManager.addTask(title: title, text: text, order: todoList.items.count, todoList: todoList)
      dismiss()
    }
  }
  
  func createSamples() {
    var samples = ToDoTask.getSamples(count: 3,todoList: todoList)
    let _ = `throw`.task {
      samples = try await firebaseManager.batchAddTasks(tasks: samples,todoList: todoList)
    }
  }
}
