//
//  MapViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/15.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate  {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var transportSegument: UISegmentedControl!
    lazy var locationManager = CLLocationManager()
    // restaurant 的位置标记
    var currentRestaurantPlacemark: CLPlacemark!
    var restaurant: Restaurant!
    var chooseTransportType = MKDirectionsTransportType.Walking
    var currentRoutes: MKRoute?
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnnotation()
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        }

        transportSegument.addTarget(self, action: #selector(MapViewController.getMyLocation), forControlEvents: .ValueChanged)
        // 分别让地图显示指南针，交通信息和比例
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsScale = true
        mapView.showsBuildings = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func getMyLocation() {
        let segmentIndex = transportSegument.selectedSegmentIndex
        chooseTransportType = { switch segmentIndex {
        case 1:
            return .Automobile
        default:
            return .Walking
            } }()

        transportSegument.hidden = false

        // Set the source and destination of the route
        func setRoute() -> MKDirectionsRequest{
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = MKMapItem.mapItemForCurrentLocation()
            let destinationPlacemark = MKPlacemark(placemark: currentRestaurantPlacemark)
            directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
            directionRequest.transportType = chooseTransportType

            return directionRequest
        }
        let directionRequest = setRoute()

        // Calculate the direction
        func calculateDirection(directionRequest: MKDirectionsRequest) {
            let directions = MKDirections(request: directionRequest)
            directions.calculateDirectionsWithCompletionHandler {
                routeResponse, routeError in
                if routeError != nil {
                    print("Error: \(routeError!.localizedFailureReason), \(routeError?.localizedDescription)")
                } else {
                    // 获得 Apple 服务器发来的路线数据.一般情况下只会发送一个
                    // 但是在 requestsAlternateRoutes 设置为 true 的情况下, 就会返回多个.
                    // 之后再给通过添加 overlay 把路线添加的地图上.
                    // 不过需要注意的是, 还需要设置 overlay 的属性才行, 否则虽然会显示, 但是看不到
                    let route = routeResponse?.routes.first
                    self.currentRoutes = route
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.addOverlay(route!.polyline, level: .AboveRoads)
                    // 获得路径的矩形视图, 自动缩放. 以获得更加完美的显示效果, 而不要手动拖动和缩放.
                    let rect = route?.polyline.boundingMapRect
                    if let rect = rect {
                        self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                    }
                }
            }

        }
        calculateDirection(directionRequest)
    }

    @IBAction func showNearby() {
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = restaurant.type
        searchRequest.region = mapView.region

        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.startWithCompletionHandler {
            response, error -> Void in
            if error != nil { print("Error: \(error!.localizedDescription)"); return }
            let mapItems = response!.mapItems

            var nearbyAnnotations:[MKAnnotation] = []
            if mapItems.count > 0 {
                for item in mapItems {
                    // Add annotation 
                    let annotation = MKPointAnnotation()
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.coordinate = item.placemark.location!.coordinate
                    nearbyAnnotations.append(annotation)
                }
            }
            self.mapView.showAnnotations(nearbyAnnotations, animated: true)
        }
    }

    private func createAnnotation() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location) {
            [unowned self] placemarks, error in
            if error != nil {
                print(error)
                return
            }

            guard let location = placemarks?.first?.location else { return }
            self.currentRestaurantPlacemark = placemarks!.first! as CLPlacemark
            let annotation = MKPointAnnotation()
            annotation.title = self.restaurant.name
            annotation.subtitle = self.restaurant.type
            annotation.coordinate = location.coordinate

            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    // MARK: - MapView Delegate Method
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "My Pin"

        if annotation is MKUserLocation {
            return nil
        }

        // 和 Cell 一样, 也通过重用队列中的 Annotation 来节省内存
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)

        // 如果队列中不存在可重用的， 则重新创建
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }

        annotationView?.tintColor = UIColor.blueColor()

        // 只为自己的 restaurant 创建额外的信息.
        if annotation.title! == restaurant.name {
            let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
            leftIconView.image = UIImage(data: restaurant.image!)
            annotationView?.leftCalloutAccessoryView = leftIconView
            annotationView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }

        return annotationView
    }

    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = chooseTransportType == .Walking ? .blueColor() : UIColor.yellowColor()

        render.lineWidth = 4.0

        return render
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if currentRoutes == nil {
            let alert = UIAlertController(title: "You Can't Do This", message: "You should tap the direction button first", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "I will do it", style: .Default) { _ in
                self.performSelector(#selector(MapViewController.getMyLocation), withObject: nil, afterDelay: 0.5, inModes: [])
                })
            presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("showNavigationSteps", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNavigationSteps" {
            let stepsTC = segue.destinationViewController as! StepsTableViewController
            if let route = currentRoutes?.steps {
                stepsTC.routeSteps = route
            }
        }
    }
}
