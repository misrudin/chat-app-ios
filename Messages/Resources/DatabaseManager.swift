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
    
    public func userExsist(with email: String, completion: @escaping ((Bool)-> Void)){
        
    }
    
    ///insert new user  to database
    public func insertUser(with user: ChatAppUser){
        database.child(user.emailAddress).setValue([
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
    
    
}
