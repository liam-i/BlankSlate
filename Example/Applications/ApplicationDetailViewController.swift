//
//  ApplicationDetailViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/11.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class ApplicationDetailViewController: UITableViewController {
    deinit {
        #if DEBUG
        print("👍🏻👍🏻👍🏻 ApplicationDetailViewController is released.")
        #endif
    }

    private var application: Application
    private let applications: [Application]
    private var randomApplication: Application { applications[.random(in: 0..<applications.count)] }
    private var isLoading: Bool = false { didSet { if isLoading != oldValue { tableView.bs.reload() } } }

    init(with application: Application, applications: [Application]) {
        self.application = application
        self.applications = applications
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = application.displayName

//        edgesForExtendedLayout = []

        tableView.bs.setDataSourceAndDelegate(self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(shuffle))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        configureHeaderAndFooter()
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
            switch application.type {
            case .px500, .camera, .facebook, .fancy, .foursquare, .instagram, .path, .skype, .tumblr, .twitter, .vesper, .vine:
                return .lightContent
            default:
                return .default
            }
    }

    @objc private func shuffle(_ sender: UIBarButtonItem) {
        var random = randomApplication

        while random.identifier == application.identifier {
            random = randomApplication
        }

        application = random

        configureHeaderAndFooter()
        configureNavigationBar()

        tableView.bs.reload()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.titleTextAttributes = nil

        var barColor: UIColor? = nil
        var tintColor: UIColor? = nil
        switch application.type {
            case .px500:
                barColor = UIColor(hex: "242424")
                tintColor = UIColor(hex: "d7d7d7")
            case .airbnb:
                barColor = UIColor(hex: "f8f8f8")
                tintColor = UIColor(hex: "08aeff")
            case .camera:
                barColor = UIColor(hex: "595959")
                tintColor = UIColor.white
                navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            case .dropbox:
                barColor = UIColor.white
                tintColor = UIColor(hex: "007ee5")
            case .facebook:
                barColor = UIColor(hex: "506da8")
                tintColor = UIColor.white
            case .fancy:
                barColor = UIColor(hex: "353b49")
                tintColor = UIColor(hex: "c4c7cb")
            case .foursquare:
                barColor = UIColor(hex: "00aeef")
                tintColor = UIColor.white
            case .instagram:
                barColor = UIColor(hex: "2e5e86")
                tintColor = UIColor.white
            case .kickstarter:
                barColor = UIColor(hex: "f7f8f8")
                tintColor = UIColor(hex: "2bde73")
            case .path:
                barColor = UIColor(hex: "544f49")
                tintColor = UIColor(hex: "fffff2")
            case .pinterest:
                barColor = UIColor(hex: "f4f4f4")
                tintColor = UIColor(hex: "cb2027")
            case .slack:
                barColor = UIColor(hex: "f4f5f6")
                tintColor = UIColor(hex: "3eba92")
            case .skype:
                barColor = UIColor(hex: "00aff0")
                tintColor = UIColor.white
            case .tumblr:
                barColor = UIColor(hex: "2e3e53")
                tintColor = UIColor.white
            case .twitter:
                barColor = UIColor(hex: "58aef0")
                tintColor = UIColor.white
            case .vesper:
                barColor = UIColor(hex: "5e7d9a")
                tintColor = UIColor(hex: "f8f8f8")
            case .videos:
                barColor = UIColor(hex: "4a4b4d")
                tintColor = UIColor.black
            case .vine:
                barColor = UIColor(hex: "00bf8f")
                tintColor = UIColor.white
            case .wwdc:
                tintColor = UIColor(hex: "fc6246")
            default:
                barColor = UIColor(hex: "f8f8f8")
                tintColor = UIApplication.shared.keyWindow?.tintColor
        }

        if let logo = UIImage(named: "logo_\(application.displayName.lowercased())") {
            navigationItem.titleView = UIImageView(image: logo)
        } else {
            navigationItem.titleView = nil
            navigationItem.title = application.displayName
        }

        navigationController?.navigationBar.barTintColor = barColor
        navigationController?.navigationBar.tintColor = tintColor
    }

    private func configureHeaderAndFooter() {
        var imageName: String? = nil

        if application.type == .pinterest {
            imageName = "header_pinterest"
        }
        if application.type == .podcasts {
            imageName = "header_podcasts"
        }

        if let imageName {
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image)
            imageView.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapHeaderView))
            imageView.addGestureRecognizer(tapGesture)

            var frame = view.bounds
            if let image {
                frame.size.height = image.size.height
            }
            let headerView = UIView(frame: frame)
            headerView.backgroundColor = UIColor.white

            imageView.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)

            headerView.addSubview(imageView)
            tableView.tableHeaderView = headerView
        } else {
            tableView.tableHeaderView = UIView()
        }

        tableView.tableFooterView = UIView()
    }

    @objc private func didTapHeaderView(_ sender: UITapGestureRecognizer) {
        print(#function)
    }
}

