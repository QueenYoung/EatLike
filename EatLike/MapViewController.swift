//
//  MapViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/15.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var transportSegument: UISegmentedControl!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.delegate = self
        return manager
    }()

    // 用户 的位置标记
    var currentLocation: CLLocationCoordinate2D?
    var currentRestaurantPlacemark: CLPlacemark?
    var restaurant: Restaurant!
    // 用户选择的导航方式
    var chooseTransportType = MKDirectionsTransportType.walking
    // 用于在获得详细的导航路径的参数
    var currentRoutes: MKRoute?
    // 搜索栏
    var resultSearchController: UISearchController!
    var restaurantAnnotation: MKAnnotation!
    // 只创建一次的 annotation

    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        createAnnotation()
        // Do any additional setup after loading the view.
        getAuthorization()
        configureSearch()
        transportSegument.addTarget(
            self, action: #selector(getMyLocation), for: .valueChanged)
        // 分别让地图显示指南针，交通信息和比例
        mapView.showsCompass = true
        mapView.showsTraffic = true
        mapView.showsScale = true
        mapView.showsBuildings = true

    }

    override func viewWillDisappear(_ animated: Bool) {
        mapView.showsUserLocation = false
        locationManager.stopUpdatingLocation()
    }

    // Naviation Methods
    @IBAction func getMyLocation(sender: UIBarButtonItem) {
        let segmentIndex = transportSegument.selectedSegmentIndex
        chooseTransportType = { switch segmentIndex {
        case 1:
            return .automobile
        default:
            return .walking
            } }()

        transportSegument.isHidden = false

        let directionRequest = setRoute()
        calculateDirection(for: directionRequest)
    }

    @IBAction func showNearby(sender: UIBarButtonItem) {
        let searchRequest = MKLocalSearchRequest()
        // 去除 emoji 的影响
        searchRequest.naturalLanguageQuery = String(restaurant.type.characters.split(separator: " ")[1])
        // 获得当前地图中心, 方圆 2 公里的区域
        let region = MKCoordinateRegionMakeWithDistance(mapView.centerCoordinate, 2000, 2000)
        searchRequest.region = region

        let localSearch = MKLocalSearch(request: searchRequest)
        localSearch.start {
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


    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNavigationSteps" {
            let stepsTC = segue.destinationViewController as! StepsTableViewController
            if let route = currentRoutes?.steps {
                stepsTC.routeSteps = route
            }
        }
    }

}

// MARK: - MapView Delegate Method
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "ShopPinDetailView"

        // 如果是用户自己的位置的话, 忽略
        if annotation is MKUserLocation || annotation.title! != restaurant.name {
            return nil
        }

        // 和 Cell 一样, 也通过重用队列中的 Annotation 来节省内存
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        // 如果队列中不存在可重用的， 则重新创建
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }

            // 通过 nib 文件创建直接创建 UIView
        let detailView = (UINib(nibName: identifier, bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? UIView) as! MapPinView
        detailView.delegate = self
        detailView.restaurant = restaurant
        detailView.currentRestaurantPlacemark = currentRestaurantPlacemark
        annotationView?.detailCalloutAccessoryView = detailView
        annotationView?.pinTintColor = MKPinAnnotationView.greenPinColor()
        restaurantAnnotation = annotation
        
        return annotationView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = chooseTransportType == .walking ? .blue() : UIColor.yellow()
        render.lineWidth = 8.0

        return render
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if currentRoutes == nil {
            let alert = UIAlertController(title: "You Can't Do This", message: "You should tap the direction button first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I will do it", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "showNavigationSteps", sender: self)
        }
    }

}

