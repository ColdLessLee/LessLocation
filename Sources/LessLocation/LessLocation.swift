// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreLocation

public final class LessLocation {
    
    /// 地理位置管理器
    private let locationManager: CLLocationManager
    
    /// 地理位置管理器代理
    private let locationManagerDelegate = LessLocationDelegate()
    
    /// 消费者队列协调者
    private let locationRequstCoordinator = LessLocationTaskCoordinator()
    
    required init(for locationManager: CLLocationManager? = nil, accuracy: LessLocationAccuracy, allowsBackgroundUpdates: Bool = false) {
        /* 断言当前的初始化操作是在主线程上进行的 */
        assert(Thread.isMainThread, "it must call on the main-thread, if you think that is a bug, try to post an issue about it")
        
        /* ---设置locationManager字段 => 如果有传入参数, 以传入参数为主, 如果没有则新建一个--- */
        self.locationManager = locationManager ?? CLLocationManager()
        self.locationManager.desiredAccuracy = accuracy.clLocationAccuracy
        self.locationManager.allowsBackgroundLocationUpdates = allowsBackgroundUpdates
        self.locationManager.delegate = self.locationManagerDelegate
        /* -------------------------------end--------------------------------------- */
        
        /* ---设置delegate字段 => 实现地理位置代理的集中处理--- */
        self.locationManagerDelegate.reflector = self.locationRequstCoordinator
        /* ----------------------end--------------------- */
        
    }
    
}

// MARK: - LocationRequest
extension LessLocation {
    
    public func requestLocations() async -> [CLLocation] {
        await withCheckedContinuation { continuation in
            requestLocations { locations in
                continuation.resume(returning: locations)
            }
        }
    }
    
    private func requestLocations(completion: @escaping LessLocationTaskCoordinator.LocationRequst) {
        Task.detached { [weak self] in
            guard let self = self else { return completion([]) }
            await self.locationRequstCoordinator.push { [completion, self] locations in
                self.locationManager.stopUpdatingLocation()
                return completion(locations)
            }
            self.locationManager.startUpdatingLocation()
        }
    }

}

// MARK: - RegionMonitoring
extension LessLocation {
    
    public enum RegionMonitoringEvent {
        case enter(region: CLRegion)
        case exits(region: CLRegion)
    }
    
    public func monitoring(for inputRegion: CLRegion, with action: @escaping (_ event: RegionMonitoringEvent) -> Void) {
        Task.detached {
            await self.locationRequstCoordinator.pushRegionMonitoringTask { [action, inputRegion] regionEvent in
                switch regionEvent {
                case .enter(region: let region):
                    guard inputRegion.identifier == region.identifier else { break }
                    action(.enter(region: region))
                case .exits(region: let region):
                    guard inputRegion.identifier == region.identifier else { break }
                    action(.exits(region: region))
                }
               
            }
            self.locationManager.startMonitoring(for: inputRegion)
        }
    }
    
    public func stopMonitoring(for inputRegion: CLRegion) {
        self.locationManager.stopMonitoring(for: inputRegion)
    }
    
}

// MARK: - AuthrizationRequest
extension LessLocation {
    
    public enum AuthrizationTarget {
        case always
        case whenInUse
    }
    
    public func requestAuthrization(for target: AuthrizationTarget) async throws -> CLAuthorizationStatus {
        let status: CLAuthorizationStatus = try await withCheckedThrowingContinuation { continuation in
            requestAuthrization(for: target) { status in
                switch status {
                case .success(status: let status):
                    continuation.resume(returning: status)
                case .failure(error: let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        return status
    }
    
    private func requestAuthrization(for target: AuthrizationTarget, completion: @escaping LessLocationTaskCoordinator.AuthrizationRequest) {
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        Task.detached {[weak self, semaphore, completion] in
            guard let self = self else { return completion(.failure(error: NSError(domain: "LessLocation miss reference", code: 404))) }
            await self.locationRequstCoordinator.setAuthrizationRequest { [semaphore, completion] result in
                completion(result)
                semaphore.signal()
            }
            switch target {
            case .always:
               return self.locationManager.requestAlwaysAuthorization()
            case .whenInUse:
               return self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
}
