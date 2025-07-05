//
//  todoListItem.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI

struct TodoListItemView: View {
  var todoListItem: TodoList
  
  var body: some View {
    VStack {
      HStack {
        Text(todoListItem.name)
        Spacer()
        if todoListItem.state == .completed {
          Text("Completed")
          .foregroundStyle(chooseColor())
        }
        else if todoListItem.dueDate != nil {
          Text(todoListItem.dueDate!.formatted(date: .numeric, time: .omitted))
            .foregroundStyle(chooseColor())
        } else {
          Text("Undefined due date")
            .font(.footnote)
            .foregroundStyle(chooseColor())
        }
      }
      HStack {
        Text("Created: " + todoListItem.createdAt.formatted(date: .numeric, time: .omitted))
          .font(.footnote)
        Spacer()
        Text("Priority: " + todoListItem.priority.formatted())
          .font(.footnote)
      }
    }
    .foregroundStyle(todoListItem.state == .completed ? Color.secondary : Color.primary)
  }
  
  private func chooseColor() -> Color {
    if todoListItem.state == .completed {
      return Color.secondary
    }
    
    if todoListItem.dueDate == nil {
      return Color.red
    }
    
    if todoListItem.dueDate! < Date() {
      return Color.red
    }
    return Color.primary
  }
}

#Preview {
  TodoListItemView(todoListItem: TodoList.sample)
}
