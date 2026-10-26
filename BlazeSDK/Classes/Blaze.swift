import UIKit
import WebKit

public typealias CallbackFn = (_ event: [String: Any]) -> Void

public class Blaze: NSObject {

    private var webView: BlazeWebView!
    private var context: UIViewController!
    private var callbackFn: CallbackFn?
    private var isInitialized: Bool = false

    public func initiate(
        context: UIViewController, initiatePayload: [String: Any],
        container: UIView? = nil,
        callbackFn: @escaping CallbackFn
    ) {

        if isInitialized {
            return
        }

        self.context = context
        self.callbackFn = callbackFn

        DispatchQueue.main.async {
            self.webView = BlazeWebView(
                context: self.context, initiatePayload: initiatePayload,
                container: container, callbackFn: callbackFn)
        }
        self.isInitialized = true
    }

    public func process(payload: [String: Any]) {
        if let webView = self.webView {
            webView.process(payload: payload)
        } else if let callbackFn = self.callbackFn {
            let response = notInitialisedResponse(processPayload: payload)
            DispatchQueue.main.async {
                callbackFn(response)
            }
        }
    }

    public func terminate() {
        self.webView.terminate()
    }

}
