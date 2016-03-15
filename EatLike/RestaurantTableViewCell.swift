//
//  RestaurantTableViewCell.swift
//  EatLike
//
//  Created by Queen Y on 16/3/11.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var LocationLabel: UILabel!
	@IBOutlet weak var TypeLabel: UILabel!
	@IBOutlet weak var thumbnailImageView: UIImageView!

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		// Configure the view for the selected state
	}

	func updateLabelPerferredFont() {
		let headFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
		let captionFont = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
		let subFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)

		nameLabel.font = headFont
		LocationLabel.font = subFont
		TypeLabel.font = captionFont
	}
}
