//
//  ExpensesTrackerView.swift
//  PawPlan
//
//  Created for PawPlan Pet Expenses.
//

import SwiftUI

public struct ExpensesTrackerView: View {
    @ObservedObject var container: AppDependencyContainer

    @State private var expenses: [Expense] = []
    @State private var summary: ExpenseSummary?
    @State private var showAddExpenseSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var csvExportString: String = ""

    public init(container: AppDependencyContainer) {
        self.container = container
    }

    public var body: some View {
        ZStack {
            PawPlanTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Summary Banner Card
                    if let summary = summary {
                        ExpenseBudgetBanner(summary: summary)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                    }

                    // Category Breakdown Cards
                    if let summary = summary, !summary.categoryBreakdown.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CATEGORY BREAKDOWN")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .tracking(1)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(Array(summary.categoryBreakdown.keys), id: \.self) { cat in
                                    let amount = summary.categoryBreakdown[cat] ?? 0.0
                                    CategoryExpenseTile(category: cat, amount: amount)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Recent Expenses List
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("EXPENSE TRANSACTIONS")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .tracking(1)
                            Spacer()
                            Button {
                                exportCSV()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Export CSV")
                                }
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(PawPlanTheme.electricTurquoise)
                            }
                        }

                        if expenses.isEmpty {
                            Text("No expenses logged yet. Tap '+' to record vet bills, kibble, or gear.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(PawPlanTheme.textSecondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(expenses) { exp in
                                ExpenseRow(expense: exp)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Pet Expenses")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddExpenseSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
        .sheet(isPresented: $showAddExpenseSheet) {
            AddExpenseModal(container: container, isPresented: $showAddExpenseSheet)
                .onDisappear { loadExpenses() }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [csvExportString])
        }
        .onAppear { loadExpenses() }
        .onChange(of: container.activeDog) { loadExpenses() }
    }

    private func loadExpenses() {
        guard let dog = container.activeDog else { return }
        do {
            expenses = try container.expenseRepository.fetchExpenses(for: dog.id, from: nil, to: nil)
            summary = try container.manageExpensesUseCase.executeSummary(for: dog.id)
        } catch {
            print("Failed to load expenses: \(error)")
        }
    }

    private func exportCSV() {
        guard let dog = container.activeDog else { return }
        do {
            csvExportString = try container.manageExpensesUseCase.executeExportCSV(for: dog.id)
            showShareSheet = true
        } catch {
            print("Error exporting CSV: \(error)")
        }
    }
}

private struct ExpenseBudgetBanner: View {
    let summary: ExpenseSummary

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Care Total (AUD)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)

                    Text(String(format: "$%.2f", summary.totalAmount))
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(PawPlanTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Budget Goal")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                    Text(String(format: "$%.0f", summary.monthlyBudgetGoal))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PawPlanTheme.expenses)
                }
            }

            // Budget bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(PawPlanTheme.cardBackgroundElevated)
                        .frame(height: 8)

                    Capsule()
                        .fill(summary.isOverBudget ? PawPlanTheme.pinkGradient : PawPlanTheme.turquoiseGradient)
                        .frame(width: min(geo.size.width, geo.size.width * CGFloat(summary.totalAmount / max(1.0, summary.monthlyBudgetGoal))), height: 8)
                }
            }
            .frame(height: 8)

            HStack {
                Text(summary.isOverBudget ? "Over monthly target" : String(format: "$%.2f remaining", summary.remainingBudget))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(summary.isOverBudget ? PawPlanTheme.vetHealth : PawPlanTheme.lightCyan)
                Spacer()
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PawPlanTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1.2)
                )
        )
    }
}

private struct CategoryExpenseTile: View {
    let category: ExpenseCategory
    let amount: Double

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex).opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: category.iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: category.colorHex))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)
                    .lineLimit(1)
                Text(String(format: "$%.2f", amount))
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(PawPlanTheme.cardBackgroundElevated)
        )
    }
}

private struct ExpenseRow: View {
    let expense: Expense

    private var dateString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: expense.date)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: expense.category.colorHex).opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: expense.category.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: expense.category.colorHex))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.merchant ?? expense.category.rawValue)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.textPrimary)

                HStack(spacing: 6) {
                    Text(expense.category.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textSecondary)
                    Text("•")
                        .foregroundColor(PawPlanTheme.textTertiary)
                    Text(dateString)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(PawPlanTheme.textTertiary)
                }
            }

            Spacer()

            Text(expense.formattedAmount)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(PawPlanTheme.textPrimary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(PawPlanTheme.cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(PawPlanTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

public struct AddExpenseModal: View {
    @ObservedObject var container: AppDependencyContainer
    @Binding var isPresented: Bool

    @State private var amountString: String = "45.00"
    @State private var category: ExpenseCategory = .food
    @State private var merchant: String = "PetO Alexandria"
    @State private var date: Date = Date()
    @State private var notes: String = ""

    public var body: some View {
        NavigationView {
            ZStack {
                PawPlanTheme.background
                    .ignoresSafeArea()

                Form {
                    Section(header: Text("Expense Information").foregroundColor(PawPlanTheme.textSecondary)) {
                        TextField("Amount (AUD $)", text: $amountString)
                            .keyboardType(.decimalPad)

                        Picker("Category", selection: $category) {
                            ForEach(ExpenseCategory.allCases, id: \.self) { c in
                                Text(c.rawValue).tag(c)
                            }
                        }

                        TextField("Merchant / Vet Clinic", text: $merchant)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .tint(PawPlanTheme.electricTurquoise)
                        TextField("Notes / Description", text: $notes)
                    }
                    .listRowBackground(PawPlanTheme.cardBackgroundElevated)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Record Pet Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                        .foregroundColor(PawPlanTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard let dog = container.activeDog else { return }
                        let amount = Double(amountString) ?? 0.0
                        let exp = Expense(
                            dogId: dog.id,
                            category: category,
                            amount: amount,
                            currency: "AUD",
                            date: date,
                            merchant: merchant.isEmpty ? nil : merchant,
                            notes: notes.isEmpty ? nil : notes
                        )
                        try? container.manageExpensesUseCase.executeSave(exp)
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(PawPlanTheme.electricTurquoise)
                }
            }
        }
    }
}

public struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    public func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
