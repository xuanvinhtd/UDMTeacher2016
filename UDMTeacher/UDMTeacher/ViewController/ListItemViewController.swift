//
//  ReviewsViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit

enum ItemType {
    case Video
    case Review
}

final class ListItemViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var typeScreen = ItemType.Video
    
    
    override func configItems() {
        
    }
    
    override func initData() {
        
    }
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configItems()
        initData()
    }
}

// MARK: - UITableViewDataSource
extension ListItemViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
