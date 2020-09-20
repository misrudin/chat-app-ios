//
//  DatabaseManager.swift
//  Messages
//
//  Created by BMG MacbookPro on 19/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import Foundation
import FirebaseDatabase


final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

//MARK - Account Management

extension DatabaseManager{
    
    public func userExsist(with email: String,
                           completion: @escaping ((Bool)-> Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapsoot in
            guard  snapsoot.value as? String != nil else {
               completion(false)
                return
            }
            completion(true)
        })
        
    }
    
    ///insert new user  to database
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ])
    }
}




struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl: String
    
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}