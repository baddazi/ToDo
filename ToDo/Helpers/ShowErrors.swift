//
//  ShowErrors.swift
//  ToDo
//
//  Created by David Záruba on 09.02.2025.
//
import SwiftUI

struct ShowErrors: ViewModifier {
  @State private var errors: [Error] = []
  
  func body(content: Content) -> some View {
    content
      .environment(\.`throw`, Throw { error in
        errors.append(error)
      })
      .alert(errors.count > 1 ? "\(errors.count) Errors" : "Error", isPresented: Binding<Bool> {
        !errors.isEmpty } set : { _ in }, actions:  {
          if errors.count == 1 {
            Button {
              errors.removeFirst()
            } label: {
              Text("Cancel")
            }
          }
          else {
            Button(role: .destructive) {
              errors = []
            } label: {
              Text("Clear all errors")
            }
            
            Button {
              errors.removeFirst()
            } label: {
              Text("Move to next Error")
            }
          }
        }, message: {
          Text(errors.first?.localizedDescription ?? "")
        })
  }
}

extension View {
  func showErrors() -> some View {
    modifier(ShowErrors())
  }
}

