//
//  HistoryView.swift
//  Cabbage-iOS
//
//  Created by Harrison Kleiman on 6/13/22.
//

import SwiftUI

import SwiftUI

struct StatisticsGraphView: View{
    @EnvironmentObject var expenseViewModel: ExpenseViewModel
    // MARK: Environment Values
    @Environment(\.self) var env
    @State var statisticsGraph: [StatisticsGraph] = []
    var body: some View{
        ScrollView(.vertical, showsIndicators: false) {
            VStack{
                HStack(spacing: 15){
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "arrow.backward.circle.fill")
                            .foregroundColor(Color("Cream"))
                            .frame(width: 40, height: 40)
                            .background(Color("Red"),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    }
                    
                    Text("Your Expense Trends")
                        .foregroundColor(Color("Green"))
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .opacity(0.7)
                        .frame(maxWidth: .infinity,alignment: .leading)
                }
                
                DynamicFilteredView(startDate: Date(), endDate: Date(), type: "NONE") { (expenses: FetchedResults<Expense>) in
                    VStack(spacing: 15){
                        ForEach(statisticsGraph) { graph in
                            GroupedCardView(graph: graph)
                        }
                    }
                    .padding(.top)
                    .onAppear {
                        groupByMonths(expenses: expenses)
                    }
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
        .background{
            Color("BG")
                .ignoresSafeArea()
        }
    }
    
    // MARK: Grouped Card View
    @ViewBuilder
    func GroupedCardView(graph: StatisticsGraph)-> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(graph.monthString)
                .font(.callout)
                .fontWeight(.semibold)
                .opacity(0.7)
            
            Text(convertExpensesToPrice(expenses: graph.expenses))
                .font(.title.bold())
                .padding(.vertical,10)
            
            HStack(spacing: 10){
                Circle()
                    .fill(Color("Green"))
                    .overlay {
                        Image(systemName: "arrow.up")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Income")
                        .font(.caption)
                        .opacity(0.7)
                    
                    Text(convertExpensesToPrice(expenses: graph.expenses,type: "Income"))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .opacity(0.7)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                
                Circle()
                    .fill(Color("Red"))
                    .overlay {
                        Image(systemName: "arrow.down")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expenses")
                        .font(.caption)
                        .opacity(0.7)
                    
                    Text(convertExpensesToPrice(expenses: graph.expenses,type: "Expenses"))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .opacity(0.7)
                }
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity,alignment: .leading)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.07), radius: 5, x: 5, y: 5)
        }
    }
    
    // MARK: Converting Expenses Into Group Of Months
    func groupByMonths(expenses: FetchedResults<Expense>){
        let groupedExpenses = Dictionary(grouping: expenses){$0.date!.month}
        for item in groupedExpenses{
            let expenses = item.value.compactMap { expense -> Expense? in
                return expense
            }
            let firstDate = item.value.first?.date ?? Date()
            let statisticsGraph: StatisticsGraph = .init(monthString: getDate(date: firstDate), monthDate: firstDate, expenses: expenses)
            self.statisticsGraph.append(statisticsGraph)
        }
        self.statisticsGraph = self.statisticsGraph.sorted(by: { first, scnd in
            return scnd.monthDate < first.monthDate
            
        })
    }
    
    // MARK: Date Formatter
    func getDate(date: Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        return formatter.string(from: date)
    }
    
    // MARK: Converting Expenses into Price
    func convertExpensesToPrice(expenses: [Expense],type: String = "")->String{
        var value: CGFloat = 0
        if type == ""{
            value = expenses.reduce(0.0) { partialResult, expense in
                return partialResult + (expense.type == "Income" ? expense.amount : -expense.amount)
            }
        }else{
            value = expenses.reduce(0.0) { partialResult, expense in
                return partialResult + (expense.type == type ? expense.amount : 0)
            }
        }
        
        return expenseViewModel.convertNumberToPrice(value: value)
    }
}
struct StatisticsGraphView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
