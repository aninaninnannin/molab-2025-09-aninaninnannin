import UIKit
import PlaygroundSupport

let size: CGFloat = 1024

let canvas = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
canvas.backgroundColor = .black

if let bgImage = UIImage(named: "week2.png") {
    let bgView = UIImageView(image: bgImage)
    bgView.frame = canvas.bounds
    bgView.contentMode = .scaleAspectFill
    bgView.clipsToBounds = true
    canvas.addSubview(bgView)
}

for _ in 0..<10 {
    guard let icon = UIImage(named: "week21.png") else { continue }
    let w: CGFloat = 64
    let h = w * (icon.size.height / icon.size.width)
    let x = CGFloat.random(in: 0...(size - w))
    let y = CGFloat.random(in: 0...(size - h))
    
    let iv = UIImageView(image: icon)
    iv.frame = CGRect(x: x, y: y, width: w, height: h)
    iv.contentMode = .scaleAspectFit
    
    iv.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -10...10) * .pi/180)
    iv.layer.shadowColor = UIColor.black.cgColor
    iv.layer.shadowOpacity = 0.25
    iv.layer.shadowRadius = 4
    iv.layer.shadowOffset = CGSize(width: 0, height: 2)
    
    canvas.addSubview(iv)
}

PlaygroundPage.current.liveView = canvas
