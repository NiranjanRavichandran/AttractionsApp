//
//  RearViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 20/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit

class RearViewController: UITableViewController {
    
    var categories: [Category]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.navigationController?.navigationBarHidden = false
        self.tableView.separatorStyle = .None
        
        //Registering custom cell
        self.tableView.registerNib(UINib(nibName: "MenuTableCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        self.title = "Menu"
        self.getCategories()
        
        //Removing navbar shadow
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if childView.frame.height == 0.5 {
                    childView.removeFromSuperview()
                }
            }
        }
    }
    
    //Fetching menu items
    func getCategories() {
        ParseFetcher.sharedInstance.fetchCategories([2]) { (result) -> Void in
            if result.count > 0 {
                self.categories = result.sort({ $0.position < $1.position })
                self.tableView.reloadData()
            }
        }
        
        //Adding language change notification observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.languageChange), name: "languageChange", object: nil)
    }

    func languageChange() {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return categories?.count ?? 0
        }else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Attractions"
        }else if section == 1 {
            return "Favourites"
        }else {
            return "Settings"
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 38/255, green: 40/255, blue: 43/255, alpha: 1.0)
        header.textLabel?.textColor = UIColor.whiteColor()
        header.textLabel?.font = UIFont(name: "HelveticaNeue", size: (header.textLabel?.font?.pointSize)!)
        if header.textLabel?.text == "Favourites" {
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RearViewController.favouritesPage)))
        }else if header.textLabel?.text == "Settings"{
            header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RearViewController.settingsPage)))
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableCell
        cell.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)
        
        switch APP_DEFAULT_LANGUAGE {
        case .English:
            cell.menuLabel.text = categories?[indexPath.row].name
        case .Chinese:
            cell.menuLabel.text = categories?[indexPath.row].chinese
        case .Italian:
            cell.menuLabel.text = categories?[indexPath.row].italian
        case .German:
            cell.menuLabel.text = categories?[indexPath.row].german
        case .French:
            cell.menuLabel.text = categories?[indexPath.row].french
        }
        
        if let iconName = categories?[indexPath.row].iconName {
            cell.menuIcon.image = UIImage(named: iconName)?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.menuIcon.tintColor = UIColor.grayColor()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTableCell
        selectedCell?.backgroundColor = UIColor(red: 255/255, green: 66/255, blue: 70/255, alpha: 1.0)
        selectedCell?.menuIcon.tintColor = UIColor.whiteColor()

        var newFrontViewController: UINavigationController?
        let mainVC = MainViewController()
        if let item = categories?[indexPath.row].objectId {
            mainVC.currentObjectId = item
            //print("#### passed on Id \(item)")
            mainVC.newTitle = categories?[indexPath.row].name
            newFrontViewController = UINavigationController(rootViewController: mainVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let deselectedCell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTableCell
        deselectedCell?.backgroundColor = UIColor(red: 45/255, green: 47/255, blue: 50/255, alpha: 1.0)
        deselectedCell?.menuIcon.tintColor = UIColor.grayColor()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, .PortraitUpsideDown]
    }
    
    //Settings Page
    func settingsPage() {
        
        let settingsVC = SettingsViewController()
        revealViewController().pushFrontViewController(UINavigationController(rootViewController: settingsVC), animated: true)
    }
    
    //Favourites page
    func favouritesPage() {
        let mainVC = MainViewController()
        mainVC.title = "Favourites"
        mainVC.currentObjectId = " "
        let newFrontViewController = UINavigationController(rootViewController: mainVC)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }
    
}
