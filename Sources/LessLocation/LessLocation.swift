// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreLocation

public final class LessLocation {
    
    /// 地理位置管理器
    internal let locationManager: CLLocationManager
    
    /// 地理位置管理器代理
    internal let locationManagerDelegate = LessLocationDelegate()
    
    /// 消费者队列协调者
    internal let locationRequstCoordinator = LessLocationTaskCoordinator()
    
    public required init(for locationManager: CLLocationManager? = nil, accuracy: LessLocationAccuracy, allowsBackgroundUpdates: Bool = false) {
        /* 断言当前的初始化操作是在主线程上进行的 */
        assert(Thread.isMainThread, "it must call on the main-thread, if you think that is a bug, try to post an issue about it")
        
        /* ---设置locationManager字段 => 如果有传入参数, 以传入参数为主, 如果没有则新建一个--- */
        self.locationManager = locationManager ?? CLLocationManager()
        self.locationManager.desiredAccuracy = accuracy.clLocationAccuracy
        self.locationManager.allowsBackgroundLocationUpdates = allowsBackgroundUpdates
        self.locationManager.delegate = self.locationManagerDelegate
        /* -------------------------------end--------------------------------------- */
        
        /* ---设置delegate字段 => 实现地理位置代理的集中处理--- */
        self.locationManagerDelegate.reflector = self
        /* ----------------------end--------------------- */
    }
    
}

// MARK: - 通用方法
extension LessLocation {
    
    public func isLocationFetchable(manager: CLLocationManager? = nil) -> Bool {
        let status = manager?.authorizationStatus ?? locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
}

// MARK: - LessLocationDelegate
extension LessLocation: LessLocationDelegateReflector {
 
    internal func manager() -> CLLocationManager {
        locationManager
    }
    
    internal func except(_ event: LessLocationDelegateEvent) {
        switch event {
        case .updateLocations(let locations):
            locationRequstCoordinator.dispatch(locationsResult: .success(locations))
        case .updateLocationsFailure(let error):
            locationRequstCoordinator.dispatch(locationsResult: .failure(.operation(error: error)))
        case .startMonitoring(let region):
            debugPrint(region)
        case .failureMonitoring(_, let error):
            locationRequstCoordinator.dispatch(regionMonitoringResult: .failure(.operation(error: error)))
        case .didExitMonitored(let region):
            locationRequstCoordinator.dispatch(regionMonitoringResult: .success(.exits(region: region)))
        case .didEnterMoitored(let region):
            locationRequstCoordinator.dispatch(regionMonitoringResult: .success(.enter(region: region)))
        case .didChangeLocationAuthsStatus(let status):
            locationRequstCoordinator.dispatch(authrizationStatus: .success(status))
        }
    }
    
}
