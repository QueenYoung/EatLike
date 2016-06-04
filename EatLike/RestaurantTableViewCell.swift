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
        let footNote = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)

        nameLabel.font = headFont
        LocationLabel.font = footNote
        TypeLabel.font = captionFont
    }

    func configure(data: Restaurant) {
        let cache = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCache
        nameLabel.text = data.name
        LocationLabel.text = data.location
        TypeLabel.text = data.type
        thumbnailImageView.image = cache.imageForKey(data.keyString)
        updateLabelPerferredFont()

    }

}
