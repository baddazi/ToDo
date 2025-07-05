//
//  FilterView.swift
//  ToDo
//
//  Created by David Záruba on 31.03.2025.


// TODO: DoubleSlider, acepteble movemnt only three top.


import SwiftUI

struct FilterView: View {
  @Environment(\.dismiss) var dismiss
  @State var todoLists: [TodoList]
  @State var boundaries: Filter
  @Binding var activeFilter: Filter?
  @State var currentFilter: Filter
  @Binding var completedTodoListActive: CompletedTodoList
  @State var completedTodoList: CompletedTodoList
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          if todoLists.count > 1 {
            Section(header: Text("Priority")) {
              prioriyFiler
            }
            Divider()
            Section(header: Text("Completion status")) {
              competedTaskFilter
            }
            Divider()
            Section(header: Text("Created at")) {
              createdAtFilter
            }
            Divider()
            Section(header: Text("Updated at")) {
              updatedAtFilter
            }
            Divider()
            Section(header: Text("Due date")) {
              dueDateFilter
            }
            Spacer()
          }
          else {
            Text("Not enough ToDo Lists to apply filter")
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
        ToolbarItem(placement: .topBarLeading) {
          Image(systemName: activeFilter != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
            .foregroundStyle(Color.secondary)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Text(currentFilter.filterTodoList(todoLists: todoLists, state: completedTodoList).count.formatted())
            .foregroundStyle(.red)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            activeFilter = currentFilter
            completedTodoListActive = completedTodoList
          }
          .disabled(isSaveDisable())
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Clear") {
            currentFilter = boundaries
            activeFilter = nil
            completedTodoListActive = .both
            completedTodoList = .both
          }
          .disabled(isClearDisable())
        }
      }
    }
  }
  
  private var prioriyFiler: some View {
    VStack {
      if boundaries.priorityRange.lowerBound != boundaries.priorityRange.upperBound {
        HStack {
          Text("From:")
            .frame(width: 50, alignment: .leading)
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
        
        HStack {
          Text("To:")
            .frame(width: 50, alignment: .leading)
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
      } else {
        Text("Not enough Todo lists to apply priority filter")
      }
    }
  }
  private var createdAtFilter: some View {
    VStack {
      if boundaries.createDateRange.lowerBound != boundaries.createDateRange.upperBound {
        VStack {
          DatePicker("From:", selection: Binding<Date> {
            currentFilter.createDateRange.lowerBound
          } set: { newValue in
            if newValue <= currentFilter.createDateRange.upperBound && newValue >= boundaries.createDateRange.lowerBound {
              currentFilter.createDateRange = newValue...currentFilter.createDateRange.upperBound
            }
          }, in: boundaries.createDateRange.lowerBound ... currentFilter.createDateRange.upperBound, displayedComponents: .date)
          .padding()
        }
        
        VStack {
          DatePicker("To:", selection: Binding<Date> {
            currentFilter.createDateRange.upperBound
          } set: { newValue in
            if newValue >= currentFilter.createDateRange.lowerBound && newValue <= boundaries.createDateRange.upperBound {
              currentFilter.createDateRange = newValue...currentFilter.createDateRange.upperBound
            }
          }, in: currentFilter.createDateRange.lowerBound ... boundaries.createDateRange.upperBound, displayedComponents: .date)
          .padding()
        }
      } else {
        Text("Not enough Todo lists to apply created at filter")
      }
    }
  }
  private var updatedAtFilter: some View {
    VStack {
      if boundaries.updatedDateRange.lowerBound != boundaries.updatedDateRange.upperBound {
        VStack {
          DatePicker("From:", selection: Binding<Date> {
            currentFilter.updatedDateRange.lowerBound
          } set: { newValue in
            if newValue <= currentFilter.updatedDateRange.upperBound && newValue >= boundaries.updatedDateRange.lowerBound {
              currentFilter.updatedDateRange = newValue...currentFilter.updatedDateRange.upperBound
            }
          }, in: boundaries.updatedDateRange.lowerBound ... currentFilter.updatedDateRange.upperBound, displayedComponents: .date)
          .padding()
        }
        
        VStack {
          DatePicker("To:", selection: Binding<Date> {
            currentFilter.updatedDateRange.upperBound
          } set: { newValue in
            if newValue >= currentFilter.updatedDateRange.lowerBound && newValue <= boundaries.updatedDateRange.upperBound {
              currentFilter.updatedDateRange = newValue...currentFilter.updatedDateRange.upperBound
            }
          }, in: currentFilter.updatedDateRange.lowerBound...boundaries.updatedDateRange.upperBound, displayedComponents: .date)
          .padding()
        }
      } else {
        Text("Not enough Todo lists to apply updatedAt filter")
      }
    }
  }
  private var dueDateFilter: some View {
    VStack {
      if todoLists.filter({$0.dueDate == nil}).count != 0 {
        Toggle("Include undefine due date", isOn: $currentFilter.isNotDefineDueDateIncluded)
          .padding()
      }
      VStack {
        if boundaries.dueDateRange.lowerBound != boundaries.dueDateRange.upperBound &&
      boundaries.dueDateRange.lowerBound != .distantPast && boundaries.dueDateRange.upperBound != .distantFuture {
          VStack {
            DatePicker("From:", selection: Binding<Date> {
              currentFilter.dueDateRange.lowerBound
            } set: { newValue in
              if newValue <= currentFilter.dueDateRange.upperBound && newValue >= boundaries.dueDateRange.lowerBound {
                currentFilter.dueDateRange = newValue...currentFilter.dueDateRange.upperBound
              }
            }, in: boundaries.dueDateRange.lowerBound...currentFilter.dueDateRange.upperBound, displayedComponents: .date)
          }
          .padding()
          VStack {
            DatePicker("To:", selection: Binding<Date> {
              currentFilter.dueDateRange.upperBound
            } set: { newValue in
              if newValue >= currentFilter.dueDateRange.lowerBound && newValue <= boundaries.dueDateRange.upperBound {
                currentFilter.dueDateRange = newValue...currentFilter.dueDateRange.upperBound
              }
            }, in: currentFilter.dueDateRange.lowerBound...boundaries.dueDateRange.upperBound, displayedComponents: .date)
            .padding()
          }
        } else {
          Text("Not enough Todo lists to apply due dates filter")
        }
      }
    }
  }
  private var competedTaskFilter: some View {
    Picker("Priority", selection: $completedTodoList) {
      ForEach(CompletedTodoList.allCases) { option in
        Text(option.rawValue).tag(option)
      }
    }
    .pickerStyle(.segmented)
    .padding()
  }
  
  func isSaveDisable() -> Bool {
    if activeFilter == currentFilter && completedTodoList == completedTodoListActive {
      return true
    }
    
    if currentFilter == boundaries && completedTodoList == .both {
      return true
    }
    return false
  }
  
  func isClearDisable() -> Bool {
    if activeFilter == nil && currentFilter == boundaries && completedTodoListActive == .both && completedTodoList == .both {
      return true
    }
    return false
  }
}


#Preview {
  FilterView(todoLists: [], boundaries: Filter.sample(), activeFilter: .constant(nil), currentFilter: Filter.sample(), completedTodoListActive: .constant(CompletedTodoList.both), completedTodoList: (CompletedTodoList.both))
}
