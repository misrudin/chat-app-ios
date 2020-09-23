//
//  ChatViewController.swift
//  Messages
//
//  Created by BMG MacbookPro on 20/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
   public var sender: SenderType
   public var messageId: String
   public var sentDate: Date
   public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audion"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
   public var photoUrl: String
   public var senderId: String
   public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    
    public static let dateFormatter: DateFormatter = {
       let formater = DateFormatter()
        formater.dateStyle = .medium
        formater.timeStyle = .long
        formater.locale = .current
        
        return formater
    }()
    
    public let otherUserEmail:String
    private let conversationId:String?
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String  else {
            return nil
        }
        
//        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
       return Sender(photoUrl: "",
         senderId: email,
         displayName: "Me")
    }
    
    
    init(with email: String,id: String?){
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func listenForMessagess(id: String,shouldScrollToBottom: Bool){
        print("Start listen")
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: {[weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    
                }
            case .failure(let error):
                print("Failed to get messages \(error)")
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessagess(id: conversationId, shouldScrollToBottom: true)
        }
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = generateMessageId() else{
            return
        }
        print("Sending: \(text)")
        //sen message
        
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        if isNewConversation {
            //create new convo in database
            DatabaseManager.shared.createNewConversation(with: otherUserEmail,name: self.title ?? "User",firstMessage: message,compleiton: {[weak self] success in
                if success {
                    self?.isNewConversation = false
                    print("Sending Message")
                }else{
                    print("Failed to send Messages")
                }
            })
            
        }else{
            // append to existing conv
            guard let conversationId = conversationId,
                  let name = self.title else{
                return
            }
            
            DatabaseManager.shared.sendMessage(to: conversationId,otherUserEmail: otherUserEmail ,name:name ,newMessage: message, completion: {success in
                if success {
                    print("Message sent")
                }else{
                    print("Failed to send")
                }
            })
        }
    }
    
    private func generateMessageId()-> String? {
        //date, otherUserEmail, senderemail, random int
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeEmail)_\(dateString)"
        print("Create message id : \(newIdentifier)")
        return newIdentifier
    }
}
 
extension ChatViewController: MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
