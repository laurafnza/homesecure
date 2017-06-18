/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit


class AddGeotificationViewController: UITableViewController
{

  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var zoomButton: UIBarButtonItem!
  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!

  let locationManager = CLLocationManager()

  override func viewDidLoad()
  {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    
    navigationItem.rightBarButtonItems = [addButton, zoomButton]
    addButton.isEnabled = false
  }
  
  
  func startMonitoring(geotification: Geotification)
  {
    // 1
    if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
    {
      showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
      return
    }
    // 2
    if CLLocationManager.authorizationStatus() != .authorizedAlways
    {
      showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
    }
    // 3
    let region = self.region(withGeotification: geotification)
    // 4
    locationManager.startMonitoring(for: region)
  }

  func region(withGeotification geotification: Geotification) -> CLCircularRegion
  {
    // 1
    let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
    // 2
    region.notifyOnEntry = (geotification.eventType == .onEntry)
    return region
  }


  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showTime" {
      let coordinate = mapView.centerCoordinate
      let radius = Double(radiusTextField.text!) ?? 0
      let identifier = NSUUID().uuidString
      let note = noteTextField.text
      let eventType: EventType = .onEntry

      // 1
      let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
      let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note!, eventType: eventType)
      
      // 2
      startMonitoring(geotification: geotification)
    }
  }
  @IBAction func textFieldEditingChanged(sender: UITextField)
  {
    addButton.isEnabled = !radiusTextField.text!.isEmpty && !noteTextField.text!.isEmpty
  }

  @IBAction func onCancel(sender: AnyObject)
  {
    dismiss(animated: true, completion: nil)
  }

  @IBAction private func onZoomToCurrentLocation(sender: AnyObject)
  {
    mapView.zoomToUserLocation()
  }
}



// MARK: - Location Manager Delegate
extension AddGeotificationViewController: CLLocationManagerDelegate
{
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
  {
    mapView.showsUserLocation = (status == .authorizedAlways)
  }
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
  {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
  {
    print("Location Manager failed with the following error: \(error)")
  }
}

