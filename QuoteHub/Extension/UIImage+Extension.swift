//
//  ImageResize.swift
//  QuoteHub
//
//  Created by 이융의 on 6/17/25.
//

import UIKit

extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let aspectSize = CGSize(width: width, height: aspectRatio * width)
        UIGraphicsBeginImageContext(aspectSize)
        draw(in: CGRect(origin: .zero, size: aspectSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    var aspectRatio: CGFloat {
        return size.height / size.width
    }
}
