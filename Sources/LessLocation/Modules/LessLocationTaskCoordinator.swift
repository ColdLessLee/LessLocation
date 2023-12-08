//
//  LessLocationTaskCoordinator.swift
//
//
//  Created by Lee ColdWorker on 2023/12/6.
//

import Foundation
import CoreLocation

actor LessLocationTaskCoordinator {
    
    typealias LocationRequst = (_ locations: [CLLocation]) -> Void
    private var locationRequstQueue: [LocationRequst] = []
        
    enum RegionMonitoringEvent {
        case enter(region: CLRegion)
        case exits(region: CLRegion)
    }
    typealias RegionMonitoringTask = (_ regionEvent: RegionMonitoringEvent) -> Void
    private var regionMonitoringTasks: [RegionMonitoringTask] = []
    
    typealias AuthrizationEvent = LessLocation.AuthrizationEvent
    typealias AuthrizationRequest = LessLocation.AuthrizationRequest
    private var authrizationRequest: AuthrizationRequest? = nil
    
}

// MARK: - Locations
extension LessLocationTaskCoordinator {
    
    public func push(locationRequst: @escaping LocationRequst) {
        self.locationRequstQueue.append(locationRequst)
    }
    
    public func dispatch(locations: [CLLocation]) async {
        for locationRequst in self.locationRequstQueue {
            locationRequst(locations)
        }
        locationRequstQueue.removeAll()
    }
    
}

// MARK: - RegionMonitoring
extension LessLocationTaskCoordinator {
    
    public func pushRegionMonitoringTask(_ regionMonitoringTask: @escaping RegionMonitoringTask) {
        self.regionMonitoringTasks.append(regionMonitoringTask)
    }
    
    public func dispatch(regionMonitoringEvent: RegionMonitoringEvent) async {
        for regionMonitoringTask in self.regionMonitoringTasks {
            regionMonitoringTask(regionMonitoringEvent)
        }
        regionMonitoringTasks.removeAll()
    }
    
}

// MARK: - Authrizations
extension LessLocationTaskCoordinator {
    
    public func setAuthrizationRequest(_ request: @escaping AuthrizationRequest) {
        self.authrizationRequest = request
    }
    
    public func dispatch(authrizationStatus status: AuthrizationEvent) async {
        self.authrizationRequest?(status)
        self.authrizationRequest = nil
    }
    
}

// MARK: - LessLocationDelegate
extension LessLocationTaskCoordinator: LessLocationDelegateReflector {
 
    nonisolated func except(_ event: LessLocationDelegateEvent) {
            switch event {
            case .updateLocations(let locations):
                Task.detached {
                    await self.dispatch(locations: locations)
                }
            case .didStartMonitoring(let region):
                print(region)
                break
            case .didExitMonitoredRegion(let region):
                Task.detached {
                    await self.dispatch(regionMonitoringEvent: .exits(region: region))
                }
            case .didEnterMoitoredRegion(let region):
                Task.detached {
                    await self.dispatch(regionMonitoringEvent: .enter(region: region))
                }
            case .error(let detail):
                print(detail.localizedDescription)
                break
            case .didChangeLocationAuthsStatus(let status):
                Task.detached {
                    await self.dispatch(authrizationStatus: .success(status: status))
                }
            }
    }
    
}
