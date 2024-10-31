//
//  MapView.swift
//  FeedMapLite
//
//  Created by 신이삭 on 7/22/24.
//

import SwiftUI
import GoogleMaps
import Kingfisher
import ComposableArchitecture

struct MapView: UIViewRepresentable {
    var store: ViewStore<MapFeature.State, MapFeature.Action>
    var gMap = GMSMapView()
    
    func makeUIView(context: Context) -> GMSMapView {
        gMap.frame = .zero
        gMap.camera = GMSCameraPosition.camera(
            withLatitude: store.state.moveLocation?.coordinate.latitude ?? 0.0,
            longitude: store.state.moveLocation?.coordinate.longitude ?? 0.0,
            zoom: store.state.zoomLevel)
        gMap.delegate = context.coordinator
        gMap.isUserInteractionEnabled = true
        gMap.isMyLocationEnabled = true
        gMap.mapType = .normal
        gMap.setMinZoom(5.0, maxZoom: 20.0)
        gMap.settings.myLocationButton = true
        
        return gMap
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        if store.state.isUpdateCheck {
            uiView.clear()
            
            if let location = store.state.moveLocation {
                self.mapCameraMove(mapView: uiView, location: location)
            }
        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(store: self.store)
    }
    
    final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
       
        var store: ViewStore<MapFeature.State, MapFeature.Action>

        init(store: ViewStore<MapFeature.State, MapFeature.Action>) {
            self.store = store
        }
        
        // 마커클릭
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            return true
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            let zoomLevel = mapView.camera.zoom
            store.send(.setMapView(zoomLevel: zoomLevel))
        }
        
        // 지도 클릭
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            
        }
        
        // 지도 중앙 위치
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            let clocation: CLLocation = CLLocation(
                latitude: position.target.latitude,
                longitude: position.target.longitude
            )
            print("Center Position: \(clocation)")
            store.send(.setCenterPosition(cLocation: clocation))
        }
    }

}

extension MapView {
    private func mapCameraMove(mapView: GMSMapView, location: CLLocation) {
        let camera = GMSCameraPosition.camera(
            withLatitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            zoom: mapView.camera.zoom
        )
        mapView.camera = camera
        
        store.send(.setMapView(moveLocation: nil,
                                   isUpdateCheck: false))

    }
}
