//
//  StorageManager.swift
//  Messages
//
//  Created by BMG MacbookPro on 20/09/20.
//  Copyright © 2020 BMG MacbookPro. All rights reserved.
//

import Foundation
import FirebaseStorage


final class StorageManager{
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/udin-gmail-com_profile_picture.png
     */
    
    
    public typealias UploadPictureCompletion = (Result<String,Error>)-> Void
    
    /// upload picture to firebase storage and return completion  with url string to download
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data,metadata: nil,completion: { metadata, error in
            guard error == nil else {
                // failed
                print("Failed to upload profile picture to firebase.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else {
                    print("Failed to download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                
                print("Download url returned : \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
