//
//  SpiderChart.swift
//  JKSpiderChartLibrary
//
//  Created by Jayesh Kawli on 10/1/16.
//  Copyright © 2016 Jayesh Kawli Backup. All rights reserved.
//

import UIKit
import BlocksKit

public class SpiderChart: UIView {
    let hexColorValues: [UInt]
    var layersCollection: [CALayer]
    let chartLabelTitles: [String]
    let firstOptions: [String]
    let secondOptions: [String]
    var selectedLegendIndex: Int
    var chartCenter: CGPoint
    var chartMaxRadius: CGFloat
    var graphPadding: CGFloat
    var animated: Bool
    weak var chartDelegate: SpiderChartProtocol?

    
    public init(firstOptions: [String], secondOptions: [String], labelTitles: [String], animated: Bool = false) {
        self.firstOptions = firstOptions
        self.secondOptions = secondOptions
        self.chartLabelTitles = labelTitles
        self.selectedLegendIndex = -1
        self.layersCollection = []
        self.hexColorValues = [0x64DDBB, 0x8F6F40, 0xFD5B03, 0xD33257, 0x6C8784, 0x1DABB8, 0x60646D, 0x8870FF, 0xBB3658, 0x3D8EB9]
        self.chartCenter = CGPointZero
        self.chartMaxRadius = 0
        self.graphPadding = 44
        self.animated = animated
        super.init(frame: .zero)
        self.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.layer.borderWidth = 2.0
        
        assert(firstOptions.count == secondOptions.count, "Option counts should match")
        assert(firstOptions.count == chartLabelTitles.count, "Option count should match with label titles count")
        assert(firstOptions.count <= 10, "This library supports maximum 10 options to be shown on the graph")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func drawSpiderChart() {
        if let graphPadding = self.chartDelegate?.graphPadding?() {
            self.graphPadding = graphPadding
        } else {
            self.graphPadding = 44
        }
    
        self.chartMaxRadius = min(self.frame.width - graphPadding, self.frame.height - (2 * graphPadding))/2.0
        self.chartCenter = CGPoint(x: self.frame.size.width/2.0, y: (self.frame.size.height - graphPadding)/2.0)
        
        var maxInputRadiusValue = 0
    
        for option in firstOptions {
            if let numberValue = Int(option) {
                if numberValue > maxInputRadiusValue {
                    maxInputRadiusValue = numberValue
                }
            }
        }
        
        let scrollViewParentView = UIView()
        scrollViewParentView.translatesAutoresizingMaskIntoConstraints = false
        scrollViewParentView.layer.borderColor = UIColor.blackColor().CGColor
        scrollViewParentView.layer.borderWidth = 2.0
        self.addSubview(scrollViewParentView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollViewParentView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let scrollViewSubViews = ["contentView": contentView, "scrollView": scrollView, "scrollViewParentView": scrollViewParentView]
    
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollViewParentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: scrollViewSubViews))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[scrollViewParentView(graphPadding)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["graphPadding": self.graphPadding], views: scrollViewSubViews))
    
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: scrollViewSubViews))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: scrollViewSubViews))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: scrollViewSubViews))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: scrollViewSubViews))
    
        scrollViewParentView.addConstraint(NSLayoutConstraint(item: scrollViewParentView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: 0))
        scrollViewParentView.addConstraint(NSLayoutConstraint(item: scrollViewParentView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        
        var updatedAngleValue: CGFloat = 0
        for (index, _) in firstOptions.enumerate() {
            let mappedRadiusToNewValue = CGFloat(((Float(firstOptions[index])!)/Float(maxInputRadiusValue)) * Float(self.chartMaxRadius))
        let angleValue = CGFloat((Float(secondOptions[index])!/100.0) * 360)
        let endAngle = angleValue + updatedAngleValue
        let childLayer = createPieSliceWith(mappedRadiusToNewValue, startAngle: updatedAngleValue, endAngle: endAngle, index: index)
        self.layer.addSublayer(childLayer)
        layer.addSublayer(labelWith("R: \(firstOptions[index])\nA: \(secondOptions[index])", startAngle: updatedAngleValue, endAngle: endAngle, radius: mappedRadiusToNewValue))
        updatedAngleValue = updatedAngleValue + angleValue
        layersCollection.append(childLayer)
    }
    
    
    var previousView = UIView()
        let numberOfLegends = self.chartLabelTitles.count
        for i in 0 ..< numberOfLegends {
            let legend = self.legendViewFor(i)
            contentView.addSubview(legend)
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[legend]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["legend": legend]))
            
            if (i == 0) {
                if (i == numberOfLegends - 1) {
                    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[legend(>=0)]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["legend": legend]))
                } else {
                    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[legend(>=0)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["legend": legend]))
                }
            } else {
                if (i == numberOfLegends - 1) {
                    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[previousView]-[legend(>=0)]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["legend": legend, "previousView": previousView]))
                } else {
                    contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[previousView]-[legend(>=0)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["legend": legend, "previousView": previousView]))
                }
            }
            previousView = legend
        }
    }
        
    func labelWith(title: String, startAngle: CGFloat, endAngle: CGFloat, radius: CGFloat) -> CATextLayer {
        let label = CATextLayer()
        let angle = CGFloat(startAngle + (endAngle - startAngle) / 2.0)
        let angleCos = cos(degreesToRadians(angle))
        let angleSin = sin(degreesToRadians(angle))
        let xLabelOffset = 18.0
        let yLabelOffset = 15.0
        
        label.frame = CGRect(x: Double(self.chartCenter.x) - xLabelOffset + ((Double(radius) + xLabelOffset)) * Double(angleCos), y: Double(self.chartCenter.y) - yLabelOffset + ((Double(radius) + yLabelOffset)) * Double(angleSin), width: 40, height: 26)
        
        if let graphLabelFont = self.chartDelegate?.graphLabelsFont?() {
            let labelFont = graphLabelFont
            label.fontSize = labelFont.pointSize
            label.font = labelFont.fontName
        } else {
            label.fontSize = 10
        }
            
        label.contentsScale = UIScreen.mainScreen().scale
        label.string = title
        label.alignmentMode = kCAAlignmentCenter
        label.foregroundColor = UIColor.blackColor().CGColor
        label.zPosition = 100
        return label
    }
            
    func legendViewFor(index: Int) -> UIView {
        let legendView = UIView()
        legendView.translatesAutoresizingMaskIntoConstraints = false
        legendView.backgroundColor = UIColorFromRGB(hexColorValues[index])
        let legendLabel = UILabel()
        legendLabel.translatesAutoresizingMaskIntoConstraints = false
        if let legendLabelFont = self.chartDelegate?.legendLabelsFont?() {
            legendLabel.font = legendLabelFont
        } else {
            legendLabel.font = UIFont.systemFontOfSize(13)
        }
        legendLabel.textAlignment = .Center
        legendLabel.text = chartLabelTitles[index]
                
        let legendParentView = UIView()
        legendParentView.translatesAutoresizingMaskIntoConstraints = false
        legendParentView.addSubview(legendView)
        legendParentView.addSubview(legendLabel)
        legendParentView.bk_whenTapped({
            for layer in self.layersCollection {
                if (self.selectedLegendIndex == index) {
                    layer.opacity = 1.0
                } else {
                    layer.opacity = (layer == self.layersCollection[index]) ? 1.0 : 0.4
                }
            }
            
            if (self.selectedLegendIndex == index) {
                self.selectedLegendIndex = -1
            } else {
                self.selectedLegendIndex = index
            }
            self.chartDelegate?.mapLegendSelectedAt?(index)
        })
        
        let views = ["legendView": legendView, "legendLabel": legendLabel]
        
        legendParentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[legendView(20)][legendLabel]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        legendParentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[legendLabel]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        legendParentView.addConstraint(NSLayoutConstraint(item: legendView, attribute: .CenterX, relatedBy: .Equal, toItem: legendParentView, attribute: .CenterX, multiplier: 1.0, constant: 0))
        legendParentView.addConstraint(NSLayoutConstraint(item: legendView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 20))
                return legendParentView
    }

    func createPieSliceWith(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, index: Int) -> CAShapeLayer {
        let fromPath = bezierPathWithCenter(chartCenter, radius: 0, startAngle: startAngle, endAngle: endAngle)
        let toPath = bezierPathWithCenter(chartCenter, radius: radius, startAngle: startAngle, endAngle: endAngle)
        let slice = CAShapeLayer()
        slice.fillColor = self.UIColorFromRGB(hexColorValues[index]).CGColor
        slice.shadowOffset = CGSizeMake(5, 5)
        slice.shadowRadius = 10.0
        slice.shadowColor = UIColor.lightGrayColor().CGColor
        slice.masksToBounds = false
        slice.strokeColor = UIColor.lightGrayColor().CGColor
        slice.lineWidth = 1.0
        slice.path = toPath
        if self.animated == true {
            let anim = CABasicAnimation(keyPath: "path")
            anim.duration = 1.0
            anim.fromValue = fromPath
            anim.toValue = toPath
            anim.removedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            slice.addAnimation(anim, forKey: nil)
        }
        return slice
    }
    
    func bezierPathWithCenter(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CGPathRef {
        let piePath = UIBezierPath()
        piePath.moveToPoint(center)
        piePath.addLineToPoint(CGPoint(x: center.x + radius * CGFloat(cosf(Float(degreesToRadians(startAngle)))), y: center.y + radius * CGFloat(sinf(Float(degreesToRadians(startAngle))))))
        piePath.addArcWithCenter(center, radius: radius, startAngle: degreesToRadians(startAngle), endAngle: degreesToRadians(endAngle), clockwise: true)
        piePath.closePath()
        return piePath.CGPath
    }

    func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return (degrees * CGFloat((M_PI / 180.0)))
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(rgbValue & 0xFF))/255.0, alpha: 1.0)
    }
}
