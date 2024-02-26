//
//  LineBreak.swift
//
//
//  Created by Oleh Korchytskyi on 10.01.2024.
//

import SwiftUI


struct LineBreakKey: LayoutValueKey {
    static let defaultValue: LineBreak? = nil
}

/// Represent a demand to break the line **.before** or **.after** the particular element.
///
/// ```swift
/// Fit {
///     Image(systemName: "swift")
///     Text("SwiftUI")
///         .fit(lineBreak: .after)
///
///     ForEach(items) { item in
///         ItemView(item)
///     }
/// }
/// ```
public struct LineBreak {
    
    let after: Bool
    var before: Bool { after == false}
    
    /// A piece of information derived from the layout cache, representing current line
    public typealias LineInfo = Fit.LayoutCache.Line
    
    let condition: (LineInfo) -> Bool
    
    init(after: Bool, condition: @escaping (LineInfo) -> Bool) {
        self.after = after
        self.condition = condition
    }
}

extension LineBreak {
    
    public static let noBreak = LineBreak(after: false, condition: { _ in false })
    
    /// A demand to place the element on the next line.
    public static let before = LineBreak(after: false, condition: { _ in true })
    
    /// A conditional demand to place the element on the next line.
    /// - Parameter condition: a required condition that needs to be met for performing a line brake.
    /// - Returns: a line brake demand.
    public static func before(when condition: @escaping (LineInfo) -> Bool) -> LineBreak {
        LineBreak(after: false, condition: condition)
    }
    
    /// A demand to line brake after current element.
    public static let after = LineBreak(after: true, condition: { _ in true })
    /// A conditional demand to line brake after current element.
    /// - Parameter condition: a required condition that needs to be met for performing a line brake.
    /// - Returns: a line brake demand
    public static func after(when condition: @escaping (LineInfo) -> Bool) -> LineBreak {
        LineBreak(after: true, condition: condition)
    }
    
}

public extension LineBreak.LineInfo {
    /// Number of items added so far.
    var itemsAdded: Int { indices.count }
    
    /// Percentage of offered space filled (e.g. 0.5).
    var percentageFilled: Double { lineLength / availableSpaceOffered }
}

public extension View {
    
    /// Attaches a line brake demand to the view in the ``Fit`` layout.
    /// - Parameter lineBreak: a line brake configuration.
    /// - Returns: a view with attached line brake demand.
    func fit(lineBreak: LineBreak) -> some View {
        layoutValue(key: LineBreakKey.self, value: lineBreak)
    }
}
