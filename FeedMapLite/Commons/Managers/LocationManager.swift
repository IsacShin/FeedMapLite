//
//  LocationManager.swift
//  FeedMapLite
//
//  Created by 신이삭 on 8/30/24.
//

import CoreLocation
import ComposableArchitecture
import Combine

final class LocationManager: NSObject, CLLocationManagerDelegate {
    var delegate: Delegate?
    private var manager = CLLocationManager()
    private var statusHandler: (() -> ())?
    
    struct Delegate {
        var didChangeAuthorization: (CLAuthorizationStatus) -> Void
        var didUpdateLocations: (Result<CLLocation, Error>) -> Void
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 10
    }

    func requestLocation() {
        if let statusHandler = self.statusHandler {
            statusHandler()
        } else {
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
        }
    }
    
    func setDelegate(delegate: Delegate) {
        self.delegate = delegate
    }

    enum Action: Equatable {
        case didChangeAuthorization(CLAuthorizationStatus)
        case didUpdateLocations(Result<CLLocation, Error>)
    }

    enum Error: Swift.Error, Equatable {
        case locationError
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if delegate == nil && status == .denied {
            self.statusHandler = {
                self.delegate?.didChangeAuthorization(status)
                self.statusHandler = nil
            }
        } else {
            self.requestLocation()
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else {
            delegate?.didUpdateLocations(.failure(.locationError))
            return
        }
        manager.stopUpdatingLocation()
        delegate?.didUpdateLocations(.success(location))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
        delegate?.didUpdateLocations(.failure(error))
    }
}
