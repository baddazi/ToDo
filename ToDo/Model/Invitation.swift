//
//  Invitation.swift
//  ToDo
//
//  Created by David Záruba on 07.02.2025.
//
import Foundation
import FirebaseFirestore

struct Invitation: Codable {
  typealias ID = String?
  @DocumentID var id: ID
  var toDoListID: ToDoList.ID
  var from: User.ID
  var to: User.ID
  var toDoList: ToDoList.ID
  var status: InvitationStatus = .pending
}

enum InvitationStatus: Codable {
  case pending
  case accepted
  case declined
}
