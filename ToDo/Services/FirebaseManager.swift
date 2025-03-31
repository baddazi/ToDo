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
  private let ref = Firestore.firestore()
  
  
  func fetchToDoLists(userID: User.ID) async throws -> [ToDoList] {
    var toDoLists: [ToDoList] = []
    try await ref.collection("ToDoLists").getDocuments().documents.forEach { rawToDoList in
      let toDoList = try rawToDoList.data(as: ToDoList.self)
      if toDoList.creator == userID {
        toDoLists.append(try rawToDoList.data(as: ToDoList.self))
      }
    }
    return toDoLists
  }
    
  func fetchToDoList(toDoList: ToDoList) async throws -> ToDoList {
    guard let id = toDoList.id,
      let todoList = try await ref.collection("ToDoLists").getDocuments().documents.first(where: {
      try $0.data(as: ToDoList.self).id == id })
            else {
      throw SimpleError("ToDoList not found")
    }
    return try todoList.data(as: ToDoList.self)
  }
  
  func addToDoList(toDoList: ToDoList) throws -> Void {
    try ref.collection("ToDoLists").addDocument(from: toDoList)
  }
  
  func updateToDoList(toDoList: ToDoList) throws -> Void {
    guard let id = toDoList.id
    else { throw SimpleError("Unable to update ToDoList")}
    try ref.collection("ToDoLists").document(id).setData(from: toDoList)
  }
  
  func deleteToDoList(toDoList: ToDoList) throws -> Void {
    guard let id = toDoList.id
    else { throw SimpleError("Unable to delete ToDoList")}
    ref.collection("ToDoLists").document(id).delete()
  }
  
  func deleteToDoItem(toDoList: ToDoList,toDoItem: ToDoItem) throws -> Void {
    var updatedToDoList = toDoList
    guard let index = toDoList.items.firstIndex(where: { $0.id == toDoItem.id })
    else { throw SimpleError("Unable to delete ToDoList")}
    updatedToDoList.items.remove(at: index)
    try updateToDoList(toDoList: updatedToDoList)
  }
}

extension FirebaseManager: EnvironmentKey {
  static var defaultValue = FirebaseManager()
}
