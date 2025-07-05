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
  @Environment(\.`throw`) var `throw`
  @Environment(\.dismiss) var dismiss
  var body: some View {
    VStack {
      Button("Test Error") {
        testError()
      }
      Button("Test Errors") {
        testErrors()
      }
      Button("Sign out") {
        signOut()
        dismiss()
      }
    }
  }
  
  private func signOut() {
    `throw`.try {
      try Auth.auth().signOut()
    }
  }
  
  private func testError() {
      `throw`.try {
        throw SimpleError (" Testing error")
      }
  }
  
  private func testErrors() {
    `throw`.try {throw SimpleError (" Testing error 1")}
    `throw`.try {throw SimpleError (" Testing error 2")}
    `throw`.try {throw SimpleError (" Testing error 3")}
    `throw`.try {throw SimpleError (" Testing error 4")}
   
  }
  
}
