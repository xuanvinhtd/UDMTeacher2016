//
//  CourseCell.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/24/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit
import Cosmos

final class CourseCell: UITableViewCell, Reusable {
    // MARK: - Properties
    
    @IBOutlet weak var courseImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var ratingControl: CosmosView!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var moneyNew: UILabel!
    @IBOutlet weak var moneyOld: UILabel!
    
    static var nib: UINib? {
        return UINib(nibName: String(CourseCell.self), bundle: nil)
    }
    
    // MARK: - Inittialzation
    override func awakeFromNib() {
        super.awakeFromNib()
        moneyNew.textColor = UDMHelpers.textTheme()
        ratingControl.userInteractionEnabled = false
    }
    
    func initData(from c: Course) {
        title.text = c.title
        ratingControl.rating = c.review
        teacherName.text = c.author
        moneyNew.text = "$" + c.newPrice
        
        let attributes = [NSStrikethroughStyleAttributeName : 1]
        let moneyStr = NSAttributedString(string: "$" + ((c.oldPrice == "0") ? "45.000" : c.oldPrice), attributes: attributes)
        moneyOld.attributedText = moneyStr
        
        let url = c.thumbnail
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let img = UDMHelpers.getImageByURL(with: url)
            dispatch_async(dispatch_get_main_queue(), {
                self.courseImage.image = img
            })
        }
    }
}
