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
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4.0
        layout.itemSize = CGSize(width: 100, height: 92)
        return layout
    }()
    
    var previews = [PreviewCollectionViewController]()
    
    
    var newRestaurant: Restaurant!
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        if newRestaurant != nil {
            title = newRestaurant.name
            configeRestaurantInformation()
        } else {
            nameTextField.becomeFirstResponder()
            title = NSLocalizedString("New Restaurant", comment: "newrestaurant")
        }
        
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table View Delegate
    override func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            showImagePicker()
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    // unwind 回来并更新 category
    @IBAction func updateCategary(sender: UIStoryboardSegue) {
        let categaryTVC = sender.source as! ChooseCategaryTableViewController
        categaryLabel.text = categaryTVC.choosedCategary
        categaryLabel.textColor = .black
        if phoneTextField.text!.isEmpty {
            phoneTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func saveNewRestaurant(sender: UIBarButtonItem) {
        let name = nameTextField.text!
        let type = categaryLabel.text!
        let location = locationTextField.text!
        let hudText: String
        
        // 如果 name type 或者 location 有一个没有填, 则提示用户
        if name.isEmpty || type.isEmpty || location.isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
            let alert = UIAlertController(
                title: "Wrong!",
                message: "Can't proceed because one of fields is blank.",
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let managedObjectContext =
            (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
            else { return }
        
        // 如果是添加新的数据, 则插入一个新的数据实例.
        // 并且设置一个 UUID, 插入 Spotlight index
        if !isUpdate {
            newRestaurant = NSEntityDescription
                .insertNewObject(
                    forEntityName: "Restaurant",
                    into: managedObjectContext) as! Restaurant
            newRestaurant.keyString = NSUUID().uuidString
            hudText = "Done"
        } else {
            hudText = "Updated"
        }
        
        let queue = DispatchQueue.global()
        queue.async() {
            self.updateRestaurantInformation()
            do {
                try managedObjectContext.save()
                self.newRestaurant.updateSpotlightIndex()
            } catch {
                print(error)
                return
            }


            DispatchQueue.main.async() {
                let hud = HudView.hud(
                    in: self.navigationController!.view, animated: true)
                hud.text = hudText
                delay(with: 0.6) {
                    self.dismiss(animated: true, completion: nil)
                    if self.isUpdate {
                        self.performSegue(withIdentifier: "unwindToDetailView", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "unwindToHomeView", sender: self)
                    }
                }
            }
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configeRestaurantInformation() {
        imageView.image        = newRestaurant.image,
        nameTextField.text     = newRestaurant.name
        locationTextField.text = newRestaurant.location
        categaryLabel.text     = newRestaurant.type
        phoneTextField.text    = newRestaurant.phoneNumber
        noteTextField.text     = newRestaurant.note
        isUpdate               = true
        
        imageView.contentMode = .scaleAspectFill
        categaryLabel.textColor = .black
    }
    
    
    private func updateRestaurantInformation() {
        
        let name     = nameTextField.text!
        let location = locationTextField.text!
        let type     = categaryLabel.text!
        // 返回的是 NSData 类型, 刚好可以初始化
        let image    = imageView.image.flatMap { UIImageJPEGRepresentation($0, 0.8) }
        let phone    = phoneTextField.text!
        let note     = noteTextField.text!
        

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
    
    fileprivate func showImagePicker() {
        let canMakePicture = UIImagePickerController.isCameraDeviceAvailable(.rear)
        let imagePicker = UIImagePickerController()
        // Never don't forget!!!!!!!!
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        operationInRealDevices(with: imagePicker, isRealDevice: canMakePicture)
    }
    
    private func operationInRealDevices(with imagePicker: UIImagePickerController, isRealDevice: Bool) {
        // 如果可以后置照相机的话, 再询问使用哪一种
        let actionSheet = UIAlertController(title: "\n\n\n\n",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let pictureAction = UIAlertAction(title: "Saved Pictures", style: .default) {
            [unowned self] _ in
            imagePicker.sourceType = .photoLibrary
            // imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }


		let queue = DispatchQueue(
			label: "com.queen.jxau.eatlike",
			attributes: .concurrent,
			target: nil)

        queue.async { [unowned self] in
            let previewController = PreviewCollectionViewController(
				collectionViewLayout: self.collectionLayout)
            previewController.delegate = self
            self.previews.append(previewController)
            DispatchQueue.main.async {
                let width = self.view.frame.width
                let view = UIView(frame: CGRect(x: 4, y: 4, width: width - 30, height: 96))
                view.addSubview(previewController.view)
                actionSheet.view.addSubview(view)
            }
        }
        
        if isRealDevice {
            let cameraAction = UIAlertAction(title: "From Camera", style: .default) {
                [unowned self] _ in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
                //                self.performSegueWithIdentifier("ShowCamera", sender: self)
            }
            actionSheet.addAction(cameraAction)
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(pictureAction)
        present(actionSheet, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Text Field Delegates
extension AddRestaurantTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        if nameTextField.isFirstResponder {
            locationTextField.becomeFirstResponder()
        } else if locationTextField.isFirstResponder {
            locationTextField.resignFirstResponder()
        } else if noteTextField.isFirstResponder {
            noteTextField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField === phoneTextField else { return true }
        // 过滤那些不是数字的所有输入, 即使是粘贴也不行.
        var decimalSet = CharacterSet.decimalDigits
        let typeSet = CharacterSet(charactersIn: string)
        decimalSet.insert(charactersIn: "-")
		print("2")
        var phone = String(phoneTextField.text!.characters.filter({ $0 != "-" }))
        let count = phone.characters.count
//        var phone = phoneTextField.text!
        let firstSeparator = phone.index(phone.startIndex, offsetBy: 3, limitedBy: phone.endIndex)
        let secondSeparator = phone.index(phone.startIndex, offsetBy: 8, limitedBy: phone.endIndex)
		print("3")
		guard decimalSet.isSuperset(of: typeSet) else { return false }
		print("4")
        if count == 11 && Int(string) != nil { return false }
        switch count {
        case 3...7 where Int(string) != nil:
            phone.insert("-", at: firstSeparator!)
        case 8...11 where Int(string) != nil:
            phone.insert("-", at: firstSeparator!)
            phone.insert("-", at: secondSeparator!)
        default:
            break
        }
        phoneTextField.text = phone
        return true
    }
}

extension AddRestaurantTableViewController: PreviewSelectable {
    func imageBeSelected(selectedImage image: UIImage) {
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        if !nameTextField.text!.isEmpty {
            view.endEditing(true)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    var pictureWidth: CGFloat {
        return self.view.frame.width - 30
    }
}
