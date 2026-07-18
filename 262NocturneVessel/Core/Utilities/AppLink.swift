import Foundation

enum AppLink: String {
    case privacyPolicy = "https://nocturne262vessel.site/privacy/342"
    case termsOfUse = "https://nocturne262vessel.site/terms/342"

    var url: URL? {
        URL(string: rawValue)
    }
}
