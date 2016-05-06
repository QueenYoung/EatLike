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
    // MARK: - Property
    var isUpdate = false

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categaryLabel: UILabel!
	@IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    let cache = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCache

	var newRestaurant: Restaurant!

    // MARK: View Controller
	override func viewDidLoad() {
		super.viewDidLoad()
        if newRestaurant != nil {
            configeRestaurantInformation()
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


    // MARK: Table View Delegate
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row == 0 {
            showImagePicker()
        }

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChooseCategary" {
            
        }
    }

    // MARK: - ImagePicker Delegate Methods
    func showImagePicker() {
        let canMakePicture = UIImagePickerController.isCameraDeviceAvailable(.Rear)
        let imagePicker = UIImagePickerController()
        // Never don't forget!!!!!!!!
        imagePicker.delegate = self
        if !canMakePicture {
            imagePicker.sourceType = .SavedPhotosAlbum
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
                //                    imagePicker.sourceType = .Camera
                //                    self.presentViewController(imagePicker, animated: true, completion: nil)
                self.performSegueWithIdentifier("ShowCamera", sender: self)
            }

            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            actionSheet.addAction(pictureAction)
            actionSheet.addAction(cameraAction)

            presentViewController(actionSheet, animated: true, completion: nil)
        }
    }

	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 如果是修改图片的话, 就删除之前的缓存.
        if newRestaurant != nil {
            cache.removeImage(newRestaurant.keyString)
        }
		imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
		imageView.contentMode = .ScaleAspectFill
		imageView.clipsToBounds = true

		dismissViewControllerAnimated(true, completion: nil)
	}

	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		dismissViewControllerAnimated(true, completion: nil)
	}

    // MARK: - IBAction
    @IBAction func unwindFromCamera(sender: UIStoryboardSegue) {
        if let capturePhoto = sender.sourceViewController as? CapturePhotoViewController {
            if let image = capturePhoto.image {
                imageView.image = image
                imageView.contentMode = .ScaleAspectFill
                imageView.clipsToBounds = true
            }
        }
    }

    @IBAction func updateCategary(sender: UIStoryboardSegue) {
        let categaryTVC = sender.sourceViewController as! ChooseCategaryTableViewController
        categaryLabel.text = categaryTVC.choosedCategary
        categaryLabel.textColor = .blackColor()
    }

	@IBAction func saveNewRestaurant(sender: UIButton) {
        let name = nameTextField.text!
        let type = categaryLabel.text!
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

		dismissViewControllerAnimated(true, completion: nil)
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
			categaryLabel.becomeFirstResponder()
		} else if noteTextField.isFirstResponder() {
            noteTextField.resignFirstResponder()
		}
		return true
	}

	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard textField === phoneTextField else { return true }
        // 过滤那些不是数字的所有输入, 即使是粘贴也不行.
		let decimalSet = NSMutableCharacterSet.decimalDigitCharacterSet()
		let typeSet = NSCharacterSet(charactersInString: string)
        decimalSet.addCharactersInString("-")

		var phone = phoneTextField.text!

		guard decimalSet.isSupersetOfSet(typeSet) else { return false }

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
        imageView.image        = cache.imageForKey(newRestaurant.keyString)
        nameTextField.text     = newRestaurant.name
        locationTextField.text = newRestaurant.location
        categaryLabel.text     = newRestaurant.type
        phoneTextField.text    = newRestaurant.phoneNumber
        noteTextField.text     = newRestaurant.note
        isUpdate               = true

        imageView.contentMode = .ScaleAspectFill
        categaryLabel.textColor = .blackColor()
    }


    private func updateRestaurantInformation() {

        let name     = nameTextField.text!
        let location = locationTextField.text!
        let type     = categaryLabel.text!
        // 返回的是 NSData 类型, 刚好可以初始化
        let image    = imageView.image.flatMap { UIImageJPEGRepresentation($0, 0.6) }
        let phone    = phoneTextField.text!
        let note     = noteTextField.text!

        newRestaurant.name        = name
        newRestaurant.location    = location
        newRestaurant.type        = type
        newRestaurant.image       = image
        newRestaurant.phoneNumber = phone
        newRestaurant.note        = note
        newRestaurant.keyString   = NSUUID().UUIDString

        cache.setImage(newRestaurant.image!, key: newRestaurant.keyString)
    }

}