extension ApplicationDetailViewController: BlankSlateDataSource, BlankSlateDelegate {
    func title(forBlankSlate view: UIView) -> NSAttributedString? {
        var text: String
        var font: UIFont?
        var textColor: UIColor? = nil
        var attributes: [NSAttributedString.Key: Any] = [:]

        switch application.type {
        case .px500:
            text = "No Photos"
            font = UIFont.boldSystemFont(ofSize: 17.0)
            textColor = UIColor(hex: "545454")
        case .airbnb:
            text = "No Messages"
            font = UIFont(name: "HelveticaNeue-Light", size: 22.0)
            textColor = UIColor(hex: "c9c9c9")
        case .camera:
            text = "Please Allow Photo Access"
            font = UIFont.boldSystemFont(ofSize: 18.0)
            textColor = UIColor(hex: "5f6978")
        case .dropbox:
            text = "Star Your Favorite Files"
            font = UIFont.boldSystemFont(ofSize: 17.0)
            textColor = UIColor(hex: "25282b")
        case .facebook:
            text = "No friends to show."
            font = UIFont.boldSystemFont(ofSize: 22.0)
            textColor = UIColor(hex: "acafbd")

            let shadow = NSShadow()
            shadow.shadowColor = UIColor.white
            shadow.shadowOffset = CGSize(width: 0.0, height: 1.0)
            attributes[.shadow] = shadow
        case .fancy:
            text = "No Owns yet"
            font = UIFont.boldSystemFont(ofSize: 14.0)
            textColor = UIColor(hex: "494c53")
        case .iCloud:
            text = "iCloud Photo Sharing"
        case .instagram:
            text = "Instagram Direct"
            font = UIFont(name: "HelveticaNeue-Light", size: 26.0)
            textColor = UIColor(hex: "444444")
        case .iTunesConnect:
            text = "No Favorites"
            font = UIFont.systemFont(ofSize: 22.0)
        case .kickstarter:
            text = "Activity empty"
            font = UIFont.boldSystemFont(ofSize: 16.0)
            textColor = UIColor(hex: "828587")
            attributes[.kern] = -0.10
        case .path:
            text = "Message Your Friends"
            font = UIFont.boldSystemFont(ofSize: 14.0)
            textColor = UIColor.white
        case .pinterest:
            text = "No boards to display"
            font = UIFont.boldSystemFont(ofSize: 18.0)
            textColor = UIColor(hex: "666666")
        case .photos:
            text = "No Photos or Videos"
        case .podcasts:
            text = "No Podcasts"
        case .remote:
            text = "Cannot Connect to a Local Network"
            font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
            textColor = UIColor(hex: "555555")
        case .tumblr:
            text = "This is your Dashboard."
            font = UIFont.boldSystemFont(ofSize: 18.0)
            textColor = UIColor(hex: "aab6c4")
        case .twitter:
            text = "No lists"
            font = UIFont.boldSystemFont(ofSize: 14.0)
            textColor = UIColor(hex: "292f33")
        case .vesper:
            text = "No Notes"
            font = UIFont(name: "IdealSans-Book-Pro", size: 16.0)
            textColor = UIColor(hex: "d9dce1")
        case .videos:
            text = "AirPlay"
            font = UIFont.systemFont(ofSize: 17.0)
            textColor = UIColor(hex: "414141")
        case .vine:
            text = "Welcome to VMs"
            font = UIFont.boldSystemFont(ofSize: 22.0)
            textColor = UIColor(hex: "595959")
            attributes[.kern] = 0.45
        case .whatsapp:
            text = "No Media"
            font = UIFont.systemFont(ofSize: 20.0)
            textColor = UIColor(hex: "808080")
        case .wwdc:
            text = "No Favorites"
            font = UIFont(name: "HelveticaNeue-Medium", size: 16.0)
            textColor = UIColor(hex: "b9b9b9")
        default:
            return nil
        }

        if let font { attributes[.font] = font }
        if let textColor { attributes[.foregroundColor] = textColor }
        return NSAttributedString(string: text, attributes: attributes)
    }

