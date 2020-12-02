//
//  Park.swift
//  NJParksMap
//
//  Created by Krish Bhavnani on 12/1/20.
//  Copyright © 2020 Krish Bhavnani. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Park: NSObject, MKAnnotation {
  let title: String?
  let county: String?
  let coordinate: CLLocationCoordinate2D


  init(
    title: String?,
    county: String?,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = title
    self.county = county
    self.coordinate = coordinate

    super.init()
  }

  var subtitle: String? {
    return county
  }
    
  var mapItem: MKMapItem? {
    guard let location = title else {
      return nil
    }

    let addressDict = [CNPostalAddressStreetKey: location]
    let placemark = MKPlacemark(
    coordinate: coordinate,
    addressDictionary: addressDict)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    return mapItem
  }
    
  init?(feature: MKGeoJSONFeature) {
    // 1
    guard
      let point = feature.geometry.first as? MKPointAnnotation,
      let propertiesData = feature.properties,
      let json = try? JSONSerialization.jsonObject(with: propertiesData),
      let properties = json as? [String: Any]
      else {
        return nil
    }

    // 3
    title = properties["NAME"] as? String
    county = properties["COUNTY"] as? String
    coordinate = point.coordinate
    super.init()
  }

    
}
