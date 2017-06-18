//
//  HaveanicetimeViewControler.swift
//  Geotify
//
//  Created by admin on 17.06.17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import UIKit
import CoreLocation

class HaveanicetimeViewControler: UIViewController, CLLocationManagerDelegate {
  
  let locationManager = CLLocationManager ()
  var geotifications: [Geotification] = []
  var isAtHome = false

  override func viewDidLoad()
  {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    showLate()
  }

  func showGreat() {
    performSegue(withIdentifier: "showGreat", sender: self)
  }
  
  func showLate() {
    performSegue(withIdentifier: "showLate", sender: self)
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    print("location manager function triggered")
    if region is CLCircularRegion && isAtHome == false {
      isAtHome = true
      showGreat()
    }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
    }
}

}
}
