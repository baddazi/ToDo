//
//  SimpleError.swift
//  ToDo
//
//  Created by David Záruba on 07.02.2025.
//

import Foundation

struct SimpleError: LocalizedError {
  var errorDescription: String?
}

extension SimpleError {
  init(_ errorDescription: String?) {
    self.init(errorDescription: errorDescription)
  }
}
