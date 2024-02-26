//
//  ItemSpacing.swift
//
//
//  Created by Oleh Korchytskyi on 09.01.2024.
//

import SwiftUI


/// Defines an item spacing rule in the ``Fit`` layout.
public enum ItemSpacing {
    /// Uses **ViewSpacing** distance to determine preferred spacing, but not less then specified minimum.
    case viewSpacing(minimum: CGFloat)
    
    /// Fixed spacing.
    case fixed(CGFloat)
    
    @inlinable
    func distance(between leadingViewSpacing: ViewSpacing, and trailingViewSpacing: ViewSpacing) -> CGFloat {
        switch self {
        case .viewSpacing(minimum: let spacing):
            max(spacing, leadingViewSpacing.distance(to: trailingViewSpacing, along: .horizontal))
        case .fixed(let spacing):
            spacing
        }
    }
}
