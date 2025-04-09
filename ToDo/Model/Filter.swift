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
  
  init(toDoLists: [ToDoList], isNotDefineDueDateIncluded: Bool = true) {
    let (priority, created, due, updated) = Filter.createRangesFromToDoLists(toDoLists: toDoLists)
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
  
  func isFilterActive(toDoLists: [ToDoList]) -> Bool {
    let (priority, created, due, updated) = Filter.createRangesFromToDoLists(toDoLists: toDoLists)
    return priority == self.priorityRange && created == self.createDateRange && due == self.dueDateRange && updated == self.updatedDateRange
  }
  
  private static func createRangesFromToDoLists(toDoLists: [ToDoList]) -> (ClosedRange<Int>, ClosedRange<Date>, ClosedRange<Date>, ClosedRange<Date>) {
    let priorityRangeMin = toDoLists.min(by: { $0.priority < $1.priority })?.priority ?? 0
    let priorityRangeMax = toDoLists.max(by: { $0.priority < $1.priority })?.priority ?? 0
    let priorityRange = priorityRangeMin...priorityRangeMax
    
    let createDateRangeMin = toDoLists.min(by: { $0.createdAt < $1.createdAt })?.createdAt ?? .distantPast
    let createDateRangeMax = toDoLists.max(by: { $0.createdAt < $1.createdAt })?.createdAt ?? .distantPast
    let createDateRange = createDateRangeMin...createDateRangeMax
    
    let dueDateRangeMin = toDoLists.min(by: { $0.dueDate ?? .distantFuture < $1.dueDate ?? .distantFuture })?.dueDate ?? .distantPast
    let dueDateRangeMax = toDoLists.max(by: { $0.dueDate ?? .distantPast < $1.dueDate ?? .distantPast })?.dueDate ?? .distantFuture
    let dueDateRange = dueDateRangeMin...dueDateRangeMax
    
    let updatedDateRangeMin = toDoLists.min(by: { $0.updatedAt < $1.updatedAt })?.updatedAt ?? .distantPast
    let updatedDateRangeMax = toDoLists.max(by: { $0.updatedAt < $1.updatedAt })?.updatedAt ?? .distantPast
    let updatedDateRange = updatedDateRangeMin...updatedDateRangeMax
    
    return (priorityRange, createDateRange, dueDateRange, updatedDateRange)
  }
  
  func filterToDoList(toDoLists: [ToDoList]) -> [ToDoList] {
    let filteredToDoLists: [ToDoList] = toDoLists
      .filter { toDoList in
        self.priorityRange.contains(toDoList.priority)
      }
      .filter { toDoList in
        self.createDateRange.contains(toDoList.createdAt)
      }
      .filter { toDoList in
        self.updatedDateRange.contains(toDoList.updatedAt)
      }
      .filter { toDoList in
        if let dueDate = toDoList.dueDate {
          return self.dueDateRange.contains(dueDate)
        }
        return isNotDefineDueDateIncluded
      }
    
    return filteredToDoLists
  }
}

extension Filter {
  static func sample() -> Filter {
    Filter(priorityRange: 0...1000, createDateRange: (Date() - 10000000)...Date(), dueDateRange: Date()...(Date() + 10000000) , updatedDateRange: (Date() - 100000000)...(Date() + 100000000), isNoteDefineDueDateIncluded: true )
  }
}


