//
//  Filter.swift
//  ToDo
//
//  Created by David Záruba on 01.04.2025.

import Foundation

struct Filter {
  var priorityRange: ClosedRange<Int>
  var createDateRange: ClosedRange<Date>
  var dueDateRange: ClosedRange<Date>
  var updatedDateRange: ClosedRange<Date>
  var isNotDefineDueDateIncluded: Bool
  
  init(priorityRange: ClosedRange<Int>, createDateRange: ClosedRange<Date>, dueDateRange: ClosedRange<Date>, updatedDateRange: ClosedRange<Date>, isNoteDefineDueDateIncluded: Bool) {
    self.priorityRange = priorityRange
    self.createDateRange = createDateRange
    self.dueDateRange = dueDateRange
    self.updatedDateRange = updatedDateRange
    self.isNotDefineDueDateIncluded = isNoteDefineDueDateIncluded
  }
  
  init(todoLists: [TodoList], isNotDefineDueDateIncluded: Bool = true) {
    let (priority, created, due, updated) = Filter.createRangesFromTodoLists(todoLists: todoLists)
    self.priorityRange = priority
    self.createDateRange = created
    self.dueDateRange = due
    self.updatedDateRange = updated
    self.isNotDefineDueDateIncluded = isNotDefineDueDateIncluded
  }
}

extension Filter: Equatable {
  static func == (lhs: Filter, rhs: Filter) -> Bool {
    return lhs.createDateRange == rhs.createDateRange && lhs.dueDateRange == rhs.dueDateRange && lhs.priorityRange == rhs.priorityRange && lhs.updatedDateRange == rhs.updatedDateRange && lhs.isNotDefineDueDateIncluded == rhs.isNotDefineDueDateIncluded
  }
  
  func isFilterActive(todoLists: [TodoList]) -> Bool {
    let (priority, created, due, updated) = Filter.createRangesFromTodoLists(todoLists: todoLists)
    return priority == self.priorityRange && created == self.createDateRange && due == self.dueDateRange && updated == self.updatedDateRange
  }
  
  private static func createRangesFromTodoLists(todoLists: [TodoList]) -> (ClosedRange<Int>, ClosedRange<Date>, ClosedRange<Date>, ClosedRange<Date>) {
    let priorityRangeMin = todoLists.min(by: { $0.priority < $1.priority })?.priority ?? 0
    let priorityRangeMax = todoLists.max(by: { $0.priority < $1.priority })?.priority ?? 0
    let priorityRange = priorityRangeMin...priorityRangeMax
    
    let createDateRangeMin = todoLists.min(by: { $0.createdAt < $1.createdAt })?.createdAt ?? .distantPast
    let createDateRangeMax = todoLists.max(by: { $0.createdAt < $1.createdAt })?.createdAt ?? .distantPast
    let createDateRange = createDateRangeMin...createDateRangeMax
    
    let dueDateRangeMin = todoLists.min(by: { $0.dueDate ?? .distantFuture < $1.dueDate ?? .distantFuture })?.dueDate ?? .distantPast
    let dueDateRangeMax = todoLists.max(by: { $0.dueDate ?? .distantPast < $1.dueDate ?? .distantPast })?.dueDate ?? .distantFuture
    let dueDateRange = dueDateRangeMin...dueDateRangeMax
    
    let updatedDateRangeMin = todoLists.min(by: { $0.updatedAt < $1.updatedAt })?.updatedAt ?? .distantPast
    let updatedDateRangeMax = todoLists.max(by: { $0.updatedAt < $1.updatedAt })?.updatedAt ?? .distantPast
    let updatedDateRange = updatedDateRangeMin...updatedDateRangeMax
    
    return (priorityRange, createDateRange, dueDateRange, updatedDateRange)
  }
  
  func filterTodoList(todoLists: [TodoList], state: CompletedTodoList) -> [TodoList] {
    let filteredTodoLists: [TodoList] = todoLists
      .filter { todoList in
        self.priorityRange.contains(todoList.priority)
      }
      .filter { todoList in
        self.createDateRange.contains(todoList.createdAt)
      }
      .filter { todoList in
        self.updatedDateRange.contains(todoList.updatedAt)
      }
      .filter { todoList in
        if let dueDate = todoList.dueDate {
          return self.dueDateRange.contains(dueDate)
        }
        return isNotDefineDueDateIncluded
      }
      .filter { todoList in
        return state.checkWithToDoState(state: todoList.state)
      }
    
    return filteredTodoLists
  }
}

extension Filter {
  static func sample() -> Filter {
    Filter(priorityRange: 0...1000, createDateRange: (Date() - 10000000)...Date(), dueDateRange: Date()...(Date() + 10000000) , updatedDateRange: (Date() - 100000000)...(Date() + 100000000), isNoteDefineDueDateIncluded: true)
  }
}

enum CompletedTodoList: String, CaseIterable, Identifiable  {
  case both = "both"
  case completed = "completed"
  case inProgress = "in progress"

  var id: Self { self }
  
  func checkWithToDoState(state: ToDoState) -> Bool {
    if self == .both {
      return true
    }
    
    if self == .inProgress && state == .inProgress{
      return true
    }
    
    if self == .completed && state == .completed{
      return true
    }
    
    return false
  }
}


