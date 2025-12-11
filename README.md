# HorizontalDialPicker

A customizable horizontal dial picker component for SwiftUI that provides an intuitive scrolling interface for value selection.

## Features

- Smooth scrolling horizontal dial interface
- Haptic feedback on value selection
- Customizable tick spacing and segment labels
- Support for any `BinaryFloatingPoint` type (Double, Float, CGFloat, etc.)
- Automatic value label formatting (integers vs decimals)
- Full SwiftUI integration with `@Binding`

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add HorizontalDialPicker to your project using Swift Package Manager:

1. In Xcode, select File > Add Package Dependencies...
2. Enter the repository URL: `https://github.com/yourusername/HorizontalDialPicker`
3. Select the version you want to use
4. Click Add Package

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/HorizontalDialPicker", from: "1.0.0")
]
```

## Usage

### Basic Example

```swift
import SwiftUI
import HorizontalDialPicker

struct ContentView: View {
    @State private var value: Double = 10

    var body: some View {
        VStack(spacing: 24) {
            Text("Selected Value: \(String(format: "%.2f", value))")
                .font(.headline)

            HorizontalDialPicker(value: $value, range: 0...100, step: 1)
        }
        .padding()
    }
}
```

### Customization

You can customize various aspects of the picker:

```swift
HorizontalDialPicker(
    value: $value,
    range: 0...100,
    step: 0.5,
    tickSpacing: 12.0,           // Space between ticks
    tickSegmentCount: 5,          // Ticks between labeled segments
    showSegmentValueLabel: true,  // Show/hide value labels
    labelSignificantDigit: 2      // Decimal places for labels
)
```

### Full Example

```swift
import SwiftUI
import HorizontalDialPicker

struct HorizontalDialPickerDemo: View {
    @State private var value: Double = 10

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Selected Value: \(String(format: "%.2f", value))")
                    .font(.headline)
                    .fontWeight(.semibold)

                HorizontalDialPicker(value: $value, range: 0...100, step: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(.yellow.opacity(0.1))
            .navigationTitle("Horizontal Dial!")
        }
    }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `Binding<V>` | Required | Binding to the selected value |
| `range` | `ClosedRange<V>` | Required | Range of selectable values |
| `step` | `V` | Required | Increment between tick marks |
| `tickSpacing` | `CGFloat` | `8.0` | Spacing between ticks in points |
| `tickSegmentCount` | `Int` | `10` | Number of ticks between labeled segments |
| `showSegmentValueLabel` | `Bool` | `true` | Whether to display value labels |
| `labelSignificantDigit` | `Int` | `1` | Decimal places for labels |

## How It Works

The picker uses SwiftUI's `ScrollView` with scroll position tracking to create a ruler-like interface. When a user scrolls, the component:

1. Snaps to the nearest tick mark using `.scrollTargetBehavior(.viewAligned)`
2. Updates the bound value based on the centered position
3. Provides haptic feedback via `.sensoryFeedback()`
4. Highlights the selected tick with visual scaling and color changes

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
