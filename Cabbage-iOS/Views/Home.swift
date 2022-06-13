//
//  Home.swift
//  Cabbage-iOS
//
//  Created by Harrison Kleiman on 6/13/22.
//

import SwiftUI

struct Home: View{
    @StateObject var expenseViewModel: ExpenseViewModel = .init()
    @AppStorage("user_name") var userName: String = ""
    
    // MARK: - Face/Touch ID Properties
    @EnvironmentObject var lockModel: LockViewModel
    @AppStorage("lock_content") var lockContent: Bool = false
    
    // MARK: - Environment Values
    @Environment(\.self) var env
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false, content: {
            
            VStack(spacing: 12) {
                
                HStack(spacing: 15) {
                    
                    VStack(alignment: .leading, spacing: 4, content: {
                        
                        Text("Let's Manage \nYour Cabbage!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Green"))
                        
                        Text(userName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .onTapGesture {
                                expenseViewModel.askUsername()
                            }
                    })
                    .frame(maxWidth: .infinity,alignment: .leading)
                    
                    if lockModel.isAvailable{
                        Button {
                            lockContent.toggle()
                            if lockContent{
                                lockModel.authenticateUser()
                            }
                        } label: {
                            Image(systemName: !lockContent ? "lock.open" : "lock")
                                .foregroundColor(Color("Cream"))
                                .frame(width: 40, height: 40)
                                .background(Color("Red"),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .shadow(color: Color("BG").opacity(0.1), radius: 5, x: 5, y: 5)
                        }
                    }
                    
                    NavigationLink {
                        HistoryView()
                            .environmentObject(expenseViewModel)
                    } label: {
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(Color("Cream"))
                            .frame(width: 40, height: 40)
                            .background(Color("Red"),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    }
                    
                    NavigationLink {
                        FilterableTransactionView()
                            .environmentObject(expenseViewModel)
                    } label: {
                        
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color("Cream"))
                            .overlay(content: {
                               
                                Circle()
                                    .stroke(.white,lineWidth: 2)
                                    .padding(7)
                            })
                            .frame(width: 40, height: 40)
                            .background(Color("Red"),in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    }
                }
                
                DynamicFilteredView(startDate: expenseViewModel.currentMonthStartDate, endDate: Date(), type: "ALL") { (expenses: FetchedResults<Expense>) in
                    ExpenseCard(expenses: expenses)
                        .environmentObject(expenseViewModel)
                    Transactions(expenses: expenses)
                }
            }
            .padding()
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background{
            Color("BG")
                .ignoresSafeArea()
        }
        .overlay(alignment: .bottomTrailing) {
            AddButton()
                .padding()
        }
        .overlay {
            if expenseViewModel.addNewExpense{
                NewExpense()
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.easeInOut, value: expenseViewModel.addNewExpense)
    }
    
    // MARK: - Current Month Transactions View
    @ViewBuilder
    func Transactions(expenses: FetchedResults<Expense>)->some View{
        VStack {
            Text("Your Transactions")
                .font(.title2.bold())
                .foregroundColor(Color("Green").opacity(0.7))
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(.bottom)
            
            ForEach(expenses){ expense in
                TransactionCardView(expense: expense)
                    .environmentObject(expenseViewModel)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Add Expense/Income Button
    @ViewBuilder
    func AddButton() -> some View {
        Button {
            expenseViewModel.addNewExpense.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(Color("Cream"))
                .frame(width: 55, height: 55)
                .background{
                    Circle()
                        .fill(Color("Green"))
                }
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
        }
    }
    
    // MARK: New Expense View
    @ViewBuilder
    func NewExpense() -> some View {
        VStack {
            VStack(spacing: 15) {
                
                Text("Add a Transaction?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .opacity(0.8)
                    .foregroundColor(Color("Cream"))
                
                if let symbol = expenseViewModel.convertNumberToPrice(value: 0).first {
                    
                    HStack(alignment: .center, spacing: 6) {
                        TextField("0", text: $expenseViewModel.amount)
                        .font(.system(size: 35))
                        .foregroundColor(Color("Cream"))
                        .multilineTextAlignment(.center)
                        .textSelection(.disabled)
                        .keyboardType(.numberPad)
                        .background {
                            Text(expenseViewModel.amount == "" ? "0" : expenseViewModel.amount)
                                .font(.system(size: 35))
                                .opacity(0)
                                .overlay(alignment: .leading) {
                                    Text(String(symbol))
                                        .opacity(0.5)
                                        .offset(x: -15,y: 5)
                                }
                        }
                            
                    }
                    .padding(.vertical,10)
                    .frame(maxWidth: .infinity)
                    .background{
                        Capsule()
                            .fill(Color("Green"))
                    }
                    .padding(.horizontal, 50)
                    .padding(.top)
                }
                
                Label {
                    TextField("Note", text: $expenseViewModel.remark)
                        .padding(.leading, 10)
                        .foregroundColor(Color("BG"))
                } icon: {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.title3)
                        .foregroundColor(Color("Red"))
                }
                .padding(.vertical, 25)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("Cream"))
                }
                .padding(.top, 25)
                
                Label {
                    CheckBoxToggle()
                } icon: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title3)
                        .foregroundColor(Color("Red"))
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("Cream"))
                }
                .padding(.top,5)
                
                Label {
                    DatePicker("", selection: $expenseViewModel.expenseDate,displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(.leading,10)
                        .frame(maxWidth: .infinity,alignment: .leading)
                } icon: {
                    Image(systemName: "calendar")
                        .font(.title3)
                        .foregroundColor(Color("Red"))
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .background{
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("Cream"))
                }
                .padding(.top, 5)
            }
            .frame(maxHeight: .infinity,alignment: .center)
            
            Button {
                expenseViewModel.addExpense(env: env)
            } label: {
                
                Text("Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical,15)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color("Cream"))
                    
                    .background{
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                Color("Green"))
                    }
            }
            .disabled(expenseViewModel.remark == "" || expenseViewModel.amount == "" || expenseViewModel.type == "")
            .opacity(expenseViewModel.remark == "" || expenseViewModel.amount == "" || expenseViewModel.type == "" ? 0.6 : 1)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background{
            Color("BG")
                .ignoresSafeArea()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                expenseViewModel.addNewExpense = false
                expenseViewModel.clearData()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(Color("Red").opacity(0.8))
            }
            .padding()
        }
    }
    
    // MARK: CheckBox Toggle
    @ViewBuilder
    func CheckBoxToggle() -> some View {
        HStack(spacing: 10) {
            ForEach(["Income","Expenses"],id: \.self){type in
                ZStack{
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color("BG"), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .opacity(0.5)
                    
                    if expenseViewModel.type == type {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(Color("Green"))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    expenseViewModel.type = type
                }
                
                Text(type)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .opacity(0.6)
                    .padding(.trailing,10)
            }
        }
        .frame(maxWidth: .infinity,alignment: .leading)
        .padding(.leading,10)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
