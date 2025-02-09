//
//  FirebaseManager.swift
//  ToDo
//
//  Created by David Záruba on 07.02.2025.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct FirebaseManager {
  private static let ref = Firestore.firestore()
  
  
  var fetchToDoLists: (User.ID) async throws -> [ToDoList] = { id in
    var toDoLists: [ToDoList] = []
    try await ref.collection("ToDoLists").getDocuments().documents.forEach { rawToDoList in
      let toDoList = try rawToDoList.data(as: ToDoList.self)
      if toDoList.creator == id {
        toDoLists.append(try rawToDoList.data(as: ToDoList.self))
      }
    }
    return toDoLists
  }
  
  var fetchToDoList: (ToDoList.ID) async throws -> ToDoList = { id in
    guard let todoList = try await ref.collection("ToDoLists").getDocuments().documents.first(where: {
      try $0.data(as: ToDoList.self).id == id })
            else {
      throw SimpleError("ToDoList not found")
    }
    return try todoList.data(as: ToDoList.self)
  }
  
  var addToDoList: (ToDoList) async throws -> Void = { toDoList in
    try ref.collection("ToDoLists").addDocument(from: toDoList)
  }
  
  var updateToDoList: (ToDoList) async throws -> Void = { toDoList in
    guard let id = toDoList.id
    else { throw SimpleError("Unable to update note")}
    try ref.collection("notes").document(id).setData(from: toDoList)
  }
}

extension FirebaseManager: EnvironmentKey {
  static var defaultValue = FirebaseManager()
}
