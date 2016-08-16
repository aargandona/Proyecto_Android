//
//  MapViewController.swift
//  FoodTracker
//
//  Created by Diego Alejandro Orellana Lopez on 7/28/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var meals = [Meal]()
    var viewWillDisappear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //mapView.scrollEnabled = true
        self.mapView.delegate = self
        //mapView.removeAnnotations(mapView.annotations)
        //addMealsAnnotations()
        
        mapView.scrollEnabled = true
        mapView.zoomEnabled = true
        mapView.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewWillDisappear = true
    }
    
    override func viewWillAppear(animated: Bool) {
        if viewWillDisappear{
            print("View resume")
            mapView.removeAnnotations(mapView.annotations)
            addMealsAnnotations()
        }
    }

    func addMealsAnnotations(){
        self.meals = GlobalVariables.sharedManager.meals
        
        //Config MapView
        if  meals.count > 0 {
            // Set region
            //let currentLocation = CLLocationCoordinate2D(latitude: meals[0].latitud, longitude: meals[0].longitud)
            //let region = MKCoordinateRegion(center: currentLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            //self.mapView.setRegion(region, animated: true)
            
            // Create annotations
            var location:CLLocationCoordinate2D
            //var anotation:MKPointAnnotation
            var anotation:CustomPointAnnotation
            for mealItem in meals{
                location = CLLocationCoordinate2D(latitude: mealItem.latitud, longitude: mealItem.longitud)
                
                //anotation = MKPointAnnotation()
                anotation = CustomPointAnnotation()
                anotation.coordinate = location
                anotation.title = mealItem.name
                anotation.subtitle = mealItem.name
                anotation.image = mealItem.photo
                mapView.addAnnotation(anotation)
            }
            
            // Enclosed all annotations
            fitMapViewToAnnotaionList(mapView.annotations)
            //>>
        }
        //>>
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.canShowCallout = true
        anView!.image = cpa.image
        anView!.calloutOffset = CGPointMake(0, 32)
        anView!.frame.size = CGSize(width: 40.0, height: 40.0)
        
        return anView
    }
    
    func fitMapViewToAnnotaionList(annotations: [MKAnnotation]) -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<annotations.count {
            let annotation = annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        addMealsAnnotations()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
