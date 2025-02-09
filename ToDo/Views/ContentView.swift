//
//  ContentView.swift
//  ToDo
//
//  Created by David Záruba on 07.02.2025.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
  @State private var session: AuthStateDidChangeListenerHandle?
  @State private var user: User?
  
  var body: some View {
    Group {
      if let user = user {
        MainView()
          .environment(\.user, user)
      }
      else {
        SignInView()
      }
    }
    .onAppear {
      listen()
    }
    .onDisappear {
      stopListeninig()
    }
  }
  
  func listen() {
    if let _ = session {
      return
    }
    user = User.createUserFromFirebaseAuth(user: Auth.auth().currentUser)
    session = Auth.auth().addStateDidChangeListener{ auth, user in
      self.user = User.createUserFromFirebaseAuth(user: user)
    }
  }
  
  func stopListeninig() {
    if let _ = session {
      Auth.auth().removeStateDidChangeListener(session!)
    }
    session = nil
  }
}
