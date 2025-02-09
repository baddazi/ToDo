//
//  ToDoList.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import Foundation
import FirebaseFirestore

struct ToDoList: Identifiable, Codable {
  typealias ID = String?
  @DocumentID var id: ID
  var creator: User.ID
  var name: String
  var description: String?
  var items: [ToDoItem] = []
  var sharedTo: [User.ID] = []
  var createdAt: Date = Date()
  var dueDate: Date?
  var updatedAt: Date?
  var reletedTo: UUID?
  var state: ToDoState = .created
          
}

enum ToDoState: Codable {
  case created
  case inProgress
  case completed
  case paused
}

extension ToDoList {
  static let sample: ToDoList = .init(id: nil, creator: User.defaultValue.id, name: "Example", createdAt: Date() - 10000)
  static let samples: [ToDoList] = [
    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Test", createdAt: Date() - 10000),
    .init(id: nil,creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Example", createdAt: Date()  + 10000),
    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Temp", createdAt: Date()),
    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "ToDo", createdAt: Date() - 40000)
  ]
}
