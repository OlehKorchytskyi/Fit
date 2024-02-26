import SwiftUI



/// Automatically forms lines from the elements, using **.sizeThatFits(.unspecified)** to determine each element size.
///
/// Add your views just like you would do it with all other **SwiftUI** stacks:
///
/// ```swift
/// Fit {
///     ForEach(items) { item in
///         ItemView(item)
///     }
/// }
/// ```
///
public struct Fit {

    public let lineStyle: LineStyle
    public let lineSpacing: CGFloat
    
    public let itemAlignment: VerticalAlignment
    public let itemSpacing: ItemSpacing
    
    /// Initialises ``Fit`` with a custom ``LineStyle``.
    /// - Parameters:
    ///   - lineStyle: description of a line style represented by ``LineStyle``;
    ///   - lineSpacing: fixed spacing between lines;
    ///   - itemAlignment: vertical items alignment, behaves in the same way as HStack alignment;
    ///   - itemSpacing: configuration of spacing between items represented by ``ItemSpacing``.
    ///   The default implementation uses **.viewSpacing** option which takes preferred distance based on views ViewSpacing.
    ///   To specify fixed item spacing use **.fixed(CGFloat)** option.
    ///
    public init(
        lineStyle: LineStyle,
        lineSpacing: CGFloat = 8,
        itemAlignment: VerticalAlignment = .center,
        itemSpacing: ItemSpacing = .viewSpacing(minimum: 0)
    ) {
        self.lineStyle = lineStyle
        self.lineSpacing = lineSpacing
        self.itemAlignment = itemAlignment
        self.itemSpacing = itemSpacing
    }
    
    /// Initialises ``Fit`` with a set of static attributes.
    /// - Parameters:
    ///   - lineAlignment: alignment of the lines in the container;
    ///   - lineSpacing: fixed spacing between lines;
    ///   - itemAlignment: vertical items alignment, behaves in the same way as HStack alignment;
    ///   - itemSpacing: configuration of spacing between items represented by ``ItemSpacing``;
    ///   - stretched: determines container should be stretched to fill available space.
    public init(
        lineAlignment: LineAlignment = .leading,
        lineSpacing: CGFloat = 8,
        itemAlignment: VerticalAlignment = .center,
        itemSpacing: ItemSpacing = .viewSpacing(minimum: 0),
        stretched: Bool = false
    ) {
        self.lineStyle = LineStyle(alignment: lineAlignment, reversed: false, stretched: stretched)
        self.lineSpacing = lineSpacing
        
        self.itemAlignment = itemAlignment
        self.itemSpacing = itemSpacing
    }
    
    // MARK: Forming container
    
    func prepareLines(_ subviews: Subviews, inContainer proposal: ProposedViewSize, cache: inout LayoutCache) {
        
        let container = proposal.replacingUnspecifiedDimensions()
        
        var currentLine: LayoutCache.Line?
        
        var breakAtIndex = -1
        
        for index in subviews.indices {
            let subview = subviews[index]
            
            let dimensions = subview.dimensions(in: .unspecified)
            cache.dimensions.append(dimensions)
            
            let size = subview.sizeThatFits(.unspecified)

            cache.sizes.append(size)
            cache.proposals.append(ProposedViewSize(size))
            
            // capture current line
            var line: LayoutCache.Line! = currentLine
            // or create a new one if there is no one
            if line == nil {
                line = LayoutCache.Line(
                    index: cache.lines.count,
                    leadingItem: index,
                    dimensions: dimensions,
                    spacing: subview.spacing,
                    alignment: itemAlignment,
                    availableSpace: container.width
                )
                
                cache.distances.append(0)
                currentLine = line

                continue
            }
            
            // Extract the line break request
            let lineBreak = subview[LineBreakKey.self]
            
            // Check if we should break before appending the item 
            // and that conditions are met
            var breakLineBeforeAppending = false
            if let lineBreak, lineBreak.before {
                breakLineBeforeAppending = lineBreak.condition(line)
            }

            // We should not attempt to append if the attached LineBreak
            // requests to break before that, or after previous item
            let attemptToAppend = (breakAtIndex != index) && (breakLineBeforeAppending == false)

            if attemptToAppend && line.appendIfPossible(
                index,
                dimensions: dimensions,
                spacing: subview.spacing,
                spacingRule: itemSpacing,
                cache: &cache
            ) {
                // updating current line to continue filling it on the next step
                currentLine = line

            } else {
                // if line has no space left:
                // 1. cache it
                // 2. create new line
                
                cache.lines.append(line)
                
                cache.distances.append(0)
                currentLine = LayoutCache.Line(
                    index: cache.lines.count,
                    leadingItem: index,
                    dimensions: dimensions,
                    spacing: subview.spacing,
                    alignment: itemAlignment,
                    availableSpace: container.width
                )
            }
            
            // Check and remember if we should break before appending the NEXT item
            // and that conditions are met
            if let lineBreak, lineBreak.after, lineBreak.condition(line) {
                breakAtIndex = index + 1
            }
        }
        
        // caching last line
        if let currentLine {
            cache.lines.append(currentLine)
        }
        
        
        var sizeThatFits = cache.lines.reduce(into: CGSize.zero) { size, line in
            let style = lineStyle.specific(for: line)
            cache.lineStyle.append(style)
            size.width = style.stretched ? container.width : max(size.width, line.lineLength)
            size.height += line.lineHeight
        }
        
        // accounting for the space between rows
        if cache.lines.count > 1 {
            sizeThatFits.height += lineSpacing * CGFloat(cache.lines.count - 1)
        }
        
        cache.sizeThatFits = sizeThatFits
    }
    
    // MARK: - Placing Lines
    
    func placeLines(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {

        guard cache.lines.isEmpty == false else { return }
        
        var verticalOffset: CGFloat = bounds.minY
        
        for line in cache.lines {
            
            let style = cache.lineStyle[line.index] //lineStyle.specific(for: line)
            
            var horizontalOffset = horizontalStart(for: line, withStyle: style, in: bounds, subviews: subviews, cache: cache)
            
            let baseLine = line.baseLine
                                    
            let indices = style.reversed ? line.indices.reversed() : line.indices
            
            for index in indices {
                let subview = subviews[index]
                
                let size = cache.sizes[index]
                let sizeProposal = cache.proposals[index]
                
                var distance = cache.distances[index]
                
                if style.stretched {
                    distance += line.maximumStretch(to: index)
                }
                
                if style.reversed == false {
                    horizontalOffset += distance
                }
                
                var itemPosition = CGPoint(x: horizontalOffset, y: verticalOffset)
                
                let dimensions = cache.dimensions[index]
                let itemBaseline = dimensions[itemAlignment]
                
                itemPosition.y += baseLine - itemBaseline

                subview.place(at: itemPosition, proposal: sizeProposal)
                
                if style.reversed {
                    horizontalOffset += distance
                }
                
                horizontalOffset += size.width
            }
            
            verticalOffset += line.lineHeight + lineSpacing

        }

    }
    
    @inlinable
    func horizontalStart(for line: LayoutCache.Line, withStyle specificStyle: LineStyle, in bounds: CGRect, subviews: Subviews, cache: LayoutCache) -> CGFloat {
        
        if specificStyle.stretched {
            return bounds.minX
        }

        switch specificStyle.alignment {
        case .leading:
            return bounds.minX
        case .center:
            return bounds.midX - line.lineLength / 2
        case .trailing:
            return bounds.maxX - line.lineLength
        }
    }
    
}


