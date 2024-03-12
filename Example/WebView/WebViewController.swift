//
//  WebViewController.swift
//  BlankSlate_Example
//
//  Created by Liam on 2021/12/19.
//  Copyright © 2021 Liam. All rights reserved.
//

import UIKit
import WebKit
import BlankSlate
import FlyHUD

class WebViewController: UIViewController, BlankSlateDataSource, BlankSlateDelegate {
    private var webView: WKWebView = WKWebView(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(webView, at: 0)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bs.setDataSourceAndDelegate(self)
    }

    @IBAction func errorButtonClicked(_ sender: Any) {
        HUD.show(to: view, using: .animation(.zoomInOut, damping: .default, duration: 0.3)) {
            $0.minShowTime = 0.5
        }
        webView.load(URLRequest(url: URL(string: "https://error.test/")!))
    }

    @IBAction func successButtonClicked(_ sender: Any) {
        HUD.show(to: view, using: .animation(.zoomInOut, damping: .default, duration: 0.3)) {
            $0.minShowTime = 0.5
        }
        webView.load(URLRequest(url: URL(string: "https://www.baidu.com/")!))
    }

    func image(forBlankSlate scrollView: UIScrollView) -> UIImage? {
        UIImage(named: "icon_appstore")
    }

    func blankSlateShouldBeInsertAtIndex(_ scrollView: UIScrollView) -> Int {
        -1
    }

    func elementLayout(forBlankSlate scrollView: UIScrollView, for element: BlankSlate.Element) -> BlankSlate.Layout {
        .init(edgeInsets: .init(top: 11, left: 16, bottom: 11, right: 16), height: 500)
    }
}

// MARK: WKScriptMessageHandler
extension WebViewController: WKUIDelegate, WKNavigationDelegate {

    /// 开始加载时调用
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    /// 当内容开始返回时调用
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.scrollView.bs.dismiss()
    }

    /// 页面加载完成之后调用
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.bs.dismiss()
        HUD.hide(for: view)
    }

    /// 页面加载失败时调用
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.bs.dataLoadStatus = .failure
        HUD.hide(for: view)
    }

    /// 在发送请求之前，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
