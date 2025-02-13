//
//  SignInView.swift
//  ToDo
//
//  Created by David Záruba on 06.02.2025.
//

import SwiftUI
import FirebaseAuth
import SwiftUIIntrospect
import GoogleSignInSwift
import GoogleSignIn
import Firebase

// TODO: add Sign with apple.

struct SignInView: View {
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var confirmePassword: String = ""
  @State private var signInType: SignInType  = .signIn
  @State private var isSignIn = false
  @State private var uiViewController: UIViewController? = nil
  @Environment(\.`throw`) var `throw`
  var body: some View {
    VStack {
      emailSignInUP
      signInUpButton
      if signInType == .signIn {
        forgetPassword
      }
      singInGoogleButton
      switchingSignInUp
    }
    .navigationTitle("Welcome to ToDo")
    .introspect(.viewController, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) {
      uiViewController = $0
    }
  }
  
  private var switchingSignInUp: some View {
    VStack {
      HStack {
        Text(signInType == .signIn ? "Don't have an account?" : " Allready have an account?")
        Button(action: {
          signInType = signInType == .signIn ? .signUp : .signIn
        }) {
          Text(signInType == .signIn ? "Sign Up" : "Sign In")
        }
      }
    }
  }
  
  private var emailSignInUP: some View {
    VStack {
      Text("Please sign in to you accout")
      TextField("email", text: $email)
      SecureField("Password", text: $password)
      if signInType == .signUp {
        SecureField("Confirm Password", text: $confirmePassword)
      }
      
    }
  }
  
  private var forgetPassword: some View {
    HStack {
      Spacer()
      Button {
        `throw`.try {
          try resetPassword()
        }
      } label: {
        Text("Forgot Password?")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }
  
  private var signInUpButton: some View {
    Button {
      _ = `throw`.task {
        try checkInputs()
        if signInType == .signIn {
          try await signIn()
        } else {
          try await signUp()
        }
      }
    } label: {
      if isSignIn {
        ProgressView()
      } else {
        Text(signInType == .signIn ? "Sign in" : "Sign up")
      }
    }
  }
  
  private var singInGoogleButton: some View {
    GoogleSignInButton(action: googleSignIn)
      .disabled(isSignIn)
  }
  
  private func checkInputs() throws {
    if email.isEmpty {
      throw SimpleError("Email need to be filled")
    }
    if password.isEmpty {
      throw SimpleError("Password need to be filled")
    }
    if signInType == .signUp, password != confirmePassword {
      throw SimpleError("Password do not match")
    }
  }
  
  private func signIn() async throws {
    isSignIn = true
    defer{ isSignIn = false }
    _ = try await Auth.auth().signIn(withEmail: email, password: password)
  }
  
  private func signUp() async throws {
    isSignIn = true
    defer{ isSignIn = false }
    _ = try await Auth.auth().createUser(withEmail: email, password: password)
  }
  
  private func resetPassword() throws {
    throw SimpleError("Not implemented yet")
  }
  
  private func googleSignIn() {
    let _ = `throw`.task { @MainActor in
      isSignIn = true
      defer{ isSignIn = false }
      guard let clientID = FirebaseApp.app()?.options.clientID,
            let uiViewController = uiViewController
      else { throw SimpleError("Unable to sign in")  }
      let config = GIDConfiguration(clientID: clientID)      
      GIDSignIn.sharedInstance.configuration = config
  
      let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: uiViewController)
      
      guard let idToken = gidSignInResult.user.idToken?.tokenString
      else {throw SimpleError("Unable to sign in") }
      
      let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: gidSignInResult.user.accessToken.tokenString)
      
      try await Auth.auth().signIn(with: credential)
    }
  }
}

private enum SignInType {
  case signIn
  case signUp
}

#Preview {
  SignInView()
}
