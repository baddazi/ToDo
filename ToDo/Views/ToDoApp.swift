//
//  ToDoApp.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        ContentView()
          //.autoSignIn()
          .showErrors()
      }
    }
  }
}

// For development purpose

struct AutoSignIn: ViewModifier {
  private let email = "test@test.cz"
  private let password = "Test1234"
  func body(content: Content) -> some View {
    content
      .task {
        let _ = try? await Auth.auth().signIn(withEmail: email, password: password)
      }
  }
  
  
}

private extension View {
  func autoSignIn() -> some View {
    modifier(AutoSignIn())
  }
}


