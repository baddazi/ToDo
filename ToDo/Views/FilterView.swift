//
//  FilterView.swift
//  ToDo
//
//  Created by David Záruba on 31.03.2025.

import SwiftUI

struct FilterView: View {
  @Environment(\.dismiss) var dismiss
  @State var toDoLists: [ToDoList]
  @State var boundaries: Filter
  @Binding var activeFilter: Filter?
  @State var currentFilter: Filter
  @State private var lowwerBoundCreteAtType: DateTypeMovement = .days
  @State private var upperBoundCreteAtType: DateTypeMovement = .days
  @State private var lowwerBoundUpdateAtType: DateTypeMovement = .days
  @State private var upperBoundUpdateAtType: DateTypeMovement = .days
  @State private var lowwerBoundDueDateRangeType: DateTypeMovement = .days
  @State private var upperBoundDueDateRangeType: DateTypeMovement = .days
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          if toDoLists.count > 1 {
            prioriyFiler
            Divider()
            createdAtFilter
            Divider()
            updatedAtFilter
            Divider()
            dueDateFilter
            Spacer()
          }
          else {
            Text("Not enough ToDoLists to apply filter")
          }
        }
      }
      .navigationTitle("Filter")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Close") {
            dismiss()
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Text(currentFilter.filterToDoList(toDoLists: toDoLists).count.formatted())
            .foregroundStyle(.red)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            activeFilter = currentFilter
          }
          .disabled(activeFilter == currentFilter || currentFilter == boundaries)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Clear") {
            currentFilter = boundaries
            activeFilter = nil
          }
          .disabled(activeFilter == boundaries && currentFilter == boundaries)
        }
      }
    }
  }
  
  private var prioriyFiler: some View {
    VStack {
      Text("Priority")
      if boundaries.priorityRange.lowerBound != boundaries.priorityRange.upperBound {
        HStack {
          Text("From")
          TextField("", value: Binding<Int> {
            currentFilter.priorityRange.lowerBound
          } set: { newValue in
            if newValue <= currentFilter.priorityRange.upperBound && newValue >= boundaries.priorityRange.lowerBound {
              currentFilter.priorityRange = newValue...currentFilter.priorityRange.upperBound
            }
          }, format: .number)
          .textFieldStyle(.roundedBorder)
        }
        .padding()
        
        Slider(value: Binding<Double> {
          Double(currentFilter.priorityRange.lowerBound)
        } set: { newValue in
          let newValue = Int(newValue)
          if (newValue <= currentFilter.priorityRange.upperBound) {
            currentFilter.priorityRange = newValue...(currentFilter.priorityRange.upperBound)
          }
        }, in: Double(boundaries.priorityRange.lowerBound)...Double(boundaries.priorityRange.upperBound), step: 1) {
          Text("Priority lower bound")
        } minimumValueLabel: {
          Text(boundaries.priorityRange.lowerBound.formatted())
        } maximumValueLabel: {
          Text(boundaries.priorityRange.upperBound.formatted())
        }
        .padding()
        
        VStack {
          HStack {
            Text("To")
            TextField("", value: Binding<Int> {
              currentFilter.priorityRange.upperBound
            } set: { newValue in
              if newValue >= currentFilter.priorityRange.lowerBound && newValue <= boundaries.priorityRange.upperBound {
                currentFilter.priorityRange = currentFilter.priorityRange.lowerBound...newValue
              }
            }, format: .number)
            .textFieldStyle(.roundedBorder)
          }
          .padding()
          
          Slider(value: Binding<Double> {
            Double(currentFilter.priorityRange.upperBound)
          } set: { newValue in
            let newValue = Int(newValue)
            if (newValue >= currentFilter.priorityRange.lowerBound) {
              currentFilter.priorityRange = currentFilter.priorityRange.lowerBound...Int(newValue)
            }
          }, in: Double(boundaries.priorityRange.lowerBound)...(Double(boundaries.priorityRange.upperBound)), step: 1) {
            Text("")
          } minimumValueLabel: {
            Text(boundaries.priorityRange.lowerBound.formatted())
          } maximumValueLabel: {
            Text(boundaries.priorityRange.upperBound.formatted())
          }
          .padding()
        }
      } else {
        Text("Not enough ToDoLists to apply priority filter")
      }
    }
  }
  private var createdAtFilter: some View {
    VStack {
      Text("Created at")
      if boundaries.createDateRange.lowerBound != boundaries.createDateRange.upperBound {
        VStack {
          DatePicker("from:", selection: Binding<Date> {
            currentFilter.createDateRange.lowerBound
          } set: { newValue in
            if newValue <= currentFilter.createDateRange.upperBound && newValue >= boundaries.createDateRange.lowerBound {
              currentFilter.createDateRange = newValue...currentFilter.createDateRange.upperBound
            }
          })
          .padding()
          
          HStack {
            Text("Move by: ")
            Picker("movement type ", selection: $lowwerBoundCreteAtType) {
              let acceptableMovements = DateTypeMovement.acceptableMovements(from: boundaries.createDateRange.lowerBound, to: boundaries.createDateRange.upperBound)
              
              ForEach(DateTypeMovement.allCases, id: \.self.rawValue) { movement in
                if acceptableMovements.contains(movement) {
                  Text(movement.rawValue).tag(movement)
                }
              }
            }
            .pickerStyle(MenuPickerStyle())
          }
          
          VStack {
            
            Slider(value: Binding<Double> {
              currentFilter.createDateRange.lowerBound.timeIntervalSince1970
            } set: { newValue in
              let newDateValue = Date(timeIntervalSince1970: newValue)
              if newDateValue <= currentFilter.createDateRange.upperBound  {
                if ((boundaries.updatedDateRange.upperBound.timeIntervalSince1970 - newValue) < lowwerBoundCreteAtType.movementInSeconds()) {
                  currentFilter.createDateRange = currentFilter.createDateRange.upperBound...currentFilter.createDateRange.upperBound
                } else {
                  currentFilter.createDateRange = newDateValue...currentFilter.createDateRange.upperBound
                }
              }
            }, in: boundaries.createDateRange.lowerBound.timeIntervalSince1970...boundaries.createDateRange.upperBound.timeIntervalSince1970,
                   step: lowwerBoundCreteAtType.movementInSeconds())
            HStack {
              Text(boundaries.createDateRange.lowerBound.formatted(date: .numeric, time: .omitted))
              Spacer()
              Text(boundaries.createDateRange.upperBound.formatted(date: .numeric, time: .omitted))
            }
          }
          .padding()
        }
        
        VStack {
          DatePicker("to:", selection: Binding<Date> {
            currentFilter.createDateRange.upperBound
          } set: { newValue in
            if newValue >= currentFilter.createDateRange.lowerBound && newValue <= boundaries.createDateRange.upperBound {
              currentFilter.createDateRange = newValue...currentFilter.createDateRange.upperBound
            }
          })
          .padding()
          
          HStack {
            Text("Move by: ")
            Picker("movement type ", selection: $upperBoundCreteAtType) {
              let acceptableMovements = DateTypeMovement.acceptableMovements(from: boundaries.createDateRange.lowerBound, to: boundaries.createDateRange.upperBound)
              ForEach(DateTypeMovement.allCases, id: \.self.rawValue) { movement in
                if acceptableMovements.contains(movement) {
                  Text(movement.rawValue).tag(movement)
                }
              }
            }
            .pickerStyle(MenuPickerStyle())
          }
          
          VStack {
            Slider(value: Binding<Double> {
              currentFilter.createDateRange.upperBound.timeIntervalSince1970
            } set: { newValue in
              let newDateValue = Date(timeIntervalSince1970: newValue)
              if currentFilter.createDateRange.lowerBound <= newDateValue {
                if ((boundaries.createDateRange.upperBound.timeIntervalSince1970 - newValue) < upperBoundCreteAtType.movementInSeconds()) {
                  currentFilter.createDateRange = currentFilter.createDateRange.lowerBound...boundaries.createDateRange.upperBound
                } else {
                  currentFilter.createDateRange = currentFilter.createDateRange.lowerBound...newDateValue
                }
              }
            }, in: boundaries.createDateRange.lowerBound.timeIntervalSince1970...boundaries.createDateRange.upperBound.timeIntervalSince1970,
                   step: upperBoundCreteAtType.movementInSeconds())
            HStack {
              Text(boundaries.createDateRange.lowerBound.formatted(date: .numeric, time: .omitted))
              Spacer()
              Text(boundaries.createDateRange.upperBound.formatted(date: .numeric, time: .omitted))
            }
          }
          .padding()
        }
      } else {
        Text("Not enough ToDoLists to apply created at filter")
      }
    }
  }
  private var updatedAtFilter: some View {
    VStack {
      Text("Updated at")
      if boundaries.updatedDateRange.lowerBound != boundaries.updatedDateRange.upperBound {
        VStack {
          DatePicker("from:", selection: Binding<Date> {
            currentFilter.updatedDateRange.lowerBound
          } set: { newValue in
            if newValue <= currentFilter.updatedDateRange.upperBound && newValue >= boundaries.updatedDateRange.lowerBound {
              currentFilter.updatedDateRange = newValue...currentFilter.updatedDateRange.upperBound
            }
          })
          .padding()
          
          HStack {
            Text("Move by: ")
            Picker("movement type ", selection: $lowwerBoundUpdateAtType) {
              let acceptableMovements = DateTypeMovement.acceptableMovements(from: boundaries.updatedDateRange.lowerBound, to: boundaries.updatedDateRange.upperBound)
              
              ForEach(DateTypeMovement.allCases, id: \.self.rawValue) { movement in
                if acceptableMovements.contains(movement) {
                  Text(movement.rawValue).tag(movement)
                }
              }
            }
            .pickerStyle(MenuPickerStyle())
          }
          
          VStack {
            
            Slider(value: Binding<Double> {
              currentFilter.updatedDateRange.lowerBound.timeIntervalSince1970
            } set: { newValue in
              let newDateValue = Date(timeIntervalSince1970: newValue)
              if newDateValue <= currentFilter.updatedDateRange.upperBound  {
                if ((boundaries.updatedDateRange.upperBound.timeIntervalSince1970 - newValue) < lowwerBoundUpdateAtType.movementInSeconds()) {
                  currentFilter.updatedDateRange = currentFilter.updatedDateRange.upperBound...currentFilter.updatedDateRange.upperBound
                } else {
                  currentFilter.updatedDateRange = newDateValue...currentFilter.updatedDateRange.upperBound
                }
                
              }
            }, in: boundaries.updatedDateRange.lowerBound.timeIntervalSince1970...boundaries.updatedDateRange.upperBound.timeIntervalSince1970,
                   step: lowwerBoundUpdateAtType.movementInSeconds())
            HStack {
              Text(boundaries.updatedDateRange.lowerBound.formatted(date: .numeric, time: .omitted))
              Spacer()
              Text(boundaries.updatedDateRange.upperBound.formatted(date: .numeric, time: .omitted))
            }
          }
          .padding()
        }
        
        VStack {
          DatePicker("to:", selection: Binding<Date> {
            currentFilter.updatedDateRange.upperBound
          } set: { newValue in
            if newValue >= currentFilter.updatedDateRange.lowerBound && newValue <= boundaries.updatedDateRange.upperBound {
              currentFilter.updatedDateRange = newValue...currentFilter.updatedDateRange.upperBound
            }
          })
          .padding()
          
          HStack {
            Text("Move by: ")
            Picker("movement type ", selection: $upperBoundUpdateAtType) {
              let acceptableMovements = DateTypeMovement.acceptableMovements(from: boundaries.updatedDateRange.lowerBound, to: boundaries.updatedDateRange.upperBound)
              ForEach(DateTypeMovement.allCases, id: \.self.rawValue) { movement in
                if acceptableMovements.contains(movement) {
                  Text(movement.rawValue).tag(movement)
                }
              }
            }
            .pickerStyle(MenuPickerStyle())
          }
          
          VStack {
            Slider(value: Binding<Double> {
              currentFilter.updatedDateRange.upperBound.timeIntervalSince1970
            } set: { newValue in
              let newDateValue = Date(timeIntervalSince1970: newValue)
              if currentFilter.updatedDateRange.lowerBound <= newDateValue {
                if ((boundaries.updatedDateRange.upperBound.timeIntervalSince1970 - newValue) < upperBoundUpdateAtType.movementInSeconds()) {
                  currentFilter.updatedDateRange = currentFilter.updatedDateRange.lowerBound...boundaries.updatedDateRange.upperBound
                } else {
                  currentFilter.updatedDateRange = currentFilter.updatedDateRange.lowerBound...newDateValue
                }
              }
            }, in: boundaries.updatedDateRange.lowerBound.timeIntervalSince1970...boundaries.updatedDateRange.upperBound.timeIntervalSince1970,
                   step: upperBoundUpdateAtType.movementInSeconds())
            HStack {
              Text(boundaries.updatedDateRange.lowerBound.formatted(date: .numeric, time: .omitted))
              Spacer()
              Text(boundaries.updatedDateRange.upperBound.formatted(date: .numeric, time: .omitted))
            }
          }
          .padding()
        }
      } else {
        Text("Not enough ToDoLists to apply updatedAt filter")
      }
    }
  }
  private var dueDateFilter: some View {
    VStack {
      Text("Due date")
      if toDoLists.filter({$0.dueDate == nil}).count != 0 {
        Toggle("Include not defined due date", isOn: $currentFilter.isNotDefineDueDateIncluded)
      }
      VStack {
        if boundaries.dueDateRange.lowerBound != boundaries.dueDateRange.upperBound {
          VStack {
            DatePicker("from:", selection: Binding<Date> {
              currentFilter.dueDateRange.lowerBound
            } set: { newValue in
              if newValue <= currentFilter.dueDateRange.upperBound && newValue >= boundaries.dueDateRange.lowerBound {
                currentFilter.dueDateRange = newValue...currentFilter.dueDateRange.upperBound
              }
            })
            .padding()
          }
          
          HStack {
            Text("Move by: ")
            Picker("movement type ", selection: $lowwerBoundDueDateRangeType) {
              let acceptableMovements = DateTypeMovement.acceptableMovements(from: boundaries.dueDateRange.lowerBound, to: boundaries.dueDateRange.upperBound)
              
              ForEach(DateTypeMovement.allCases, id: \.self.rawValue) { movement in
                if acceptableMovements.contains(movement) {
                  Text(movement.rawValue).tag(movement)
                }
              }
            }
            .pickerStyle(MenuPickerStyle())
          }
          
          VStack {
            Slider(value: Binding<Double> {
              currentFilter.dueDateRange.lowerBound.timeIntervalSince1970
            } set: { newValue in
              let newDateValue = Date(timeIntervalSince1970: newValue)
              if newDateValue <= currentFilter.dueDateRange.upperBound  {
                if ((boundaries.dueDateRange.upperBound.timeIntervalSince1970 - newValue) < lowwerBoundDueDateRangeType.movementInSeconds()) { currentFilter.dueDateRange = currentFilter.dueDateRange.upperBound...currentFilter.dueDateRange.upperBound
                } else {
                  currentFilter.dueDateRange = newDateValue...currentFilter.dueDateRange.upperBound
                }
              }
            }, in: boundaries.dueDateRange.lowerBound.timeIntervalSince1970...boundaries.dueDateRange.upperBound.timeIntervalSince1970,
                   step: lowwerBoundDueDateRangeType.movementInSeconds())
            HStack {
              Text(boundaries.dueDateRange.lowerBound.formatted(date: .numeric, time: .omitted))
              Spacer()
              Text(boundaries.dueDateRange.upperBound.formatted(date: .numeric, time: .omitted))
            }
          }
          .padding()
          
          VStack {
          DatePicker("to:", selection: Binding<Date> {
            currentFilter.dueDateRange.upperBound
          } set: { newValue in
            if newValue >= currentFilter.dueDateRange.lowerBound && newValue <= boundaries.dueDateRange.upperBound {
              currentFilter.dueDateRange = newValue...currentFilter.dueDateRange.upperBound
            }
          })
          .padding()
          
          HStack {
            Text("Move by: ")
            Picker("movement type ", selection: $upperBoundDueDateRangeType) {
              let acceptableMovements = DateTypeMovement.acceptableMovements(from: boundaries.dueDateRange.lowerBound, to: boundaries.dueDateRange.upperBound)
              ForEach(DateTypeMovement.allCases, id: \.self.rawValue) { movement in
                if acceptableMovements.contains(movement) {
                  Text(movement.rawValue).tag(movement)
                }
              }
            }
            .pickerStyle(MenuPickerStyle())
          }
          
          VStack {
            Slider(value: Binding<Double> {
              currentFilter.dueDateRange.upperBound.timeIntervalSince1970
            } set: { newValue in
              let newDateValue = Date(timeIntervalSince1970: newValue)
              if currentFilter.dueDateRange.lowerBound <= newDateValue {
                if ((boundaries.dueDateRange.upperBound.timeIntervalSince1970 - newValue) < lowwerBoundDueDateRangeType.movementInSeconds()) {
                  currentFilter.dueDateRange = currentFilter.dueDateRange.lowerBound...boundaries.dueDateRange.upperBound
                } else {
                  currentFilter.dueDateRange = currentFilter.dueDateRange.lowerBound...newDateValue
                }
              }
            }, in: boundaries.dueDateRange.lowerBound.timeIntervalSince1970...boundaries.dueDateRange.upperBound.timeIntervalSince1970,
                   step: upperBoundDueDateRangeType.movementInSeconds())
            HStack {
              Text(boundaries.dueDateRange.lowerBound.formatted(date: .numeric, time: .omitted))
              Spacer()
              Text(boundaries.dueDateRange.upperBound.formatted(date: .numeric, time: .omitted))
            }
          }
          .padding()
        }
      } else {
        Text("Not enough ToDoLists to apply due dates filter")
      }
      }
     
    }
  }
}

