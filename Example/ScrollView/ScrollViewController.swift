//
//  ScrollViewController.swift
//  Example iOS
//
//  Created by liam on 2024/3/13.
//  Copyright © 2024 Liam. All rights reserved.
//

import UIKit
import BlankSlate

class ScrollViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    private var colors: [Color] = Palette.shared.colors[0..<5].shuffled()

    @IBAction func remove(_ sender: UIBarButtonItem) {
        colors.removeAll()
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.contentSize = .zero
        scrollView.bs.reload()
    }

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        let i = Int.random(in: 5..<Palette.shared.colors.count)
        colors = Palette.shared.colors[i-5..<i].shuffled()
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        refresh()
        scrollView.bs.reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        scrollView.bs.setDataSourceAndDelegate(self)
        refresh()
    }

    private func refresh() {
        var constraints: [NSLayoutConstraint] = []
        var previous: UIView?
        colors.enumerated().forEach {
            let label = UILabel()
            label.backgroundColor = $0.element.color ?? .red
            label.text = "\($0.offset)\n\($0.element.name)\n\($0.element.hex)\n\($0.element.rgb)"
            label.numberOfLines = 0
            label.textAlignment = .center
            scrollView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(contentsOf: [
                label.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                label.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                label.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            ])
            if let previous { // Previous view
                constraints.append(label.leadingAnchor.constraint(equalTo: previous.trailingAnchor))
            } else { // First view
                constraints.append(label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor))
            }
            previous = label // Save previous view
        }
        if let previous { // Last view
            constraints.append(previous.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor))
        }
        NSLayoutConstraint.activate(constraints)
    }
}

extension ScrollViewController: BlankSlate.DataSource, BlankSlate.Delegate {
    func title(forBlankSlate view: UIView) -> NSAttributedString? {
        let text = "No colors loaded"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 17.0),
            .foregroundColor: UIColor(red: 170 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1.0),
            .paragraphStyle: paragraphStyle
        ])
    }

    func detail(forBlankSlate view: UIView) -> NSAttributedString? {
        let text = "To show a list of random colors, tap on the refresh icon in the right top corner.\n\nTo clean the list, tap on the trash icon."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        return NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 15.0),
            .foregroundColor: UIColor(red: 170 / 255.0, green: 171 / 255.0, blue: 179 / 255.0, alpha: 1.0),
            .paragraphStyle: paragraphStyle
        ])
    }

    func image(forBlankSlate view: UIView) -> UIImage? {
        UIImage(named: "empty_placeholder")
    }

    func blankSlateShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        true
    }

    func blankSlate(_ view: UIView, didTapView sender: UIView) {
        print(#function)
    }
}
