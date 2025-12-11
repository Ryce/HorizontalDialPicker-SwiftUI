import SwiftUI

/// A horizontal dial picker component that allows users to select a value by scrolling through tick marks.
///
/// `HorizontalDialPicker` displays a scrollable horizontal ruler with tick marks, where users can scroll
/// to select a value within a specified range. The component provides haptic feedback and visual
/// highlighting of the selected value.
///
/// Example usage:
/// ```swift
/// struct ContentView: View {
///     @State private var value: Double = 10
///
///     var body: some View {
///         VStack {
///             Text("Selected: \(value, specifier: "%.2f")")
///             HorizontalDialPicker(value: $value, range: 0...100, step: 1)
///         }
///     }
/// }
/// ```
public struct HorizontalDialPicker<V>: View where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {

    @Binding var value: V
    var range: ClosedRange<V>
    var step: V

    var tickSpacing: CGFloat
    var tickSegmentCount: Int
    var showSegmentValueLabel: Bool
    var labelSignificantDigit: Int

    @State private var scrollPosition: Int? = nil
    @State private var viewSize: CGSize? = nil

    // to avoid haptic effects on initialization,
    // ie: when setting self.scrollPosition in onAppear
    @State private var initialized: Bool = false

    /// Creates a horizontal dial picker.
    ///
    /// - Parameters:
    ///   - value: A binding to the currently selected value
    ///   - range: The range of selectable values
    ///   - step: The increment between each tick mark
    ///   - tickSpacing: The spacing between tick marks in points. Default is 8.0
    ///   - tickSegmentCount: How many ticks between labeled segments. Default is 10
    ///   - showSegmentValueLabel: Whether to show value labels at segments. Default is true
    ///   - labelSignificantDigit: Number of decimal places for labels. Default is 1
    public init(
        value: Binding<V>,
        range: ClosedRange<V>,
        step: V,
        tickSpacing: CGFloat = 8.0,
        tickSegmentCount: Int = 10,
        showSegmentValueLabel: Bool = true,
        labelSignificantDigit: Int = 1
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.tickSpacing = tickSpacing
        self.tickSegmentCount = tickSegmentCount
        self.showSegmentValueLabel = showSegmentValueLabel
        self.labelSignificantDigit = labelSignificantDigit
    }

    public var body: some View {
        content
        // using initial: true cannot replace onAppear
        // ie: will not set the correct initial position
        .onChange(of: value) { _, newValue in
            self.scrollPosition = Int((newValue - range.lowerBound) / step)
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .defaultScrollAnchor(.center, for: .alignment)
        .defaultScrollAnchor(.center, for: .initialOffset)
        .defaultScrollAnchor(.center, for: .sizeChanges)
        .safeAreaPadding(.horizontal, ((viewSize?.width ?? 0) - 2) / 2)

        .onChange(of: scrollPosition) { _, newPosition in
            guard let pos = newPosition else { return }
            value = range.lowerBound + V(pos) * step
        }
        .overlay(content: {
            GeometryReader { geometry in
                if geometry.size != self.viewSize {
                    DispatchQueue.main.async {
                        self.viewSize = geometry.size
                    }
                }
                return Color.clear
            }
        })
        .onChange(of: viewSize) {
            // Set the initial scroll position once the view size is known.
            // Check if scrollPosition is nil to ensure this only runs once.
            if self.scrollPosition == nil {
                self.scrollPosition = Int((value - range.lowerBound) / step)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.initialized = true
                }
            }
        }
    }

    @ViewBuilder
    var content: some View {
        ScrollView(.horizontal, content: {
            let totalTicks = Int((range.upperBound - range.lowerBound) / step) + 1
            LazyHStack(spacing: tickSpacing) {
                ForEach(0..<totalTicks, id: \.self) { index in
                    let isSegment = index % tickSegmentCount == 0
                    let isTarget = index == scrollPosition
                    tick(isTarget: isTarget, isSegment: isSegment, index: index)
                }
            }
            .frame(height: 56)
            .padding(.vertical, 16)
            .scrollTargetLayout()
        })
    }

    @ViewBuilder
    func tick(isTarget: Bool, isSegment: Bool, index: Int) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isTarget ? .yellow : isSegment ? .primary : .gray)
            .frame(width: 2, height: 24)
            .id(index)
            .scaleEffect(x: isTarget ? 1.2 : 1, y: isTarget ? 1.5 : 0.8, anchor: .bottom)
            .animation(.default.speed(1.2), value: isTarget)
            .sensoryFeedback(.selection, trigger: isTarget && initialized)
            .overlay(alignment: .bottom, content: {
                if isSegment, self.showSegmentValueLabel {
                    let value = Double(range.lowerBound + V(index) * step)
                    // Show as integer if value is a whole number, otherwise use decimal format
                    if value.truncatingRemainder(dividingBy: 1) == 0 {
                        Text("\(Int(value))")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .fixedSize() // required to avoid being cutoff horizontally
                            .offset(y: 16)
                    } else {
                        Text("\(String(format: "%.\(labelSignificantDigit)f", value))")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .fixedSize() // required to avoid being cutoff horizontally
                            .offset(y: 16)
                    }
                }
            })
    }
}
