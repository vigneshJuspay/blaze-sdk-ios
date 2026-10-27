# BlazeSDK

[![Version](https://img.shields.io/cocoapods/v/BlazeSDK.svg?style=flat)](https://cocoapods.org/pods/BlazeSDK)
[![License](https://img.shields.io/cocoapods/l/BlazeSDK.svg?style=flat)](https://cocoapods.org/pods/BlazeSDK)
[![Platform](https://img.shields.io/cocoapods/p/BlazeSDK.svg?style=flat)](https://cocoapods.org/pods/BlazeSDK)

The Blaze SDK is an easy-to-use toolkit that allows you to effortlessly integrate and utilize [Breeze 1 Click Checkout](https://breeze.in) & its services into your iOS app.

## Requirements

- iOS 12.0+
- Swift 5.0+
- Xcode 13.0+

## iOS SDK Integration

Follow the below steps to integrate Blaze SDK into your iOS application:

These steps open one-click checkout (`in.breeze.onecco`). For agentic commerce (`in.breeze.shop`), see [Agentic commerce](#agentic-commerce).

### Step 1: Obtaining the Blaze SDK

BlazeSDK is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'BlazeSDK'
```

Then run:

```bash
pod install
```

### Step 2: Initialize the SDK

**2.1. Import the SDK and create an instance of the `Blaze` class in your view controller.**

```swift
import BlazeSDK

class ViewController: UIViewController {
    let blaze = Blaze()
}
```

**2.2. Initiate the Blaze instance.**

Call `initiate` once per `Blaze` instance. Further calls are ignored, even after `terminate`; create a new `Blaze` instance to initiate again.

In order to call initiate you need to perform the following steps:

#### 2.2.1: Construct the Initiate Payload

Create a dictionary with the correct parameters to initiate the SDK. This is the data that will be used to initialize the SDK.

```swift
// Create the Initiate data
var initiatePayload: [String: Any] = [:]
initiatePayload["merchantId"] = "<MERCHANT_ID>"
initiatePayload["environment"] = "<ENVIRONMENT>"
initiatePayload["shopUrl"] = "<SHOP_URL>"

// Place Initiate Payload into SDK Payload
var initSDKPayload: [String: Any] = [:]
initSDKPayload["requestId"] = UUID().uuidString
initSDKPayload["service"] = "in.breeze.onecco"
initSDKPayload["payload"] = initiatePayload
```

> **Note:** Obtain values for `merchantId`, `environment` and `shopUrl` from the Breeze team.

All three are required; if one is missing, the `initiate` answer has `error: true`. `environment` is `beta`, `release`, `smbBeta` or `smbRelease`, and decides which Breeze environment the SDK loads.

#### 2.2.2: Construct the Callback Method

During the user journey the SDK will call the callback method with the result of the SDK operation. You need to implement this method in order to handle the result of the SDK operation.

The callback receives a dictionary with `requestId`, `service` and `payload`. `payload["eventName"]` names the event: the first is `initiate`, in answer to your `initiate` call, and the rest depend on the service and the journey.

When something fails, `payload["error"]` is `true` and `payload["errorDetails"]` describes the failure for your logs. If the failure has a code, `payload["errorCode"]` names it; see [Error codes](docs/error-codes.md).

The SDK calls the callback on the main thread.

```swift
func blazeCallbackHandler(event: [String: Any]) {
    if let payload = event["payload"] as? [String: Any], let eventName = payload["eventName"] as? String {
        switch eventName {
        // Handle various events according to your desired logic
        default:
            break
        }
    }
}
```

#### 2.2.3: Call the initiate method on the Blaze Instance

Finally, call the initiate method on the Blaze instance with the payload and the callback method. The first parameter is the `UIViewController` context.

```swift
blaze.initiate(
    context: self,
    initiatePayload: initSDKPayload,
    callbackFn: { event in
        self.blazeCallbackHandler(event: event)
    }
)
```

***Combined Example:***

```swift
import BlazeSDK
import UIKit

class ViewController: UIViewController {

    // Create Blaze Instance
    let blaze = Blaze()

    override func viewDidLoad() {
        super.viewDidLoad()
        initiateSDK()
    }

    func initiateSDK() {
        // 2.2.1 Create the Initiate data
        var initiatePayload: [String: Any] = [:]
        initiatePayload["merchantId"] = "<MERCHANT_ID>"
        initiatePayload["environment"] = "<ENVIRONMENT>"
        initiatePayload["shopUrl"] = "<SHOP_URL>"

        // Place Initiate Payload into SDK Payload
        var initSDKPayload: [String: Any] = [:]
        initSDKPayload["requestId"] = UUID().uuidString
        initSDKPayload["service"] = "in.breeze.onecco"
        initSDKPayload["payload"] = initiatePayload

        // 2.2.3 Initiate Blaze SDK
        blaze.initiate(
            context: self,
            initiatePayload: initSDKPayload,
            callbackFn: { event in
                self.blazeCallbackHandler(event: event)
            }
        )
    }

    // 2.2.2: Creating a Callback handler
    func blazeCallbackHandler(event: [String: Any]) {
        if let payload = event["payload"] as? [String: Any], let eventName = payload["eventName"] as? String {
            switch eventName {
            // Handle various events according to your desired logic
            default:
                print("Received event: \(eventName)")
            }
        }
    }
}
```

### Step 3: Start Processing Your Requests

Once the SDK is initiated, you can start processing your requests using the initialized instance of the SDK. The SDK will call the callback method with the result of the SDK operation.

#### 3.1: Construct the Process Payload

Create a dictionary payload with the required parameters to process the request. The process payload differs based on the request.

```swift
// 3.1 Create SDK Process Payload
var processPayload: [String: Any] = [:]
processPayload["action"] = "<ACTION>"
// and more parameters required as per the action

// Place Process Payload into SDK Payload
var processSDKPayload: [String: Any] = [:]
processSDKPayload["requestId"] = UUID().uuidString
processSDKPayload["service"] = "in.breeze.onecco"
processSDKPayload["payload"] = processPayload
```

#### 3.2: Call the process method on the Blaze Instance

Call the process method on the Blaze instance with the process payload to start the user journey or a headless flow.

```swift
blaze.process(payload: processSDKPayload)
```

### Step 4: Terminate the SDK

When you are done with the SDK, call the `terminate` method to clean up resources. It closes the journey and removes the SDK's view. To use the SDK again, create a new `Blaze` instance and call `initiate` on it.

```swift
blaze.terminate()
```

### Step 5: UPI Intent Flow Configuration

In order to allow the SDK to launch UPI apps in UPI intent flow, you need to add the following to the `Info.plist` file of your iOS app:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>upi</string>
    <string>credpay</string>
    <string>phonepe</string>
    <string>paytmmp</string>
    <string>tez</string>
    <string>gpay</string>
    <string>paytm</string>
    <string>bhim</string>
    <string>mobikwik</string>
    <string>freecharge</string>
    <string>myairtel</string>
    <string>slice-upi</string>
    <string>ppe</string>
    <string>amazonpay</string>
</array>
```

This declares the URL schemes for UPI apps that the SDK may attempt to open. Without this configuration, iOS will not allow the SDK to check for or launch these apps.

| Scheme       | App              |
|--------------|------------------|
| `upi`        | Any UPI app      |
| `credpay`    | CRED             |
| `phonepe`    | PhonePe          |
| `paytmmp`    | Paytm            |
| `tez`        | Google Pay       |
| `gpay`       | Google Pay       |
| `paytm`      | Paytm            |
| `bhim`       | BHIM             |
| `mobikwik`   | MobiKwik         |
| `freecharge` | Freecharge       |
| `myairtel`   | Airtel Thanks    |
| `slice-upi`  | Slice            |
| `ppe`        | PhonePe (legacy) |
| `amazonpay`  | Amazon Pay       |

### Agentic commerce

Agentic commerce (`in.breeze.shop`) lets the shopper search for products, build a cart and check out, all inside your app. You open it with the same `Blaze` calls as one-click checkout (`initiate`, `process`, `terminate`); only the payloads, and what comes back, differ.

#### Prepare it with `initiate`

```swift
var initiatePayload: [String: Any] = [:]
initiatePayload["action"] = "initiate"
initiatePayload["publisherId"] = "<PUBLISHER_ID>"
initiatePayload["environment"] = "<ENVIRONMENT>"

var initSDKPayload: [String: Any] = [:]
initSDKPayload["requestId"] = UUID().uuidString
initSDKPayload["service"] = "in.breeze.shop"
initSDKPayload["payload"] = initiatePayload

blaze.initiate(
    context: self,
    initiatePayload: initSDKPayload,
    callbackFn: { event in
        self.blazeCallbackHandler(event: event)
    }
)
```

| Key | Required | Value |
| --- | --- | --- |
| `publisherId` | Yes | Your publisher id, from the Breeze team |
| `environment` | No | `beta` or `release`. Defaults to `release` |

Nothing appears yet: `initiate` prepares everything in the background, so the shopper sees it instantly when you open it. `merchantId` and `shopUrl` aren't needed.

Your callback then gets `eventName: "initiate"` with `status: "success"`. If something is wrong, it gets `error: true` instead, with the reason in `errorDetails`, for example `Missing publisherId in initiate payload`.

#### Open it with `process`

Once the `initiate` answer has arrived, call `process`. It opens full screen. Wait for that answer: calling `process` earlier crashes the app in this version.

```swift
var processPayload: [String: Any] = [:]
processPayload["action"] = "launch"

var processSDKPayload: [String: Any] = [:]
processSDKPayload["requestId"] = UUID().uuidString
processSDKPayload["service"] = "in.breeze.shop"
processSDKPayload["payload"] = processPayload

blaze.process(payload: processSDKPayload)
```

Your callback gets `eventName: "eventStream"` with `payload.event` set to `ProcessStarted`.

#### What your callback receives

| `payload.eventName` | Means |
| --- | --- |
| `initiate` | The answer to `initiate`: ready, or an error |
| `eventStream` with `payload.event` `ProcessStarted` | It opened, in answer to `process` |
| `process` with `error: true` | The `process` payload couldn't be read |

#### Terminate

`terminate` works as in Step 4. To open it again afterwards, create a new `Blaze` instance.

### Error codes

The error codes the SDK sends are listed in [Error codes](docs/error-codes.md).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```bash
git clone https://github.com/juspay/blaze-sdk-ios.git
cd blaze-sdk-ios/Example
pod install
open BlazeSDK.xcworkspace
```

## License

BlazeSDK is available under the MIT license. See the LICENSE file for more info.
