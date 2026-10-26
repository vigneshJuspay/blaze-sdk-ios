enum BlazeErrorCodes: String {
    case notInitialised = "NOT_INITIALISED"

    var code: String { "SDK_" + rawValue }
}
