//
//  File.swift
//  
//
//  Created by Igor on 07.02.2023.
//

import CoreLocation

extension LocationManagerAsync{
    
    final class Delegate: NSObject, CLLocationManagerDelegate{
        
        /// Continuation asynchronously passing location data
        var stream: Streaming?{
            didSet {
                stream?.onTermination = { @Sendable termination in
                    self.onTermination(termination)
                    
                }
            }
        }
        
        // MARK: - Delegate
        
        /// Pass `CLLocation` into the async stream
        /// - Parameters:
        ///   - manager: Location manager
        ///   - locations: Array of `CLLocation`
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                locations.forEach{ pass(location: $0) }
        }
        
        /// Notify about location manager changed authorization status
        /// - Parameter manager: Location manager
        public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            NotificationCenter.default.post(name: Permission.authorizationStatus, object: manager.authorizationStatus)
        }
        
        // MARK: - Private
        
        /// Process termination
        /// - Parameter termination: A type that indicates how the stream terminated.
        private func onTermination(_ termination: Termination){
            let type = AsyncLocationErrors.self
            stream?.finish(throwing: type.streamTerminated)
         }
        
        /// Passing ``CLLocation`` data
        /// - Parameter location: Location data
        private func pass(location : CLLocation){
            stream?.yield(location)
        }
        
    }    
    
    // MARK: - Alias types -

    private typealias Termination = AsyncThrowingStream<CLLocation, Error>.Continuation.Termination
    
    typealias Streaming = AsyncThrowingStream<CLLocation, Error>.Continuation
    
}


