//
//  VideoListCell.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit

final class VideoListCell: UITableViewCell, Reusable {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seeAllBtn: UIButton!
    
    static var nib: UINib? {
        return UINib(nibName: String(VideoListCell.self), bundle: nil)
    }
    
    // MARK: - Inittialzation
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initData() {
        
    }
}
// MARK: - UITableViewDataSource
extension VideoListCell: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        animateCell(cell)
    }
    
    // MARK: Animation TableViewCell
    func animateCell(cell: UITableViewCell) {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1
        animation.duration = 0.5
        cell.layer.addAnimation(animation, forKey: animation.keyPath)
    }
}