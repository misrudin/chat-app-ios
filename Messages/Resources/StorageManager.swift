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
    
    /// Upload image will be send to convo
    public func uploadMessagePhoto(with data: Data,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        storage.child("message_images/\(fileName)").putData(data,metadata: nil,completion: {[weak self] metadata, error in
            guard error == nil else {
                // failed
                print("Failed to upload photo to firebase.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: {url, error in
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
    
    /// Upload video message
    public func uploadMessageVideo(with fileUrl: URL,
                                     fileName: String,
                                     completion: @escaping UploadPictureCompletion){
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl,metadata: nil,completion: {[weak self] metadata, error in
            guard error == nil else {
                // failed
                print("Failed to upload video file to firebase.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: {url, error in
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
    
    public func downloadURL(for path: String, comletion: @escaping (Result<URL,Error>)-> Void){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else{
                comletion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            comletion(.success(url))
        })
    }
}
