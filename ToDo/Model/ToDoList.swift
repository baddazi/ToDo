//
//  todoList.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.

import Foundation
import FirebaseFirestore

struct TodoList: Identifiable, Codable, Hashable {
  typealias ID = String?
  @DocumentID var id: ID
  var invitation: Invitation.ID?
  var creator: User.ID
  var name: String
  var description: String?
  var items: [ToDoTask.ID] = []
  var sharedTo: [User.ID] = []
  var createdAt: Date = Date.nowWithouSec()
  var dueDate: Date?
  var updatedAt: Date = Date.nowWithouSec()
  var reletedTo: ID?
  var state: ToDoState = .inProgress
  var markedToDelete: Date?
  var priority: Int = 1
          
}

enum ToDoState: String, Codable, Hashable {
  case created
  case inProgress
  case completed
  case paused
  
}

//extension todoList: Equatable {
//  static func == (lhs: todoList, rhs: todoList) -> Bool {
//    lhs.items == rhs.items && lhs.createdAt == rhs.createdAt && lhs.dueDate == rhs.dueDate && lhs.updatedAt == rhs.updatedAt && lhs.priority == rhs.priority && lhs.id == rhs.id
//  }
//}



extension TodoList {
  static let sample: TodoList = .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Example", createdAt:  Date.creatingTestingDate())
//  static let samples: [todoList] = [
//    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Test", items: [Task.getSampleWithOrder(order: 1)], createdAt: Date.creatingTestingDate(),dueDate: Date.dueTestingDate(), updatedAt: Date.creatingTestingDate(), priority: 200),
//    .init(id: nil,creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Example", items: [Task.getSampleWithOrder(order: 1), Task.getSampleWithOrder(order: 2)], createdAt: Date.creatingTestingDate(),dueDate: Date.dueTestingDate(), updatedAt: Date.creatingTestingDate(), priority: 40),
//    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "Temp", items: [Task.getSampleWithOrder(order: 1)], priority: 20),
//    .init(id: nil, creator: "kYVFGL6sQGRfJvp9TQYYomeOOw93", name: "ToDo", items: [Task.getSampleWithOrder(order: 1), Task.getSampleWithOrder(order: 2)], createdAt: Date.nowWithouSec(),dueDate: Date.dueTestingDate(),updatedAt: Date.nowWithouSec(), priority: 10)
//  ]
}
