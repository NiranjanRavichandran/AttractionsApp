//
//  MainViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 21/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var beachDict = [String: [Beach]]()
    var beachArray = [String]()
    
    var collectionView: UICollectionView!
    var pid = "nL3YwipKy6" // default place to be loaded
    var currentObjectId: String? // Current place for view
    var selectedObject: [Beach]? // Beach that is currently viewed
    var newTitle: String? //Title for view controller

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if newTitle != nil {
            self.title = newTitle
        }else {
            self.title = "Activities"
        }
        //Setting up collection view
        let layout = UltravisualLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 55, left: 0, bottom: 0, right: 0)
        
        //Registering custom Cell
        self.collectionView.registerNib(UINib(nibName: "ImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        self.view.addSubview(collectionView)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = barButtonItem

        }
        
        //Title for view controller
//        if let str = newTitle {
//            self.title = str
//        }else {
//            self.title = "Beaches"
//        }
        
        if let id = currentObjectId {
            pid = id
        }
        
        if pid == " " {
            self.errorMessageView()
        }else {
            //Load images from parse
            if Reachability.isConnectedToNetwork() {
                self.getImages()
            }else {
                Reachability.networkErrorView(self.view)
            }
        }
        
    }
    
    
    func getImages() {
        ParseFetcher.sharedInstance.fetchBeaches(pid) { (result) -> Void in
            if result.count > 0 {
                for item in result {
                    if var existingArray = self.beachDict[item.linkId!] {
                        existingArray.append(item)
                        self.beachDict[item.linkId!] = existingArray
                    } else {
                        let newArray: [Beach] = [item]
                        self.beachDict[item.linkId!] = newArray
                        self.beachArray.append(item.linkId!)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView.reloadData()
                })
                if let firstItem = self.beachArray.first {
                    self.selectedObject = self.beachDict[firstItem]
                }
            }else {
                self.errorMessageView()
            }
            
        }
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beachDict.count
  }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCollectionCell
        if let currentItem = beachDict[beachArray[indexPath.item]] {
            //Setting title for the images from description
            let title = currentItem.first?.description
            let index = title?.rangeOfString("-")?.startIndex
            if let value = index {
                cell.cellTitle.text = title?.substringFromIndex(value.successor())
            }else {
                cell.cellTitle.text = currentItem.first?.description
            }
            
            //Fetch image from parse
            if let imageFile = currentItem.first?.imageFile {
                imageFile.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                    if error == nil {
                        if let result = imageData {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cell.currentImage = result
                            })

                        }
                    }
                })
            }
        }
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            let layout = self.collectionView.collectionViewLayout as! UltravisualLayout
            let offset = layout.dragOffset * CGFloat(indexPath.item)
            if collectionView.contentOffset.y != offset {
                collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
            self.selectedObject = self.beachDict[self.beachArray[indexPath.item]]
            
            }) { (isComplete) -> Void in
                if isComplete {
                    //Push Detailed view
                    let photosVC = PhotosViewController()
                    if let objects = self.selectedObject {
                        photosVC.currentObjects = objects
                    }
                    self.navigationController?.pushViewController(photosVC, animated: true)
                }
        }
        
    }


    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, .PortraitUpsideDown]
    }
    
    func errorMessageView() {
        let messageView = UIView(frame: UIScreen.mainScreen().bounds)
        messageView.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1.0)
        let messageLabel = UILabel(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 25))
        messageLabel.center = messageView.center
        messageLabel.font = UIFont(name: "Helvetica", size: 18)
        messageLabel.text = "Coming Soon... Stay Tuned!"
        messageLabel.textColor = UIColor.darkGrayColor()
        messageLabel.textAlignment = .Center
        let icon = UIImageView(frame: CGRectMake(0, 0, 60, 60))
        icon.image = UIImage(named: "coming_soon.png")
        icon.center.x = messageView.center.x
        icon.center.y = messageView.center.y - 60
        messageView.addSubview(icon)
        messageView.addSubview(messageLabel)
        
        self.view.addSubview(messageView)
        
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
    
    override func viewDidLayoutSubviews() {
        collectionView.frame.size.width = UIScreen.mainScreen().bounds.width
    }
}
