//
//  CoreLocationObject.swift
//  ToySwiftUILocation
//
//  Created by Faiz Mokhtar AD0502 on 17/11/2020.
//

import Foundation
import CoreLocation
import Combine
import SwiftUI

protocol CLLocationManagerCombineDelegate: CLLocationManagerDelegate {
    func authorizationPublisher() -> AnyPublisher<CLAuthorizationStatus, Never>
    func locationPublisher() -> AnyPublisher<[CLLocation], Never>
}

class CoreLocationObject: ObservableObject {
    @Published var authorizationStatus = CLAuthorizationStatus.notDetermined
    @Published var location: CLLocation?
    
    let manager: CLLocationManager
    let publicist: CLLocationManagerDelegate
    
    var cancellables = [AnyCancellable]()
    
    init() {
        let manager = CLLocationManager()
        let publicist = CLLocationManagerPublisher()
        
        manager.delegate = publicist
        
        self.manager = manager
        self.publicist = publicist
        
        let authorizationPublisher = publicist.authorizationPublisher()
        let locationPublisher = publicist.locationPublisher()
        
        authorizationPublisher
            .sink(receiveValue: beginUpdates)
            .store(in: &cancellables)
        
        authorizationPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$authorizationStatus)
        
        locationPublisher
            .flatMap(Publishers.Sequence.init(sequence:))
            .map { $0 as CLLocation? }
            .receive(on: DispatchQueue.main)
            .assign(to: &$location)
    }
    
    func beginUpdates(_ authorizationStatus: CLAuthorizationStatus) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func authorize() {
        manager.requestAlwaysAuthorization()
    }
}

class CLLocationManagerPublisher: NSObject, CLLocationManagerCombineDelegate {
    let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    let locationSubject = PassthroughSubject<[CLLocation], Never>()
    
    func authorizationPublisher() -> AnyPublisher<CLAuthorizationStatus, Never> {
        return Just(CLLocationManager.authorizationStatus())
            .merge(with:
                    authorizationSubject.compactMap { $0 }
            ).eraseToAnyPublisher()
    }
    
    func locationPublisher() -> AnyPublisher<[CLLocation], Never> {
        return locationSubject.eraseToAnyPublisher()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationSubject.send(status)
    }
}
extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authorizedAlways:
            return "Always Authorized"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        @unknown default:
            return "🤷‍♂️"
        }
    }
}
