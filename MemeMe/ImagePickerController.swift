//
//  ImagePickerController.swift
//  MemeMe
//
//  Created by Leoncio Perez on 2/5/16.
//  Copyright © 2016 Leoncio Perez. All rights reserved.
//

import UIKit

class ImagePickerController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var botText: UITextField!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    // Load, Appear, Dissapear
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextAttribute(botText, str : " BOTTOM ")
        setTextAttribute(topText, str: " TOP ")
    }
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        shareButton.enabled = imagePickerView.image != nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    // End
    
    // Keyboard Subscriptions
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    // End
    
    // Keyboard Will Show/Hide
    func keyboardWillShow(notification: NSNotification) {
        if botText.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    // End
    
    // Keyboard Height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    //Photo Gallery
    @IBAction func pickAnImage(sender: AnyObject) {
        simplify(false)
    }
    
    // Camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        simplify(true)
    }
    
    // Testing purposes
    func simplify(fromCamera: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if fromCamera {
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Text Attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 38)!,
        NSStrokeWidthAttributeName : NSNumber(float: -3.0)
    ]
    
    // Default Text Settings
    func setTextAttribute(textField : UITextField, str : String) {
        textField.delegate = self
        textField.text = str
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
    }
    
    // Text Edit
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == topText && topText.text == " TOP ") {
            topText.text = ""
        } else if (textField == botText && botText.text == " BOTTOM ") {
            botText.text = ""
        }
    }
    
    // Return To Escape
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Generate Meme
    func generateMemedImage() -> UIImage {
        navBar.hidden = true
        //Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        navBar.hidden = false
        return memedImage
    }
    
    // Save
    func save() {
        let memedImage = generateMemedImage()
        //Create the meme
        var meme = Meme(topText: topText.text!, botText: botText.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    // Share
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                //Save the image
                self.save()
                //Dismiss the view controller
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // Image Picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Did Cancel
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}

