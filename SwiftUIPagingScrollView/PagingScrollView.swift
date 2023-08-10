//
//  PagingScrollView.swift
//  SwiftUIPagingScrollView
//
//  Created by myf on 27/08/2019.
//  Copyright © 2019 Pavel Zak. All rights reserved.
//

import SwiftUI

struct FrameMeasurePreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]

    static var defaultValue: Value = Value()

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { current, new in
            new
        }
    }
}

struct MeasureGeometry: View {
    let space: CoordinateSpace
    let identifier: String
    // this dummy view will measure the view and store its width to preference value
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: FrameMeasurePreferenceKey.self, value: [identifier: geometry.frame(in: space)])
        }
    }
}

struct PagingScrollView: View {
    let items: [AnyView]

    public init<Data, id,  Content: View>(activePageIndex:Binding<Int>, tileWidth:CGFloat, tilePadding: CGFloat, @ViewBuilder content: () -> ForEach<Data, id, Content>) {
        let views = content()
        self.items = views.data.map({ AnyView(views.content($0)) })
        
        let itemCount = views.data.count
        
        self._activePageIndex = activePageIndex
        
        self.tileWidth = tileWidth
        self.tilePadding = tilePadding
        self.itemCount = itemCount
    }
      
    /// index of current page 0..N-1
    @Binding var activePageIndex : Int
    
    /// pageWidth==frameWidth used to properly compute offsets
    @State var pageWidth: CGFloat = 0
    
    /// width of item / tile
    let tileWidth : CGFloat
    
    /// padding between items
    private let tilePadding : CGFloat
        
    private let itemCount : Int
    
    /// some damping factor to reduce liveness
    private let scrollDampingFactor: CGFloat = 0.66
    
    /// drag offset during drag gesture
    @State private var dragOffset : CGFloat = 0
    
    
    func offsetForPageIndex(_ index: Int)->CGFloat {
        return -self.baseTileOffset(index: index)
    }
    
    func indexPageForOffset(_ offset : CGFloat) -> Int {
        guard self.itemCount>0 else {
            return 0
        }
        let offset = self.logicalScrollOffset(trueOffset: offset)
        let floatIndex = (offset)/(tileWidth+tilePadding)
        var computedIndex = Int(round(floatIndex))
        computedIndex = max(computedIndex, 0)
        return min(computedIndex, self.itemCount-1)
    }
    
    /// current scroll offset applied on items
    func currentScrollOffset(activePageIndex: Int, dragoffset: CGFloat)->CGFloat {
        return self.offsetForPageIndex(activePageIndex) + dragOffset
    }
    
    /// logical offset startin at 0 for the first item - this makes computing the page index easier
    func logicalScrollOffset(trueOffset: CGFloat)->CGFloat {
        return (trueOffset) * -1.0
    }
    
    private let animation = Animation.interpolatingSpring(mass: 0.1, stiffness: 20, damping: 1.5, initialVelocity: 0)
   
    func baseTileOffset(index: Int) -> CGFloat {
        return CGFloat(index)*(self.tileWidth + self.tilePadding)
    }
    
    var body: some View {
        
            ZStack(alignment: .center)  {
                let globalOffset = self.currentScrollOffset(activePageIndex: self.activePageIndex, dragoffset: self.dragOffset)
                ForEach(0..<self.items.count, id:\.self) { index in
                   
                    self.items[index]
                        .frame(width: self.tileWidth)
                        .offset(x: self.baseTileOffset(index: index) + globalOffset)
                        /*.simultaneousGesture(
                                TapGesture()
                                    .onEnded { _ in
                                        withAnimation(self.animation) {
                                            self.activePageIndex = index
                                            self.dragOffset = 0
                                        }
                                    }
                            )*/
                }
            }
            .background(
                MeasureGeometry(space: .local, identifier: "container")
            )
            .onPreferenceChange(FrameMeasurePreferenceKey.self) {
                guard let frame = $0["container"] else { return }
                self.pageWidth = frame.size.width
            }
            
            .background(Color.black.opacity(0.00001)) // hack - this allows gesture recognizing even when background is transparent
            .simultaneousGesture( DragGesture(minimumDistance: 1, coordinateSpace: .local) // can be changed to simultaneous gesture to work with buttons
                .onChanged { value in
                    self.dragOffset = value.translation.width
                }
                .onEnded { value in
                    // compute nearest index
                    let velocityDiff = (value.predictedEndTranslation.width - self.dragOffset)*self.scrollDampingFactor
                    let targetOffset = self.currentScrollOffset(activePageIndex: self.activePageIndex, dragoffset: self.dragOffset)
                    
                    withAnimation(self.animation){
                        self.dragOffset = 0
                        self.activePageIndex = self.indexPageForOffset(targetOffset+velocityDiff)
                    }
                }
            )
    }
}
