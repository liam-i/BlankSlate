//
//  Color.swift
//  Example iOS
//
//  Created by liam on 2024/3/11.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit

struct Color: Equatable {
    let hex, name, rgb: String

    var color: UIColor? { UIColor(hex: hex) }

    init(dict: [String: String]) {
        hex = dict["hex"]!
        name = dict["name"]!
        rgb = dict["rgb"]!
    }

    static func roundThumb(with color: UIColor?) -> UIImage? {
        roundImage(for: CGSize(width: 32.0, height: 32.0), with: color)
    }

    static func roundImage(for size: CGSize, with color: UIColor?) -> UIImage? {
        guard let color = color else { return nil }

        let bounds = CGRect(origin: .zero, size: size)

        // Create the image context
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        // Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: bounds)
        color.setFill()
        ovalPath.fill()
        // Create the image using the current context.
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
}
