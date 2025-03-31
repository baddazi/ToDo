//
//  User.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import Foundation
import FirebaseAuth
import SwiftUI

struct User: Identifiable {
  typealias ID = String
  var id: ID
  var name: String
  var invitaions: [Invitation] = []
}

extension User {
  static func createUserFromFirebaseAuth(user: FirebaseAuth.User?) -> User? {
    if let user = user{
      return User(id: user.uid, name: user.displayName ?? user.email ?? "Anonymous")
    }
    return nil
  }
}

extension User: EnvironmentKey {
  // probably not perfect solution but I do not want to be optional.
  static let defaultValue: User = User(id: "", name: "")
}


