//
//  TodoItem.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import Foundation
import FirebaseFirestore

struct ToDoTask: Identifiable, Codable {
  typealias ID = String?
  @DocumentID  var id: ID
  var todoListId: TodoList.ID
  var isCompleted = false
  var title: String
  var text: String?
  var order: Int
}

extension ToDoTask: Equatable {
  static func == (lhs: ToDoTask, rhs: ToDoTask) -> Bool {
    lhs.id == rhs.id && lhs.order == rhs.order && lhs.title == rhs.title && lhs.text == rhs.text && lhs.isCompleted == rhs.isCompleted
  }
}

extension ToDoTask: Comparable {
  static func < (lhs: ToDoTask, rhs: ToDoTask) -> Bool {
     lhs.order < rhs.order
     }
}

extension ToDoTask {
  static let sample: ToDoTask = .init(id: nil, todoListId: TodoList.sample.id!, title: "ToDoItemTitle", text: "Sample text, description of Task.", order: 1)
  static func getSampleWithOrder(order: Int) -> ToDoTask {
    var sample = ToDoTask.sample
    sample.order = order
    sample.title = "ToDoItemTitle" + order.formatted()
    return sample
  }
  
  static func getSamples(count: Int, todoList: TodoList) -> [ToDoTask] {
    var samples: [ToDoTask] = []
    for i in 0..<count {
      samples.append(.init(id: nil, todoListId: todoList.id!, title: "Title " + Int.random(in: 0...1000).formatted(), text: "Sample text, description of Task.", order: i))
    }
    
    return samples
  }
}


