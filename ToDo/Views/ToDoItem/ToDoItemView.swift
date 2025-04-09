//
//  ToDoListItem.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI

struct ToDoItemView: View {
  var ToDoListItem: ToDoList
  var body: some View {
    
    VStack {
      HStack {
        Text(ToDoListItem.name)
        Spacer()
        if ToDoListItem.dueDate != nil {
          Text(ToDoListItem.dueDate!.formatted(date: .numeric, time: .omitted))
            .foregroundStyle(ToDoListItem.dueDate! < Date() ? Color.red : .primary)
        } else {
          Text("undefined due date")
            .font(.footnote)
            .foregroundStyle(Color.red)
        }
      }
      
      HStack {
        Text("Created: " + ToDoListItem.createdAt.formatted(date: .numeric, time: .omitted))
          .font(.footnote)
        Spacer()
        Text("Priority: " + ToDoListItem.priority.formatted())
          .font(.footnote)
      }
    }
  }
}

#Preview {
  ToDoItemView(ToDoListItem: ToDoList.sample)
}
