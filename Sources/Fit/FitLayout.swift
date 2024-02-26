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
        
        cache.reset()

        prepareLines(subviews, inContainer: proposal, cache: &cache)

        return cache.sizeThatFits
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {
        guard subviews.isEmpty == false else { return }
        placeLines(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = nil
        return properties
    }
    
    
    
    // MARK: - Caching
    
    public func makeCache(subviews: Subviews) -> LayoutCache {
        LayoutCache(capacity: subviews.count)
    }
    
}
