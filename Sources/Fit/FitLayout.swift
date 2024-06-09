//
//  FitLayout.swift
//
//
//  Created by Oleh Korchytskyi on 18.01.2024.
//

import SwiftUI


extension Fit: Layout {
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) -> CGSize {
        guard subviews.isEmpty == false else { return .zero }
        cache.validate(forProposedContainer: proposal) {
            prepareLines(subviews, inContainer: proposal, cache: &$0)
        }
        return cache.sizeThatFits
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {
        guard cache.lines.isEmpty == false else { return }
        
        if cache.locations.count == subviews.count, proposal.width == cache.locationsProposal?.width {
            
            for index in subviews.indices {
                let subview = subviews[index]
                let cachedLocation = cache.locations[index]
                let sizeProposal = cache.proposals[index]
                
                subview.place(at: CGPoint(x: cachedLocation.x + bounds.minX,
                                          y: cachedLocation.y + bounds.minY), proposal: sizeProposal)
            }
            
            return
        }
        
        cache.prepareToCachePlacementLocations(subviews.count)
        
        placeLines(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = nil
        return properties
    }
    
    // Note: runs before .placeSubviews(...)
    public func spacing(subviews: Subviews, cache: inout LayoutCache) -> ViewSpacing {
        guard subviews.isEmpty == false else { return ViewSpacing() }
        guard subviews.count > 1 else { return subviews[0].spacing }
        
        if cache.isClean, let spacing = cache.spacing {
            return spacing
        }
        
        let spacing = subviews.dropFirst().reduce(into: subviews[0].spacing) {
            $0.formUnion($1.spacing)
        }
        
        cache.spacing = spacing
        
        return spacing
    }
    
    
    // MARK: - Caching
    
    public func makeCache(subviews: Subviews) -> LayoutCache {
        LayoutCache(capacity: subviews.count)
    }
    
    public func updateCache(_ cache: inout LayoutCache, subviews: Subviews) {
        cache.isDirty = true
    }
}
