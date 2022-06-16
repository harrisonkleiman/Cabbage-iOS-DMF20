//
//  BarChartCell.swift
//  Cabbage-iOS
//
//  Created by Harrison Kleiman on 6/16/22.
//

import SwiftUI
 
struct BarChartCell: View {
    
    var value: Double
    var barColor = Color("Green")
                            
       var body: some View {
           RoundedRectangle(cornerRadius: 5)
               .fill(barColor)
               .scaleEffect(CGSize(width: 1, height: value), anchor: .bottom)
            }
}
 
struct BarChartCell_Previews: PreviewProvider {
     static var previews: some View {
         BarChartCell(value: 3800, barColor: .blue)
             .previewLayout(.sizeThatFits)
     }
}
