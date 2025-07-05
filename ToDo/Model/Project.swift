//
//  Projects.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import Foundation


// TODO: Not sure if I wannt this in the app. 

struct Project: Identifiable{
  var id: UUID = UUID()
  var name: String
  var todoLists: [TodoList] = []
  
  
}
