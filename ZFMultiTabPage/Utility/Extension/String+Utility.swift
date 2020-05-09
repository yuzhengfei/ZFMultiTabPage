//
//  String+Utility.swift
//  ZFMultiTabPage
//
//  Created by Flying on 2020/5/9.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation

extension String {
    
    func strWidth(font: UIFont, size: CGSize) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: size.width, height: size.height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
}
