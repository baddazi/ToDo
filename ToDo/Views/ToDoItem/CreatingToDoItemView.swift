//
//  CreatingToDoItemView.swift
//  ToDo
//
//  Created by David Záruba on 26.03.2025.
//

import SwiftUI

struct CreatingToDoItemView: View {
  @Environment(\.firebaseManager) var firebaseManager
  @Environment(\.`throw`) var `throw`
  @Environment(\.dismiss) var dismiss
  
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    CreatingToDoItemView()
}
