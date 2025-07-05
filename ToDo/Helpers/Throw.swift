//
//  Throw.swift
//  ToDo
//
//  Created by David Záruba on 09.02.2025.
//
import SwiftUI

struct Throw: EnvironmentKey {
  static var defaultValue: Self = .init()
  var handleError: (Error) -> Void = { error in
//#if DEBUG
//    raise(SIGINT) // trigger a breakpoint
//#endif
  }
}

extension Throw {
  func callAsFunction(_ error: Error) {
    self.handleError(error)
  }
  
  func `try`(_ work: () throws -> Void) {
    do {
      try work()
    } catch {
      self(error)
    }
  }
  
  func `try`(_ work: @escaping () async throws -> Void) async {
    do {
      try await work()
    } catch {
      self(error)
    }
  }
  
  func task(_ work: @escaping () async throws -> Void) -> Task<Void, Never> {
    Task { @MainActor in
      await `try`(work)
    }
  }
}
