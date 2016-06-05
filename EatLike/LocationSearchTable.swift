//
//  LocationSearchTable.swift
//  EatLike
//
//  Created by Queen Y on 16/5/17.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import MapKit
class LocationSearchTable: UITableViewController {
    var matchingItems = [MKMapItem]()
    var mapView: MKMapView?
    weak var delegate: HandleMapSearchDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(
        _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)

        // Configure the cell...
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(for: selectedItem)
        return cell
    }

    private func parseAddress(for selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
            selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        /* let comma = (selectedItem.subThoroughfare != nil
            || selectedItem.thoroughfare != nil) && (
               selectedItem.subAdministrativeArea != nil ||
               selectedItem.administrativeArea != nil) ? ", " : "" */
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@",
            // city
            selectedItem.locality ?? "",
            secondSpace,

            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,

            // street name
            selectedItem.thoroughfare ?? ""
//            comma
        )
        return addressLine
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: NSIndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        delegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let setLocationAction = UITableViewRowAction(
            style: .destructive, title: "Replace") {
                _ in
                let cell = self.tableView.cellForRow(at: indexPath)!
                print(cell.textLabel!.text!)
                self.delegate?.replaceLocationFor(
                    place: cell.detailTextLabel!.text! +  cell.textLabel!.text!)
                self.dismiss(animated: true, completion: nil)
        }

        setLocationAction.backgroundColor = .blue()
        return [setLocationAction]
    }
}

extension LocationSearchTable: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
              let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region

        let search = MKLocalSearch(request: request)
        search.start {
            response, _ in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

// MARK: - delefate for map view controller
protocol HandleMapSearchDelegate: class {
    func dropPinZoomIn(placemark: MKPlacemark)
    func replaceLocationFor(place: String)
}