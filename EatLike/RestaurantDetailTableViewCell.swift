//
//  RestaurantDetailTableViewCell.swift
//  EatLike
//
//  Created by Queen Y on 16/3/12.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantDetailTableViewCell: UITableViewCell {

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		// Configure the view for the selected state
	}

	@IBOutlet weak var fieldLabel: UILabel!
	@IBOutlet weak var valueField: UILabel!
}
