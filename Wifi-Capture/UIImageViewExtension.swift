//
//  UIImageViewExtension.swift
//  Wifi-Capture
//
//  Created by 김상우 on 2022/01/26.
//

import Foundation
import UIKit

extension UIImageView {
    func drawRect(imageView: UIImageView) {
        print("빨간 사각형을 그립니다...")
        UIGraphicsBeginImageContext(imageView.frame.size)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        ctx.setLineWidth(2.0)
        ctx.setStrokeColor(UIColor.red.cgColor)
        // (50,100) 위치에서 가로 200, 세로 200 크기의 사각형 추가
        ctx.addRect(CGRect(x: 50, y: 100, width: 200, height: 200))
        ctx.strokePath()
        
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        
    }
}
