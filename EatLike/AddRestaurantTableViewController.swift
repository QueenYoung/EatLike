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

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var typeTextField: UITextField!
	@IBOutlet weak var yesButton: UIButton!
	@IBOutlet weak var noButton: UIButton!
	@IBOutlet weak var phoneTextField: UITextField!
	
	var newRestaurant: Restaurant!
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "New Restaurant"
		if yesButton.backgroundColor == UIColor.redColor() {
			yesButton.enabled = false
		} else {
			noButton.enabled = false
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
			let imagePicker = UIImagePickerController()
			// Never don't forget!!!!!!!!
			imagePicker.delegate = self
			let actionSheet = UIAlertController(title: "Select Image",
			                                    message: "Which way you want to use",
			                                    preferredStyle: .ActionSheet)
			let pictureAction = UIAlertAction(title: "Saved Pictures", style: .Default) {
				[unowned self] _ in
				imagePicker.sourceType = .SavedPhotosAlbum
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
			if UIImagePickerController.isSourceTypeAvailable(.Camera) {
				actionSheet.addAction(cameraAction)
			}

			presentViewController(actionSheet, animated: true, completion: nil)
		}

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}


	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
		imageView.contentMode = .ScaleAspectFill
		imageView.clipsToBounds = true

		dismissViewControllerAnimated(true, completion: nil)
	}

	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		dismissViewControllerAnimated(true, completion: nil)
	}


	@IBAction func changeState(sender: UIButton) {
		swap(&yesButton.backgroundColor, &noButton.backgroundColor)
		swap(&yesButton.enabled, &noButton.enabled)
	}

	@IBAction func saveNewRestaurant(sender: UIBarButtonItem) {
		guard let managedObjectContext =
			(UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
			else { return }
		newRestaurant = NSEntityDescription.insertNewObjectForEntityForName("Restaurant", inManagedObjectContext: managedObjectContext) as? Restaurant

		let name = nameTextField.text!
		let location = locationTextField.text!
		let type = locationTextField.text!
		// 返回的是 NSData 类型, 刚好可以初始化
		let image = imageView.image.flatMap { UIImagePNGRepresentation($0) }
		let phone = phoneTextField.text!
		let visit = yesButton.backgroundColor == UIColor.redColor() ? true : false

		if name.isEmpty || location.isEmpty || type.isEmpty {
			navigationItem.rightBarButtonItem?.enabled = false
			return
		}
		
		newRestaurant.name = name
		newRestaurant.location = location
		newRestaurant.type = type
		newRestaurant.image = image
		newRestaurant.phoneNumber = phone
		newRestaurant.isVisited = visit

		do {
			try managedObjectContext.save()
		} catch {
			print(error)
			return
		}

		performSegueWithIdentifier("unwindToHome", sender: self)
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
		} else if phoneTextField.isFirstResponder() {
			phoneTextField.resignFirstResponder()
		}
		return true
	}

	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard textField === phoneTextField else { return true }
		let decimalSet = NSCharacterSet.decimalDigitCharacterSet()
		let typeSet = NSCharacterSet(charactersInString: string)
		var phone = phoneTextField.text!
		guard decimalSet.isSupersetOfSet(typeSet) && phone.characters.count < 13 else { return false }
		if phone.characters.count >= 7 {
			if phone[3] != "-" {
				phone.insert("-", atIndex: phone.startIndex.advancedBy(3))
				phone.insert("-", atIndex: phone.startIndex.advancedBy(8))
			}
		}

		phoneTextField.text = phone
		return true
	}


}
