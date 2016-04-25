//
//  PhotosViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 26/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit
//import SKPhotoBrowser
import Parse
import MessageUI

class PhotosViewController: UIViewController, MFMailComposeViewControllerDelegate /*SKPhotoBrowserDelegate*/ {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    @IBOutlet var enquireNow: UIButton!
    @IBOutlet var indexLabel: UILabel!
    
    
    var currentObjects: [Beach]?
    //var imageArray = [SKPhoto]()
    var index: Int = 0
    var lattitude: String?
    var longitude: String?
    var weblink: String?
    
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    let imageBrowser = AFImageViewer(frame: CGRectMake(0, 0, 200, 300))
    var imageURLs = [NSURL]()
    var currentFavs: [String]?
    
    override func viewDidLoad() {

        super.viewDidLoad()
        //Setting up view
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "MauritiusBG.png")!)
        self.containerView.alpha = 0.8
        self.containerView.layer.cornerRadius = 4
        self.imageView.layer.cornerRadius = 4
        self.imageView.clipsToBounds = true
        self.imageView.userInteractionEnabled = true
        //self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PhotosViewController.photoViewer)))
        self.leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PhotosViewController.loadNextImage))
        self.leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        self.rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PhotosViewController.loadPreviousImage))
        self.rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        self.imageView.addGestureRecognizer(leftSwipe)
        self.imageView.addGestureRecognizer(rightSwipe)
        self.enquireNow.layer.cornerRadius = 4
        
        //Activity indicator
        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        if let imageFile = currentObjects?.first?.imageFile {
            if Reachability.isConnectedToNetwork() {
                //Setting initial image on view load
                self.loadImageView(imageFile)
            }else {
                Reachability.networkErrorView(self.view)
            }
        }
        
        //Title for the view
        if let object = currentObjects?.first {
            if let newTitle = object.description {
                let index = newTitle.rangeOfString("-")?.startIndex
                if let value = index {
                    self.title = newTitle.substringFromIndex(value.successor())
                }else {
                    self.title = newTitle
                }
            }
        }
        
        //Adding actions to buttons
        self.nextButton.addTarget(self, action: #selector(PhotosViewController.loadNextImage), forControlEvents: .TouchUpInside)
        self.previousButton.addTarget(self, action: #selector(PhotosViewController.loadPreviousImage), forControlEvents: .TouchUpInside)
        self.favouriteButton.addTarget(self, action: #selector(PhotosViewController.favouriteAction), forControlEvents: .TouchUpInside)
        self.directionsButton.addTarget(self, action: #selector(PhotosViewController.showDirections), forControlEvents: .TouchUpInside)
        self.shareButton.addTarget(self, action: #selector(PhotosViewController.shareImage), forControlEvents: .TouchUpInside)
        
        if let count = currentObjects?.count {
            self.indexLabel.text = "\(index+1)/\(count)"
        }
        
        //Enquire now button
        enquireNow.addTarget(self, action: #selector(self.sendEnquireMail(_:)), forControlEvents: .TouchUpInside)
        
        //Get lat & long for directions
        self.getGeopoints()
        
        //Get user favs
        self.fetchAllUserFavs()
        
        //Image Browser
//        imageBrowser.frame = imageView.bounds
//        imageBrowser.delegate = self
//        imageView.addSubview(imageBrowser)
        
//        if let _ = currentObjects {
//            for item in currentObjects! {
//                imageURLs.append(NSURL(string: (item.imageFile?.url)!)!)
//            }
//        }
//        imageBrowser.contentMode = .ScaleToFill
//        imageBrowser.imagesUrls = imageURLs
    }
    
    //Fetching geopoints and weblink for current category
    func getGeopoints() {
        if let category = currentObjects?.first {
            if let object: String = category.linkId {
                let query = PFQuery(className: "Categories")
                query.getObjectInBackgroundWithId(object, block: { (response, error) -> Void in
                    
                    if error == nil {
                        let cat:Category = Category(categoryObject: response!)
                        if let link = cat.webLink {
                            self.weblink = link
                            self.directionsButton.setImage(UIImage(named: "open.png"), forState: .Normal)
                        }
                        self.lattitude = cat.lattitude
                        self.longitude = cat.longitude
                    } else if error?.code == 100 {
                        Reachability.networkErrorView(self.view)
                    }
                })
            }
        }
    }
    
    //Loading image
    func loadImageView(imageFile: PFFile) {
        
        imageFile.getDataInBackgroundWithBlock { (imageData, responseError) -> Void in
            
            if responseError == nil {
                if let result = imageData {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.imageView.image = UIImage(data: result)
                        self.activityIndicator.stopAnimating()
                        self.imageView.alpha = 1.0
                    })
                }
            } else if responseError?.code == 100 {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //Call to Error connection view
                })
            }
        }
    }
    
    func loadNextImage() {
        imageBrowser.setCurrentPage(true)
        self.index += 1
        guard let count = currentObjects?.count else {
            return
        }
        if index < count {
            self.markFavorites()
            self.activityIndicator.startAnimating()
            self.imageView.alpha = 0.6
            self.previousButton.userInteractionEnabled = true
            self.previousButton.alpha = 1.0
            self.imageView.addGestureRecognizer(rightSwipe)
            self.indexLabel.text = "\(index+1)/\(count)"
            if let imageFile = currentObjects?[index].imageFile {
                self.loadImageView(imageFile)
            } else {
                //Implement error image **TBU**
            }
        }
        
        if index == count - 1 {
            self.imageView.removeGestureRecognizer(leftSwipe)
            self.nextButton.userInteractionEnabled = false
            self.nextButton.alpha = 0.8
        }
        
    }
    
    func loadPreviousImage() {
        imageBrowser.setCurrentPage(false)
        index -= 1
        if index >= 0 {
            self.markFavorites()
            self.activityIndicator.startAnimating()
            self.imageView.alpha = 0.6
            self.nextButton.userInteractionEnabled = true
            self.nextButton.alpha = 1.0
            self.imageView.addGestureRecognizer(leftSwipe)
            if let count = currentObjects?.count {
                self.indexLabel.text = "\(index+1)/\(count)"
            }
            if let imageFile = currentObjects?[index].imageFile{
                self.loadImageView(imageFile)
            } else {
                //Implement error image **TBU**
            }
        }
        
        if index == 0 {
            self.previousButton.userInteractionEnabled = false
            self.previousButton.alpha = 0.8
            self.imageView.removeGestureRecognizer(rightSwipe)
        }
    }
    
    func markFavorites() {
        if currentFavs != nil {
            if currentFavs!.contains(currentObjects![index].objectId!) {
                self.favouriteButton.setImage(UIImage(named: "like-filled.png"), forState: .Normal)
            }else {
                self.favouriteButton.setImage(UIImage(named: "like.png"), forState: .Normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Setting up photo browser
//    func photoViewer() {
//        //Calling Activitty Indicator
//        var config : SwiftLoader.Config = SwiftLoader.Config()
//        config.size = 150
//        config.spinnerColor =  UIColor.whiteColor()
//        config.foregroundColor = .blackColor()
//        config.foregroundAlpha = 0.5
//        config.speed = 2
//        SwiftLoader.show("Loading...", animated: true)
//        
//        if imageArray.isEmpty {
//            if let objects = currentObjects {
//                for item in objects {
//                    if let image = item.imageFile {
//                        image.getDataInBackgroundWithBlock({ (imageData, responseError) -> Void in
//                            
//                            if responseError == nil {
//                                
//                                if let result = imageData {
//                                    let photo = SKPhoto.photoWithImage(UIImage(data: result)!)
//                                    self.imageArray.append(photo)
//                                    
//                                    if (item.objectId == objects.last?.objectId) {
//                                        let photoBrowser = SKPhotoBrowser(photos: self.imageArray)
//                                        photoBrowser.delegate = self
//                                        photoBrowser.initializePageIndex(self.index)
//                                        
//                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                                            SwiftLoader.hide()
//                                            self.presentViewController(photoBrowser, animated: true, completion: nil)
//                                        })
//                                        
//                                    }
//                                }
//                            } else {
//                                SwiftLoader.hide()
//                                if let error = responseError{
//                                    if error.code == 100 {
//                                        let alertView = UNAlertView(title: "Oops!", message: "Please check you internet connection and try again")
//                                        alertView.addButton("Ok", backgroundColor: UIColor(red: 243/255, green: 57/255, blue: 57/255, alpha: 1.0), action: {})
//                                        alertView.show()
//                                    } else {
//                                        let alertView = UNAlertView(title: "Oops!", message: "Some thing went wrong!. Please try again")
//                                        alertView.addButton("Ok", backgroundColor: UIColor(red: 243/255, green: 57/255, blue: 57/255, alpha: 1.0), action: {})
//                                        alertView.show()
//                                    }
//                                }
//                                
//                            }
//                            
//                        })
//                    }
//                }
//            }
//            
//        } else {
//            presentPhotoBrowser()
//        }
//    }
    
//    func presentPhotoBrowser() {
//        SwiftLoader.hide()
//        let photoBrowser = SKPhotoBrowser(photos: self.imageArray)
//        photoBrowser.delegate = self
//        photoBrowser.initializePageIndex(self.index)
//        
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.presentViewController(photoBrowser, animated: true, completion: nil)
//        })
//    }
    
    
    //Adding favourites
    func favouriteAction() {
        favouriteButton.setImage(UIImage(named: "like-filled.png"), forState: .Normal)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let email = userDefaults.objectForKey("username") as? String else {
            let alertView = UNAlertView(title: "Alert", message: "Please add your email to add favourites")
            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.addButton("Add Email", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: { () -> Void in
                let settingsVC: SettingsViewController = SettingsViewController()
                settingsVC.isPushed = true
                self.navigationController?.pushViewController(settingsVC, animated: true)
            })
            alertView.show()
            return
        }
        
        if currentFavs != nil {
            if let imageId = currentObjects?[index].objectId {
                currentFavs?.append(imageId)
                //Save existing favorites
                ParseFetcher.sharedInstance.saveFavorites(email, favs: currentFavs!, completion: { (saveSuccess, error) in
                    if saveSuccess {
                        print("Favs saved to server")
                    }else {
                        print(error)
                    }
                })
            }
        }else {
            currentFavs = [String]()
            if let imageId = currentObjects?[index].objectId {
                currentFavs?.append(imageId)
                ParseFetcher.sharedInstance.setFavorites(email, favs: currentFavs!, completion: { (saveSuccess, error) in
                    if saveSuccess{
                        print("Favs saved to server **")
                    }else {
                        print(error)
                    }
                })
            }
        }
        
    }
    
    //Activity view controller
    func shareImage() {
        let actitvityVC = UIActivityViewController(activityItems: [""], applicationActivities: nil)
        
        navigationController?.presentViewController(actitvityVC, animated: true, completion: nil)
    }
    
    //Opening maps to show directions
    func showDirections() {
        if self.weblink == nil {
            let alertView = UNAlertView(title: "Open Maps", message: "")
            alertView.addButton("Google Maps", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                
                //Google Maps
                UIApplication.sharedApplication().openURL(NSURL(string:"comgooglemaps://?saddr=&daddr=\(self.lattitude!),\(self.longitude!)&directionsmode=driving")!)
            }
            alertView.addButton("Apple Maps", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                
                //Apple Maps
                UIApplication.sharedApplication().openURL(NSURL(string:"http://maps.apple.com/?daddr=\(self.lattitude!),\(self.longitude!)&saddr=")!)
            }

            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.buttonAlignment = UNButtonAlignment.Vertical
            alertView.show()
        } else {
            let alertView = UNAlertView(title: "Open in Safari", message: "")
            alertView.addButton("Open", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0)) { () -> Void in
                //Open url in browser
                UIApplication.sharedApplication().openURL(NSURL(string: self.weblink!)!)
            }

            alertView.addButton("Cancel", backgroundColor: UIColor(red: 55/255, green: 55/255, blue: 55/255, alpha: 1.0), action: {})
            alertView.show()
        }
    }
    
    //Try again action for network error
    func tryAgainAction() {
        for subview in self.view.subviews{
            if subview.tag == 100{
                subview.removeFromSuperview()
                self.viewDidLoad()
            }
        }
    }

    //Send mail function
    func sendEnquireMail(sender: UIButton) {
        
        let mailPicker = MFMailComposeViewController()
        mailPicker.mailComposeDelegate = self
        mailPicker.setToRecipients(["info@planetexplored.com"])
        mailPicker.setSubject("Mauritius Attractions - Enquiry")
        mailPicker.setMessageBody("I'm interested in this place. I would love to hear more about this.", isHTML: false)
        self.presentViewController(mailPicker, animated: true, completion: nil)
    }
    
    func fetchAllUserFavs() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let email = userDefaults.objectForKey("username") as? String {
            ParseFetcher.sharedInstance.getFavorites(email, completion: { (favroites) in
                if favroites != nil {
                    if let favs = favroites?.first?["ImageId"] as? [String] {
                        self.currentFavs = favs
                        self.markFavorites()
                    }
                }
            })
        }
    }
    
}

