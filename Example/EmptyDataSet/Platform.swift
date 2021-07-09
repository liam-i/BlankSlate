//
//  Platform.swift
//  EmptyDataSet
//
//  Created by pengli on 2020/2/10.
//  Copyright © 2020 pengli. All rights reserved.
//

import Foundation

struct Platform {
    var displayName: String { return type.rawValue }
    let developerName: String
    let identifier: String
    let iconName: String
    let type: DisplayName
        
    static func applicationsFromJSON(at fileURL: URL) -> [Platform] {
        do {
            let data = try Data(contentsOf: fileURL)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let array = json as? [[String: Any]] else { fatalError() }
            return array.map { Platform(with: $0) }
        } catch {
            fatalError("\(error)")
        }
    }
    
    init(with dict: [String: Any]) {
        type = DisplayName(rawValue: dict["display_name"] as! String)!
        developerName = dict["developer_name"] as! String
        identifier = dict["identifier"] as! String
        iconName = "icon_\(type.rawValue)".lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    enum DisplayName: String {
        case px500 = "500px"
        case airbnb = "Airbnb"
        case appstore = "AppStore"
        case camera = "Camera"
        case dropbox = "Dropbox"
        case facebook = "Facebook"
        case fancy = "Fancy"
        case foursquare = "Foursquare"
        case iCloud = "iCloud"
        case instagram = "Instagram"
        case iTunesConnect = "iTunes Connect"
        case kickstarter = "Kickstarter"
        case path = "Path"
        case pinterest = "Pinterest"
        case photos = "Photos"
        case podcasts = "Podcasts"
        case remote = "Remote"
        case safari = "Safari"
        case skype = "Skype"
        case slack = "Slack"
        case tumblr = "Tumblr"
        case twitter = "Twitter"
        case videos = "Videos"
        case vesper = "Vesper"
        case vine = "Vine"
        case whatsapp = "WhatsApp"
        case wwdc = "WWDC"
    }
}
