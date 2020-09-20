//
//  LoginViewController.swift
//  Messages
//
//  Created by BMG MacbookPro on 16/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailTextFiled: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 5
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.keyboardType = .emailAddress
        return field
    }()
    
    private let passwordTextFiled: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 5
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton={
        let loginButton = UIButton()
        loginButton.setTitle("Log In", for: .normal)
        loginButton.backgroundColor = .link
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        loginButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold )
        return loginButton
    }()
    
    private let facebookLoginoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        
        return button
    }()
    
    private let gooleSignInButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification,
                                                   object: nil,
                                                   queue: .main,
                                                   using: { [weak self] _ in
                                                    
                                                    guard let strongSelf = self else {
                                                        return
                                                    }
                                                    strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                                                   })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Log In"
        view.backgroundColor = .white
        
        
        //    mambuat tombol register
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(ditTapRegister))
        
        
        //        click login
        loginButton.addTarget(self, action: #selector(onPressLogin), for: .touchUpInside)
        
        emailTextFiled.delegate = self
        passwordTextFiled.delegate = self
        
        facebookLoginoginButton.delegate = self
        
        //        add view
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailTextFiled)
        scrollView.addSubview(passwordTextFiled)
        scrollView.addSubview(loginButton)
        // facebook login button
        scrollView.addSubview(facebookLoginoginButton)
        // google login button
        scrollView.addSubview(gooleSignInButton)
    }
    
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    //setting layout
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20, width: size,
                                 height: size)
        emailTextFiled.frame = CGRect(x: 30,
                                      y: imageView.bottom+10, width: scrollView.width-60,
                                      height: 52)
        passwordTextFiled.frame = CGRect(x: 30,
                                         y: emailTextFiled.bottom+10, width: scrollView.width-60,
                                         height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordTextFiled.bottom+10, width: scrollView.width-60,
                                   height: 52)
        
        facebookLoginoginButton.frame = CGRect(x: 30,
                                               y: loginButton.bottom+10, width: scrollView.width-60,
                                               height: 52)
        
        gooleSignInButton.frame = CGRect(x: 30,
                                         y: facebookLoginoginButton.bottom+10, width: scrollView.width-60,
                                         height: 52)
    }
    
    
    @objc private func onPressLogin(){
        emailTextFiled.resignFirstResponder()
        passwordTextFiled.resignFirstResponder()
        
        guard let email = emailTextFiled.text, let password = passwordTextFiled.text,
              !email.isEmpty,!password.isEmpty,password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        //        firebase login
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else{
                print("Failed to logged in user with email \(email)")
                return
            }
            
            let user = result.user
            
            print("Logged in \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    
    //    alert inputan kosong
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops..", message: "Please enter all information to log in!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert,animated: true)
    }
    
    //    navigate ke register
    
    @objc private func ditTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}


extension LoginViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextFiled{
            passwordTextFiled.becomeFirstResponder()
        }
        else if textField == passwordTextFiled {
            onPressLogin()
        }
        
        return true
    }
}


extension LoginViewController:LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no opration
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User gagal untuk login menggunakan facebook!")
            return
        }
        
        let fbRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                   parameters: ["fields":"email,name"],
                                                   tokenString: token,
                                                   version: nil, httpMethod: .get)
        
        fbRequest.start(completionHandler: {_, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else{
                print("Failed to get user")
                return
            }
            
            var firstName:String
            var lastName:String
            let nameComponent = userName.components(separatedBy: " ")
            if nameComponent.count < 2 {
                firstName = userName
                lastName = userName
            }else{
                firstName = nameComponent[0]
                lastName = nameComponent[1]
            }
            
            print("\(nameComponent)")
            
            
            
            DatabaseManager.shared.userExsist(with: email, completion: {exist in
                if !exist {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                }
            })
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    print("Facebook credential login failed, MFA maybe needed.")
                    return
                }
                
                print("Successfuly logedin")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
        
    }
}
