//
//  CourseDetailViewController.swift
//  UDMTeacher
//
//  Created by OSXVN on 12/25/16.
//  Copyright © 2016 XUANVINHTD. All rights reserved.
//
import UIKit

final class CourseDetailViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    var course = Course()
    
    //Section Index
    enum SectionIndex: Int {
        case Video = 0
        case Description = 1
        case VideoList = 2
        case Reviews = 3
    }
    
    override func initData() {
        UDMServer.share.getCoursesDetail(withCourseID: course.id) { (data, msg, success) in
            if success {
                if let _data = data.first {
                    self.course = Course(withInfo: _data)
                    self.tableView.reloadData()
                }
            } else {
                UDMAlert.alert(title: "Cannot Get Data", message: msg , dismissTitle: "OK", inViewController: self, withDismissAction: nil)
                log.error("ERROR message: \(msg)")
            }
        }
    }
    
    override func configItems() {
        tableView.registerReusableCell(VideoListCell.self)
        tableView.registerReusableCell(CourseDescriptionCell.self)
        tableView.registerReusableCell(ReviewsCell.self)
        tableView.registerReusableCell(VideoCourseCell.self)
        tableView.contentInset = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        self.automaticallyAdjustsScrollViewInsets = false
    }
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configItems()
        initData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: - Handling event
    func createLiveStream(seden: AnyObject) {
        UDMServer.share.turnStream(withCoures: course.id, state: "1") { (data, msg, success) in
            if success {
                log.info("Create Live stream success: \(msg)")
                if let _data = data.first {
                    let stream = StreamVideoViewController.initFromNib() as! StreamVideoViewController
                    stream.coursesID = self.course.id
                    stream.streamName = _data["liveName"] as? String ?? "STREAMNAMEDEFAULT"
                    self.presentViewController(stream, animated: true, completion: nil)
                }
            } else {
                UDMAlert.alert(title: "Error Live", message: msg , dismissTitle: "OK", inViewController: self, withDismissAction: nil)
                log.error("ERROR message: \(msg)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CourseDetailViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (SectionIndex.Reviews.rawValue + 1)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SectionIndex.Video.rawValue {
            return 1.0
        }
        return 20.0
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SectionIndex.Video.rawValue:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as VideoCourseCell
            cell.streamBtn.addTarget(self, action: #selector(CourseDetailViewController.createLiveStream(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.initData(course)
            return cell
        case SectionIndex.Description.rawValue:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as CourseDescriptionCell
            cell.initData(withString: course.descriptions)
            return cell
        case SectionIndex.VideoList.rawValue:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as VideoListCell
            cell.initData(withCourseID: course.id)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReviewsCell
            cell.initData(withCourseID: course.id)
            return cell
        }
    }
}
