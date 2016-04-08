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
	var restaurant: Restaurant!
	override func viewDidLoad() {
		super.viewDidLoad()
		createAnnotation()
		// Do any additional setup after loading the view.


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

	private func createAnnotation() {
		let geoCoder = CLGeocoder()
		geoCoder.geocodeAddressString(restaurant.location) {
			placemarks, error in
			if error != nil {
				print(error)
				self.mapView.showsUserLocation = true
				return
			}

			guard let location = placemarks?.first?.location else { return }

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

		let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 53))
		leftIconView.image = UIImage(data: restaurant.image!)
		annotationView?.leftCalloutAccessoryView = leftIconView

		annotationView?.tintColor = UIColor.orangeColor()

		return annotationView
	}

}
