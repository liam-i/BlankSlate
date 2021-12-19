//
//  WebViewController.swift
//  EmptyDataSet_Example
//
//  Created by Liam on 2021/12/19.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import LPEmptyDataSet

class WebViewController: UIViewController, EmptyDataSetDataSource, EmptyDataSetDelegate {
    private var webView: WKWebView = WKWebView(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(webView, at: 0)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.emptyDataSetSource = self
        webView.scrollView.emptyDataSetDelegate = self
    }

    @IBAction func errorButtonClicked(_ sender: Any) {
        webView.load(URLRequest(url: URL(string: "https://www.baiduerror.com/")!))
    }
    
    @IBAction func successButtonClicked(_ sender: Any) {
        webView.load(URLRequest(url: URL(string: "https://www.baidu.com/")!))
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "icon_appstore")
    }

    func emptyDataSetShouldBeInsertAtIndex(_ scrollView: UIScrollView) -> Int {
        return -1
    }
}

// MARK: WKScriptMessageHandler
extension WebViewController: WKUIDelegate, WKNavigationDelegate {

    /// 开始加载时调用
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    /// 当内容开始返回时调用
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        webView.scrollView.invalidate()
    }

    /// 页面加载完成之后调用
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.invalidate()
    }

    /// 页面加载失败时调用
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.reloadAllData(with: .error)
    }

    /// 在发送请求之前，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}
