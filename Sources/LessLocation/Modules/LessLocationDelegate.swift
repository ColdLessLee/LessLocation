//
//  LessLocationDelegate.swift
//
//
//  Created by Lee ColdWorker on 2023/12/7.
//

import Foundation
import CoreLocation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum LessLocationDelegateEvent {
    
    case updateLocations(locations: [CLLocation])
    case updateLocationsFailure(error: Error)
    
    case startMonitoring(region: CLRegion)
    case failureMonitoring(region: CLRegion?, error: Error)
    case didExitMonitored(region: CLRegion)
    case didEnterMoitored(region: CLRegion)

    case didChangeLocationAuthsStatus(status: CLAuthorizationStatus)
}

protocol LessLocationDelegateReflector: AnyObject {
    func except(_ event: LessLocationDelegateEvent)
    func manager() -> CLLocationManager
}

class LessLocationDelegate: NSObject, CLLocationManagerDelegate {
    
    public weak var reflector: LessLocationDelegateReflector?
    
    private weak var observer: NSObjectProtocol?
    
    override init() {
        super.init()
    }
    
}

// MARK: - 地理位置更新
extension LessLocationDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        reflector?.except(.updateLocations(locations: locations))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        reflector?.except(.updateLocationsFailure(error: error))
    }
    
}

// MARK: - 电子围栏相关
extension LessLocationDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        reflector?.except(.startMonitoring(region: region))
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        reflector?.except(.didExitMonitored(region: region))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        reflector?.except(.didEnterMoitored(region: region))
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        reflector?.except(.failureMonitoring(region: region, error: error))
    }
    
}

// MARK: - 授权相关
extension LessLocationDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.reflector?.except(.didChangeLocationAuthsStatus(status: manager.authorizationStatus))
    }
    
    func obserbveAuthrizationChangeByAppStateEvent() {
        #if os(iOS)
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] notify in
            self?.authrizationChangeByAppStateEventAction()
        }
        #endif
        #if os(macOS)
        observer = NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] notify in
            self?.authrizationChangeByAppStateEventAction()
        }
        #endif
    }
    
    func removeOberverOfAuthrizationChange() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func authrizationChangeByAppStateEventAction() {
        guard let manager = reflector?.manager() else { return }
        self.locationManagerDidChangeAuthorization(manager)
    }
    
}
