//
//  LessLocation+Authrization.swift
//
//
//  Created by Lee ColdWorker on 2023/12/8.
//

import Foundation
import CoreLocation

// MARK: - 权限请求 - 类型定义
extension LessLocation {
    
    public enum AuthrizationTarget {
        case always
        case whenInUse
    }
    
    public typealias AuthrizationResult = Result<CLAuthorizationStatus, AuthrizationError>
    
    public enum AuthrizationError: Error {
        case missContext
        case unrequestable(CLAuthorizationStatus)
        case others(error: Error)
    }
    
    public typealias AuthrizationRequest = (_ status: AuthrizationResult) -> Void
   
}

// MARK: - Public
extension LessLocation {
    
    /// 异步请求地理位置授权
    /// - Parameter target: LessLocation.AuthrizationTarget
    /// - Returns: CLAuthorizationStatus
    public func requestAuthrization(for target: AuthrizationTarget) async throws -> CLAuthorizationStatus {
        // 必须是未决定才能往下走, 否则直接抛出错误内容
        guard locationManager.authorizationStatus == .notDetermined else {
            throw AuthrizationError.unrequestable( locationManager.authorizationStatus)
        }
        // 创建一个挂起
        let status: CLAuthorizationStatus = try await withCheckedThrowingContinuation { continuation in
            requestAuthrization(for: target) { status in
                switch status {
                case .success(let status):
                    continuation.resume(returning: status)
                case .failure(let detail):
                    continuation.resume(throwing: detail)
                }
            }
        }
        // 返回
        return status
    }
    
    /// 请求地理位置授权
    /// - Parameters:
    ///   - target: LessLocation.AuthrizationTarget
    ///   - completion: (_ status: LessLocation.AuthrizationEvent) -> Void
    public func requestAuthrization(for target: AuthrizationTarget, completion: @escaping AuthrizationRequest) {
        // 必须是未决定才能往下走, 否则直接抛出错误内容
        guard locationManager.authorizationStatus == .notDetermined else {
            let status = locationManager.authorizationStatus
            return completion(.failure(.unrequestable(status)))
        }
        locationRequstCoordinator.setAuthrizationRequest { [completion] result in
            completion(result)
        }
        DispatchQueue.main.async {
            switch target {
            case .always:
               return self.locationManager.requestAlwaysAuthorization()
            case .whenInUse:
               return self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
  
}
