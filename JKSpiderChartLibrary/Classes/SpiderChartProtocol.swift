//
//  SpiderChartProtocol.swift
//  JKSpiderChartLibrary
//
//  Created by Jayesh Kawli on 10/2/16.
//  Copyright © 2016 Jayesh Kawli Backup. All rights reserved.
//

import UIKit

@objc public protocol SpiderChartProtocol: class {
    optional func mapLegendSelectedAt(index: Int)
    optional func legendLabelsFont() -> UIFont
    optional func graphLabelsFont() -> UIFont
    optional func graphPadding() -> CGFloat
}
