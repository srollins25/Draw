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
    
    
    override func draw(_ rect: CGRect)
    {
        //custom drawing
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(10)
        context.setLineCap(.butt)
        
        lines.forEach
            { (line) in
                
            for (i, point) in line.enumerated()
            {
                if (i == 0)
                {
                    context.move(to: point)
                }
                else
                {
                    context.addLine(to: point)
                }
            }
        }
        
        context.strokePath()
    }
    
    var lines = [[CGPoint]]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        lines.append([CGPoint]())
    }
    // track finger movement on screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let point = touches.first?.location(in: nil) else { return }
        
        guard var lastLine = lines.popLast() else { return }
        lastLine.append(point)
        
        lines.append(lastLine)
        setNeedsDisplay()
    }
}










