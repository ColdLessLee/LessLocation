# LessLocation ![Swift](https://img.shields.io/badge/swift-5.9-orange.svg) ![iOS](https://img.shields.io/badge/iOS-14.0%2B-blue.svg) ![macOS](https://img.shields.io/badge/macOS-12%2B-blue.svg)

## Overview
`LessLocation` is a Swift Package Manager (SPM) package that simplifies interactions with Apple's CoreLocation framework. 
It is designed to reduce operational complexity and eliminate the need for cumbersome delegate management and callback handling.
The package leverages Swift's latest async/await syntax for efficient and straightforward geographical location interactions.

## Features
- Simplified operations for interacting with CoreLocation.
- Asynchronous functions using Swift's async/await syntax for fetching geolocation data, setting up geofences, and requesting location permissions.
- Eliminates the intricacies of delegate and callback management.

## Requirements
Ensure your `info.plist` file contains the necessary permissions descriptions for location services, such as:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`

The package is written in Swift 5.9 and supports:
- iOS 14.0 and above
- macOS 12 and above

## Author
ColdLessLee

## License
`LessLocation` is available under the MIT License. See the [LICENSE](LICENSE) file for more details.
