//
//  Palette.swift
//  Example iOS
//
//  Created by liam on 2024/3/11.
//  Copyright © 2024 Liam. All rights reserved.
//

import Foundation

class Palette {
    static let shared = Palette()

    private(set) var colors: [Color] = []

    private init() {
        loadColors()
    }

    private func loadColors() {
        // A list of crayola colors in JSON by Jjdelc https://gist.github.com/jjdelc/1868136
        let url = Bundle.main.url(forResource: "colors", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let array = json as? [[String: String]] else { fatalError() }
            colors = array.map { Color(dict: $0) }
        } catch {
            fatalError("\(error)")
        }
    }

    func reloadAll() {
        removeAll()
        loadColors()
    }

    func remove(at color: Color) {
        colors.removeAll { $0 == color }
    }

    func removeAll() {
        colors.removeAll()
    }
}
