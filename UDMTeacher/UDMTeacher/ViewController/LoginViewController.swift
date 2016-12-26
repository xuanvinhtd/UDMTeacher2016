//
//  LoginViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit


final class LoginViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var textBoxEmail: UITextField!
    @IBOutlet weak var textBoxPassword: UITextField!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func configItems() {
        // Delegate textBox
        textBoxEmail.delegate = self
        textBoxPassword.delegate = self
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configItems()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Handling event
    @IBAction func login(sender: AnyObject) {
        
        if !UserManager.share.isInternet {
            UDMAlert.alert(title: "Network Error", message: "Please check again network.", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return
        }
        
        buttonSignUp.userInteractionEnabled = false
        activityIndicatorView.startAnimating()
        
        if checkError() {
            buttonSignUp.userInteractionEnabled = true
            activityIndicatorView.stopAnimating()
            return
        }
        
        UDMServer.share.login(withEmail: textBoxEmail.text!, password: textBoxPassword.text!) { (data, msg ,success) in
            if success {
                log.info("LogIn success!!!")
                UserManager.share.isLogInSuccess = true
                UserManager.share.info = User(withInfo: data)
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                NSNotificationCenter.defaultCenter().postNotificationName(CoursesViewController.Notification.ReloadPage, object: nil, userInfo: nil)
            } else {
                UDMAlert.alert(title: "Sigin Error", message: msg, dismissTitle: "OK", inViewController: self, withDismissAction: nil)
                log.error("ERROR message: \(msg)")
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicatorView.stopAnimating()
                self.buttonSignUp.userInteractionEnabled = true
            })
        }
    }
    
    @IBAction func resetPassword(sender: AnyObject) {
        UDMAlert.textInput(title: "Reset password", placeholder: "Input your email", oldText: "", dismissTitle: "Send", inViewController: self) { (text) in
            UDMHUD.showActivityIndicator()
            UDMServer.share.resetPassword(withEmail: text, completion: { (data, msg, success) in
                UDMHUD.hideActivityIndicator({
                    if success {
                        log.info("Send email message: \(msg)")
                    } else {
                        UDMAlert.alert(title: "Reset Password Error", message: data["message"] as! String, dismissTitle: "OK", inViewController: self, withDismissAction: nil)
                        log.error("ERROR message: \(msg)")
                    }
                })
            })
        }
    }
    
    // MARK: - Func other
    func checkError() -> Bool {
        
        if textBoxEmail.text == nil || textBoxPassword.text == nil || textBoxEmail.text! == "" || textBoxPassword.text! == "" {
            UDMAlert.alert(title: "Empty field", message: "Cannot empty fields. \nPlease input.", dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return true
        }
        //Error check
        var isError = false
        var strError = ""
        if !UDMHelpers.isValidEmail(textBoxEmail.text!) {
            strError = "Must be a valid email address."
            isError = true
        }
        if !UDMHelpers.checkMinLength(textBoxPassword, minLength: 3) {
            strError += "\nPassword must be >= 4 length."
            isError = true
        }
        if UDMHelpers.checkMaxLength(textBoxPassword, maxLength: 16) {
            strError += "\nPassword must be <= 15 length."
            isError = true
        }
        if isError {
            UDMAlert.alert(title: "Incorrect Password", message: strError, dismissTitle: "OK", inViewController: self, withDismissAction: nil)
            return true
        }
        return false
    }
}
// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
