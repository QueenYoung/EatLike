//
//  LaunchViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/6/6.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, HolderViewDelegate {
    var holderView = HolderView(frame: CGRect.zero)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func addHolderView() {
        let boxSize: CGFloat = 100.0
        holderView.frame = CGRect(x: view.bounds.width / 2 - boxSize / 2,
                                  y: view.bounds.height / 2 - boxSize / 2,
                                  width: boxSize,
                                  height: boxSize)
        holderView.parentFrame = view.frame
        holderView.delegate = self
        view.addSubview(holderView)
        holderView.addOval()
    }

    func animateLabel() {
        // 1
        holderView.removeFromSuperview()
        view.backgroundColor = UIColor.blue

        // 2
        let label: UILabel = UILabel(frame: view.frame)
        label.textColor = .white()
        label.font = UIFont(name: "HelveticaNeue-Thin", size: 100.0)
        label.textAlignment = NSTextAlignment.center
        label.text = "EatLike"
        label.transform = label.transform.scaleBy(x: 0.25, y: 0.25)
        view.addSubview(label)

        // 3
        UIView.animate(
            withDuration: 0.4,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.1,
            options: [],
            animations: ({
                label.transform = label.transform.scaleBy(x: 4.0, y: 4.0)
            })
        ) { _ in
            let main = self.storyboard!.instantiateViewController(withIdentifier: "Main")
            main.modalTransitionStyle = .crossDissolve
            self.present(main, animated: true, completion: nil)
        }
    }

}
