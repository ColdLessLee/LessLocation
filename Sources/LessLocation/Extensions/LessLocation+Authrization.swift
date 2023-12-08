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
    
    public enum AuthrizationEvent {
        case success(status: CLAuthorizationStatus)
        case failure(detail: AuthrizationError)
    }
    
    public enum AuthrizationError: Error {
        case missContext
        case unrequestable(CLAuthorizationStatus)
        case others(error: Error)
    }
    
    public typealias AuthrizationRequest = (_ status: AuthrizationEvent) -> Void
   
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
            return completion(.failure(detail: .unrequestable(status)))
        }
        // 创建信号量, 禁止方法重入
        let semaphore = DispatchSemaphore(value: 1)
        semaphore.wait()
        // 异步任务
        Task.detached { [weak self, semaphore, completion] in
            guard let self = self else {
                completion(.failure(detail: .missContext))
                return
            }
            await self.locationRequstCoordinator.setAuthrizationRequest { [semaphore, completion] result in
                completion(result)
                semaphore.signal()
            }
            // 在主线程发起请求
             await MainActor.run { [self] in
                switch target {
                case .always:
                   return self.locationManager.requestAlwaysAuthorization()
                case .whenInUse:
                   return self.locationManager.requestWhenInUseAuthorization()
                }
            }
        }
    }
  
}
