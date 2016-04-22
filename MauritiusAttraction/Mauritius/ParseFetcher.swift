//
//  ParseFetcher.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import Foundation
import Parse

let APP_PARENT_ID: String = "ts0KaVynvA"

class ParseFetcher {
    
    static let sharedInstance = ParseFetcher()
    
    //Fetching Categories
    func fetchCategories(values: [Int], completion: (result: [Category])-> Void){
        var categories = [Category]()
        let query = PFQuery(className: "Categories")
        query.whereKey("Level", containedIn: values)
        query.whereKey("ParentId", equalTo: APP_PARENT_ID)
        query.findObjectsInBackgroundWithBlock { (fetchedObjects, fetchError) -> Void in
            
            if fetchError == nil {
                if let objects = fetchedObjects {
                    for item in objects {
                        
                        categories.append(Category(categoryObject: item))
                    }
                }
            }
            completion(result: categories)
        }
    }
    
    func fetchBeaches(superParentId: String, completion: (result: [Beach]) -> Void) {
        var beaches = [Beach]()
        let query = PFQuery(className: "Beaches")
        query.whereKey("SuperParentId", equalTo: superParentId)
        query.findObjectsInBackgroundWithBlock { (responseObjects, responseError) -> Void in
            
            if responseError == nil {
                
                if let objects = responseObjects {
                    for item in objects {
                        beaches.append(Beach(parseObject: item))
                    }
                }
            }
            completion(result: beaches)
        }
        
    }
    
    //Check if user exists
    func checkUser(username: String, completion: (userExists: Bool)-> Void) {
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        query.findObjectsInBackgroundWithBlock { (parseObject, responseError) in
            
            if responseError == nil {
                print(parseObject?.first?.objectId, "######")
                if parseObject?.first?.objectId != nil {
                    completion(userExists: true)
                }else {
                    completion(userExists: false)
                }
            }else {
                //Handle error from parse
            }
        }
        
    }
    
    //Create a new user
    func createUser(userObject: PFUser, completion: (status: Bool)-> Void) {
        userObject.signUpInBackgroundWithBlock { (signUpsuccess, signupError) in
            if signUpsuccess{
                completion(status: true)
            }else {
                completion(status: false)
            }
        }
    }
    
    //Get favorites for username
    func getFavorites(username: String, completion: (favroites: [PFObject]?)-> Void) {
        let query = PFQuery(className: "Favourites")
        query.whereKey("UserId", equalTo: username)
        query.findObjectsInBackgroundWithBlock { (favs, fetchError) in
            if fetchError == nil {
                completion(favroites: favs)
            }else {
                completion(favroites: nil)
            }
        }
    }
    
    //Save favorites to server
    func saveFavorites(username: String, favs: [String], completion: (saveSuccess: Bool, error: String?) -> Void){
        let query = PFQuery(className: "Favourites")
        query.whereKey("UserId", equalTo: username)
        query.findObjectsInBackgroundWithBlock { (favObjects, fetchError) in
            if fetchError == nil {
                if let currentFav = favObjects?.first {
                    currentFav["ImageId"] = favs
                    currentFav.saveInBackgroundWithBlock({ (saveStatus, saveError) in
                        if saveStatus {
                            completion(saveSuccess: true, error: nil)
                        }else {
                            completion(saveSuccess: false, error: saveError?.localizedDescription)
                        }
                    })
                }
            }
        }
    }
    
    //Save favorites for first time
    func setFavorites(username: String, favs: [String], completion: (saveSuccess: Bool, error: String?)-> Void) {
        let favObject = PFObject(className: "Favourites")
        favObject["UserId"] = username
        favObject["ImageId"] = favs
        favObject.saveInBackgroundWithBlock { (saveStatus, saveError) in
            if saveStatus {
                completion(saveSuccess: true, error: nil)
            }else {
                completion(saveSuccess: false, error: saveError?.localizedDescription)
            }
        }
    }
}