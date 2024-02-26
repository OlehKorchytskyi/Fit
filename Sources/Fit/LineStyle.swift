//
//  LineStyle.swift
//
//
//  Created by Oleh Korchytskyi on 18.01.2024.
//

import Foundation
import SwiftUI


/// An alignment position along the horizontal axis for the line in ``Fit`` layout.
public enum LineAlignment {
    case leading, center, trailing
}

/// Configure static or dynamic style for the ``Fit`` layout lines.
///
/// Use public initialiser to define a static style:
/// ```swift
/// let style = LineStyle(alignment: .trailing)
/// ```
///
/// To specify a custom dynamic style for each line use **.lineSpecific** static method:
/// ```swift
/// let customStyle: LineStyle = .lineSpecific { style, line in
///     // reverse every second line
///     style.reversed = (line.index + 1).isMultiple(of: 2)
///     // if the line is reversed, it should start from the trailing edge
///     style.alignment = style.reversed ? .trailing : .leading
/// }
/// ```
///
public struct LineStyle {
    
    public var alignment: LineAlignment = .leading
    
    /// Reversed lines starts to layout its elements starting from the last one
    public var reversed: Bool = false
    /// Stretched lines add an additional spacing between elements to fill the available space
    public var stretched: Bool = false
    /// A piece of information derived from the layout cache, representing current line
    public typealias LineInfo = Fit.LayoutCache.Line

    let specifier: (inout LineStyle, LineInfo) -> Void
    
    public init(alignment: LineAlignment = .leading, reversed: Bool = false, stretched: Bool = false) {
        self.alignment = alignment
        self.reversed = reversed
        self.stretched = stretched
        self.specifier = { _,_ in }
    }
    
    init(specifier: @escaping (inout LineStyle, LineInfo) -> Void) {
        self.specifier = specifier
    }
    
    /// Creates a dynamic style for the line.
    ///
    /// ```swift
    /// let customStyle: LineStyle = .lineSpecific { style, line in
    ///     // reverse every second line
    ///     style.reversed = (line.index + 1).isMultiple(of: 2)
    ///     // if the line is reversed, it should start from the trailing edge
    ///     style.alignment = style.reversed ? .trailing : .leading
    /// }
    /// ```
    ///
    /// - Parameter specifier: a closure which will be called to specify the style for the particular line.
    /// - Returns: line style with saved specifier closure.
    ///
    /// Specifier can be called multiple times if layout engine will decide to reset the cache during the layout process.
    ///
    public static func lineSpecific(_ specifier: @escaping (inout LineStyle, LineInfo) -> Void) -> LineStyle {
        LineStyle(specifier: specifier)
    }
    
    
    func specific(for line: LineInfo) -> LineStyle {
        var style = self
        specifier(&style, line)
        return style
    }
}