    func detail(forBlankSlate view: UIView) -> NSAttributedString? {
        var text: String
        var font: UIFont?
        var textColor: UIColor?

        var attributes: [NSAttributedString.Key: Any] = [:]

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center

        switch application.type {
        case .px500:
            text = "Get started by uploading a photo."
            font = UIFont.boldSystemFont(ofSize: 15.0)
            textColor = UIColor(hex: "545454")
        case .airbnb:
            text = "When you have messages, you’ll see them here."
            font = UIFont.systemFont(ofSize: 13.0)
            textColor = UIColor(hex: "cfcfcf")
            paragraph.lineSpacing = 4.0
        case .appstore:
            text = "There are no results for “wwdc2014”."
            font = UIFont.systemFont(ofSize: 14.0)
            textColor = UIColor(hex: "333333")
        case .camera:
            text = "This allows you to share photos from your library and save photos to your camera roll."
            font = UIFont.systemFont(ofSize: 14.0)
            textColor = UIColor(hex: "5f6978")
        case .dropbox:
            text = "Favorites are saved for offline access."
            font = UIFont.systemFont(ofSize: 14.5)
            textColor = UIColor(hex: "7b8994")
        case .fancy:
            text = "Tap Add to List and add things to Owns"
            font = UIFont.systemFont(ofSize: 13.0)
            textColor = UIColor(hex: "7a7d83")
        case .foursquare:
            text = "Nobody has liked or commented on your check-ins yet."
            font = UIFont.boldSystemFont(ofSize: 14.0)
            textColor = UIColor(hex: "cecbc6")
        case .iCloud:
            text = "Share photos and videos with just the people you choose, and let them add photos, videos, and comments."
            paragraph.lineSpacing = 2.0
        case .instagram:
            text = "Send photos and videos directly to your friends. Only the people you send to can see these posts."
            font = UIFont.systemFont(ofSize: 16.0)
            textColor = UIColor(hex: "444444")
            paragraph.lineSpacing = 4.0
        case .iTunesConnect:
            text = "To add a favorite, tap the star icon next to an App's name."
            font = UIFont.systemFont(ofSize: 14.0)
        case .kickstarter:
            text = "When you back a project or follow a friend, their activity will show up here."
            font = UIFont.systemFont(ofSize: 14.0)
            textColor = UIColor(hex: "828587")
        case .path:
            text = "Send a message or create a group."
            font = UIFont.systemFont(ofSize: 14.0)
            textColor = UIColor(hex: "a6978d")
        case .photos:
            text = "You can sync photos and videos onto your iPhone using iTunes."
        case .podcasts:
            text = "You can subscribe to podcasts in Top Charts or Featured."
        case .remote:
            text = "You must connect to a Wi-Fi network to control iTunes or Apple TV"
            font = UIFont(name: "HelveticaNeue-Medium", size: 11.75)
            textColor = UIColor(hex: "555555")
        case .safari:
            text = "Safari cannot open the page because your iPhone is not connected to the Internet."
            textColor = UIColor(hex: "7d7f7f")
            paragraph.lineSpacing = 2.0
        case .skype:
            text = "Keep all your favorite people together, add favorites."
            font = UIFont(name: "HelveticaNeue-Light", size: 17.75)
            textColor = UIColor(hex: "a6c3d1")
            paragraph.lineSpacing = 3.0
        case .slack:
            text = "You don't have any recent mentions"
            font = UIFont(name: "Lato-Regular", size: 19.0)
            textColor = UIColor(hex: "d7d7d7")
        case .tumblr:
            text = "When you follow some blogs, their latest posts will show up here!"
            font = UIFont.systemFont(ofSize: 17.0)
            textColor = UIColor(hex: "828e9c")
        case .twitter:
            text = "You aren’t subscribed to any lists yet."
            font = UIFont.systemFont(ofSize: 12.0)
            textColor = UIColor(hex: "8899a6")
        case .videos:
            text = "This video is playing on “Apple TV”."
            font = UIFont.systemFont(ofSize: 12.0)
            textColor = UIColor(hex: "737373")
        case .vine:
            text = "This is where your private conversations will live"
            font = UIFont.systemFont(ofSize: 17.0)
            textColor = UIColor(hex: "a6a6a6")
        case .whatsapp:
            text = "You can exchange media with Ignacio by tapping on the Arrow Up icon in the conversation screen."
            font = UIFont.systemFont(ofSize: 15.0)
            textColor = UIColor(hex: "989898")
        case .wwdc:
            text = "Favorites are only available to Registered Apple Developers."
            font = UIFont.systemFont(ofSize: 16.0)
            textColor = UIColor(hex: "b9b9b9")
        default:
            return nil
        }

        if let font {
            attributes[.font] = font
        }
        if let textColor {
            attributes[.foregroundColor] = textColor
        }
        attributes[.paragraphStyle] = paragraph

        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        if application.type == .skype
            , let color = UIColor(hex: "00adf1")
            , let range = attributedString.string.range(of: "add favorites") {
            let loc = range.lowerBound.utf16Offset(in: attributedString.string)
            let len = range.upperBound.utf16Offset(in: attributedString.string) - loc
            attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: loc, length: len))
        }
        return attributedString
    }

    func image(forBlankSlate view: UIView) -> UIImage? {
        if isLoading {
            return UIImage(named: "loading_imgBlue_78x78")
        }
        let imageName = "placeholder_\(application.displayName)".lowercased().replacingOccurrences(of: " ", with: "_")
        return UIImage(named: imageName)
    }

    func imageAnimation(forBlankSlate view: UIView) -> CAAnimation? {
        guard isLoading else { return nil }

        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat.pi / 2.0, 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.isCumulative = true
        animation.repeatCount = MAXFLOAT
        return animation
    }

    func buttonTitle(forBlankSlate view: UIView, for state: UIControl.State) -> NSAttributedString? {
        var text: String
        var font: UIFont?
        var textColor: UIColor?

        switch application.type {
        case .airbnb:
            text = "Start Browsing"
            font = UIFont.boldSystemFont(ofSize: 16.0)
            textColor = UIColor(hex: state == .normal ? "05adff" : "6bceff")
        case .camera:
            text = "Continue"
            font = UIFont.boldSystemFont(ofSize: 17.0)
            textColor = UIColor(hex: state == .normal ? "007ee5" : "48a1ea")
        case .dropbox:
            text = "Learn more"
            font = UIFont.systemFont(ofSize: 15.0)
            textColor = UIColor(hex: state == .normal ? "007ee5" : "48a1ea")
        case .foursquare:
            text = "Add friends to get started!"
            font = UIFont.boldSystemFont(ofSize: 14.0)
            textColor = UIColor(hex: state == .normal ? "00aeef" : "ffffff")
        case .iCloud:
            text = "Create New Stream"
            font = UIFont.systemFont(ofSize: 14.0)
            textColor = UIColor(hex: state == .normal ? "999999" : "ebebeb")
        case .kickstarter:
            text = "Discover projects"
            font = UIFont.boldSystemFont(ofSize: 14.0)
            textColor = UIColor.white
        case .wwdc:
            text = "Sign In"
            font = UIFont.systemFont(ofSize: 16.0)
            textColor = UIColor(hex: state == .normal ? "fc6246" : "fdbbb2")
        default:
            return nil
        }

        var attributes: [NSAttributedString.Key: Any] = [:]
        if let font { attributes[.font] = font }
        if let textColor { attributes[.foregroundColor] = textColor }
        return NSAttributedString(string: text, attributes: attributes)
    }

    func blankSlate(_ view: UIView, configure button: UIButton) {
        var capInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        var rectInsets = UIEdgeInsets.zero
        switch application.type {
        case .foursquare:
            capInsets = UIEdgeInsets(top: 25.0, left: 25.0, bottom: 25.0, right: 25.0)
            rectInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        case .iCloud:
            rectInsets = UIEdgeInsets(top: -19.0, left: -61.0, bottom: -19.0, right: -61.0)
        case .kickstarter:
            capInsets = UIEdgeInsets(top: 22.0, left: 22.0, bottom: 22.0, right: 22.0)
            rectInsets = UIEdgeInsets(top: 0.0, left: -20.0, bottom: 0.0, right: -20.0)
        default:
            break
        }

        func image(for state: UIControl.State) -> UIImage? {
            var imageName = "button_background_\(application.displayName)".lowercased()
            if state == .normal {
                imageName += "_normal"
            }
            if state == .highlighted {
                imageName += "_highlight"
            }
            let image = UIImage(named: imageName)
            return image?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch).withAlignmentRectInsets(rectInsets)
        }
        button.setBackgroundImage(image(for: .normal), for: .normal)
        button.setBackgroundImage(image(for: .highlighted), for: .highlighted)
    }

    func backgroundColor(forBlankSlate view: UIView) -> UIColor? {
        switch application.type {
        case .px500:      return UIColor.black
        case .airbnb:     return UIColor.white
        case .dropbox:    return UIColor(hex: "f0f3f5")
        case .facebook:   return UIColor(hex: "eceef7")
        case .fancy:      return UIColor(hex: "f0f0f0")
        case .foursquare: return UIColor(hex: "fcfcfa")
        case .instagram:  return UIColor.white
        case .kickstarter:return UIColor(hex: "f7fafa")
        case .path:       return UIColor(hex: "726d67")
        case .pinterest:  return UIColor(hex: "e1e1e1")
        case .slack:      return UIColor.white
        case .tumblr:     return UIColor(hex: "34465c")
        case .twitter:    return UIColor(hex: "f5f8fa")
        case .vesper:     return UIColor(hex: "f8f8f8")
        case .videos:     return UIColor.black
        case .whatsapp:   return UIColor(hex: "f2f2f2")
        default:          return nil
        }
    }

    func alignment(forBlankSlate view: UIView) -> BlankSlate.Alignment {
        if application.type == .kickstarter {
            return .top(.offset(y: 10))
        }
        if application.type == .twitter {
            return .bottom(.offset(y: 20))
        }
        return .center()
    }

    func blankSlateShouldDisplay(_ view: UIView) -> Bool {
        return true
    }

    func blankSlateShouldAllowTouch(_ view: UIView) -> Bool {
        return true
    }

    func blankSlateShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func blankSlate(_ view: UIView, didTapView sender: UIView) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isLoading = false
        }
    }

    func blankSlate(_ view: UIView, didTapButton sender: UIButton) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isLoading = false
        }
    }
}
