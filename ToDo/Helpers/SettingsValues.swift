import SwiftUI
var countOfDayToDeleteTodoList: Int = 30

struct AlertMessage: Identifiable {
  var id = UUID()
  var title: String
  var message: String
}
