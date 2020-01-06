//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Naif on 22/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {
    
    let flickrCall = FlickrCall()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var context: NSManagedObjectContext {
        return appDelegate.dataController.viewContext
    }
    
    @IBOutlet var mapView: MKMapView!
    var dataController: DataController!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toolbarButton: UIButton!
    
    public var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photos>!
    var selectedPhotos: [IndexPath]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        collectionView.allowsMultipleSelection = true
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        createAnnotation()
        setupFetchedResultsController()
        let w = view.frame.size.width / 3
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: w, height: w)
        
        if fetchedResultsController.fetchedObjects!.count == 0 {
            print("loading")
            loadPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    func setDelegateAndDataSource() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func createAnnotation(){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitute)
        mapView.addAnnotation(annotation)
        
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitute)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        
        self.mapView.isZoomEnabled = false;
        self.mapView.isScrollEnabled = false;
        self.mapView.isUserInteractionEnabled = false;
        
        mapView.setRegion(region, animated: true)
    }
    
    func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func loadPhotos() {
        
        flickrCall.getPhotosforLocation(pin.latitude, pin.longitute, 20) { (success, photos) in
            
            if success == false {
                displayAlert.displayAlert(message: "Error in internet Connection, please try again later", title: "Connection Error", vc: self, shouldReturn: true)
                print("Unable to download images from Flickr.")
                return
            }            
            print("Flickr images fetched : \(photos!.count)")
            if photos!.count == 0 {
                DispatchQueue.main.async {
                    displayAlert.displayAlert(message: "Thies location has no images.", title: "Error", vc: self, shouldReturn: true)
                    return
                }
            }
            photos!.forEach() { photo_url in
                let photo = Photos(context: self.context)
                photo.imageUrl = URL(string: photo_url["url_m"] as! String)?.absoluteString
                photo.pin = self.pin
                
                do {
                    try self.context.save()
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: Data?, _ errorString: String?) -> Void){
        
        let session = URLSession.shared
        let imgURL = NSURL(string: imagePath)
        let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
            
            if downloadError != nil {
                completionHandler(nil, "Could not download image \(imagePath)")
            } else {
                
                completionHandler(data, nil)
            }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weather"{
            let vc = segue.destination as! WeatherViewController
            vc.long = pin.longitute
            vc.lat = pin.latitude
        }
    }
    
    @IBAction func updateCollection(_ sender: Any) {
        if hasSelectedPhotos() {
            deleteSelectedPhotos()
        } else {
            fetchedResultsController.fetchedObjects?.forEach() { photo in
                context.delete(photo)
                do {
                    try context.save()
                } catch {
                    print("Unable to delete photo. \(error.localizedDescription)")
                }
            }
            loadPhotos()
            self.collectionView.reloadData()
        }
    }
    func deleteSelectedOrAll(indexPath: IndexPath?, flag:String) {
        if(flag == "All"){
            if let photoToDelete = fetchedResultsController.fetchedObjects{
                for photo in photoToDelete {
                    context.delete(photo)
                }
                try? context.save()
            }
        }else{
            let photoToDelete = fetchedResultsController.object(at: indexPath!)
            context.delete(photoToDelete)
            try? context.save()
        }
    }
}



extension PhotosViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}

extension PhotosViewController:NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            self.collectionView.deleteItems(at: [indexPath!])
        case .move:
            self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        case .update:
            self.collectionView.reloadItems(at: [indexPath!])
        }
    }
}


