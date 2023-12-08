//
//  LessLocation+RegionMonitoring.swift
//
//
//  Created by Lee ColdWorker on 2023/12/8.
//

import Foundation
import CoreLocation

// MARK: - 电子围栏相关 - 类型定义
extension LessLocation {
    public enum RegionMonitoringEvent {
        case enter(region: CLRegion)
        case exits(region: CLRegion)
    }
    
    public enum RegionMonitoringError: Error {
        case unreachable
        case operation(error: Error)
    }
    
    public typealias RegionMonitoringResult = Result<RegionMonitoringEvent, RegionMonitoringError>
    
    public typealias RegionMonitoringTask = (_ result: RegionMonitoringResult) -> Void
    
}

// MARK: - Public
extension LessLocation {
    
    public func stopMonitoring(for inputRegion: CLRegion) {
        self.locationManager.stopMonitoring(for: inputRegion)
    }
    
    public func monitoring(for inputRegion: CLRegion, with action: @escaping RegionMonitoringTask) {
        locationRequstCoordinator.pushRegionMonitoringTask { result in
            switch result {
            case .success(let event):
                switch event {
                case .enter(region: let region):
                    guard inputRegion.identifier == region.identifier else { break }
                    action(result)
                case .exits(region: let region):
                    guard inputRegion.identifier == region.identifier else { break }
                    action(result)
                }
            
            case .failure:
                action(result)
            }
            
        }
    }
    
   
}
