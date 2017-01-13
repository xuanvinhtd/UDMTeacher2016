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
    let tabLabel = 100
    
    var curruculums = [Curruculum]()
    
    static var nib: UINib? {
        return UINib(nibName: String(VideoListCell.self), bundle: nil)
    }
    
    // MARK: - Inittialzation
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.contentInset = UIEdgeInsetsZero;
        tableView.contentInset = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func initData(withCourseID id: String) {
        UDMServer.share.getCurriculumns(withCourseID: id) { (data, msg, success) in
            if success {
                self.curruculums = Curruculum.createCurruculum(withInfos: data)
                if self.curruculums.count == 0 {
                    self.seeAllBtn.hidden = true
                } else {
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
extension VideoListCell: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curruculums.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellTable = tableView.dequeueReusableCellWithIdentifier("defaulCell")
        if cellTable == nil {
            cellTable = UITableViewCell.init(style: .Subtitle, reuseIdentifier: "defaulCell")
            cellTable?.imageView?.image = UIImage(named: "imageWhite_1")
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            label.layer.cornerRadius = 12.5
            label.layer.borderWidth = 1.0
            label.layer.borderColor = UDMHelpers.grayTheme().CGColor
            label.text = curruculums[indexPath.row].numbers
            label.textAlignment = .Center
            label.tag = tabLabel
            label.backgroundColor = UIColor.clearColor()
            
            cellTable?.imageView?.addSubview(label)
            cellTable?.detailTextLabel?.textColor = UDMHelpers.grayTheme()
            cellTable?.detailTextLabel?.text = "Video - " + curruculums[indexPath.row].timeVideo
            // goi y : thay image co size phu hop va mau trang
        }
        if let labelNumber = cellTable?.imageView?.viewWithTag(tabLabel) as? UILabel {
            labelNumber.text = String(indexPath.row)
        }
        
        cellTable?.textLabel?.text = curruculums[indexPath.row].title
        return cellTable!
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

// MARK: - UITableViewDataSource
extension VideoListCell: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        log.info("click row: \(indexPath.row)")
    }
}