// MARK: - Helper Methods
extension MapViewController {
    private func getAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // Set the source and destination of the route
    private func setRoute() -> MKDirectionsRequest? {
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = MKMapItem.forCurrentLocation()

        guard let currentRestaurantPlacemark = currentRestaurantPlacemark else { return nil }
        let destinationPlacemark = MKPlacemark(placemark: currentRestaurantPlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = chooseTransportType
        return directionRequest
    }

    // Calculate the direction
    private func calculateDirection(for request: MKDirectionsRequest?) {
        guard let directionRequest = request else { return }
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            routeResponse, routeError in
            if routeError != nil {
                print("Error: \(routeError!.localizedFailureReason), \(routeError?.localizedDescription)")
                let alert = UIAlertController(
                    title: routeError!.localizedFailureReason!,
                    message: routeError!.localizedDescription,
                    preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "I got it!", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // 获得 Apple 服务器发来的路线数据.一般情况下只会发送一个
                // 但是在 requestsAlternateRoutes 设置为 true 的情况下, 就会返回多个.
                // 之后再给通过添加 overlay 把路线添加的地图上.
                // 不过需要注意的是, 还需要设置 overlay 的属性才行, 否则虽然会显示, 但是看不到
                let route = routeResponse?.routes.first
                // 为之后 segue 操作做准备.
                self.currentRoutes = route
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.add(route!.polyline, level: .aboveRoads)
                // 获得路径的矩形视图, 自动缩放. 以获得更加完美的显示效果, 而不要手动拖动和缩放.
                let rect = route?.polyline.boundingMapRect
                if let rect = rect {
                    self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                }
            }
        }
    }
    
    /**
     在无法获得定位服务的时候调用
     */
    private func showLocationRequiredAlert() {
        let alertController = UIAlertController(
            title: "Location Access Required",
            message: "Location access is required to fetch the weather for your current location.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let appSettingsAction = UIAlertAction(title: "App Settings", style: .default) { action in
            UIApplication.shared().open(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        alertController.addAction(appSettingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /**
     要求改善地理位置的时候使用
     */
    private func reinputLocation() {
        let alertView = UIAlertController(
            title: "Location Error!",
            message: "You can use search bar to replace your location",
            preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "Replace It", style: .default) {
            _ in
            self.resultSearchController.becomeFirstResponder()
            })
        
        alertView.addAction(UIAlertAction(title: "Go Back", style: .cancel, handler: {
            _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertView, animated: true, completion: nil)
    }
    
    /**
     用来创建一个 **Annotation**, 在刚进入视图或者更新了地理位置后调用
     */
    private func createAnnotation() {
        
        func addAnnotation(in location: CLLocation) {
            let annotation = MKPointAnnotation()
            annotation.title = self.restaurant.name
            annotation.subtitle = self.restaurant.type
            annotation.coordinate = location.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location) {
            [unowned self] placemarks, error in
            // 如果不能成功定位, 就调用 警告框要求重新输入正确的地理位置
            if error != nil {
                print(error)
                self.reinputLocation()
                return
            }
            
            guard let location = placemarks?.first?.location else {
                return
            }
            self.currentRestaurantPlacemark = placemarks!.first!
            
            addAnnotation(in: location)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChange status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Location authorization not determined")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            mapView.showsUserLocation = true
        case .denied, .restricted:
            mapView.showsUserLocation = false
            showLocationRequiredAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location \(error.localizedDescription)")
    }
}


// MARK: Protocol Extension
extension MapViewController: Navigationable {
    func getNavigationRoute() {
        if currentRoutes == nil {
            let alert = UIAlertController(title: "You Can't Do This", message: "You should tap the direction button first", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I will do it", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "showNavigationSteps", sender: self)
        }
    }
}

extension MapViewController: HandleMapSearchDelegate {
    func configureSearch() {
        let locationSearchTable = storyboard?
            .instantiateViewController(withIdentifier: "LocationSearchTable")
            as! LocationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.delegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        resultSearchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = NSLocalizedString("Search for places", comment: "search")
        navigationItem.titleView = resultSearchController?.searchBar
    }
    
    func dropPinZoomIn(placemark: MKPlacemark) {
        
        // 先移除所有的 annotations
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        // 获得城市名和州名
        if let city = placemark.locality,
            let state = placemark.subAdministrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        // 把 restaurant 的 annotation 重新加入
        mapView.addAnnotations([restaurantAnnotation, annotation])
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        resultSearchController?.searchBar.text = ""
    }
    
    func replaceLocationFor(place: String) {
        restaurant.location = place
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        createAnnotation()
        
        resultSearchController?.searchBar.text = ""
    }
}

