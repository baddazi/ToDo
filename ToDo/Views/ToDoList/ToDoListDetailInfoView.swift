//
//  todoListDetailInfoView.swift
//  ToDo
//
//  Created by David Záruba on 16.04.2025.
//

import Foundation
import SwiftUI

struct TodoListDetailInfoView: View {
  @State var todoListInfo: TodoList
  @State var todoListNewValues: TodoList
  @State var isEditing: Bool = false
  var update: (TodoList) -> Void
  @State private var message: AlertMessage? =  nil
  
  var body: some View {
    ScrollView {
      VStack {
        textInfo
        dateInfo
        markAsCompleted
          .padding()
      }
      .toolbar {
        if todoListInfo.state == .completed && !isEditing {
          ToolbarItem(placement: .topBarTrailing) {
            Text("Completed")
              .foregroundStyle(.secondary)
          }
        }
        if isEditing {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
              verifyInputs()
            }
            .disabled(todoListInfo == todoListNewValues)
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          editButton
        }
      }
      .alert(item: $message) { message in
        Alert(title: Text(message.title), message: Text(message.message), dismissButton: .default(Text("OK")))
      }
      .padding()
    }
    .navigationTitle(todoListNewValues.name)
  }
  
  var updateButton: some View {
    Button("Update") {
      verifyInputs()
    }
    .disabled(todoListInfo == todoListNewValues)
  }
  
  var editButton: some View {
    Button(isEditing ? "Done" : "Edit") {
      isEditing.toggle()
    }
  }
  
  var textInfo: some View {
    VStack {
      HStack {
        Text("Name: ")
        TextField("Name", text: isEditing ? $todoListNewValues.name : $todoListInfo.name)
          .textFieldStyle(.roundedBorder)
          .disabled(!isEditing)
      }
      HStack {
        Text("Priority: ")
        TextField("Priority", value: isEditing ? $todoListNewValues.priority : $todoListInfo.priority, format: .number)
          .textFieldStyle(.roundedBorder)
          .disabled(!isEditing)
      }
      VStack {
        HStack {
          Text("Description: ")
          Spacer()
        }
        TextEditor(text: Binding<String> {
          isEditing ? todoListNewValues.description ?? "" : todoListInfo.description ?? ""
        } set: {
            todoListNewValues.description = $0
        })
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.gray.opacity(0.5), lineWidth: 1)
          )
        .disabled(!isEditing)
        .frame(height: 300)
      }
    }
  }
  
  var dateInfo: some View {
    VStack {
      HStack {
        Text("Create at:")
        Text(todoListInfo.createdAt.formatted(date: .numeric, time: .standard))
        Spacer()
      }
      HStack {
        Text("Updated at:")
        Text(todoListInfo.updatedAt.formatted(date: .numeric, time: .standard))
        Spacer()
      }
      if isEditing == false {
        HStack {
          Text("Due date: " + (todoListInfo.dueDate != nil ? todoListInfo.dueDate!.formatted(date: .numeric, time: .omitted) : "not set"))
          Spacer()
        }
      } else {
        HStack {
          DatePicker("Due date: ", selection: Binding<Date> {
            (todoListInfo.dueDate ?? Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? .distantPast))
          } set: {
            todoListNewValues.dueDate = $0
          }, displayedComponents: .date)
          Spacer()
        }
      }
    }
  }
  
  var markAsCompleted: some View {
    Button {
      if todoListInfo.state == .completed { todoListNewValues.state = .inProgress }
      else { todoListNewValues.state = .completed }
      updateToDoList()
    }
    label: {
      Text(todoListInfo.state == .completed ? "Change to In Progress" : "Change to Completed")
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.bordered)
  }
  
  private func verifyInputs() {
    if todoListNewValues.name.isEmpty {
      message = AlertMessage(title: "Wrong imput", message: "Name is required")
      return
    }
    
    if !(0...1000).contains(Double(todoListNewValues.priority)) {
      message =  AlertMessage(title: "Wrong imput", message: "Priority needs to be in range 0 to 1000")
      return
    }
    
    updateToDoList()
  }
  
  private func updateToDoList(){
    todoListNewValues.updatedAt = Date()
    todoListInfo = todoListNewValues
    update(todoListNewValues)
  }
}


