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
        if content.text == "" {
            seeAllBtn.hidden = true
        }
    }
}
