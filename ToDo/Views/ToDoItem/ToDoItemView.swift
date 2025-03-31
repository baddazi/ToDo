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
      Text(ToDoListItem.name)
      Text(ToDoListItem.createdAt.formatted())
    }
    }
}

#Preview {
  ToDoItemView(ToDoListItem: ToDoList.sample)
}
