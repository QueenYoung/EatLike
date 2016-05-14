//
//  PreviewCollectionViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/5/14.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PreviewCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    weak var delegate: PreviewSelectable?
    let pictures = [
        UIImage(named: "royaloak"),
        UIImage(named: "wafflewolf"),
        UIImage(named: "upstate"),
        UIImage(named: "traif"),
        UIImage(named: "thaicafe"),
        UIImage(named: "teakha"),
        UIImage(named: "confessional")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.registerClass(previewCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.collectionView?.backgroundColor = UIColor.clearColor()
        self.view.frame.size = CGSize(width: 290, height: 98)
        collectionView?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictures.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! previewCollectionCell
    
        // Configure the cell
        cell.photoImageView.image = pictures[indexPath.row]
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // 总是会出问题, 不知道为什么.
    /* func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! previewCollectionCell
        let (cellWidth, cellHeight): (CGFloat, CGFloat)
        guard let width = cell.photoImageView.image?.size.width,
              let height = cell.photoImageView.image?.size.height else {
                return CGSize(width: 100, height: 92)
        }
        cellHeight = 92
        cellWidth = cellHeight * (width / height)
        print("NImabi")
        return CGSize(width: cellWidth, height: cellHeight)
    } */

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! previewCollectionCell
        let image = cell.photoImageView.image!
        delegate?.imageBeSelected(selectedImage: image)
    }
}

protocol PreviewSelectable: class {
    func imageBeSelected(selectedImage image: UIImage)
}

final class previewCollectionCell: UICollectionViewCell {
    let photoImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        photoImageView.contentMode = .ScaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(photoImageView)

        photoImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        photoImageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor).active = true
        photoImageView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
        photoImageView.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}