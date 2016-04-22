//
//  SettingsViewController.swift
//  Mauritius
//
//  Created by Niranjan Ravichandran on 27/12/15.
//  Copyright © 2015 adavers. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    var isPushed: Bool = false
    var cellData: NSMutableArray?
    var isExpanded: Bool = false
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var isEditable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        
        //setting up table view
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
        self.tableView.registerNib(UINib(nibName: "LanguageCell", bundle: nil), forCellReuseIdentifier: "LanguageCell")
        
        if !isPushed {
            if self.revealViewController() != nil {
                self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
                let barButton = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
                self.navigationItem.leftBarButtonItem = barButton
            }
        }
        //Loading cell data from plist
        self.loadCellData()
        
        let editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(self.enableEdit(_:)))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    func loadCellData() {
        if let path = NSBundle.mainBundle().pathForResource("SettingsPage", ofType: "plist") {
            cellData = NSMutableArray(contentsOfFile: path)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let data = cellData {
            return data.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = cellData![section] as? NSDictionary {
           return data["cellItems"]!.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let data = cellData![indexPath.section] as? NSDictionary {
            if data["type"] as! Int == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath) as! SettingsTableViewCell
                cell.cellTextField.tag = indexPath.row
                if let cellText = (data["cellItems"] as! NSArray)[indexPath.row] as? String {
                    cell.cellLable.text = cellText
                    cell.cellTextField.placeholder = cellText
                    cell.cellTextField.delegate = self
                    if !isEditable{
                        //Disable user interaction when edit not enabled
                        cell.cellTextField.userInteractionEnabled = false
                    }else {
                        //Allow user interaction when edit is enabled
                        cell.cellTextField.userInteractionEnabled = true
                    }
                }
                return cell
            } else if data["type"] as! Int == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell", forIndexPath: indexPath) as! LanguageCell
                //Setting language
                if let lang = userDefaults.objectForKey("currentLanguage") as? String{
                    //Setting from user prefernece saved
                    cell.languageLabel.text = lang
                } else {
                    //Setting default language
                    cell.languageLabel.text = "\(APP_DEFAULT_LANGUAGE)"
                }
                if isExpanded {
                    cell.languagePicker.alpha = 1
                } else {
                    cell.languagePicker.alpha = 0
                }
                return cell
            } else {
                let cell = UITableViewCell()
                if let cellText = (data["cellItems"] as? NSArray)![indexPath.row] as? String {
                    cell.textLabel?.text = cellText
                    cell.accessoryType = .DisclosureIndicator
                }
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let data = cellData![indexPath.section] as? NSDictionary {
            if data["type"] as! Int == 2 {
                if isExpanded {
                    isExpanded = false
                }else {
                    isExpanded = true
                }
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let data = cellData![indexPath.section] as? NSDictionary {
            if data["type"] as! Int == 2 {
                if self.isExpanded {
                    //Height for expanded cell
                    return 240
                }else {
                    //Height for closed cell
                    return 44
                }
            } else {
                //Height for other cells
                return 44
            }
        } else {
            return 44
        }

    }
    
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if let data = cellData {
            if section == data.count - 1 {
                let footerView = UITableViewHeaderFooterView(frame: CGRectMake(0, 0, tableView.bounds.width, 55))
                let contentLabel = UILabel(frame: footerView.bounds)
                contentLabel.center = footerView.center
                contentLabel.font = UIFont(name: "Helvetica", size: 13)
                contentLabel.textAlignment = NSTextAlignment.Center
                
                let footerText = "Designed and Developed by Niranjan Ravichandran" as NSString
                contentLabel.textColor = UIColor.lightGrayColor()
                //Creating attributed String
                let attributedText = NSMutableAttributedString(string: footerText as String)
                attributedText.addAttributes([NSUnderlineStyleAttributeName: 1], range: footerText.rangeOfString("Niranjan Ravichandran"))
                attributedText.addAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], range: footerText.rangeOfString("Niranjan Ravichandran"))
                contentLabel.attributedText = attributedText
                
                footerView.addSubview(contentLabel)
                contentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openInSafari)))
                contentLabel.userInteractionEnabled = true
                return footerView
            }else {
                return nil
            }
        }else {
            return nil
        }
    
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let data = cellData {
            if section == data.count - 1 {
             return 55
            }else {
                return 0
            }
        }else {
            return 0
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        var name: String?
        var email: String?
        var phone: String?
        switch textField.tag {
        case 0:
            if let _ = textField.text {
                name = textField.text!
            }
        case 1:
            if let _ = textField.text {
                email = textField.text!
            }
        case 2:
            if let _ = textField.text {
                phone = textField.text!
            }
            
        default:
            print("Handle textfield with no tags")
        }
        
        if email != nil {
            
            ParseFetcher.sharedInstance.checkUser(email!) { (userExists) in
                if userExists {
                    self.userDefaults.setObject(email, forKey: "username")
                }else {
                    //Sign up new user
                    let newUser = PFUser()
                    newUser.email = email
                    if let _ = name {
                        newUser.setObject(name!, forKey: "Name")
                    }
                    
                    if let _ = phone {
                        newUser.setObject(phone!, forKey: "Phone")
                    }
                    
                    ParseFetcher.sharedInstance.createUser(newUser, completion: { (status) in
                        if status{
                            self.userDefaults.setObject(newUser.email, forKey: "username")
                        }
                    })
                }
            }
        }
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.tableView.endEditing(true)
    }
    
    func enableEdit(sender: UIBarButtonItem) {
        if !isEditable {
            isEditable = true
            sender.title = "Save"
            tableView.reloadData()
        }else {
            isEditable = false
            sender.title = "Edit"
        }
    }
    
    func openInSafari() {
        let url = NSURL(string: "http://nravichan.paperplane.io/#about")
        UIApplication.sharedApplication().openURL(url!)
    }

}
