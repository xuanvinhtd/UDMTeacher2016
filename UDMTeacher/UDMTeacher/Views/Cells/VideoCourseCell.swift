//
//  VideoCourseViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit
import Cosmos

final class VideoCourseCell: UITableViewCell, Reusable {
    // MARK: - Properties
    @IBOutlet weak var couresImage: UIImageView!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var ratingControl: CosmosView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var streamBtn: UIButton!
    var courseID = ""
    
    static var nib: UINib? {
        return UINib(nibName: String(VideoCourseCell.self), bundle: nil)
    }
    
    // MARK: - Inittialzation
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initData(c: Course) {
        courseID = c.id
        title.text = c.title
        teacherName.text = c.author
        ratingControl.rating = c.review
        price.text = "$" + c.newPrice
        
        let url = c.thumbnail
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let img = UDMHelpers.getImageByURL(with: url)
            dispatch_async(dispatch_get_main_queue(), {
                self.couresImage.image = img
            })
        }
    }
}
