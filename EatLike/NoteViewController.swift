//
//  NoteViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/5/19.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    @IBOutlet weak var noteView: UITextView! {
        didSet {
            noteView.text = text
        }
    }

    var text = "" {
        didSet {
            noteView?.text = oldValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredContentSize: CGSize {
        get {
            if noteView != nil && presentedViewController != nil  {
                return CGSize(width: 100, height: 100)
            } else {
                return super.preferredContentSize
            }
        }

        set {
            super.preferredContentSize = newValue
        }
    }

}
