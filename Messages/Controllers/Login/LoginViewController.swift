//
//  LoginViewController.swift
//  Messages
//
//  Created by BMG MacbookPro on 16/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import UIKit
import FirebaseAuth

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
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
        title = "Log In"
        view.backgroundColor = .white
        
    
//    mambuat tombol register
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(ditTapRegister))
        
        
//        click login
        loginButton.addTarget(self, action: #selector(onPressLogin), for: .touchUpInside)
        
        emailTextFiled.delegate = self
        passwordTextFiled.delegate = self
        
//        add view
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailTextFiled)
        scrollView.addSubview(passwordTextFiled)
        scrollView.addSubview(loginButton)
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