#Preview {
  FilterView(toDoLists: [], boundaries: Filter.sample(), activeFilter: .constant(nil), currentFilter: Filter.sample())
}

private enum DateTypeMovement: String, CaseIterable {
  case minutes = "Minutes"
  case hours = "Hours"
  case days = "Days"
  // for now skipping months. I want to move by count of secons and moths have different lenghts. Its easealy solvable by using build in Calendar matematic but its too much work for now. Mayby later.
  case years = "Years"
  
 static func acceptableMovements(from startDate: Date, to endDate: Date) -> [DateTypeMovement] {
    var acceptableMovements: [DateTypeMovement] = []
   let components = Calendar.current.dateComponents([.minute, .hour, .day, .year], from: startDate, to: endDate)
    
   if components.minute ?? 0 > 1 {
     acceptableMovements.append(.minutes)
   }
   
   if components.hour ?? 0 > 1 {
     acceptableMovements.append(.hours)
   }
   
   if components.day ?? 0 > 1 {
     acceptableMovements.append(.days)
   }

   if components.year ?? 0 > 1 {
     acceptableMovements.append(.years)
   }
   
   return acceptableMovements
  }
  
  static func isShowable(from startDate: Date, to endDate: Date) -> Bool {
    return acceptableMovements(from: startDate, to: endDate).count > 0
  }
  
  func movementInSeconds() -> Double {
    switch self {
    case .minutes:
      return 60
    case .hours:
      return 60 * 60
    case .days:
      return 60 * 60 * 24
    case .years:
      // probably not precices. For our cases probobly good enough. I shoud look to use Calendar for adding years and convert back to Double. Mayby I will do that later.
      return 60 * 60 * 24 * 365
    }
  }
}
