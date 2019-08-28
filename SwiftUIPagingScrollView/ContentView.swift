//
//  ContentView.swift
//  SwiftUIPagingScrollView
//
//  Created by myf on 27/08/2019.
//  Copyright © 2019 Pavel Zak. All rights reserved.
//

import SwiftUI

struct TileView: View {
    
    let icon: String
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .cornerRadius(20.0)
                Image(systemName: icon)
                    .imageScale(.large)
                    .font(.largeTitle)
            }
        }
    }
}

struct ContentView: View {
    @State private var scrollEffectValue: Double = 13
    
    let tileWidth: CGFloat = 220
    let tilePadding: CGFloat = 20
    
    var body: some View {
        VStack {
        Spacer()
        GeometryReader { geometry in
            PagingScrollView(itemCount:5 ,pageWidth:geometry.size.width, tileWidth:self.tileWidth, tilePadding: self.tilePadding){
                ForEach(1..<6) { index in
                    GeometryReader { geometry2 in
                    TileView(icon: "\(index).circle")
                        .rotation3DEffect(Angle(degrees: Double((geometry2.frame(in: .global).minX - self.tileWidth/2) / -10 )), axis: (x: 2, y: 11, z: 1))
                        .onTapGesture {
                            print("TAP \(index)")
                        }
                    }
                }
            }
        }
        Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
