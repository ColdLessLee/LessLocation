//
//  File.swift
//  
//
//  Created by Lee ColdWorker on 2023/12/8.
//

import Foundation
import CoreLocation

// MARK: - 地理位置请求 通用类型定义
extension LessLocation {
    
    public enum LocationRequestEvent {
        case failure(error: Error)
        case success(locations: [CLLocation])
    }
    
    public enum LocationError: Error {
        case unreachable
        case operation(error: Error)
    }
    
    public typealias LocationResult = Result<[CLLocation], LocationError>
    
    public typealias LocationRequst = (_ result: LocationResult) -> Void
    
}

// MARK: - Public
extension LessLocation {
    
    public func requestLocations(isHighLevel: Bool = false) async throws -> [CLLocation] {
        let locations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
            requestLocations(isHighLevel: isHighLevel) { result in
                switch result {
                case .success(let locations):
                    continuation.resume(returning: locations)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        return locations
    }
    
    public func requestLocations(isHighLevel: Bool = false, completion: @escaping LocationRequst) {
        guard isLocationFetchable() else { return completion(.failure(.unreachable)) }
        locationRequstCoordinator.pushLocationRequest { result in
            completion(result)
        }
        DispatchQueue.main.async {
            return isHighLevel ? self.locationManager.requestLocation() : self.locationManager.startUpdatingLocation()
        }
    }

}
