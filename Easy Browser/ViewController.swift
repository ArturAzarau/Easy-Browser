//
//  ViewController.swift
//  Easy Browser
//
//  Created by Артур Азаров on 24.06.2018.
//  Copyright © 2018 Артур Азаров. All rights reserved.
//

import WebKit

final class WebViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var webView: WKWebView! {
        didSet {
            webView.allowsBackForwardNavigationGestures = true
        }
    }
    
    private var progressView: UIProgressView!
    private var websites = ["apple.com", "hackingwithswift.com"]
    
    // MARK: - Object life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.navigationDelegate = self
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        toolbarItems = [progressButton,spacer,refresh]
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    // MARK: - Actions
    
    @IBAction func openWebsite(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        _ = websites.map { ac.addAction(UIAlertAction(title: $0, style: .default, handler: openPage)) }
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    // MARK: - Helpers
    
    private func openPage(action: UIAlertAction) {
        let url = URL(string: "https://" + action.title!)!
        webView.load(URLRequest(url: url))
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, let host = url.host else { return }
        for website in websites {
            if host.range(of: website) != nil {
                decisionHandler(.allow)
                return
            }
        }
        decisionHandler(.cancel)
    }
}
