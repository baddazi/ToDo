//
//  TodoItem.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import Foundation
import FirebaseFirestore

struct ToDoItem: Identifiable, Codable {
  typealias ID = String?
  @DocumentID  var id: ID
  var isCompleted = false
  var title: String
  var text: String?
  var creationDate: Date = Date.nowWithouSec()
  var dueDate: Date?
  var order: Int
}

extension ToDoItem {
  static let sample: ToDoItem = .init(id: nil, title: "ToDoItemTitle", text: "Sample text, description of Task.", order: 1)
  static func getSampleWithOrder(order: Int) -> ToDoItem {
    var sample = ToDoItem.sample
    sample.order = order
    sample.title = "ToDoItemTitle" + order.formatted()
    return sample
  }
}

extension ToDoItem: Comparable {
  static func < (lhs: ToDoItem, rhs: ToDoItem) -> Bool {
     lhs.order < rhs.order
     }
}
