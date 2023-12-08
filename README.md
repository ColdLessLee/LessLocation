# LessLocation
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat)
![Swift](https://img.shields.io/badge/swift-5.9-orange.svg) [![Platforms](https://img.shields.io/badge/platforms-iOS%2014.0%20|%20macOS%2012.0-orange?style=flat)](https://img.shields.io/badge/platforms-iOS%2014.0%20|%20macOS%2012.0-orange?style=flat)


## 概览
`LessLocation` 是一个 Swift 包管理器（SPM）包，旨在简化与苹果的 CoreLocation 框架的交互。
它的设计目的是减少操作复杂性，消除繁琐的代理管理和回调处理的需要。
该包利用了 Swift async/await语法，以高效直接的方式进行地理位置交互。

## 功能
- 简化与 CoreLocation 交互的操作。
- 使用 Swift 的异步/等待语法进行地理位置数据获取、地理围栏设置和位置权限请求的异步函数。
- 消除代理和回调管理的复杂性。

## 要求
确保您的 `info.plist` 文件包含位置服务所需的权限描述，例如：
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

该包使用 Swift 5.9 编写，并支持：
- iOS 14.0 及以上
- macOS 12.0 及以上

## 使用示例
- 一次性地理位置请求:
```swift
let manager = LessLocation()
// 使用async/await
Task {
    do {
        // 更快速的请求
        let result = try await manager.requestLocations()
        switch result {
            case .success(let locations):
                 print(locations)
             case .failure(let error):
                 print(error)
        }
        // 更精准的请求
        let highQualityResult = try await manager.requestLocations(isHighLevel: ture)
         switch highQualityResult {
            case .success(let locations):
                 print(locations)
             case .failure(let error):
                 print(error)
        }
    } catch {
        print(error)
    }
}

// 使用回调
manager.requestLocations { result in
    switch result {
        case .success(let locations):
            print(locations)
        case .failure(let error):
            print(error)
    }
}
```

- 授权请求
```swift
let manager = LessLocation()
// 使用async/await
Task {
    let status = await manager.requestAuthrization(for: .whenInUse)
    let alwaysStatus = await manager.requestAuthrization(for: .always)
}
// 使用回调
manager.requestAuthrization(for: .whenInUse) { status in
    print(status)
}
```

- 电子围栏监控
```swift
let manager = LessLocation()
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
        case .falure(let error):
                // error handling...
    }
}

```

## 作者
🤵 ColdLessLee <br>
📮 leezway@foxmail.com

## 许可
`LessLocation` 在 MIT 许可下可用。有关更多详细信息，请参阅 [LICENSE](LICENSE) 文件。

