//
//  InfoViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/24/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import Foundation
import UIKit

final class InfoUserViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var avata: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var arrSetting: [String: String?] = [:]
    
    override func initData() {
        arrSetting = UserManager.share.getInfos()
        tableView.reloadData()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let img = UDMHelpers.getImageByURL(with: UserManager.share.info.avatar)
            dispatch_async(dispatch_get_main_queue(), {
                self.avata.image = img
            })
        }
    }
    
    override func configItems() {
        avata.layer.cornerRadius = avata.frame.width / 2
        avata.clipsToBounds = true
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configItems()
        initData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
}
// MARK: - UITableViewDataSource
extension InfoUserViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSetting.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idProfileCell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "idProfileCell")
        }
        guard let title = cell?.contentView.viewWithTag(10) as? UILabel else {
            fatalError()
        }
        title.text = Array(arrSetting.keys)[indexPath.row]
        
        guard let value = cell?.contentView.viewWithTag(11) as? UILabel else {
            fatalError()
        }
        value.text = Array(arrSetting.values)[indexPath.row]
        
        if title.text == "Sex" {
            value.text = Array(arrSetting.values)[indexPath.row] == "0" ? "Female" : "Male"
        }
        
        if title.text == "Description" {
            title.text = Array(arrSetting.values)[indexPath.row]
            value.text = ""
        }
        
        return cell!
    }
}