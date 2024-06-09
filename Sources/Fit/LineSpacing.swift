//
//  LineSpacing.swift
//
//
//  Created by Oleh Korchytskyi on 09.06.2024.
//

import SwiftUI


/// Defines the line spacing rule in the ``Fit`` layout.
///
/// Also can be constructed using Integer or Float literal:
/// ```
/// let spacing: LineSpacing = 8    // .fixed(8)
/// let spacing: LineSpacing = 10.5 // .fixed(10.5)
/// ```
public enum LineSpacing: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    /// Uses **ViewSpacing** distance to determine preferred spacing, but not less then specified minimum.
    case viewSpacing(minimum: CGFloat)
    
    /// Fixed spacing between lines.
    case fixed(CGFloat)
    
    /// Uses **ViewSpacing** distance to determine preferred spacing.
    public static var viewSpacing: LineSpacing { 
        .viewSpacing(minimum: -.infinity)
    }
    
    @inline(__always)
    func distance(between topViewSpacing: ViewSpacing, and bottomViewSpacing: ViewSpacing) -> CGFloat {
        switch self {
        case .viewSpacing(minimum: let minimumSpacing):
            max(minimumSpacing, topViewSpacing.distance(to: bottomViewSpacing, along: .vertical))
        case .fixed(let spacing):
            spacing
        }
    }
    
    // MARK: ExpressibleByFloatLiteral
    /// Creates **.fixed** ``LineSpacing``.
    /// - Parameter value: spacing distance.
    public init(floatLiteral value: Double) {
        self = .fixed(value)
    }
    
    // MARK: ExpressibleByIntegerLiteral
    /// Creates **.fixed** ``LineSpacing``.
    /// - Parameter value: spacing distance.
    public init(integerLiteral value: Int) {
        self = .fixed(CGFloat(value))
    }
    
}
