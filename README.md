# LessLocation ![Swift](https://img.shields.io/badge/swift-5.9-orange.svg) ![iOS](https://img.shields.io/badge/iOS-14.0%2B-blue.svg) ![macOS](https://img.shields.io/badge/macOS-12%2B-blue.svg)

## 概览
`LessLocation` 是一个 Swift 包管理器（SPM）包，旨在简化与苹果的 CoreLocation 框架的交互。
它的设计目的是减少操作复杂性，消除繁琐的代理管理和回调处理的需要。
该包利用了 Swift 最新的异步/等待语法，以高效直接的方式进行地理位置交互。

<sub><sup> Overview
`LessLocation` is a Swift Package Manager (SPM) package that simplifies interactions with Apple's CoreLocation framework. 
It is designed to reduce operational complexity and eliminate the need for cumbersome delegate management and callback handling.
The package leverages Swift's latest async/await syntax for efficient and straightforward geographical location interactions.
</sup></sub>

## 功能
- 简化与 CoreLocation 交互的操作。
- 使用 Swift 的异步/等待语法进行地理位置数据获取、地理围栏设置和位置权限请求的异步函数。
- 消除代理和回调管理的复杂性。

<sub><sup> Features
- Simplified operations for interacting with CoreLocation.
- Asynchronous functions using Swift's async/await syntax for fetching geolocation data, setting up geofences, and requesting location permissions.
- Eliminates the intricacies of delegate and callback management.
</sup></sub>

## 使用示例
- 一次性地理位置请求:
```swift
let manager = LessLocation()
Task {
    do {
        // 快速
        let locations: [CLLocation] = try await manager.requestLocations()
        // 更精准
        let highQulityLocations: [CLLocation] = try await manager.requestLocations(isHighLevel: ture)
    } catch {
        print(error)
    }
}
```
- 授权请求
```swift
let manager = LessLocation()
Task {
    let status = await manager.requestAuthrization(for: .whenInUse)
}
```
- 电子围栏监控
```swift
let manager = LessLocation()
Task {
    let region = CLRegion()
    manager.startMonitoring(for: region) { result in
        switch result {
            case .success(let event):
                switch event {
                    case .enter(let reg):
                        // do somethings when enter one region...
                    case .exits(let reg):
                        // do somethings when exits one region...
                }
            case .falure(let error):
                // 错误处理
        }
    }
}
```

## 要求
确保您的 `info.plist` 文件包含位置服务所需的权限描述，例如：
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

该包使用 Swift 5.9 编写，并支持：
- iOS 14.0 及以上
- macOS 12 及以上

<sub><sup>Requirements
Ensure your `info.plist` file contains the necessary permissions descriptions for location services, such as:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

The package is written in Swift 5.9 and supports:
- iOS 14.0 and above
- macOS 12 and above
</sup></sub>

## 作者
ColdLessLee

<sub><sup>Author
ColdLessLee
</sup></sub>

## 许可
`LessLocation` 在 MIT 许可下可用。有关更多详细信息，请参阅 [LICENSE](LICENSE) 文件。

<sub><sup>License
`LessLocation` is available under the MIT License. See the [LICENSE](LICENSE) file for more details.
</sup></sub>
