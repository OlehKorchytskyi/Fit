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
    
    // MARK: Forming the container
    
    func prepareLines(_ subviews: Subviews, inContainer proposal: ProposedViewSize, cache: inout LayoutCache) {
        
        let container = proposal.replacingUnspecifiedDimensions()
        let availableSpace = container.width
        
        var indices = subviews.indices
        
        // Preparing reassignable attributes
        var currentIndex = indices.removeFirst()
        var currentItem = subviews[currentIndex]
        var currentDimensions = currentItem.dimensions(in: proposal)
        var currentSizeThatFits = currentItem.sizeThatFits(proposal)
        var currentSpacing = currentItem.spacing
        
        // Caching attributes for the first item
        cache.dimensions.append(currentDimensions)
        cache.sizes.append(currentSizeThatFits)
        cache.proposals.append(ProposedViewSize(currentSizeThatFits))
        
        // Creating the function which creates new line from the attributes
        func newLineFromCurrentSubview() -> LayoutCache.Line {
            cache.distances.append(0) // adding zero spacing for the first item in the line
            return LayoutCache.Line(
                index: cache.lines.count,
                leadingItem: currentIndex,
                dimensions: currentDimensions,
                spacing: currentSpacing,
                alignment: itemAlignment,
                availableSpace: availableSpace
            )
        }
        
        // Creating first line
        var currentLine = newLineFromCurrentSubview()
                
        func cacheCurrentLine() {
            cache.lines.append(currentLine)
        }
        
        if indices.isEmpty {
            cacheCurrentLine()
        } else {
            var forceNewLineLater = false
            if let lineBreak = currentItem[LineBreakKey.self], lineBreak.after {
                // Check if the current item has attached request
                // to create new line after appending
                forceNewLineLater = lineBreak.condition(currentLine)
            }
            
            while indices.isEmpty == false {
                currentIndex = indices.removeFirst()
                currentItem = subviews[currentIndex]
                currentDimensions = currentItem.dimensions(in: proposal)
                currentSizeThatFits = currentItem.sizeThatFits(proposal)
                currentSpacing = currentItem.spacing
                
                cache.dimensions.append(currentDimensions)
                cache.sizes.append(currentSizeThatFits)
                cache.proposals.append(ProposedViewSize(currentSizeThatFits))
                
                var startNewLine = forceNewLineLater
                forceNewLineLater = false
                
                if let lineBreak = currentItem[LineBreakKey.self] {
                    // Check if the current item has attached request to:
                    if lineBreak.before {
                        // Create new line before appending
                        startNewLine = lineBreak.condition(currentLine)
                    } else {
                        // Create new line after appending
                        forceNewLineLater = true
                    }
                }
                
                if startNewLine {
                    cacheCurrentLine()
                    currentLine = newLineFromCurrentSubview()
                } else if currentLine.appendIfPossible(
                    currentIndex,
                    dimensions: currentDimensions,
                    spacing: currentSpacing,
                    spacingRule: itemSpacing,
                    distances: &cache.distances
                ) {
                    // Did successfully fit current item into the current line.
                } else {
                    // Cannot fit current item into the current line.
                    // Cache current line and creating a new one
                    cacheCurrentLine()
                    currentLine = newLineFromCurrentSubview()
                }
                
                if indices.isEmpty {
                    // Caching current line if there is no items left
                    cacheCurrentLine()
                }
            }
        }
                
        var sizeThatFits = cache.lines.reduce(into: CGSize.zero) { size, line in
            let style = lineStyle.specific(for: line)
            cache.specificLineStyles.append(style)
            
            size.width = style.stretched ? container.width : max(size.width, line.lineLength)
            size.height += line.lineHeight
        }
        
        // accounting for the space between lines
        if cache.lines.count > 1 {
            sizeThatFits.height += lineSpacing * CGFloat(cache.lines.count - 1)
        }
        
        cache.sizeThatFits = sizeThatFits
    }
    
    // MARK: - Placing Lines
    
    func placeLines(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout LayoutCache) {
                
        var verticalOffset: CGFloat = bounds.minY

        for line in cache.lines {
                                    
            // Extract already specified style for current line
            let style = cache.specificLineStyles[line.index]
            
            // Determine where the line will start to place items
            var horizontalOffset = horizontalStart(for: line, withStyle: style, in: bounds, subviews: subviews, cache: cache)
//            // Remember line start point, in terms of Fit container bounds
//            cache.lines[line.index].localHorizontalStart = horizontalOffset - bounds.minX
            
            // Use the lowest baseline as a general baseline every item lays on
            let generalBaseline = max(0, line.baseline.lowest)
            
            // Determine the order of the indices that will be iterated through
            let indices = style.reversed ? line.indices.reversed() : line.indices
            
            for index in indices {
                                
                let subview = subviews[index]
                
                let size = cache.sizes[index]
                let sizeProposal = cache.proposals[index]
                
                // Extract distance to the previous item
                // Note: always 0 for the first item in the row
                var distance = cache.distances[index]
                
                if style.stretched {
                    // For the stretched lines, add additional spacing to the distance
                    // to fill the available space left
                    distance += line.maximumStretch(to: index)
                }
                
                if style.reversed == false {
                    // If NOT reversed:
                    // Apply spacing between items before placing an item
                    horizontalOffset += distance
                }
                
                var itemPosition = CGPoint(x: horizontalOffset, y: verticalOffset)
                
                let dimensions = cache.dimensions[index]
                let itemBaseline = dimensions[itemAlignment]
                
                // Push item down by the general baseline length
                // and offset it by the item personal baseline length
                itemPosition.y += generalBaseline - itemBaseline
                
                subview.place(at: itemPosition, proposal: sizeProposal)
                let location = CGPoint(x: itemPosition.x - bounds.minX,
                                       y: itemPosition.y - bounds.minY)
                cache.cacheLocation(location, at: index)
                
                // Account for the placed item width
                horizontalOffset += size.width
                
                if style.reversed {
                    // If it IS reversed:
                    // Apply spacing between items after placing an item
                    horizontalOffset += distance
                }
                
            }
            
            verticalOffset += line.lineHeight + lineSpacing

        }
        
        cache.locationsProposal = proposal
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


