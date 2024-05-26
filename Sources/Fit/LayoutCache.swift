//
//  LayoutCache.swift
//
//
//  Created by Oleh Korchytskyi on 12.01.2024.
//

import SwiftUI


extension Fit {
    
    /// Cache for ``Fit`` implementation of Layout protocol.
    public struct LayoutCache {
        
        var sizeThatFits: CGSize = .zero
        
        var sizes: [CGSize] = []
        var proposals: [ProposedViewSize] = []
        var dimensions: [ViewDimensions] = []
        
        var distances: [CGFloat] = []
        
        /// Represents the group of items forming the line.
        public struct Line {
            
            public let index: Int
            
            private(set) var indices: [Int] = []
            
            let itemAlignment: VerticalAlignment
            
            var baseLine: CGFloat
            
            /// Expected line height, accounting for added items and alignments.
            var lineHeight: CGFloat
            var tallestAtIndex: Int
            
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
            
            init(index: Int, leadingItem itemIndex: Int, dimensions: ViewDimensions, spacing: ViewSpacing, alignment: VerticalAlignment, availableSpace: CGFloat) {
                self.index = index
                
                indices = [itemIndex]
                
                itemAlignment = alignment
                
                let itemBaseLine = dimensions[alignment]

                baseLine = itemBaseLine
                
                lineHeight = max(dimensions.height, itemBaseLine)
                tallestAtIndex = itemIndex
                
                lineLength = dimensions.width
                
                firstItemSpacing = spacing
                lastItemSpacing = spacing
                
                firstItemDimensions = dimensions
                lastItemDimensions = dimensions
                
                let space = max(0, availableSpace - dimensions.width)
                self.availableSpaceOffered = availableSpace
                self.availableSpace = space
            }
            
            
            mutating func appendIfPossible(
                _ itemIndex: Int,
                dimensions: ViewDimensions,
                spacing: ViewSpacing,
                spacingRule: ItemSpacing,
                cache: inout LayoutCache
            ) -> Bool {
                let distance = spacingRule.distance(between: lastItemSpacing, and: spacing)
                let spaceOccupied = distance + dimensions.width

                guard spaceOccupied <= availableSpace else { return false }
                
                indices.append(itemIndex)
                cache.distances.append(distance)
                
                availableSpace -= spaceOccupied
                lineLength += spaceOccupied
                
                lastItemSpacing = spacing
                lastItemDimensions = dimensions
                
                let itemBaseLine = dimensions[itemAlignment]

                baseLine = max(baseLine, itemBaseLine)

                let oldHeight = lineHeight
                
                // Calculate the line height based on the:
                // * current baseline of the line;
                // * item height minus item baseline (since it will vertically sit on the line baseline)
                lineHeight = max(lineHeight, dimensions.height, baseLine + (dimensions.height - itemBaseLine))

                if oldHeight < lineHeight {
                    tallestAtIndex = itemIndex
                }
                
                return true
            }
            
            func maximumStretch(to itemIndex: Int) -> CGFloat {
                guard indices.first != itemIndex else { return 0 }
                guard indices.count > 1 else { return 0 }
                return availableSpace / CGFloat(indices.count - 1)
            }
            
        }
        
        var lines: [Line] = []
        var longestLine: Line? = nil
        var lineStyle: [LineStyle] = []
                
        init(capacity: Int) {
            sizeThatFits = .zero
            
            sizes.reserveCapacity(capacity)
            proposals.reserveCapacity(capacity)
            dimensions.reserveCapacity(capacity)
            
            distances.reserveCapacity(capacity)
            
            lineStyle.reserveCapacity(capacity)
        }
        
        // MARK: - Reseting cache
        
        var isDirty: Bool = false
        var proposedContainer: ProposedViewSize?
        
        mutating func validate(forProposedContainer proposal: ProposedViewSize, afterReset performUpdate: (inout Self) -> Void) {
            // If cache is dirty, or container changed size
            if isDirty || proposedContainer != proposal {
                // reset all buffers
                reset()
                // perform updated for the caller
                performUpdate(&self)
                
                // clean the cache
                isDirty = false
                
                // remember the size proposal to compare during the next validation
                proposedContainer = proposal
            }
        }
        
        mutating func reset() {
            sizeThatFits = .zero
            
            sizes.removeAll(keepingCapacity: true)
            proposals.removeAll(keepingCapacity: true)
            dimensions.removeAll(keepingCapacity: true)
            
            distances.removeAll(keepingCapacity: true)
            
            lineStyle.removeAll(keepingCapacity: true)
            
            lines.removeAll()
            
            longestLine = nil
        }
        
    }
}
