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
    
    static func safeEmail(emailAddress: String)-> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

//MARK - get data detail first name and last name
extension DatabaseManager{
    public func getDataFor(path: String, completion: @escaping (Result<Any,Error>)->Void){
        self.database.child("\(path)").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
}



//MARK - Account Management

extension DatabaseManager{
    
    public func userExsist(with email: String,
                           completion: @escaping ((Bool)-> Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
//        print(safeEmail)
        database.child("\(safeEmail)").observeSingleEvent(of: .value, with: {snapsoot in
            guard  snapsoot.value as? [String: Any] != nil else {
               completion(false)
//                print("tidak ada, \(snapsoot.value)")
                return
            }
            completion(true)
//            print("sudah ada ada")
        })
        
    }
    
    ///insert new user  to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool)->Void){
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastName
        ],withCompletionBlock: {error, _ in
            guard error == nil else{
                print("Failed to add data to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //append to users dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection,withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }else{
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection,withCompletionBlock: { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    }
    
    
    //get all users
    public func getAllUsers(completion: @escaping (Result<[[String:String]],Error>)-> Void){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String:String]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
    }
}


//MARK : - sending messages / conversation

extension DatabaseManager{
    /// create a new conv with target email user and first message
    public func createNewConversation(with otherUserEmail: String,name: String, firstMessage: Message,compleiton: @escaping (Bool)-> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        print(safeEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapsot in
            guard var userNode = snapsot.value as? [String: Any] else {
                compleiton(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData:[String: Any] = [
                "id": conversationID,
                "other_user_email" : otherUserEmail,
                "name":name,
                "latest_message" : [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            
            let recipient_newConversationData:[String: Any] = [
                "id": conversationID,
                "other_user_email" : safeEmail,
                "name": currentName,
                "latest_message" : [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
//            update recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                if var conversation = snapsot.value as? [[String: Any]] {
                    //append
                    conversation.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([conversation])
                }else{
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            
            
//            update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // ada conv -> append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else{
                        compleiton(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: compleiton)
                })
            }else{
                // conv arr not exist -> create new
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else{
                        compleiton(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,conversationID: conversationID, firstMessage: firstMessage, completion: compleiton)
                })
            }
         })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message,
                                            completion: @escaping (Bool)-> Void){
        
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind{
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read":false,
            "name": name
            
        ]
        
        let value: [String: Any] = [
            "messages":[
                collectionMessage
            ]
        ]
        
        print("Send \(conversationID)")
        
        database.child("\(conversationID)").setValue(value,withCompletionBlock: {error,_ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///Fetch and return all conv for uset with pas an email
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation],Error>)-> Void){
        database.child("\(email)/conversations").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations:[Conversation] = value.compactMap({dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        })
    }
    
    /// get all messages for a given conv
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message],Error>)-> Void){
        database.child("\(id)/messages").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages:[Message] = value.compactMap({dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else{
                    return nil
                }
                
                let sender = Sender(photoUrl: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: .text(content))
            })
            completion(.success(messages))
        })
    }
    
    /// send a message wit target conv and message
    public func sendMessage(to conversation: String,otherUserEmail:String, name: String, newMessage: Message, completion: @escaping (Bool)-> Void){
        //add new message to messages
        //upate sender latest message
        //update recipient latest message
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: {[weak self] snapshot in
            guard let strongSelf = self else{
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else{
                completion(false)
                return
            }
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch newMessage.kind{
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
                completion(false)
                return
            }
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read":false,
                "name": name
                
            ]
            
            currentMessages.append(newMessageEntry)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages, withCompletionBlock: {error,_ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: {snapshot in
                    guard var currentUserConversation = snapshot.value as? [[String:Any]] else{
                        completion(false)
                        return
                    }
                    
                    let updateValue: [String: Any] = [
                        "date": dateString,
                        "is_read" : false,
                        "message" : message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversations in currentUserConversation {
                        if let currentId = conversations["id"] as? String, currentId == conversation  {
                           targetConversation = conversations
                            break
                        }
                        position += 1
                    }
                    
                    targetConversation?["latest_message"] = updateValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversation[position] = finalConversation
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversation, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        //update latest recpient
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: {snapshot in
                            guard var othertUserConversation = snapshot.value as? [[String:Any]] else{
                                completion(false)
                                return
                            }
                            
                            let updateValue: [String: Any] = [
                                "date": dateString,
                                "is_read" : false,
                                "message" : message
                            ]
                            
                            var targetConversation: [String: Any]?
                            
                            var position = 0
                            
                            for conversations in othertUserConversation {
                                if let currentId = conversations["id"] as? String, currentId == conversation  {
                                   targetConversation = conversations
                                    break
                                }
                                position += 1
                            }
                            
                            targetConversation?["latest_message"] = updateValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            othertUserConversation[position] = finalConversation
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(othertUserConversation, withCompletionBlock: {error, _ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                        
                        completion(true)
                    })
                })
            })
        })
    }
}




struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
   
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
}
