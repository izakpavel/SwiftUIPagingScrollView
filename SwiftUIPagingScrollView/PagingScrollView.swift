//
//  PagingScrollView.swift
//  SwiftUIPagingScrollView
//
//  Created by myf on 27/08/2019.
//  Copyright © 2019 Pavel Zak. All rights reserved.
//

import SwiftUI

struct PagingScrollView: View {
    let items: [AnyView]

    init<A: View>(itemCount: Int, pageWidth:CGFloat, tileWidth:CGFloat, @ViewBuilder content: () -> A) { // this init will be used for any non-supported number of TupleView
        let views = content()
        self.items = [AnyView(views)]
        
        self.pageWidth = pageWidth
        self.tileWidth = tileWidth
        self.tilePadding = 20
        self.tileRemain = (pageWidth-tileWidth-2*tilePadding)/2
        self.itemCount = itemCount
        self.contentWidth = (tileWidth+tilePadding)*CGFloat(self.itemCount)
        
        self.leadingOffset = tileRemain+tilePadding
        self.stackOffset = contentWidth/2 - pageWidth/2 - tilePadding/2
    }
    
    @State var activePageIndex : Int = 0
    
    let pageWidth: CGFloat
    let tileWidth : CGFloat
    private let tilePadding : CGFloat
    private let tileRemain : CGFloat
    private let contentWidth : CGFloat
    private let leadingOffset : CGFloat
    private let stackOffset : CGFloat // to fix center alignment
    private let itemCount : Int
    
    @State private var dragOffset : CGFloat = 0
    
    
    func offsetForPageIndex(_ index: Int)->CGFloat {
        let activePageOffset = CGFloat(index)*(tileWidth+tilePadding)
        
        return self.leadingOffset - activePageOffset
    }
    
    func indexPageForOffset(_ offset : CGFloat) -> Int {
        guard self.itemCount>0 else {
            return 0
        }
        let offset = self.logicalScrollOffset()
        let floatIndex = (offset)/(tileWidth+tilePadding)
        var computedIndex = Int(round(floatIndex))
        computedIndex = max(computedIndex, 0)
        return min(computedIndex, self.itemCount-1)
    }
    
    func currentScrollOffset()->CGFloat {
        return self.offsetForPageIndex(self.activePageIndex) + self.dragOffset
    }
    
    
    func logicalScrollOffset()->CGFloat {
        let currentScrollOffset = self.currentScrollOffset()
        return (currentScrollOffset-leadingOffset) * -1.0
    }
    
    func distanceEffect(index:Int)-> CGFloat{
        let scrollOffset = self.logicalScrollOffset()
        let trueOffset = CGFloat(index)*(tileWidth+tilePadding)
        let diff = (scrollOffset-trueOffset)/1000.0
        return diff
    }
    
    @State private var offset = 0
    var body: some View {
        GeometryReader { outerGeometry in
            HStack(alignment: .center, spacing: self.tilePadding)  {
                ForEach(0..<self.items.count) { index in
                    
                        self.items[index]
                            .padding()
                            .background(Color.yellow)
                            //.position(x: CGFloat(index)*(self.tileWidth+self.tilePadding), y:outerGeometry.size.height/2)
                            .offset(x: self.currentScrollOffset(), y: 0)
                            .frame(width: self.tileWidth)
                            .onTapGesture {
                                print("TAP")
                            }
                    
                }
            }
            .offset(x: self.stackOffset, y: 0)
            .background(Color.green)
            .frame(width: self.contentWidth)
            .gesture( DragGesture(minimumDistance: 1, coordinateSpace: .local)
                .onChanged { value in
                        self.dragOffset = value.translation.width
                }
                .onEnded { value in
                    // compute nearest index
                    withAnimation(.easeInOut){
                        self.activePageIndex = self.indexPageForOffset(self.currentScrollOffset())
                        self.dragOffset = 0
                    }
                }
            )
        }
    }
}
