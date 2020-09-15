//
//  RegisterViewController.swift
//  Messages
//
//  Created by BMG MacbookPro on 15/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

     private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.clipsToBounds = true
            return scrollView
        }()

        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "person")
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .gray
            return imageView
        }()
    
    private let firstNameFiled: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 5
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "First Name ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let lastNameFiled: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 5
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Last Name ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
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
        
        private let registerButton: UIButton={
            let registerButton = UIButton()
            registerButton.setTitle("Log In", for: .normal)
            registerButton.backgroundColor = .link
            registerButton.setTitleColor(.white, for: .normal)
            registerButton.layer.cornerRadius = 5
            registerButton.layer.masksToBounds = true
            registerButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold )
            return registerButton
        }()
        
        
        override func viewDidLoad() {
             super.viewDidLoad()
            title = "Log In"
            view.backgroundColor = .white
            
        
    //    mambuat tombol register
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(ditTapRegister))
            
            
    //        click login
            registerButton.addTarget(self, action: #selector(onPressLogin), for: .touchUpInside)
            
            emailTextFiled.delegate = self
            passwordTextFiled.delegate = self
            
    //        add view
            view.addSubview(scrollView)
            scrollView.addSubview(imageView)
            scrollView.addSubview(firstNameFiled)
            scrollView.addSubview(lastNameFiled)
            scrollView.addSubview(emailTextFiled)
            scrollView.addSubview(passwordTextFiled)
            scrollView.addSubview(registerButton)
            
            imageView.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapProfile))
            
            imageView.addGestureRecognizer(gesture)
        }
        
    //setting layout
        override func viewDidLayoutSubviews(){
            super.viewDidLayoutSubviews()
            scrollView.frame = view.bounds
            let size = scrollView.width/3
            imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                     y: 20, width: size,
                                     height: size)
            firstNameFiled.frame = CGRect(x: 30,
            y: imageView.bottom+10, width: scrollView.width-60,
              height: 52)
            lastNameFiled.frame = CGRect(x: 30,
            y: firstNameFiled.bottom+10, width: scrollView.width-60,
              height: 52)
            emailTextFiled.frame = CGRect(x: 30,
                                           y: lastNameFiled.bottom+10, width: scrollView.width-60,
                                             height: 52)
            passwordTextFiled.frame = CGRect(x: 30,
            y: emailTextFiled.bottom+10, width: scrollView.width-60,
              height: 52)
            
            registerButton.frame = CGRect(x: 30,
            y: passwordTextFiled.bottom+10, width: scrollView.width-60,
              height: 52)
        }
        
    @objc private func tapProfile(){
        print("di tekan")
    }
        
        @objc private func onPressLogin(){
            
            emailTextFiled.resignFirstResponder()
            passwordTextFiled.resignFirstResponder()
            firstNameFiled.resignFirstResponder()
            lastNameFiled.resignFirstResponder()
            
            guard let firstName = firstNameFiled.text,
                let lastName = lastNameFiled.text,
                let email = emailTextFiled.text,
                let password = passwordTextFiled.text,
                !email.isEmpty,
                !password.isEmpty,
                !firstName.isEmpty,
                !lastName.isEmpty,
                password.count >= 6 else {
                    alertUserLoginError()
                    return
            }
        }
        
        func alertUserLoginError(){
            let alert = UIAlertController(title: "Woops..", message: "Please enter all information to resgister!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert,animated: true)
        }

        @objc private func ditTapRegister(){
            let vc = RegisterViewController()
            vc.title = "Create Account"
            navigationController?.pushViewController(vc, animated: true)
            
        }

    }


    extension RegisterViewController:UITextFieldDelegate {
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