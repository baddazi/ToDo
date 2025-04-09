//
//  Extension.swift
//  ToDo
//
//  Created by David Záruba on 03.04.2025.
//

import Foundation
extension Date {
  static func nowWithouSec() -> Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date()))!
  }
  
  static func creatingTestingDate() -> Date {
    let years = Int.random(in: (-1)...0)
    let days = Int.random(in: (-360)...0)
    let hours = Int.random(in: (-23)...0)
    let mintues = Int.random(in: (-59)...0)
    
    return Calendar.current.date(byAdding: DateComponents(year: years, day: days, hour: hours, minute: mintues), to: Date.nowWithouSec())!
  }
  static func dueTestingDate() -> Date {
    let years = Int.random(in: (0)...1)
    let days = Int.random(in: (-10)...360)
    let hours = Int.random(in: (-23)...23)
    let mintues = Int.random(in: (-59)...59)
    
    return Calendar.current.date(byAdding: DateComponents(year: years, day: days, hour: hours, minute: mintues), to: Date.nowWithouSec())!
  }
}
