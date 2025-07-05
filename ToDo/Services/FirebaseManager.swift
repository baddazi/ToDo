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
  private let nameOfTaskCollection: String = "Tasks"
  private let nameOfTodoListCollection: String = "ToDoLists"
  
  func fetchTodoLists(userID: User.ID) async throws -> [TodoList] {
    var todoLists: [TodoList] = []
    try await ref.collection(nameOfTodoListCollection).getDocuments().documents.forEach { rawTodoList in
      let todoList = try rawTodoList.data(as: TodoList.self)
      if todoList.creator == userID && todoList.markedToDelete == nil  {
        todoLists.append(todoList)
      }
    }
    return todoLists
  }
  
  func fetchTasks(todoList: TodoList) async throws -> [ToDoTask] {
    guard let id = todoList.id
    else { throw SimpleError("Unable to fetch Tasks")}
    var tasks: [ToDoTask] = []
    try await ref.collection(nameOfTaskCollection).getDocuments().documents.forEach { rawTask in
      let task = try rawTask.data(as: ToDoTask.self)
      if task.todoListId == id {
        tasks.append(task)
      }
    }
    return tasks
  }
  
  func fetchTodoList(todoList: TodoList) async throws -> TodoList {
    guard let id = todoList.id,
          let todoList = try await ref.collection(nameOfTodoListCollection).getDocuments().documents.first(where: {
            try $0.data(as: TodoList.self).id == id })
    else {
      throw SimpleError("todoList not found")
    }
    return try todoList.data(as: TodoList.self)
  }
  
  func fetchTodoListRecentlyDeleted(userID: User.ID) async throws -> [TodoList] {
    var todoLists: [TodoList] = []
    try await ref.collection(nameOfTodoListCollection).getDocuments().documents.forEach { rawTodoList in
      let todoList = try rawTodoList.data(as: TodoList.self)
      if todoList.creator == userID && todoList.markedToDelete != nil {
        todoLists.append(todoList)
      }
    }
    return todoLists
  }
  
  func deleteTodoListAfterXDays(userID: User.ID, days: Int) async throws {
    let todoList = try await fetchTodoListRecentlyDeleted(userID: userID).filter({ Calendar.current.date(byAdding: .day, value: days, to: $0.markedToDelete ?? .distantPast) ?? .distantPast < Date()})
    try await batchDeleteTodoLists(todoLists: todoList)
  }
  
  func addTodoList(todoList: TodoList) throws -> Void {
    try ref.collection(nameOfTodoListCollection).addDocument(from: todoList)
  }
  
  func addTodoList(name: String, priority: Int, description: String?, dueDate: Date?, userID: User.ID) throws {
    let todoListRef = ref.collection(nameOfTodoListCollection).document()
    let todoList = TodoList(id: todoListRef.documentID, creator: userID, name: name, description: description, dueDate: dueDate, priority: priority)
    try ref.collection(nameOfTodoListCollection).addDocument(from: todoList)
  }
    
  func addTask(title: String, text: String?, order: Int, todoList: TodoList) async throws -> Void {
    let batch = ref.batch()
    let taskRef = ref.collection(nameOfTaskCollection).document()
    
    let task = ToDoTask(id: taskRef.documentID, todoListId: todoList.id, title: title, text: text, order: order)
    try batch.setData(from: task, forDocument: taskRef)
    
    var updatedTodoList = todoList
    updatedTodoList.items.append(taskRef.documentID)
    guard let id = updatedTodoList.id
    else { throw SimpleError("Unable to add Task")}
    try batch.setData(from: updatedTodoList, forDocument: ref.collection(nameOfTodoListCollection).document(id))
    
    try await batch.commit()
  }
  
  
  func updateTask(task: ToDoTask) throws -> Void {
    guard let id = task.id
    else { throw SimpleError("Unable to update Task")}
    try ref.collection(nameOfTaskCollection).document(id).setData(from: task)
  }
  
  func updateTodoList(todoList: TodoList) throws -> Void {
    guard let id = todoList.id
    else { throw SimpleError("Unable to update todoList")}
    try ref.collection(nameOfTodoListCollection).document(id).setData(from: todoList)
  }
  
  func deleteTodoList(todoList: TodoList) throws -> Void {
    guard let id = todoList.id
    else { throw SimpleError("Unable to delete todoList")}
    ref.collection(nameOfTodoListCollection).document(id).delete()
  }
  
  func deleteTask(task: ToDoTask, todoList: TodoList) throws -> Void {
    guard let id = task.id
    else { throw SimpleError("Unable to deleteTask")}
    ref.collection(nameOfTaskCollection).document(id).delete()
    var udpatedTodoList = todoList
    udpatedTodoList.items.removeAll(where: { $0 == id })
    try updateTodoList(todoList: udpatedTodoList)
  }
  
  func batchDeleteTasks(todoList: TodoList, batch: WriteBatch) async throws -> Void {
    let tasks = try await fetchTasks(todoList: todoList)
   try tasks.forEach { task in
      guard let id = task.id
      else { throw SimpleError("Unable to delete Task")}
      batch.deleteDocument(ref.collection(nameOfTaskCollection).document(id))
    }
   
  }
  
  func batchDeleteTodoLists(todoLists: [TodoList]) async throws  -> Void {
    let batch = ref.batch()
    for todoList in todoLists {
      guard let id = todoList.id
      else { throw SimpleError("Unable to delete todoList")}
      try await batchDeleteTasks(todoList: todoList, batch: batch)
      batch.deleteDocument(ref.collection(nameOfTodoListCollection).document(id))
    }
    try await batch.commit()
  }
  
  func batchUpadteTodoLists(todoLists: [TodoList]) async throws  -> Void {
    let batch = ref.batch()
    try todoLists.forEach { todoList in
      guard let id = todoList.id
      else { throw SimpleError("Unable to update todoList")}
      try batch.setData(from: todoList, forDocument: ref.collection(nameOfTodoListCollection).document(id))
    }
    try await batch.commit()
  }
  
  func batchUpdateTasksOrders(tasks: [ToDoTask]) async throws {
    let batch = ref.batch()
    try tasks.forEach { task in
      guard let id = task.id
      else { throw SimpleError("Unable to update Task")}
      batch.updateData(["order" : task.order], forDocument: ref.collection(nameOfTaskCollection).document(id))
    }
    try await batch.commit()
  }
  
  
  
  // Propably not effective. I can create .document() get ids, and fill in tasks and todoList manually without fetchTasks(). Its only for testing purpouse so good enough for now.
  func batchAddTasks(tasks: [ToDoTask], todoList: TodoList) async throws -> [ToDoTask] {
    let batch = ref.batch()
    try tasks.forEach { task in
      try batch.setData(from: task, forDocument: ref.collection(nameOfTaskCollection).document())
    }
    try await batch.commit()
    let updatedTasks = try await fetchTasks(todoList: todoList)
    var updatedTodoList = todoList
    updatedTodoList.items = updatedTasks.compactMap( \.id )
    try updateTodoList(todoList: updatedTodoList)
    return updatedTasks
  }
}

extension FirebaseManager: EnvironmentKey {
  static var defaultValue = FirebaseManager()
}
