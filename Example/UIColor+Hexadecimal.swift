//
//  UIColor+Hexadecimal.swift
//  EmptyDataSet
//
//  Created by Liam on 2020/2/10.
//  Copyright © 2020 Liam. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var cleanString = hex.replacingOccurrences(of: "#", with: "")
        if cleanString.count == 3 {
            let idx_0 = cleanString.startIndex
            let idx_1 = cleanString.index(cleanString.startIndex, offsetBy: 1)
            let idx_2 = cleanString.index(idx_1, offsetBy: 1)
            let idx_3 = cleanString.index(idx_2, offsetBy: 1)
            
            let char_1 = String(cleanString[idx_0..<idx_1])
            let char_2 = String(cleanString[idx_1..<idx_2])
            let char_3 = String(cleanString[idx_2..<idx_3])
            cleanString = String(format: "%@%@%@%@%@%@", char_1, char_1, char_2, char_2, char_3, char_3)
        }
        if cleanString.count == 6{
            cleanString += "ff"
        }
        
        var baseValue: UInt32 = 0
        guard Scanner(string: cleanString).scanHexInt32(&baseValue) else { return nil }
        
        let red = CGFloat((baseValue >> 24) & 0xFF) / 255.0
        let green = CGFloat((baseValue >> 16) & 0xFF) / 255.0
        let blue = CGFloat((baseValue >> 8) & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
