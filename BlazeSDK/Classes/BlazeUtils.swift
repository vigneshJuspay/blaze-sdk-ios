import Foundation

func safeParseJson(jsonString: String) -> [String: Any] {

    if jsonString == "" {
        return [:]
    }

    guard let data = jsonString.data(using: .utf8) else {
        print("Error: Could not convert string to data.")
        return [:]
    }

    do {
        if let json = try JSONSerialization.jsonObject(with: data, options: [])
            as? [String: Any]
        {
            return json
        } else {
            print("Error: JSON is not in expected dictionary format.")
        }
    } catch {
        print("Error parsing JSON: \(error.localizedDescription)")
    }
    return [:]
}

func getEnvironment(payload: [String: Any]) -> String {
    let environment =
        (payload["payload"] as? [String: Any])?["environment"] as? String
    if let environment = environment, !environment.isEmpty {
        return environment
    }
    return "release"
}

func getService(payload: [String: Any]) -> String {
    return payload["service"] as? String ?? ""
}

func getBaseUrl(payload: [String: Any]) -> String {
    if getService(payload: payload) == "in.breeze.shop" {
        return "https://shop.breeze.in/sdk"
    }

    let environment = getEnvironment(payload: payload)
    if environment == "smbBeta" {
        return "https://app.beta.v2.breezesdk.store"
    } else if environment == "smbRelease" {
        return "https://app.v2.breezesdk.store"
    } else if environment == "beta" {
        return "https://app.beta.v2.breeze.in"
    } else {
        return "https://app.v2.breeze.in"
    }
}

func sdkErrorResponse(
    request: [String: Any], eventName: String, error: BlazeErrorCodes, errorDetails: String
) -> [String: Any] {
    let payload: [String: Any] = [
        "eventName": eventName,
        "action": NSNull(),
        "status": NSNull(),
        "methodName": NSNull(),
        "params": NSNull(),
        "event": NSNull(),
        "error": true,
        "errorDetails": errorDetails,
        "errorCode": error.code,
    ]
    return [
        "requestId": request["requestId"] as? String ?? "",
        "service": getService(payload: request),
        "payload": payload,
    ]
}

func notInitialisedResponse(processPayload: [String: Any]) -> [String: Any] {
    return sdkErrorResponse(
        request: processPayload,
        eventName: "process",
        error: .notInitialised,
        errorDetails: "Call process after initiate")
}

public func isUPIIntentUri(_ url: URL) -> Bool {
    guard
        let scheme = url.scheme?.lowercased(),
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
        let queryItems = components.queryItems,
        !queryItems.isEmpty
    else {
        return false
    }

    let queryParams = Dictionary(
        uniqueKeysWithValues: queryItems.map { item in
            (item.name.lowercased(), item.value ?? "")
        }
    )
    let upiSchemes: Set<String> = [
        "upi", "phonepe", "tez", "gpay", "paytm", "paytmmp", "bhim",
        "amazonpay", "mobikwik", "freecharge", "credpay",
    ]

    let hasPayeeAddress =
        queryParams["pa"]?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    let hasPayeeName =
        queryParams["pn"]?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    let hasAmount =
        queryParams["am"]?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    let isKnownScheme = upiSchemes.contains(scheme)

    return hasPayeeAddress && hasPayeeName && hasAmount && isKnownScheme
}
