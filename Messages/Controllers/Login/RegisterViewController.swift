//
//  RegisterViewController.swift
//  Messages
//
//  Created by BMG MacbookPro on 15/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

     private let scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.clipsToBounds = true
            return scrollView
        }()

        private let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "person.circle")
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .gray
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.lightGray.cgColor
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
            imageView.layer.cornerRadius = imageView.width/2.0
            
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
        presentPhotoActionSheet( )
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
            
            
//            firebase register with email
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] authResult,error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    print("Error create user !")
                    return
                }
                
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                    lastName: lastName,
                                                                    emailAddress: email))
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
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

extension RegisterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
        style: .default,
        handler: { [weak self] _ in
            
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Phote",
        style: .default,
        handler: { [weak self] _ in
            self?.presetPhotoPicker()
        }))
         
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }
    
    func presetPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectdedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectdedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
