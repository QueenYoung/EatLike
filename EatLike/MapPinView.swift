//
//  MapPinView.swift
//  EatLike
//
//  Created by Queen Y on 16/5/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class MapPinView: UIView {
    weak var delegate: Navigationable?
    @IBOutlet weak var reaingStackView: UIStackView!
    @IBOutlet weak var restaurantNote: UILabel!
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    @IBOutlet weak var timeStackView: UIStackView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!

    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .shortStyle
        return formatter
    }()

    var currentRestaurantPlacemark: CLPlacemark?
    var response: MKETAResponse?
    var restaurant: Restaurant! {
        didSet {
            restaurantNote.preferredMaxLayoutWidth = 160.0
            if !restaurant.note.isEmpty {
                restaurantNote.text = restaurant.note
            }
            updateRating()
            if restaurant.phoneNumber.isEmpty {
                callButton.isEnabled = false
            }
        }
    }

    override func awakeFromNib() {
        timeStackView.isHidden = true
    }

    private func updateRating() {
        let count = restaurant.userRate.intValue
        for i in reaingStackView.arrangedSubviews[count..<5] {
            let star = i as! UIImageView
            star.image = UIImage(named: "cafetransit_icon_star_off")
        }

        callButton.addTarget(self, action: #selector(phoneTapped), for: .touchUpInside)
    }

    private func udpateEstimatedTimeLabels(for response: MKETAResponse?) {
        if let response = response {
            let departure = dateFormatter.string(from: response.expectedDepartureDate)
            let arrival = dateFormatter.string(from: response.expectedArrivalDate)
            if departure == response {
                self.departureLabel.text = "😭"
                self.arrivalLabel.text = "😭"
            } else {
                self.departureLabel.text = departure
                self.arrivalLabel.text = arrival
            }
        }
    }
}

extension MapPinView {
    // MARK: - IBActions
    @IBAction func phoneTapped() {
        _ = call(telphone: restaurant.phoneNumber, isAlert: false)
    }
    
    @IBAction func transitTapped() {
        if let location = currentRestaurantPlacemark?.location?.coordinate {
            openTransitDirection(for: location)
        }
    }
    
    @IBAction func timeTapped() {
        if timeStackView.isHidden {
            animated(view: timeStackView, hidden: false)
            animated(view: restaurantNote, hidden: true)
            timeButton.setImage(UIImage(named: "cafetransit_icon_time_on"), for: [])
            requestTransitTimes()
        } else {
            animated(view: timeStackView, restaurantNote, hidden: true)
            animated(view: restaurantNote, hidden: false)
            timeButton.setImage(UIImage(named: "cafetransit_icon_time_off"), for: [])
        }
    }
    
     @IBAction func navigationButtonTapped() {
        delegate?.getNavigationRoute()
    }
    
    // MARK: - Helper Methods
    private func animated(view: UIView..., hidden: Bool) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0.0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 5.0,
            options: [], animations: { _ in
            view.forEach({$0.isHidden = hidden})
            }, completion: nil)
    }
    
    private func requestTransitTimes() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        guard let currentRestaurantPlacemark = currentRestaurantPlacemark else { return }
        let destinationPlacemark = MKPlacemark(placemark: currentRestaurantPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        
        request.transportType = .transit
        
        let directions = MKDirections(request: request)
        directions.calculateETA {
            response, error in
            if let error = error {
                print(error.localizedFailureReason)
            } else {
                self.udpateEstimatedTimeLabels(for: response)
            }
        }
    }
    
    private func openTransitDirection(for coodrinates: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(
            coordinate: coodrinates,
            addressDictionary: [CNPostalAddressStreetKey: restaurant.location]
        )
        let mapItem = MKMapItem(placemark: placemark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
}

protocol Navigationable: class {
    func getNavigationRoute()
}