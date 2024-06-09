//
//  LineCache.swift
//
//
//  Created by Oleh Korchytskyi on 06.06.2024.
//

import SwiftUI


extension Fit.LayoutCache {
    
    /// Represents the group of items forming the line.
    public struct Line {
        
        public let index: Int
        
        private(set) var indices: [Int]
        
        let itemAlignment: VerticalAlignment
        
        var baseline: Baseline
        
        /// Expected line height, accounting for added items and alignments.
        var lineHeight: CGFloat
        
        /// Expected line length, accounting for added items and spacing in between.
        public private(set) var lineLength: CGFloat
        
        /// Represents how much of the available space was offered by the container during the layout process.
        public private(set) var availableSpaceOffered: CGFloat
        /// Represents how much of the available space is left.
        public private(set) var availableSpace: CGFloat
        
        private(set) var firstItemSpacing: ViewSpacing
        private(set) var firstItemDimensions: ViewDimensions
        
        private(set) var lastItemSpacing: ViewSpacing
        private(set) var lastItemDimensions: ViewDimensions
        
        var localHorizontalStart: CGFloat = 0
        
        @inline(__always)
        init(index: Int, leadingItem itemIndex: Int, dimensions: ViewDimensions, spacing: ViewSpacing, alignment: VerticalAlignment, availableSpace: CGFloat) {
            self.index = index
            
            indices = [itemIndex]
            
            itemAlignment = alignment
            
            let itemBaseline = dimensions[alignment]

            baseline = Baseline(initial: itemBaseline, itemHeight: dimensions.height)
            lineHeight = baseline.height
            
            lineLength = dimensions.width
            
            firstItemSpacing = spacing
            lastItemSpacing = spacing
            
            firstItemDimensions = dimensions
            lastItemDimensions = dimensions

            self.availableSpaceOffered = availableSpace
            self.availableSpace = max(0, availableSpace - dimensions.width)
        }
        
        @inline(__always)
        mutating func appendIfPossible(
            _ itemIndex: Int,
            dimensions: ViewDimensions,
            spacing: ViewSpacing,
            spacingRule: ItemSpacing,
            distances: inout [CGFloat]
        ) -> Bool {
            let distance = spacingRule.distance(between: lastItemSpacing, and: spacing)
            let spaceOccupied = distance + dimensions.width

            guard spaceOccupied <= availableSpace else { return false }
            
            indices.append(itemIndex)
            distances.append(distance)
            
            availableSpace -= spaceOccupied
            lineLength += spaceOccupied
            
            lastItemSpacing = spacing
            lastItemDimensions = dimensions
            
            let itemBaseline = dimensions[itemAlignment]
            
            baseline.appendItem(dimensions.height, baseline: itemBaseline)
            lineHeight = baseline.height
            
            return true
        }
        
        @inline(__always)
        func maximumStretch(to itemIndex: Int) -> CGFloat {
            guard indices.first != itemIndex else { return 0 }
            guard indices.count > 1 else { return 0 }
            return availableSpace / CGFloat(indices.count - 1)
        }
        
    }
}

extension Fit.LayoutCache.Line {
    struct Baseline {
        private(set) var highest: CGFloat
        private(set) var lowest: CGFloat
        
        private(set) var space: (up: CGFloat, down: CGFloat)
        private(set) var height: CGFloat
        
        init(initial baseline: CGFloat, itemHeight: CGFloat) {
            self.highest = baseline
            self.lowest = baseline
            
            let space = Self.space(for: itemHeight, baseline: baseline, lowestBaseline: baseline, highestBaseline: baseline)
            self.space = space
            
            self.height = space.up + space.down
        }
        
        @inline(__always)
        mutating func appendItem(_ itemHeight: CGFloat, baseline: CGFloat) {
            highest = min(highest, baseline)
            lowest = max(lowest, baseline)
            
            let newSpace = Self.space(for: itemHeight, baseline: baseline, lowestBaseline: lowest, highestBaseline: highest)
            space = (max(space.up, newSpace.up),
                     max(space.down, newSpace.down))
            
            self.height = space.up + space.down
        }
        
        @inline(__always)
        static func space(for height: CGFloat, baseline: CGFloat, lowestBaseline: CGFloat, highestBaseline: CGFloat) -> (up: CGFloat, down: CGFloat) {
            return (
                // Up:
                // Lowest baseline will push it's item above by its length
                abs(max(lowestBaseline, 0)) +
                // Highest baseline will create a space, equal to its length, above the item
                abs(min(highestBaseline, 0)),
                // Down:
                max(0, height - max(0, baseline))
            )
        }
    }
}
