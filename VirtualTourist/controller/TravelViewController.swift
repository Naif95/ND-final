//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Naif on 08/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var context: NSManagedObjectContext {
        return appDelegate.dataController.viewContext
    }
    
    var pin: Pin!
    var dataController: DataController!
    var fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(TravelViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @objc func handleLongPress(_ pressedRecognizer : UIGestureRecognizer){
        if pressedRecognizer.state != .began { return }
        let touchPoint = pressedRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        prepareToSave(Coordinate: touchMapCoordinate)
    }
    
    func prepareToSave(Coordinate: CLLocationCoordinate2D ){
        let annotation = MKPointAnnotation()
        annotation.coordinate = Coordinate
        saveNewPin(location: Coordinate)
        mapView.addAnnotation(annotation)
    }
    
    func saveNewPin(location: CLLocationCoordinate2D){
        let newPin = Pin(context: context)
        newPin.latitude = location.latitude
        newPin.longitute = location.longitude
        do{
            try context.save()
            print("saved view context")
            pin = newPin
        } catch{
            print("Persist New Pin Error")
            debugPrint()
        }
    }
    
    func setupFetchedResultsController() {
        if let result = try? context.fetch(fetchRequest) {
            for pin in result {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitute))
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoVcSegue"{
            let vc = segue.destination as! PhotosViewController
            vc.pin = pin
        }
    }
    
}


extension TravelViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            pinView!.pinTintColor = UIColor.red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin")
        //assign lat and log
        if let alatitude = view.annotation?.coordinate.latitude , let alongitude = view.annotation?.coordinate.longitude {
            if let result = try? context.fetch(fetchRequest) {
                for pin in result {
                    if pin.latitude == alatitude && pin.longitute == alongitude {
                        self.pin = pin
                        print("inside mapview did select")
                        self.performSegue(withIdentifier: "photoVcSegue", sender: nil)
                    }
                    else {
                        print("RE")
                    }
                    
                }
            }
        }
    }
}


