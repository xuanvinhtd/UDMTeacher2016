//
//  CourseDescriptionCell.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//
import UIKit

final class CourseDescriptionCell: UITableViewCell, Reusable {
    // MARK: - Properties
    @IBOutlet weak var seeAllBtn: UIButton!
    @IBOutlet weak var content: UITextView!
    
    static var nib: UINib? {
        return UINib(nibName: String(CourseDescriptionCell.self), bundle: nil)
    }
    
    // MARK: - Inittialzation
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initData(withString str:String) {
        content.text = str
        if content.text == "" {
            dispatch_async(dispatch_get_main_queue(), {
                self.seeAllBtn.hidden = true
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.seeAllBtn.hidden = false
            })
        }
    }
    
    
}
