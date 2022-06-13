//
//  StatisticsGrpah.swift
//  Cabbage-iOS
//
//  Created by Harrison Kleiman on 6/13/22.
//

import SwiftUI

// MARK: Analytics Graph Model
struct StatisticsGraph: Identifiable {
    var id = UUID().uuidString
    var monthString: String
    var monthDate: Date
    var expenses: [Expense]
}
