//
//  LessLocationTaskCoordinator.swift
//
//
//  Created by Lee ColdWorker on 2023/12/6.
//

import Foundation
import CoreLocation

class LessLocationTaskCoordinator {
    
    private let queue = DispatchQueue(label: "com.lesslocation.tasks.coordinator")
    
    internal typealias LocationResult = LessLocation.LocationResult
    internal typealias LocationRequst = LessLocation.LocationRequst
    private var locationRequst: LocationRequst?
        
    internal typealias RegionMonitoringEvent = LessLocation.RegionMonitoringEvent
    internal typealias RegionMonitoringResult = LessLocation.RegionMonitoringResult
    internal typealias RegionMonitoringTask = LessLocation.RegionMonitoringTask
    private var regionMonitoringTask: RegionMonitoringTask?
    
    /// 引用的请求事件类型别名
    internal typealias AuthrizationResult = LessLocation.AuthrizationResult
    /// 引用的请求函数类型别名
    internal typealias AuthrizationRequest = LessLocation.AuthrizationRequest
    /// 权限回调实例变量
    private var authrizationRequest: AuthrizationRequest?
}

// MARK: - Locations
extension LessLocationTaskCoordinator {
    
    public func pushLocationRequest(_ request: @escaping LocationRequst) {
        queue.async { [weak self] in
            guard let previousRequest = self?.locationRequst else {
                self?.locationRequst = request
                return
            }
            self?.locationRequst = { locations in
                previousRequest(locations)
                request(locations)
            }
        }
    }
    
    public func dispatch(locationsResult result: LocationResult) {
        queue.async { [weak self] in
            self?.locationRequst?(result)
            self?.locationRequst = nil
        }
    }
   
}

// MARK: - RegionMonitoring
extension LessLocationTaskCoordinator {
    
    public func pushRegionMonitoringTask(_ task: @escaping RegionMonitoringTask) {
        queue.async { [weak self] in
            guard let previousTask = self?.regionMonitoringTask else {
                self?.regionMonitoringTask = task
                return
            }
            self?.regionMonitoringTask = { event in
                previousTask(event)
                task(event)
            }
        }
    }
    
    public func dispatch(regionMonitoringResult result: RegionMonitoringResult) {
        queue.async { [weak self] in
            self?.regionMonitoringTask?(result)
        }
    }
    
}

// MARK: - Authrizations
extension LessLocationTaskCoordinator {
    
    public func setAuthrizationRequest(_ request: @escaping AuthrizationRequest) {
        queue.async { [weak self] in
            guard let previousRequest = self?.authrizationRequest else {
                self?.authrizationRequest = request
                return
            }
            self?.authrizationRequest = { event in
                previousRequest(event)
                request(event)
            }
        }
    }
    
    public func dispatch(authrizationStatus status: AuthrizationResult) {
        queue.async {
            self.authrizationRequest?(status)
            self.authrizationRequest = nil
        }
    }
    
}
