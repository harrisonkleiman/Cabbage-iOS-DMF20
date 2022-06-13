//
//  LineGraph.swift
//  Cabbage-iOS
//
//  Created by Harrison Kleiman on 6/13/22.
//

import SwiftUI

import SwiftUI

// MARK: - Custom Graph View
struct LineGraph: View {
    
    // Number of plots
    var data: [CGFloat]
    
    @State var currentPlot = ""
    
    // Offset
    @State var offset: CGSize = .zero
    
    @State var showPlot = false
    
    @State var translation: CGFloat = 0
    
    @GestureState var isDrag: Bool = false
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let height = proxy.size.height
            let width = (proxy.size.width) / CGFloat(data.count - 1)
            
            let maxPoint = (data.max() ?? 0) + 100
            
            let points = data.enumerated().compactMap { item -> CGPoint in
                
                // getting progress and multiplyinh with height...
                let progress = item.element / maxPoint
                
                let pathHeight = progress * height
                
                // width..
                let pathWidth = width * CGFloat(item.offset)
                
                // Since we need peak to top not bottom...
                return CGPoint(x: pathWidth, y: -pathHeight + height)
            }
            
            ZStack{
                
                // Converting plot as points....
                
                // Path....
                Path { path in
                    
                    // drawing the points..
                    path.move(to: CGPoint(x: 0, y: 0))
                    
                    path.addLines(points)
                }
                .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .fill(
                
                    // Gradient
                    LinearGradient(colors: [
                        Color("Cream"),
                        Color("Red")
                    ], startPoint: .leading, endPoint: .trailing)
                )
                
                // MARK: - Path Bacground Coloring...
                FillBG()
                // Clip shape
                    .clipShape(
                    
                        Path { path in
                            
                            // drawing the points..
                            path.move(to: CGPoint(x: 0, y: 0))
                            
                            path.addLines(points)
                            
                            path.addLine(to: CGPoint(x: proxy.size.width, y: height))
                            
                            path.addLine(to: CGPoint(x: 0, y: height))
                        }
                    )
                    //.padding(.top,15)
            }
            .overlay(
            
                // MARK: - Drag Indiccator
                VStack(spacing: 0) {
                    
                    Text(currentPlot)
                        .font(.caption.bold())
                        .foregroundColor(Color("Cream"))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color("Red"),in: Capsule())
                        .offset(x: translation < 10 ? 30 : 0)
                        .offset(x: translation > (proxy.size.width - 60) ? -30 : 0)
                    
                    Rectangle()
                        .fill(Color("Green"))
                        .frame(width: 1, height: 40)
                        .padding(.top)
                    
                    Circle()
                        .fill(Color("Red"))
                        .frame(width: 22, height: 22)
                        .overlay(
                        
                            Circle()
                                .fill(Color("Cream"))
                                .frame(width: 10, height: 10)
                        )
                    
                    Rectangle()
                        .fill(Color("Cream"))
                        .frame(width: 1, height: 25)
                }
                // Fixed Frame
                // For Gesture Calculation
                    .frame(width: 80, height: 170)
                // 170 / 2 = 85 - 15 => circle ring size
                    .offset(y: 70)
                    .offset(offset)
                    .opacity(showPlot ? 1 : 0),
                
                alignment: .bottomLeading
            )
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged({ value in
                
                withAnimation{showPlot = true}
                
                let translation = value.location.x - 20
                
                // Getting index...
                let index = max(min(Int((translation / width).rounded() + 1), data.count - 1), 0)
                
                currentPlot = "$ \(data[index])"
                self.translation = translation
                
                // removing half width...
                offset = CGSize(width: points[index].x - 40, height: points[index].y - height)
                
            }).onEnded({ value in
                
                withAnimation{showPlot = false}
                
            }).updating($isDrag, body: { value, out, _ in
                out = true
            }))
        }
        .background(
        
            VStack(alignment: .leading){
                
                let max = data.max() ?? 0
                
                Text("$ \(Int(max))")
                    .font(.caption.bold())
                    .offset(y: -5)
                
                Spacer()
                
                Text("$ 0")
                    .font(.caption.bold())
                    .offset(y: 5)
            }
            .frame(maxWidth: .infinity,alignment: .leading)
        )
        .padding(.horizontal, 10)
        .onChange(of: isDrag) { newValue in
            if !isDrag{showPlot = false}
        }
    }
    
    @ViewBuilder
    func FillBG() -> some View {
        LinearGradient(colors: [
        
            Color("Green")
                .opacity(0.8),
            Color("Green")
                .opacity(0.8),
            Color("Green")
                .opacity(0.8)]
            + Array(repeating:                     Color("Green")
                .opacity(0.8), count: 4)
            + Array(repeating:                     Color.clear, count: 2)
            , startPoint: .top, endPoint: .bottom)
    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
