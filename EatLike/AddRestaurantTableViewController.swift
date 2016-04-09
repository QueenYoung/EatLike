//
//  AddRestaurantTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/15.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import CoreData
class AddRestaurantTableViewController: UITableViewController,
                                        UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate,
                                        UITextFieldDelegate {
    var isUpdate = false

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var typeTextField: UITextField!
	@IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
	
	var newRestaurant: Restaurant!
	override func viewDidLoad() {
		super.viewDidLoad()
        if newRestaurant != nil {
            configeRestaurantInformation()
	        imageView.image = UIImage(data: newRestaurant.image!)
        } else {
            nameTextField.becomeFirstResponder()
            saveButton.hidden = true
            backButton.hidden = true
            title = "New Restaurant"
        }

	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(true)
		view.endEditing(true)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row == 0 {
            let canMakePicture = UIImagePickerController.isCameraDeviceAvailable(.Rear)
			let imagePicker = UIImagePickerController()
			// Never don't forget!!!!!!!!
			imagePicker.delegate = self
            if !canMakePicture {
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                // 如果可以后置照相机的话, 再询问使用哪一种
                let actionSheet = UIAlertController(title: "Select Image",
                                                    message: "Which way you want to use",
                                                    preferredStyle: .ActionSheet)
                let pictureAction = UIAlertAction(title: "Saved Pictures", style: .Default) {
                    [unowned self] _ in
                    imagePicker.sourceType = .PhotoLibrary
                    // imagePicker.allowsEditing = true
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }

                let cameraAction = UIAlertAction(title: "From Camera", style: .Default) {
                    [unowned self] _ in
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }

                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                actionSheet.addAction(pictureAction)
                actionSheet.addAction(cameraAction)
                
                presentViewController(actionSheet, animated: true, completion: nil)
            }
		}

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

    // MARK: - ImagePicker Delegate Methods
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
		imageView.contentMode = .ScaleAspectFill
		imageView.clipsToBounds = true

		dismissViewControllerAnimated(true, completion: nil)
	}

	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		dismissViewControllerAnimated(true, completion: nil)
	}

    // MARK: - IBAction

	@IBAction func saveNewRestaurant(sender: UIButton) {
        let name = nameTextField.text!
        let type = typeTextField.text!
        let location = locationTextField.text!

        // 如果 name type 或者 location 有一个没有填, 则提示用户
        if name.isEmpty || type.isEmpty || location.isEmpty {
            navigationItem.rightBarButtonItem?.enabled = false
            let alert = UIAlertController(
                title: "Wrong!",
                message: "Can't proceed because one of fields is blank.",
                preferredStyle: .Alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }

        guard let managedObjectContext =
                (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
                else { return }

        // 如果是添加新的数据, 则插入一个新的数据实例.
        if !isUpdate {
            newRestaurant = NSEntityDescription
                .insertNewObjectForEntityForName(
                    "Restaurant",
                    inManagedObjectContext: managedObjectContext) as? Restaurant
        }

        updateRestaurantInformation()

		do {
			try managedObjectContext.save()
		} catch {
			print(error)
			return
		}

        if isUpdate {
            performSegueWithIdentifier("unwindToDetailView", sender: self)
        } else {
            performSegueWithIdentifier("unwindToHomeView", sender: self)
        }
	}

    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

	// MARK: - Text Field Delegates
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		navigationItem.rightBarButtonItem?.enabled = true

		if nameTextField.isFirstResponder() {
			locationTextField.becomeFirstResponder()
        } else if locationTextField.isFirstResponder() {
			typeTextField.becomeFirstResponder()
		} else if typeTextField.isFirstResponder() {
			phoneTextField.becomeFirstResponder()
		} else if noteTextField.isFirstResponder() {
            noteTextField.resignFirstResponder()
		}
		return true
	}

	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard textField === phoneTextField else { return true }
		let decimalSet = NSCharacterSet.decimalDigitCharacterSet()
		let typeSet = NSCharacterSet(charactersInString: string)
		var phone = phoneTextField.text!
		guard decimalSet.isSupersetOfSet(typeSet) && phone.characters.count <= 13 else { return false }
		if phone.characters.count >= 7 {
			if phone[3] != "-" {
				phone.insert("-", atIndex: phone.startIndex.advancedBy(3))
				phone.insert("-", atIndex: phone.startIndex.advancedBy(8))
			}
		}

		phoneTextField.text = phone
		return true
	}

    private func configeRestaurantInformation() {
        imageView.image        = UIImage(data: newRestaurant.image!)
        nameTextField.text     = newRestaurant.name
        locationTextField.text = newRestaurant.location
        typeTextField.text     = newRestaurant.type
        phoneTextField.text    = newRestaurant.phoneNumber
        noteTextField.text     = newRestaurant.note
        isUpdate               = true

        imageView.contentMode = .ScaleAspectFill
    }


    private func updateRestaurantInformation() {

        let name     = nameTextField.text!
        let location = locationTextField.text!
        let type     = typeTextField.text!
        // 返回的是 NSData 类型, 刚好可以初始化
        let image    = imageView.image.flatMap { UIImagePNGRepresentation($0) }
        let phone    = phoneTextField.text!
        let note     = noteTextField.text!

        newRestaurant.name        = name
        newRestaurant.location    = location
        newRestaurant.type        = type
        newRestaurant.image       = image
        newRestaurant.phoneNumber = phone
        newRestaurant.note        = note
    }
}
