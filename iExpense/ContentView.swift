//
//  ContentView.swift
//  iExpense
//
//  Created by Ali Khaled on 3/22/2024
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()

    @State private var showingAddExpense = false
    private var personalExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type == "Personal" }
    }
    
    private var businessExpenses: [ExpenseItem] {
        expenses.items.filter { $0.type == "Business" }
    }

    var body: some View {
        NavigationStack {
            List {
                        Section(header: Text("Personal")) {
                            ForEach(expenses.items.filter { $0.type == "Personal" }) { item in
                            ExpenseRow(item: item)
                            }
                    .onDelete(perform: { offsets in
                        removeItems(at: offsets, from: "Personal")
                        })
                    }
                            
                            Section(header: Text("Business")) {
                                ForEach(expenses.items.filter { $0.type == "Business" }) { item in
                                    ExpenseRow(item: item)
                                }
                                .onDelete(perform: { offsets in
                                    removeItems(at: offsets, from: "Business")
                                })
                            }
                        }
            .navigationTitle("iExpense")
                        .toolbar {
                            Button("Add Expense", systemImage: "plus") {
                                showingAddExpense = true
                            }
                        }
                        .sheet(isPresented: $showingAddExpense) {
                            AddView(expenses: expenses)
                        }
                    }
                }

    func removeItems(at offsets: IndexSet, from category: String) {
            let itemsToRemove = expenses.items.enumerated().filter { offsets.contains($0.offset) && $0.element.type == category }.map { $0.element }
            for item in itemsToRemove {
                if let index = expenses.items.firstIndex(of: item) {
                    expenses.items.remove(at: index)
                }
            }
        }
    
    
    struct ExpenseRow: View {
            let item: ExpenseItem

            var body: some View {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.type)
                    }
                    Spacer()
                    Text(item.amount, format: .currency(code: Locale.current.currencyCode ?? "USD"))
                        .style(for: item.amount)
                }
            }
        }
}
extension View {
    func style(for amount: Double) -> some View {
        self.modifier(ExpenseAmountStyle(amount: amount))
    }
}
struct ExpenseAmountStyle: ViewModifier {
    let amount: Double
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(amountColor)
            .fontWeight(amountWeight)
    }
    
    private var amountColor: Color {
        if amount < 10 {
            return .green
        } else if amount < 100 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var amountWeight: Font.Weight {
        if amount < 10 {
            return .light
        } else if amount < 100 {
            return .regular
        } else {
            return .bold
        }
    }
}
