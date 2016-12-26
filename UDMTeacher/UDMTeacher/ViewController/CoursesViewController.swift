//
//  CoursesViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/24/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit

final class CoursesViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var courses = [Course]()
    
    private var notifyReloadPage: AnyObject!
    private var notifyDisconnectInternet: AnyObject!
    
    override func initData() {
        UDMServer.share.getCourses { (data, msg, success) in
            if success {
                self.courses.removeAll()
                self.courses = Course.createCourses(withInfos: data)
                self.tableView.reloadData()
            } else {
                UDMAlert.alert(title: "Cannot Get Data", message: msg, dismissTitle: "OK", inViewController: self, withDismissAction: nil)
                log.error("ERROR: \(msg)")
            }
        }
    }
    
    override func configItems() {
        tableView.tableFooterView = UIView()
        tableView.registerReusableCell(CourseCell.self)
        tableView.contentInset = UIEdgeInsetsZero
        self.automaticallyAdjustsScrollViewInsets = false
    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configItems()
        initData()
        registerNotitication()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if UserManager.share.isLogInSuccess {
            return
        }
        // Init screen Sign
        let login = LoginViewController.initFromNib()
        let navigationBarSignIn = UINavigationController(rootViewController: login)
        self.presentViewController(navigationBarSignIn, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        deregisterNotification()
    }
    
    // MARK: - Notification
    struct Notification {
        static let ReloadPage = "ReloadPage"
    }
    
    override func registerNotitication() {
        notifyReloadPage = NSNotificationCenter.defaultCenter().addObserverForName(Notification.ReloadPage, object: nil, queue: nil, usingBlock: { (notification) in
            log.info("Reveiced notification name: \(notification.name)")
            self.initData()
        })
        
        notifyDisconnectInternet = NSNotificationCenter.defaultCenter().addObserverForName(UDMConfig.Notification.DisconnetedInternet, object: nil, queue: nil, usingBlock: { (notification) in
            log.info("Reveiced notification name: \(notification.name)")
            
        })
    }
    
    override func deregisterNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(notifyReloadPage)
        NSNotificationCenter.defaultCenter().removeObserver(notifyDisconnectInternet)
    }
}

// MARK: - UITableViewDataSource
extension CoursesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(120)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as CourseCell
        cell.initData(from: courses[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CoursesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        log.info("Row index: \(indexPath)")
        let detail = CourseDetailViewController.initFromNib() as! CourseDetailViewController
        detail.course = courses[indexPath.row]
        self.navigationController?.pushViewController(detail, animated: true)
    }
}
