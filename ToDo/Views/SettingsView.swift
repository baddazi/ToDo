//
//  Setting.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SettingsView: View {
  var body: some View {
    Button("Sign out") {
      try? Auth.auth().signOut()
    }
  }
}
