//
//  Restaurant.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import Foundation

class Restaurant {
	/* let restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl",
	"Petite Oyster", "For Kee Restaurant", "Po's Atelier",
	"Bourke Street Bakery", "Haigh's Chocolate",
	"Palomino Espresso", "Upstate", "Traif",
	"Graham Avenue Meats And Deli",
	"Waffle & Wolf", "Five Leaves", "Cafe Lore",
	"Confessional", "Barrafina", "Donostia", "Royal Oak",
	"CASK Pub and Kitchen"]

	let restaurantImages = ["cafedeadend.jpg", "homei.jpg", "teakha.jpg",
	"cafeloisl.jpg", "petiteoyster.jpg", "forkeerestaurant.jpg", "posatelier.jpg",
	"bourkestreetbakery.jpg", "haighschocolate.jpg", "palominoespresso.jpg",
	"upstate.jpg", "traif.jpg", "grahamavenuemeats.jpg", "wafflewolf.jpg",
	"fiveleaves.jpg", "cafelore.jpg", "confessional.jpg", "barrafina.jpg",
	"donostia.jpg", "royaloak.jpg", "thaicafe.jpg"]
	let restaurantLocations = ["Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong",
	"Hong Kong", "Hong Kong", "Hong Kong", "Sydney",
	"Sydney", "Sydney", "New York", "New York", "New York",
	"New York", "New York", "New York", "New York",
	"London", "London", "London", "London"]

	let restaurantTypes = ["Coffee & Tea Shop", "Cafe", "Tea House", "Austrian Causual Drink",
	"French", "Bakery", "Bakery", "Chocolate", "Cafe",
	"American Seafood", "American", "American",
	"Breakfast & Brunch", "Coffee & Tea", "Coffee & Tea",
	"Latin American", "Spanish", "Spanish", "Spanish",
	"British", "Thai"] */

	var restaurantIsVisit = [Bool](count:21, repeatedValue: false)

	var name: String
	var location: String
	var image: String
	var type: String
	var isVisit: Bool
	var phoneNumber: String
	var rate: Rating = .None

	init(name: String, type: String, location: String,
	     phoneNumber: String, image: String, isVisited: Bool) {
		self.name = name
		self.image = image
		self.type = type
		self.isVisit = isVisited
		self.location = location
		self.phoneNumber = phoneNumber
	}

}

public enum Rating: String {
	case Dislike = "dislike"
	case Good = "good"
	case Great = "great"
	case None
}