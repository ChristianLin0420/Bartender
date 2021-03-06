//
//  ViewController.swift
//  Bartender_final_1210
//
//  Created by Christian on 2019/12/10.
//  Copyright © 2019 Christian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var tempTimer = Timer()
    private var TimerCount = 0
    
    private var shapeLayer: CAShapeLayer!
    private var pulsatingLayer: CAShapeLayer!
    private var trackLayer: CAShapeLayer!
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    private let finishLabel: UILabel = {
        let label = UILabel()
        label.text = "Finished"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return label
    }()
    
    private let BLEconnect_btn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "Start_off"), for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupNotificationObservers()
        setupCircleLayers()
        setupPercentageLabel()
        titleViewSetting()
        addBLEButton()
        
        tempTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in self.animationCountDown()}
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnterForeground), name: .NSExtensionHostWillEnterForeground, object: nil)
    }
    
    @objc private func handleEnterForeground() {
        animatePulsatingLayer()
    }
    
    private func addBLEButton() {
        BLEconnect_btn.frame = CGRect(x: 0, y: 0, width: self.view.frame.width * 0.36, height: self.view.frame.width * 0.12)
        BLEconnect_btn.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.maxY * 0.85)
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 0
        BLEconnect_btn.addGestureRecognizer(tap)
        BLEconnect_btn.isUserInteractionEnabled = false
        BLEconnect_btn.alpha = 0
        
        self.view.addSubview(BLEconnect_btn)
    }
    
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .began:
            BLEconnect_btn.setImage(UIImage(named: "Start_on"), for: .normal)
        case .ended:
            BLEconnect_btn.setImage(UIImage(named: "Start_off"), for: .normal)
            performSegue(withIdentifier: "GoToBleConnect", sender: self)
        default:
            print("BLEconnect_btn does not be tapped!!!!")
        }
    }
    
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.position = view.center
        return layer
    }
    
    private func setupPercentageLabel() {
        view.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
    }
    
    private func setupCircleLayers() {
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: UIColor.pulsatingFillColor)
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
        
        trackLayer = createCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        view.layer.addSublayer(trackLayer)
        
        shapeLayer = createCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.4
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    private func titleViewSetting() {
        let gradientView = UIView()
        gradientView.frame = CGRect(x: 0, y: self.view.frame.height  * 0.125, width: self.view.frame.width, height: self.view.frame.height * 0.1)
        let gradient = CAGradientLayer()
        
        gradient.colors = [UIColor.LabelgradientUpperColor.cgColor, UIColor.LabelgradientLowerColor.cgColor]
        
        gradient.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradient)
        self.view.addSubview(gradientView)
        
        let label = UILabel(frame: gradientView.bounds)
        label.text = "Bartender"
        label.font = UIFont(name: "TimeBurner", size: 56.0)
         
        label.textAlignment = .center
        gradientView.addSubview(label)
        gradientView.mask = label
    }
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    private func handleTap() {
        tempTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { (timer) in self.animationCountDown()}
    }
    
    @objc private func animationCountDown() {
        percentageLabel.text = "\(TimerCount)"
        if TimerCount < 100 {
            TimerCount += 1
            percentageLabel.isUserInteractionEnabled = false
            shapeLayer.strokeEnd = CGFloat(TimerCount) / CGFloat(100)
        } else {
            tempTimer.invalidate()
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.5,
                delay: 0,
                options: [],
                animations: {
                    self.percentageLabel.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY - 10)
                    self.percentageLabel.font = UIFont.systemFont(ofSize: 36)
                },
                completion: { position in
                    self.view.addSubview(self.finishLabel)
                    self.finishLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 25)
                    self.finishLabel.center = CGPoint(x: self.view.frame.midX, y: self.percentageLabel.frame.midY + 30)
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.8,
                        delay: 0,
                        options: [],
                        animations: {
                            self.BLEconnect_btn.alpha = 1
                            self.BLEconnect_btn.isUserInteractionEnabled = true
                        },
                        completion: nil)
            })
        }
    }
}

extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let backgroundColor = UIColor.rgb(r: 21, g: 22, b: 33)
    static let LabelgradientUpperColor = UIColor.rgb(r: 0, g: 249, b: 0)
    static let LabelgradientLowerColor = UIColor.rgb(r: 0, g: 118, b: 186)
    static let outlineStrokeColor = UIColor.rgb(r: 48, g: 228, b: 71)
    static let trackStrokeColor = UIColor.rgb(r: 56, g: 25, b: 49)
    static let pulsatingFillColor = UIColor.rgb(r: 88, g: 142, b: 106)
}
