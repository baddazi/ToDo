//
//  CreatingTodoListView.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI

struct CreatingTodoListView: View {
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  @Environment(\.dismiss) var dismiss
  @Environment(\.user) var user
  
  @State private var name: String = ""
  @State private var priority: Int = 1
  @State private var description: String?
  @State private var dueDate: Date?
  @State private var setDueDate: Bool = false
  @State private var message: AlertMessage?
  
  var body: some View {
    ScrollView {
      VStack {
        text
        date
        Spacer()
        Button{
          create()
        } label: {
          Text("Create")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
      }
      .navigationTitle("Add Todo list")
      .onChange(of: setDueDate) {
        if setDueDate == false {
          dueDate = nil
        }
      }
      .alert(item: $message) { message in
        Alert(title: Text("Wrong imput"), message: Text(message.message), dismissButton: .default(Text("OK")))
      }
      .padding()
    }
  }
  
  var text: some View {
    VStack {
      HStack {
        Text("Name: ")
        TextField("", text: $name)
          .textFieldStyle(.roundedBorder)
      }
      HStack {
        Text("Priority: ")
        TextField("Priority", value: $priority, format: .number)
          .textFieldStyle(.roundedBorder)
      }
      VStack {
        HStack {
          Text("Description: ")
          Spacer()
        }
        TextEditor(text: Binding<String> {
           description ?? ""
        } set: {
            description = $0
        })
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.gray.opacity(0.5), lineWidth: 1)
          )
        .frame(height: 300)
      }
    }
  }
  
  var date: some View {
    VStack {
      Toggle("Set due date", isOn: $setDueDate)
      if setDueDate {
        DatePicker("Due date: ", selection: Binding<Date> {
          (dueDate ?? Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? .distantPast))
        } set: {
          dueDate = $0
        }, displayedComponents: .date)
      }
    }
  }
  
  private func create() {
    if name.isEmpty {
      message = AlertMessage(message: "Name is required")
      return
    }
    
    if !(0...1000).contains(priority) {
      message = AlertMessage(message: "Priority must be between 0 and 1000")
      return
    }
    
    `throw`.try {
      try firebaseManager.addTodoList(name: name, priority: priority, description: description, dueDate: dueDate, userID: user.id)
      dismiss()
    }
  }
}

#Preview {
  CreatingTodoListView()
}
