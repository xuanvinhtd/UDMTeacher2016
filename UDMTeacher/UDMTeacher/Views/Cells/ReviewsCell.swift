//
//  ReviewsCell.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit

final class ReviewsCell: UITableViewCell, Reusable {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var seeAllBtn: UIButton!
    
    static var nib: UINib? {
        return UINib(nibName: String(ReviewsCell.self), bundle: nil)
    }
    
    var reviews = [Review]()
    
    // MARK: - Inittialzation
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.contentInset = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
    }
    
    func initData(withCourseID id: String) {
        UDMServer.share.getReviews(withCourseID: id) { (data, msg, success) in
            if success {
                self.reviews = Review.createReview(withInfos: data)
                if self.reviews.count == 0 {
                    self.seeAllBtn.hidden = true
                } else {
//                    let heightContraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 150)
//                    self.tableView.addConstraint(heightContraint)
                    self.tableView.reloadData()
                }
            } else {
                self.seeAllBtn.hidden = true
                log.error("Error: \(msg)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ReviewsCell: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReviewCourseCell
        cell.initData(from: reviews[indexPath.row])
        return cell
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