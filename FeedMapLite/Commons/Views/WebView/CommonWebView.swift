//
//  CommonWebView.swift
//  FeedMapLite
//
//  Created by 신이삭 on 8/26/24.
//

import Foundation
import SwiftUI
import WebKit
import Combine
import ComposableArchitecture

final class RefreshControlHelper: NSObject {
 
    var refreshCTL: UIRefreshControl?
    var webView: WKWebView?
    
    @objc func didRefresh() {
        guard let refreshCTL = self.refreshCTL else { return }
        
        Task { @MainActor in
            webView?.endEditing(true)
            try await Task.sleep(nanoseconds:UInt64(1.0 * Double(NSEC_PER_SEC)))
            refreshCTL.endRefreshing()
            webView?.reload()
        }
    }
}

struct CommonWebView: UIViewRepresentable {
    var store: StoreOf<WebViewFeature>
    var rfcHelper = RefreshControlHelper()
    var urlStr: String
    
    func makeCoordinator() -> CommonWebView.Coordinator {
        return CommonWebView.Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.urlStr) else { return WKWebView() }
        let webV = WKWebView(frame: .zero, configuration: self.createWebConfig())
        webV.navigationDelegate = context.coordinator
        webV.allowsBackForwardNavigationGestures = true
        webV.tintColor = .systemBlue
        if #available(iOS 16.4, *) {
            webV.isInspectable = true
        }
        
        let rfc = UIRefreshControl()
        rfc.tintColor = .lightGray
        webV.scrollView.bounces = true
        webV.scrollView.refreshControl = rfc
        
        rfcHelper.refreshCTL = rfc
        rfcHelper.webView = webV
        
        rfc.addTarget(rfcHelper, action: #selector(RefreshControlHelper.didRefresh), for: .valueChanged)
        
        webV.load(URLRequest(url: url))
        
        return webV
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<CommonWebView>) {
        
    }

    func createWebConfig() -> WKWebViewConfiguration {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let wkWebConfig = WKWebViewConfiguration()
        
        let userContentController = WKUserContentController()
        userContentController.add(self.makeCoordinator(), name: "W2A")
        wkWebConfig.userContentController = userContentController
        wkWebConfig.preferences = preferences
        
        return wkWebConfig
    }
    
    class Coordinator: NSObject {
        var webV: CommonWebView
        var subscriptions = Set<AnyCancellable>()

        init(_ webV: CommonWebView) {
            self.webV = webV
        }
    }
}

extension CommonWebView.Coordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webV
            .store
            .send(.showIndicator(isShowIndicator: true))
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        switch url.scheme {
        case "tel", "mailto":
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        default:
            decisionHandler(.allow)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webV
            .store
            .send(.showIndicator(isShowIndicator: false))
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        webV
            .store
            .send(.showIndicator(isShowIndicator: false))
    }
}

extension CommonWebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message)
        
        if message.name == "W2A" {
            print("\(message.body)")
            guard let body = message.body as? [String: Any] else {
                return
            }
            
            guard let jibunAddress = body["jibunAddress"] as? String,
                  let roadAddress = body["roadAddress"] as? String,
                  let zonecode = body["zonecode"] as? String else { return }
            
            print("\(jibunAddress)\n\(roadAddress)\n\(zonecode)")

            
            
            Task { @MainActor in
                var userInfo = [String: Any]()
                
                userInfo["jibunAddress"] = jibunAddress
                userInfo["roadAddress"] = roadAddress
                userInfo["zonecode"] = zonecode
                
                NotificationCenter
                    .default
                    .post(name: Notification.Name("addrInfo"),
                          object: nil,
                          userInfo: userInfo)
            }
            
            self.webV
                .store
                .send(.dismiss)
        }
    }
}
