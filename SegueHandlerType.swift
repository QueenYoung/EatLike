//
//  SegueHandlerType.swift
//  EatLike
//
//  Created by Queen Y on 16/6/6.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

public protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType
	where Self: UIViewController, SegueIdentifier.RawValue == String {
    func performSegue(with identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: self)
    }

    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
                fatalError("Invalid segue identifier \(String(describing: segue.identifier))")
        }
        return segueIdentifier
    }
}
