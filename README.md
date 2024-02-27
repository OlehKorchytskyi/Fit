<p align="center">
    <img src="https://img.shields.io/badge/SwiftUI-874dbf.svg"/>
    <img src="https://img.shields.io/badge/macOS-13.0+-212121.svg"/>
    <img src="https://img.shields.io/badge/iOS-16+-212121.svg"/>
    <img src="https://img.shields.io/badge/tvOS-16.0+-212121.svg"/>
    <img src="https://img.shields.io/badge/watchOS-9.0+-212121.svg"/>
    <a href="https://twitter.com/OKorchytskyi">
        <img src="https://img.shields.io/badge/Contact-@OKorchytskyi-212121" alt="Twitter: @OKorchytskyi"/>
    </a>
</p>

**Fit** allows you to lay out your views into lines without ever bothering to group or measure them, all thanks to the implementation of the **Layout** protocol.


## Usage


Add your views just like you would do it with all other **SwiftUI** stacks:

```swift
import Fit

Fit {
    Text("Tags:")

    ForEach(tags) { tag in
        TagView(tag: tag)
    }

    TextField("New tag", text: $input)
}
```
![tag_list_example](https://github.com/OlehKorchytskyi/Fit/assets/4789347/270802ea-6bea-455a-afa6-084ba48ffdba)

> [!NOTE]
> Full code for this example: [Tag List Example](https://github.com/OlehKorchytskyi/FitPlayground/blob/main/FitPlayground/FitPlayground/Examples/TagListExample.swift).

## Customisation

**Fit** provides multiple ways to customise your layout:

#### Line Alignment and Spacing

```swift
// .leading (default), .center or .trailing
Fit(lineAlignment: .center, lineSpacing: 12) {
    // views
}
```

#### Item Alignment and Spacing

You can align items in the same way you would do in **HStack**:

```swift
// fixed item spacing
Fit(itemAlignment: .firstTextBaseline, itemSpacing: .fixed(8)) {
    // views
}

// view's preferred spacing
Fit(itemAlignment: .firstTextBaseline, itemSpacing: .viewSpacing(minimum: 8)) {
    // views
}
```

#### Line-Break

Use view modifier to add line-break before or after a particular view:

```swift
Fit {
    Text("Title:")
        .fit(lineBreak: .after)
    // next views
}
```

#### Per-line styling

You can define secific style for each line with **LineStyle**:
```swift
let conveyorBeltStyle: LineStyle = .lineSpecific { style, line in
    // reverse every second line
    style.reversed = (line.index + 1).isMultiple(of: 2)
    // if the line is reversed, it should start from the trailing edge
    style.alignment = style.reversed ? .trailing : .leading
}

Fit(lineStyle: conveyorBeltStyle) {
    // views
}
```
![conveyor_belt_example](https://github.com/OlehKorchytskyi/Fit/assets/4789347/586f3c5c-f769-4ee0-a93d-2f6316ee9444)

> [!NOTE]
> Full code for this example: [Conveyor Belt Example](https://github.com/OlehKorchytskyi/FitPlayground/blob/main/FitPlayground/FitPlayground/Examples/ConveyorBeltExample.swift).

It is also possible to create a variable style:

```swift
var fancyAlignJustified: LineStyle {
    .lineSpecific { style, line in
        if stretch {
            style.stretched = line.percentageFilled >= threshold
        }
    }
}

Fit(lineStyle: fancyAlignJustified) {
    // views
}
```
![stretching_example](https://github.com/OlehKorchytskyi/Fit/assets/4789347/a926cac6-9ac5-431a-88cc-a62e4d7ee456)

> [!NOTE]
> Full code for this example: [Long Text Example](https://github.com/OlehKorchytskyi/FitPlayground/blob/main/FitPlayground/FitPlayground/Examples/LongTextExample.swift).

## Installing

Use **Swift Package Manager** to get **Fit**:
```swift
.package(url: "https://github.com/OlehKorchytskyi/Fit", from: "1.0.0")
```

Import **Fit** into your Swift code:

```swift
import Fit
```



## License

MIT License.

Copyright (c) 2024 Oleh Korchytskyi.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
