//
//  RestaurantModel.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import Foundation

class RestaurantModel {
	var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl",
	                       "Petite Oyster", "For Kee Restaurant", "Po's Atelier",
	                       "Bourke Street Bakery", "Haigh's Chocolate",
	                       "Palomino Espresso", "Upstate", "Traif",
	                       "Graham Avenue Meats And Deli",
	                       "Waffle & Wolf", "Five Leaves", "Cafe Lore",
	                       "Confessional", "Barrafina", "Donostia", "Royal Oak",
	                       "CASK Pub and Kitchen"]

	var restaurantImages = ["cafedeadend.jpg", "homei.jpg", "teakha.jpg",
	                        "cafeloisl.jpg", "petiteoyster.jpg", "forkeerestaurant.jpg", "posatelier.jpg",
	                        "bourkestreetbakery.jpg", "haighschocolate.jpg", "palominoespresso.jpg",
	                        "upstate.jpg", "traif.jpg", "grahamavenuemeats.jpg", "wafflewolf.jpg",
	                        "fiveleaves.jpg", "cafelore.jpg", "confessional.jpg", "barrafina.jpg",
	                        "donostia.jpg", "royaloak.jpg", "thaicafe.jpg"]


	var restaurantIsVisit = [Bool](count:21, repeatedValue: false)

	func removeResuaurant(index: Int) {
		restaurantIsVisit.removeAtIndex(index)
		restaurantImages.removeAtIndex(index)
		restaurantNames.removeAtIndex(index)
	}

	func addResuaurant(resuaurant new: RestaurantModel, index: Int) {
		
	}
}