//
//  EnviromentValues.swift
//  ToDo
//
//  Created by David Záruba on 07.02.2025.
//

import SwiftUI

extension EnvironmentValues {
    var user: User {
        get { self[User.self] }
        set { self[User.self] = newValue }
    }
}
