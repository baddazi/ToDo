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
  var invitation: Invitation.ID?
  var creator: User.ID
  var name: String
  var description: String?
  var items: [ToDoItem] = []
  var sharedTo: [User.ID] = []
  var createdAt: Date = Date.nowWithouSec()
  var dueDate: Date?
  var updatedAt: Date = Date.nowWithouSec()
  var reletedTo: ID?
  var state: ToDoState = .created
  var closed: Date?
  var priority: Int = 1
          
}

enum ToDoState: Codable {
  case created
  case inProgress
  case completed
  case paused
}

extension ToDoList {
  static let sample: ToDoList = .init(id: nil, creator: User.defaultValue.id, name: "Example", items: [.sample], createdAt:  Date.creatingTestingDate(), updatedAt: Date.creatingTestingDate())
  static let samples: [ToDoList] = [
    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Test", items: [ToDoItem.getSampleWithOrder(order: 1)], createdAt: Date.creatingTestingDate(),dueDate: Date.dueTestingDate(), updatedAt: Date.creatingTestingDate(), priority: 200),
    .init(id: nil,creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Example", items: [ToDoItem.getSampleWithOrder(order: 1), ToDoItem.getSampleWithOrder(order: 2)], createdAt: Date.creatingTestingDate(),dueDate: Date.dueTestingDate(), updatedAt: Date.creatingTestingDate(), priority: 40),
    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Temp", items: [ToDoItem.getSampleWithOrder(order: 1)], priority: 20),
    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "ToDo", items: [ToDoItem.getSampleWithOrder(order: 1), ToDoItem.getSampleWithOrder(order: 2)], createdAt: Date.nowWithouSec(),dueDate: Date.dueTestingDate(),updatedAt: Date.nowWithouSec(), priority: 10)
  ]
}
