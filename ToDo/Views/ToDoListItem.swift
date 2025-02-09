//
//  ToDoListItem.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI

struct ToDoListItem: View {
  var ToDoListItem: ToDoList
  var body: some View {
    VStack {
      Text(ToDoListItem.name)
      Text(ToDoListItem.createdAt.formatted())
    }
    }
}

#Preview {
  ToDoListItem(ToDoListItem: ToDoList.sample)
}
