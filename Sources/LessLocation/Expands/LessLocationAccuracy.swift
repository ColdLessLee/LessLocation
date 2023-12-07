//
//  LessLocationAccuracy.swift
//
//
//  Created by Lee ColdWorker on 2023/12/6.
//

import Foundation
import CoreLocation

public enum LessLocationAccuracy {
    
    /// 最适合导航的精度，这是最高的精度，使用更多的电量。
    case bestForNavigation
    
    /// 最佳精度。
    case best
    
    /// 精确到最近的十米。
    case nearestTenMeters
    
    /// 精确到最近的一百米。
    case hundredMeters
    
    /// 精确到最近的一千米。
    case kilometer
    
    /// 精确到最近的三千米。
    case threeKilometers
    
}

// MARK: - Datas
extension LessLocationAccuracy {
    /// 系统的映射值
    public var clLocationAccuracy: CLLocationAccuracy {
        switch self {
        case .bestForNavigation:
            kCLLocationAccuracyBestForNavigation
        case .best:
            kCLLocationAccuracyBest
        case .nearestTenMeters:
            kCLLocationAccuracyNearestTenMeters
        case .hundredMeters:
            kCLLocationAccuracyHundredMeters
        case .kilometer:
            kCLLocationAccuracyKilometer
        case .threeKilometers:
            kCLLocationAccuracyThreeKilometers
        }
    }
}
