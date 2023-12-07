//
//  LessLocationDelegate.swift
//
//
//  Created by Lee ColdWorker on 2023/12/7.
//

import Foundation
import CoreLocation

enum LessLocationDelegateEvent {
    case updateLocations(locations: [CLLocation])
    case didStartMonitoring(region: CLRegion)
    case didExitMonitoredRegion(region: CLRegion)
    case didEnterMoitoredRegion(region: CLRegion)
    case error(detail: Error)
}

protocol LessLocationDelegateReflector: AnyObject {
    func except(_ event: LessLocationDelegateEvent)
}

class LessLocationDelegate: NSObject, CLLocationManagerDelegate {
    
    public weak var reflector: LessLocationDelegateReflector?

}

// MARK: - 地理位置更新
extension LessLocationDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
}

// MARK: - 电子围栏相关
extension LessLocationDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
    }
    
}
