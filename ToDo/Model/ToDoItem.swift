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
  var text: String?
  var creationDate: Date = Date()
  var dueDate: Date?
  var order: Int?
}
