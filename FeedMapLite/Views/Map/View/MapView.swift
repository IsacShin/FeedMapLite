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
import SnapKit

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
            
            if let datas = store.state.feedListRawData {
                if datas.count > 0 {
                    datas.forEach { data in
                        guard let lat = data.latitude,
                              let lng = data.longitude,
                              let dLat = Double(lat),
                              let dLng = Double(lng) else { return }
                        
                        let loca = CLLocation(latitude: dLat, longitude: dLng)
                        self.createMarker(mapView: uiView, loca: loca, data: data)
                    }
                }
                
                store.send(.setMapView(moveLocation: nil,
                                           isUpdateCheck: false))
            }
            
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
            if let data = marker.userData as? FeedDataModel {
                
                store.send(.isShowSelectTab(isSelectTab: true, selectData: data))
            }
            
            return true
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            let zoomLevel = mapView.camera.zoom
            store.send(.setMapView(zoomLevel: zoomLevel))
        }
        
        // 지도 클릭
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            store.send(.isShowSelectTab(isSelectTab: false, selectData: nil))
        }
        
        // 지도 중앙 위치
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            let clocation: CLLocation = CLLocation(
                latitude: position.target.latitude,
                longitude: position.target.longitude
            )
            store.send(.setCenterPosition(cLocation: clocation))
        }
    }
    
    private func createMarker(mapView: GMSMapView, loca: CLLocation, data: FeedDataModel) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: loca.coordinate.latitude, longitude: loca.coordinate.longitude)
        marker.title = data.addr
        marker.snippet = data.title
        
        marker.userData = data
        if let imgData = data.img1,
           let img = UIImage(data: imgData) {
            let v = UIView()
            v.frame = .init(x: 0, y: 0, width: 45, height: 45)
            v.layer.cornerRadius = v.frame.width / 2
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 2
            v.clipsToBounds = true
            let imgV = UIImageView()
            v.addSubview(imgV)
            imgV.snp.makeConstraints {
                $0.leading.trailing.top.bottom.equalToSuperview()
            }
            imgV.image = img
            marker.iconView = v
        }
        marker.map = mapView
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
