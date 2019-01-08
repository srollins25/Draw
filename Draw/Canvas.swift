//
//  Canvas.swift
//  Draw
//
//  Created by stephan rollins on 1/8/19.
//  Copyright © 2019 stephan rollins. All rights reserved.
//

import Foundation
import UIKit

class Canvas: UIView
{
    //public function
    fileprivate var lines = [Line]()
    fileprivate var strokeColor = UIColor.black
    fileprivate var strokeWidth: Float = 1
    
    func setStrokeColor(color: UIColor)
    {
        self.strokeColor = color
    }
    
    func undo()
    {
       _ = lines.popLast()
        setNeedsDisplay()
    }
    
    func clear()
    {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func setStrokeWidth(width: Float)
    {
        self.strokeWidth = width
    }
    
    override func draw(_ rect: CGRect)
    {
        //custom drawing
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        

        
        
        lines.forEach { (line) in
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(CGFloat(line.strokeWidth))
            context.setLineCap(.round)
            for (i, p) in line.points.enumerated()
            {
                if (i == 0)
                {
                    context.move(to: p)
                }
                else
                {
                    context.addLine(to: p)
                }
            }
        context.strokePath()
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        lines.append(Line.init(strokeWidth: strokeWidth, color: strokeColor, points: []))
    }
    // track finger movement on screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let point = touches.first?.location(in: nil) else { return }
        
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        
        lines.append(lastLine)
        setNeedsDisplay()
    }
}










