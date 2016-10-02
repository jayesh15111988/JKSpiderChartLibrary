//
//  ViewController.swift
//  JKSpiderChartLibrary
//
//  Created by Jayesh Kawli Backup on 9/6/16.
//  Copyright © 2016 Jayesh Kawli Backup. All rights reserved.
//

import UIKit
import BlocksKit

class ViewController: UIViewController, SpiderChartProtocol {

    var spider: SpiderChart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spider = SpiderChart(firstOptions: ["200", "100", "148", "107"], secondOptions: ["20", "10", "40", "15","15"], labelTitles: ["l1", "l2", "l3", "l4", "15"])
        spider?.translatesAutoresizingMaskIntoConstraints = false
        spider?.chartDelegate = self
        self.view.addSubview(spider!)
        let views = ["spider": spider!]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[spider]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-44-[spider(300)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spider?.drawSpiderChart()
    }

}

