//
//  ViewController.swift
//  machinesense
//
//  Created by Richard Adiguna on 22/12/17.
//  Copyright © 2017 Richard Adiguna. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController, UITextFieldDelegate {
    
    // ViewContainer
    @IBOutlet weak var startActionViewContainer: UIView!
    @IBOutlet weak var registerContainerView: UIView!
    @IBOutlet weak var loginContainerView: UIView!
    @IBOutlet weak var actionButtonViewContainer: UIView!
    @IBOutlet weak var forgotPassViewContainer: UIView!
    
    // Inside Register View Container
    @IBOutlet weak var registerFirstNameTextField: UITextField!
    @IBOutlet weak var registerLastNameTextField: UITextField!
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPassTextField: UITextField!
    @IBOutlet weak var registerRePassTextField: UITextField!
    @IBOutlet weak var registerActionButton: UIButton!
    
    // Inside Login View Container
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPassTextField: UITextField!
    @IBOutlet weak var loginActionButton: UIButton!
    @IBOutlet weak var loginForgotPassButton: UIButton!
    
    // Inside forgotPassViewContainer
    @IBOutlet weak var forgotPassEmailTextField: UITextField!
    
    
    // Constraint
    @IBOutlet weak var startActionViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initializeTextField()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerAction(_ sender: Any) {
        if registerFirstNameTextField.text != "" && registerLastNameTextField.text != "" && registerEmailTextField.text != "" && registerPassTextField.text != "" && registerRePassTextField.text != "" {
            if registerRePassTextField.text == registerRePassTextField.text {
                let email = registerEmailTextField.text!
                let password = registerPassTextField.text!
                if checkValidity(email: email, password: password) {
                    self.createNewUserFirebase(email: email, password: password)
                }
            } else {
                showPopUpMessage(title: "Register Failed", message: "Enter re-type password correctly")
            }
        } else {
            showPopUpMessage(title: "Register Failed", message: "All field cannot be empty")
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        guard let email = loginEmailTextField.text, let password = loginPassTextField.text else {
            return
        }
        loginWithEmail(email: email, password: password) {
            self.performSegue(withIdentifier: "goToHomeSegue", sender: self)
        }
    }
    
    func checkValidity(email: String, password: String) -> Bool {
        if !isValidEmail(emailStr: email) && !isValidPassword(passStr: password) {
            showPopUpMessage(title: "Register Failed", message: "Please enter your valid email, password at least contained one uppercase, one digit, and have minimum 8 characters")
            return false
        }
        if !isValidEmail(emailStr: email) {
            showPopUpMessage(title: "Register Failed", message: "Please type your valid email")
            return false
        }
        if !isValidPassword(passStr: password) {
            showPopUpMessage(title: "Register Failed", message: "Password at least contained one uppercase, one digit, and have minimum 8 characters")
            return false
        }
        return true
    }
    
    func createNewUserFirebase(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.showPopUpMessage(title: "Register Error", message: error?.localizedDescription)
            } else {
                print("Register successful")
            }
        }
    }
    
    func loginWithEmail(email: String, password: String, onSuccess: @escaping ()->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.showPopUpMessage(title: "Login Failed", message: "Your email address or password is incorrect")
            } else {
                onSuccess()
                print("Login Success")
            }
        }
    }
    
    @IBAction func forgotPassAction(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.forgotPassViewContainer.alpha = 1
            self.loginContainerView.alpha = 0
            self.registerContainerView.alpha = 0
            self.actionButtonViewContainer.alpha = 0
        }
    }
    
    @IBAction func switchToLoginView(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.loginContainerView.alpha = 1
            self.registerContainerView.alpha = 0
            self.actionButtonViewContainer.alpha = 0
            self.forgotPassViewContainer.alpha = 0
        }
    }
    
    @IBAction func switchToRegisterView(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.loginContainerView.alpha = 0
            self.registerContainerView.alpha = 1
            self.actionButtonViewContainer.alpha = 0
            self.forgotPassViewContainer.alpha = 0
        }
    }
    
    @IBAction func submitEmailForNewPass(_ sender: Any) {
        forgotPassword()
    }
    
    fileprivate func forgotPassword() {
        if forgotPassEmailTextField.text != "" {
            Auth.auth().sendPasswordReset(withEmail: forgotPassEmailTextField.text!, completion: { (error) in
                if error != nil {
                    self.showPopUpMessage(title: "Email is Not Valid", message: error?.localizedDescription)
                } else {
                    self.showPopUpMessage(title: "Reset Success", message: "Check your email inbox for your new password")
                }
            })
        }
    }
    
    @IBAction func bgButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.loginContainerView.alpha = 0
            self.registerContainerView.alpha = 0
            self.forgotPassViewContainer.alpha = 0
        }, completion: { finished in
            UIView.animate(withDuration: 0.2) {
                self.actionButtonViewContainer.alpha = 1
            }
        })
    }
    
    func showPopUpMessage(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func isValidEmail(emailStr: String?) -> Bool {
        guard let emailStr = emailStr else {
            return false
        }
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: emailStr)
    }
    
    func isValidPassword(passStr: String?) -> Bool {
        guard let passStr = passStr else {
            return false
        }
        
        let regEx = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}"
        
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", regEx)
        return passwordTest.evaluate(with: passStr)
    }
    
    fileprivate func initializeTextField() {
        let whiteColor = UIColor.white
        
        registerFirstNameTextField.setPlaceHolderColor(color: whiteColor)
        registerLastNameTextField.setPlaceHolderColor(color: whiteColor)
        registerEmailTextField.setPlaceHolderColor(color: whiteColor)
        registerPassTextField.setPlaceHolderColor(color: whiteColor)
        registerRePassTextField.setPlaceHolderColor(color: whiteColor)
        
        loginEmailTextField.setPlaceHolderColor(color: whiteColor)
        loginPassTextField.setPlaceHolderColor(color: whiteColor)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            startActionViewBottom.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: {self.view.layoutIfNeeded()}, completion: nil)
        }
    }
    
}

