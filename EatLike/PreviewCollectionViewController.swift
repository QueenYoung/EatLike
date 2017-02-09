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
    lazy var pictures = [
        UIImage(named: "cafedeadend"),
        UIImage(named: "homei"),
        UIImage(named: "teakha"),
        UIImage(named: "traif"),
        UIImage(named: "cafelore"),
        UIImage(named: "confessional"),
        UIImage(named: "upstate"),
        UIImage(named: "donostia"),
        UIImage(named: "royaloak"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(previewCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
		self.collectionView?.backgroundColor = .clear
        self.view.frame.size = CGSize(width: delegate!.pictureWidth, height: 98)
        collectionView?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictures.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! previewCollectionCell
    
        // Configure the cell
        cell.photoImageView.image = pictures[indexPath.row]
        return cell
    }

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(
        _ collectionView: UICollectionView,
        shouldHighlightItemAt indexPath: IndexPath)-> Bool {
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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! previewCollectionCell
        let image = cell.photoImageView.image!
        delegate?.imageBeSelected(selectedImage: image)
    }
}

protocol PreviewSelectable: class {
    func imageBeSelected(selectedImage image: UIImage)
    var pictureWidth: CGFloat { get }
}

final class previewCollectionCell: UICollectionViewCell {
    let photoImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(photoImageView)

        photoImageView.topAnchor.constraint(
            equalTo: contentView.topAnchor).isActive = true
		photoImageView.bottomAnchor.constraint(
			equalTo:contentView.bottomAnchor).isActive = true
        photoImageView.leftAnchor.constraint(
            equalTo: contentView.leftAnchor).isActive = true
        photoImageView.rightAnchor.constraint(
            equalTo: contentView.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
