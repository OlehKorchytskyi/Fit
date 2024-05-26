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
        guard subviews.isEmpty == false else { return }
        placeLines(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }
    
    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = nil
        return properties
    }
    
    
    public func spacing(subviews: Subviews, cache: inout LayoutCache) -> ViewSpacing {
        var spacing = ViewSpacing()
        
        guard cache.lines.isEmpty == false else { return spacing }
        
        
        let topLine = cache.lines.first!
        
        // Form a union top spacing if first(top) line has all
        // its items aligned a the top
        if case .top = topLine.itemAlignment {
            for index in topLine.indices {
                spacing.formUnion(subviews[index].spacing, edges: .top)
            }
        } 
        // otherwise, use just tallest item to determine the top edge spacing
        else {
            spacing.formUnion(subviews[topLine.tallestAtIndex].spacing, edges: .top)
        }
        
        
        let longestLine = cache.longestLine!
        // For leading and trailing edges we need to take lines alignment into account
        switch lineStyle.alignment {
        case .leading:
            // Form a union leading spacing of the first item in each line
            for line in cache.lines {
                spacing.formUnion(line.firstItemSpacing, edges: .leading)
            }
            
            // For a trailing edge use the spacing of the last item in the longest line
            spacing.formUnion(longestLine.lastItemSpacing, edges: .trailing)
            
        case .center:
            // When lines are centered we only need to merge 
            // first and last items in the longest line
            spacing.formUnion(longestLine.firstItemSpacing, edges: .leading)
            spacing.formUnion(longestLine.lastItemSpacing, edges: .trailing)
            
        case .trailing:
            // Form a union trailing spacing of the last item in each line
            for line in cache.lines {
                spacing.formUnion(line.lastItemSpacing, edges: .trailing)
            }
            
            // For a leading edge use the spacing of the first item in the longest line
            spacing.formUnion(longestLine.firstItemSpacing, edges: .leading)
        }
        
        
        let bottomLine = cache.lines.first!
        
        // Form a union bottom spacing if last(bottom) line has all
        // its items aligned a the bottom
        if case .bottom = bottomLine.itemAlignment {
            for index in bottomLine.indices {
                spacing.formUnion(subviews[index].spacing, edges: .bottom)
            }
        } 
        // otherwise, use just tallest item to determine the bottom edge spacing
        else {
            spacing.formUnion(subviews[bottomLine.tallestAtIndex].spacing, edges: .bottom)
        }
        
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
