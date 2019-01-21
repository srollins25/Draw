//
//  ViewController.swift
//  Draw
//
//  Created by stephan rollins on 1/7/19.
//  Copyright © 2019 stephan rollins. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
class ViewController: UIViewController
{
    let canvas = Canvas()
    
    let undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Undo", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        return button
    }()
    
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        return button
    }()
    
    let colorPicker: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.frame = CGRect(x: 160, y: 100, width: 30, height: 30)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 15
        slider.addTarget(self, action: #selector(handleSliderChange), for: .touchDragInside)
        return slider
    }()
    
    let buttonContainer: UIView = {
        
        let colorHeight: CGFloat = 50
        let padding: CGFloat = 6
        let colorArr =  [UIColor.red, .yellow, .magenta, .green, .purple, .orange, .blue, .black]
        let colorViews = colorArr.map({ (color) -> UIButton in
            let v = UIButton()
            v.backgroundColor = color
            v.layer.cornerRadius = colorHeight / 2
            return v
        })
        
        let width = CGFloat(colorViews.count) * colorHeight + (CGFloat(colorViews.count) + 1) * padding
        let container = UIView()
        
        container.backgroundColor = .white
        container.frame = CGRect(x: 0, y: 0, width: width, height: colorHeight + 2 * padding)
        container.layer.cornerRadius = container.frame.height / 2
        container.isUserInteractionEnabled = true
        
        let stackView = UIStackView(arrangedSubviews: colorViews)
        stackView.distribution = .fillEqually
        container.addSubview(stackView)
        
        stackView.frame = container.frame
        
        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        container.layer.shadowColor = UIColor(white: 0.4, alpha: 0.4).cgColor
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.5
        
        return container
    }()
    
    override func loadView() {
        self.view = canvas
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        canvas.backgroundColor = .white
        longPressGesture()
        setUI()
    }
    
    func longPressGesture(){
        colorPicker.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer)
    {
        if gesture.state == .began
        {
            handleGestureBegan(gesture: gesture)
        }
        else if gesture.state == .ended
        {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [  .curveEaseOut], animations: {
                
                let stackView = self.buttonContainer.subviews.first
                stackView?.subviews.forEach({ (button) in
                    button.transform = .identity
                })
                self.buttonContainer.transform = self.buttonContainer.transform.translatedBy(x: 0, y: 50)
                self.buttonContainer.alpha = 0
            }, completion: { (_) in
                self.buttonContainer.removeFromSuperview()
            })
        }
        else if gesture.state == .changed
        {
            handleGstureChange(gesture: gesture)
        }
    }
    
    fileprivate func handleGstureChange(gesture: UILongPressGestureRecognizer)
    {
        let pressedLocation = gesture.location(in: self.buttonContainer)
        
        let hitTestView = buttonContainer.hitTest(pressedLocation, with: nil)
        
        if hitTestView is UIButton {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
                
                self.handleColorChange(button: hitTestView as! UIButton)
                self.colorPicker.backgroundColor = hitTestView?.backgroundColor
                self.slider.thumbTintColor = hitTestView?.backgroundColor
                let stackView = self.buttonContainer.subviews.first
                stackView?.subviews.forEach({ (button) in
                    button.transform = .identity
                })
                
                hitTestView?.transform = CGAffineTransform(translationX: 0, y: -50)
            })
        }
    }
    
    fileprivate func handleGestureBegan(gesture: UILongPressGestureRecognizer)
    {
        let location = gesture.location(in: self.view)
        print(location)
        view.addSubview(buttonContainer)
        let centerX = (view.frame.width - buttonContainer.frame.width) / 2
        
        buttonContainer.alpha = 0
        buttonContainer.transform = CGAffineTransform(translationX: centerX, y: view.frame.height * 0.8)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.buttonContainer.alpha = 1
        })
    }
    
    @objc func handleSliderChange()
    {
        canvas.setStrokeWidth(width: slider.value)
    }

    @objc func handleColorChange(button: UIButton)
    {
        canvas.setStrokeColor(color: button.backgroundColor!)
    }
    
    @objc func handleUndo()
    {
        canvas.undo()
    }
    
    @objc func handleClear()
    {
        canvas.clear()
    }
    
    fileprivate func setUI()
    {
        let colorStackView = UIStackView(arrangedSubviews: [colorPicker])
        colorStackView.distribution = .fillEqually
        
        let stackView = UIStackView(arrangedSubviews: [undoButton, colorStackView, clearButton, slider])
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
    }
}






















