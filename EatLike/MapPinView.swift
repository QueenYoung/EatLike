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
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    var currentRestaurantPlacemark: CLPlacemark?
    var restaurant: Restaurant! {
        didSet {
            if !restaurant.note.isEmpty {
                restaurantNote.text = restaurant.note
            }
            updateRating()
            if restaurant.phoneNumber.isEmpty {
                callButton.enabled = false
            }
        }
    }

    override func awakeFromNib() {
        timeStackView.hidden = true
    }

    private func updateRating() {
        let count = restaurant.userRate.integerValue
        for i in reaingStackView.arrangedSubviews[count..<5] {
            let star = i as! UIImageView
            star.image = UIImage(named: "cafetransit_icon_star_off")
        }
    }

    private func udpateEstimatedTimeLabels(response: MKETAResponse?) {
        if let response = response {
            self.departureLabel.text = dateFormatter.stringFromDate(response.expectedDepartureDate)
            self.arrivalLabel.text = dateFormatter.stringFromDate(response.expectedArrivalDate)
        }
    }
}

extension MapPinView {
    // MARK: - IBActions
    @IBAction func phoneTapped(sender: UIButton) {
        call(restaurant.phoneNumber, isAlert: false)
    }

    @IBAction func transitTapped(sender: UIButton) {
        if let location = currentRestaurantPlacemark?.location?.coordinate {
            openTransitDirectionForCoodrinates(location)
        }
    }

    @IBAction func timeTapped(sender: UIButton) {
        if timeStackView.hidden {
            animatedView(timeStackView, hidden: false)
            animatedView(restaurantNote, hidden: true)
            timeButton.setImage(UIImage(named: "cafetransit_icon_time_on"), forState: .Normal)
            requestTransitTimes()
        } else {
            animatedView(timeStackView, restaurantNote, hidden: true)
            animatedView(restaurantNote, hidden: false)
            timeButton.setImage(UIImage(named: "cafetransit_icon_time_off"), forState: .Normal)
        }
    }

    @IBAction func navigationButtonTapped(sender: UIButton) {
        delegate?.getNavigationRoute()
    }

    // MARK: - Helper Methods
    private func animatedView(view: UIView..., hidden: Bool) {
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5.0, options: [], animations: {
            _ in
            view.forEach({$0.hidden = hidden})
            }, completion: nil)
    }

    private func requestTransitTimes() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        guard let currentRestaurantPlacemark = currentRestaurantPlacemark else { return }
        let destinationPlacemark = MKPlacemark(placemark: currentRestaurantPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)

        request.transportType = .Transit

        let directions = MKDirections(request: request)
        directions.calculateETAWithCompletionHandler {
            response, error in
            if let error = error {
                print(error.localizedFailureReason)
            } else {
                self.udpateEstimatedTimeLabels(response)
            }
        }
    }

    private func openTransitDirectionForCoodrinates(coor: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coor, addressDictionary: [CNPostalAddressStreetKey: restaurant.location])
        let mapItem = MKMapItem(placemark: placemark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
}

protocol Navigationable: class {
    func getNavigationRoute()
}