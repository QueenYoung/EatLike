//
//  AddRestaurantTableViewController.swift
//  EatLike
//
//  Created by Queen Y on 16/3/15.
//  Copyright © 2016年 Queen. All rights reserved.
//

import UIKit
import CoreData
class AddRestaurantTableViewController: UITableViewController {
    // MARK: - Property
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categaryLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!

    var isUpdate = false

    lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 4.0
        layout.itemSize = CGSize(width: 100, height: 92)
        return layout
    }()

    var previews = [PreviewCollectionViewController]()

    let cache = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCache

    var newRestaurant: Restaurant!
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        if newRestaurant != nil {
            title = newRestaurant.name
            configeRestaurantInformation()
        } else {
            nameTextField.becomeFirstResponder()
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


    // MARK: - Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            showImagePicker()
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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

    // unwind 回来并更新 category
    @IBAction func updateCategary(sender: UIStoryboardSegue) {
        let categaryTVC = sender.sourceViewController as! ChooseCategaryTableViewController
        categaryLabel.text = categaryTVC.choosedCategary
        categaryLabel.textColor = .blackColor()
        if phoneTextField.text!.isEmpty {
            phoneTextField.becomeFirstResponder()
        }
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

        print(newRestaurant.keyString)

        // 把 keyString 的默认值设为了 none. 说明这个一个新的数据.
        if newRestaurant.keyString == "none" {
            newRestaurant.keyString = NSUUID().UUIDString
        }

        // TODO: 找到一个方法, 不用每次都加缓存.
        cache.setImage(image!, key: newRestaurant.keyString)

        newRestaurant.name        = name
        newRestaurant.location    = location
        newRestaurant.type        = type
        newRestaurant.phoneNumber = phone
        newRestaurant.note        = note
        newRestaurant.image       = image
    }
    
}


// MARK: - ImagePicker Delegate Methods
extension AddRestaurantTableViewController:
UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func showImagePicker() {
        let canMakePicture = UIImagePickerController.isCameraDeviceAvailable(.Rear)
        let imagePicker = UIImagePickerController()
        // Never don't forget!!!!!!!!
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        operationForRealDevices(imagePicker, isRealDevice: canMakePicture)
    }

    private func operationForRealDevices(imagePicker: UIImagePickerController, isRealDevice: Bool) {
        // 如果可以后置照相机的话, 再询问使用哪一种
        let actionSheet = UIAlertController(title: "\n\n\n\n",
                                            message: nil,
                                            preferredStyle: .ActionSheet)
        let pictureAction = UIAlertAction(title: "Saved Pictures", style: .Default) {
            [unowned self] _ in
            imagePicker.sourceType = .PhotoLibrary
            // imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }

        let previewController = PreviewCollectionViewController(collectionViewLayout: collectionLayout)
        previewController.delegate = self
        let width = self.view.frame.width
        let view = UIView(frame: CGRect(x: 4, y: 4, width: width - 30, height: 96))
        previews.append(previewController)
        view.addSubview(previewController.view)
        actionSheet.view.addSubview(view)

        if isRealDevice {
            let cameraAction = UIAlertAction(title: "From Camera", style: .Default) {
                [unowned self] _ in
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
//                self.performSegueWithIdentifier("ShowCamera", sender: self)
            }
            actionSheet.addAction(cameraAction)
        }

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        actionSheet.addAction(pictureAction)
        presentViewController(actionSheet, animated: true, completion: nil)
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
}

// MARK: - Text Field Delegates
extension AddRestaurantTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        navigationItem.rightBarButtonItem?.enabled = true

        if nameTextField.isFirstResponder() {
            locationTextField.becomeFirstResponder()
        } else if locationTextField.isFirstResponder() {
            performSegueWithIdentifier("ChooseCategary", sender: nil)
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

        let count = phoneTextField.text?.characters.filter { $0 != "-" }.count
        var phone = phoneTextField.text!

        guard decimalSet.isSupersetOfSet(typeSet) else { return false }

        if count == 4 && phone[3] != "-" {
            phone.insert("-", atIndex: phone.startIndex.advancedBy(3, limit: phone.endIndex))
        }

        if count == 7 && phone[7] != "-" {
            phone.insert("-", atIndex: phone.startIndex.advancedBy(8, limit: phone.endIndex))
            // 因为会清楚 - 的原因, 所以在重新生成 - 的时候, 同时生成第三位的
            if phone[3] != "-" {
                phone.insert("-", atIndex: phone.startIndex.advancedBy(3, limit: phone.endIndex))
            }
        }

        // 如果电话号码已经11位, 并且输入的是数字的话, 则返回 false
        // 因为非数字已经被排序, 现在能输入的之后 删除键. 通过 Int(stirng) 来判断输入的是数字还是删除
        if count >= 11 && Int(string) != nil {
            if phone[3] != "-" {
                phone.insert("-", atIndex: phone.startIndex.advancedBy(3, limit: phone.endIndex))
                phone.insert("-", atIndex: phone.startIndex.advancedBy(8, limit: phone.endIndex))
            } else {
                return false
            }
        // 在电话号码小于 10 位的时候, 清除 -
        } else if count <= 10 && Int(string) == nil {
            phone = phone.characters.split("-").map(String.init).joinWithSeparator("")
        }

        phoneTextField.text = phone
        return true
    }
}

extension AddRestaurantTableViewController: PreviewSelectable {
    func imageBeSelected(selectedImage image: UIImage) {
        imageView.image = image
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true

        if !nameTextField.text!.isEmpty {
            view.endEditing(true)
        }

        dismissViewControllerAnimated(true, completion: nil)
    }
}