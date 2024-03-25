//
//  AddView.swift
//  iExpense
//
//  Created by Ali Khaled on 3/22/2024
//



import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss  // For dismissing the view
    
    @State private var name = ""
    @State private var type = "Personal"
    @State private var amount = 0.0
    
    let types = ["Business", "Personal"]
    
    var expenses: Expenses
    
    var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"  // Fallback to USD if the currency code isn't available
        }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }

                TextField("Amount", value: $amount, format: .currency(code: currencyCode)).keyboardType(.decimalPad)
            }
            .navigationTitle("Add new expense")
            .toolbar {
                Button("Save") {
                    if isValidExpense() {  // Check if the expense is valid before saving
                        let item = ExpenseItem(name: name, type: type, amount: amount)
                        expenses.items.append(item)
                        dismiss()  // Dismiss the AddView after saving
                    }
                }
            }
        }
    }
    
    // A simple validation function to check the expense details
    private func isValidExpense() -> Bool {
        !name.isEmpty && amount > 0
    }
}

// Preview provider to test the AddView in Xcode
struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(expenses: Expenses())
    }
}
