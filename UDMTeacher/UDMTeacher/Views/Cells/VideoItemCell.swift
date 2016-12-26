//
//  VideoItemCell.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//

import UIKit

final class VideoItemCell: UITableViewCell, Reusable {
    // MARK: - Properties
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var reviewer: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var content: UITextView!
    
    static var nib: UINib? {
        return UINib(nibName: String(VideoItemCell.self), bundle: nil)
    }
    
    // MARK: - Inittialzation
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func initData(from c: Course) {
        title.text = c.title
    }
}

