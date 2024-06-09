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
        
        var spacing: ViewSpacing?
        
        var sizes: [CGSize] = []
        var proposals: [ProposedViewSize] = []
        var dimensions: [ViewDimensions] = []
        
        /// Distances to the previous subview.
        var distances: [CGFloat] = []
        
        var lines: [Line] = []
        var specificLineStyles: [LineStyle] = []
        
        /// Cached locations after placing subviews
        var locations: [CGPoint] = []
        var locationsProposal: ProposedViewSize? = nil
                
        init(capacity: Int) {
            sizeThatFits = .zero
            
            sizes.reserveCapacity(capacity)
            proposals.reserveCapacity(capacity)
            dimensions.reserveCapacity(capacity)
            
            distances.reserveCapacity(capacity)
            
            specificLineStyles.reserveCapacity(capacity)
            
            locations.reserveCapacity(capacity)
        }
        
        // MARK: - Cached Locations
        @inline(__always)
        mutating func prepareToCachePlacementLocations(_ capacity: Int) {
            let zeroLocation: CGPoint = .zero
            locations = Array(repeating: zeroLocation, count: capacity)
        }
        
        @inline(__always)
        mutating func cacheLocation(_ location: CGPoint, at index: Int) {
            locations[index] = location
        }
        
        // MARK: - Reseting cache
        
        var isDirty: Bool = false
        var isClean: Bool { isDirty == false }
        var proposedContainer: ProposedViewSize?
        
        @inline(__always)
        mutating func validate(forProposedContainer proposal: ProposedViewSize, afterReset performUpdate: (inout Self) -> Void) {
            // If cache is dirty, or container changed size
            if isDirty || proposedContainer?.width != proposal.width {
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
        
        @inline(__always)
        mutating func reset() {
            sizeThatFits = .zero
            
            spacing = nil
            
            sizes.removeAll(keepingCapacity: true)
            proposals.removeAll(keepingCapacity: true)
            dimensions.removeAll(keepingCapacity: true)
            
            distances.removeAll(keepingCapacity: true)
            
            specificLineStyles.removeAll(keepingCapacity: true)
            
            lines.removeAll()
            
            resetPlacementLocations()
        }
        
        mutating func resetPlacementLocations() {
            locations.removeAll(keepingCapacity: true)
            locationsProposal = nil
        }
    }
}
