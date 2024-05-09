# BlankSlate

[![Swift](https://img.shields.io/badge/Swift-5.10-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.10-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_tvOS_visionOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-iOS_tvOS_visionOS-Green?style=flat-square)
[![CocoaPods](https://img.shields.io/cocoapods/v/BlankSlate.svg?style=flat)](https://cocoapods.org/pods/BlankSlate)
[![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager)
[![Carthage](https://img.shields.io/badge/Carthage-supported-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/BlankSlate.svg?style=flat)](https://github.com/liam-i/BlankSlate/blob/main/LICENSE)
<!-- [![Doc](https://img.shields.io/badge/Swift-Doc-DE5C43.svg?style=flat)](https://liam-i.github.io/BlankSlate/main/documentation/blankslate) -->

BlankSlate is a drop-in UIView extension for showing empty datasets whenever the view has no content to display.

## ScreenShots

[![](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/1-small.png)](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/1.png)
[![](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/2-small.png)](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/2.png)
[![](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/3-small.png)](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/3.png)
[![](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/4-small.png)](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/4.png)
[![](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/5-small.png)](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/5.png)
[![](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/6-small.png)](https://raw.githubusercontent.com/wiki/liam-i/BlankSlate/Screenshots/6.png)

## Requirements

* iOS 12.0+ 
* tvOS 12.0+ 
* Xcode 14.1+
* Swift 5.7.1+

## Installation

### Swift Package Manager

#### ...using `swift build`

If you are using the [Swift Package Manager](https://www.swift.org/documentation/package-manager), add a dependency to your `Package.swift` file and import the BlankSlate library into the desired targets:
```swift
dependencies: [
    .package(url: "https://github.com/liam-i/BlankSlate.git", from: "0.7.0")
],
targets: [
    .target(
        name: "MyTarget", dependencies: [
            .product(name: "BlankSlate", package: "BlankSlate")
        ])
]
```

#### ...using Xcode

If you are using Xcode, then you should:

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/liam-i/BlankSlate.git`
- Select "Up to Next Minor" with "0.7.0"

> [!TIP]
> For detailed tutorials, see: [Apple Docs](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

#### CocoaPods

If you're using [CocoaPods](https://cocoapods.org), add this to your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
# Or use CND source
# source 'https://cdn.cocoapods.org/'
platform :ios, '12.0'
use_frameworks!

target 'MyApp' do
  pod 'BlankSlate', '~> 0.7.0'
end
```

And run `pod install`.

> [!IMPORTANT]  
> CocoaPods 1.13.0 or newer is required.

### Carthage

If you're using [Carthage](https://github.com/Carthage/Carthage), add this to your `Cartfile`:

```ruby
github "liam-i/BlankSlate" ~> 0.7.0
```

And run `carthage update --platform iOS --use-xcframeworks`.

## Example

To run the example project, first clone the repo, then `cd` to the root directory and run `pod install`. Then open BlankSlate.xcworkspace in Xcode.

## Credits and thanks

* Thanks a lot to [Ignacio Romero Zurbuchen](https://github.com/dzenbot) for building [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet) - all ideas in here and many implementation details were provided by his library.

## License

BlankSlate is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
