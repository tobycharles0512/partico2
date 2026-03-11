import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadParticoApp()
    }

    func setupWebView() {
        let config = WKWebViewConfiguration()

        // Allow localStorage and other storage APIs
        config.websiteDataStore = WKWebsiteDataStore.default()

        // Allow camera and microphone if needed
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        view.addSubview(webView)
    }

    func loadParticoApp() {
        // Load the Partico HTML file as a UTF-8 string to ensure emoji rendering
        if let url = Bundle.main.url(forResource: "Partico", withExtension: "html"),
           let htmlString = try? String(contentsOf: url, encoding: .utf8) {
            webView.loadHTMLString(htmlString, baseURL: url.deletingLastPathComponent())
        } else {
            showError("Could not find Partico.html in the app bundle.")
        }
    }

    func showError(_ message: String) {
        let html = """
        <html><body style='background:#0d0019;color:#fff;font-family:-apple-system;
        display:flex;align-items:center;justify-content:center;height:100vh;text-align:center;padding:20px'>
        <div><div style='font-size:48px'>🎉</div>
        <h2 style='margin:16px 0 8px'>Partico</h2>
        <p style='color:rgba(255,255,255,0.5)'>\(message)</p></div></body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    // Allow camera access prompts from web content
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    // Handle JS alert dialogs
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Partico", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }

    // Handle JS confirm dialogs
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Partico", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        present(alert, animated: true)
    }

    // Hide status bar for full-screen feel
    override var prefersStatusBarHidden: Bool { return false }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}
