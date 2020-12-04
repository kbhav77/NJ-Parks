//
//  ViewController.swift
//  NJParksMap
//
//  Created by Krish Bhavnani on 12/1/20.
//  Copyright © 2020 Krish Bhavnani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    private var parks: [Park] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let initialLocation = CLLocation(latitude: 40.352171, longitude: -74.591478)
        
        
        mapView.centerToLocation(initialLocation)
        
        mapView.delegate = self
                
        loadInitialData()
        mapView.addAnnotations(parks)


        
    }
    
    private func loadInitialData() {
      //Grab file from bundle
      guard
        let fileName = Bundle.main.url(forResource: "Parks_in_New_Jersey", withExtension: "geojson"),
        let parkData = try? Data(contentsOf: fileName)
        else {
          return
      }
        
        
      //Decode GeoJSON
      do {
        let features = try MKGeoJSONDecoder()
          .decode(parkData)
          .compactMap { $0 as? MKGeoJSONFeature }
        let displayParks = features.compactMap(Park.init)
        parks.append(contentsOf: displayParks)
      } catch {
        print("Unexpected error: \(error).")
      }
    }

    
    
    
}

private extension MKMapView {
    
  //Center the map on New Jersey on startup
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 120000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
    
}

extension ViewController: MKMapViewDelegate {
  
 //Click annotation for detailed view
 func mapView(
    _ mapView: MKMapView,
    viewFor annotation: MKAnnotation
  ) -> MKAnnotationView? {
    
    guard let annotation = annotation as? Park else {
      return nil
    }
    
    let identifier = "park"
    var view: MKMarkerAnnotationView
    
    if let dequeuedView = mapView.dequeueReusableAnnotationView(
      withIdentifier: identifier) as? MKMarkerAnnotationView {
      dequeuedView.annotation = annotation
      view = dequeuedView
    } else {
      view = MKMarkerAnnotationView(
        annotation: annotation,
        reuseIdentifier: identifier)
      view.canShowCallout = true
      view.calloutOffset = CGPoint(x: -5, y: 5)
      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    return view
  }
    
  //Open maps on click
  func mapView(
    _ mapView: MKMapView,
    annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl
  ) {
    guard let park = view.annotation as? Park else {
      return
    }

    let launchOptions = [
      MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
    ]
    park.mapItem?.openInMaps(launchOptions: launchOptions)
  }

}


