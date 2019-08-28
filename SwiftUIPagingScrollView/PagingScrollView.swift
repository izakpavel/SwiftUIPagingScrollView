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

    init<A: View>(itemCount: Int, pageWidth:CGFloat, tileWidth:CGFloat, tilePadding: CGFloat, @ViewBuilder content: () -> A) {
        let views = content()
        self.items = [AnyView(views)]
        
        self.pageWidth = pageWidth
        self.tileWidth = tileWidth
        self.tilePadding = tilePadding
        self.tileRemain = (pageWidth-tileWidth-2*tilePadding)/2
        self.itemCount = itemCount
        self.contentWidth = (tileWidth+tilePadding)*CGFloat(self.itemCount)
        
        self.leadingOffset = tileRemain+tilePadding
        self.stackOffset = contentWidth/2 - pageWidth/2 - tilePadding/2
    }
    
    /// index of current page 0..N-1
    @State var activePageIndex : Int = 0
    
    /// pageWidth==frameWidth used to properly compute offsets
    let pageWidth: CGFloat
    
    /// width of item / tile
    let tileWidth : CGFloat
    
    /// padding between items
    private let tilePadding : CGFloat
    
    /// how much of surrounding iems is still visible
    private let tileRemain : CGFloat
    
    /// total width of conatiner
    private let contentWidth : CGFloat
    
    /// offset to scroll on the first item
    private let leadingOffset : CGFloat
    
    /// since the hstack is centered by default this offset actualy moves it entirely to the left
    private let stackOffset : CGFloat // to fix center alignment
    
    /// number of items; I did not come with the soluion of extracting the right count in initializer
    private let itemCount : Int
    
    /// drag offset during drag gesture
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
    
    /// current scroll offset applied on items
    func currentScrollOffset()->CGFloat {
        return self.offsetForPageIndex(self.activePageIndex) + self.dragOffset
    }
    
    /// logical offset startin at 0 for the first item - this makes computing the page index easier
    func logicalScrollOffset()->CGFloat {
        let currentScrollOffset = self.currentScrollOffset()
        return (currentScrollOffset-leadingOffset) * -1.0
    }
    
    // future - trying to be able to appy modifiers based of scroll offset
    func distanceEffect(index:Int)-> CGFloat{
        let scrollOffset = self.logicalScrollOffset()
        let trueOffset = CGFloat(index)*(tileWidth+tilePadding)
        let diff = (scrollOffset-trueOffset)/1000.0
        return diff
    }
    
    var body: some View {
        GeometryReader { outerGeometry in
            HStack(alignment: .center, spacing: self.tilePadding)  {
                /// building items into HStack
                ForEach(0..<self.items.count) { index in
                    
                        self.items[index]
                            .padding()
                            .background(Color.yellow)
                            .offset(x: self.currentScrollOffset(), y: 0)
                            .frame(width: self.tileWidth)
                    
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
