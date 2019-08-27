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
                    .padding()
                    
                    //.blur(radius:20)
                Image(systemName: icon)
                    .imageScale(.large)
                    .font(.largeTitle)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
        Spacer()
        GeometryReader { geometry in
            PagingScrollView(itemCount:5 ,pageWidth:geometry.size.width, tileWidth:220){
                TileView(icon: "1.circle")
                TileView(icon: "2.circle")
                TileView(icon: "3.circle")
                TileView(icon: "4.circle")
                TileView(icon: "5.circle")
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
