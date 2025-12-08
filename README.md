# SuperlogicWebViewKit

A modern, secure WebView SDK for iOS applications built with SwiftUI, providing seamless SSO integration and comprehensive event handling.

## Features

- **Secure by Default**: HTTPS-only, domain allowlisting, and configurable security policies
- **SwiftUI Native**: Built specifically for SwiftUI with iOS 17+ support
- **Reactive Events**: Modern AsyncStream-based event system with category filtering
- **SSO Integration**: Built-in Single Sign-On with Keycloak token exchange and cookie-based authentication
- **Full-Featured**: Loading states, error handling, and customizable toolbar

## Requirements

- iOS 17.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Superlogic/public-ios-sdk", from: "1.0.0")
]
```

Or in Xcode:

1. **File > Add Package Dependencies**
2. Enter: `https://github.com/Superlogic/public-ios-sdk`
3. Select version `1.0.0` or later

## Quick Start

### Basic Usage

```swift
import SwiftUI
import SuperlogicWebViewKit

struct ContentView: View {
    var body: some View {
        SLWebView(
            configuration: .default(
                with: URL(string: "https://www.superlogic.com")!,
                and: SSOConfiguration(
                    clientId: "your-client-id",
                    idToken: "your-id-token",
                    subjectIssuer: "google",
                    realm: "your-realm"
                )
            )
        ) { action in
            switch action {
            case .close:
                // Handle close action
                break
            case .reload:
                // Reload is handled automatically
                break
            }
        }
    }
}
```

### Event Handling

```swift
struct WebViewWithEvents: View {
    @State private var events: [SLWebViewEvent] = []

    var body: some View {
        SLWebView(configuration: configuration) { _ in }
            .onEvent { event in
                print("Received event: \(event.type.name)")
                events.append(event)
            }
    }
}
```

### Category-Based Event Filtering

```swift
SLWebView(configuration: configuration) { _ in }
    .onEvent(category: .commerce) { event in
        switch event.type {
        case .purchaseCompleted(let data):
            handlePurchase(data)
        case .checkoutStarted:
            trackCheckoutStart()
        default:
            break
        }
    }
```

## Configuration

### Security Presets

**Default Configuration** - Balanced security with JavaScript enabled:
```swift
let config = SLWebViewConfiguration.default(with: url, and: ssoConfig)
```

**Strict Configuration** - Maximum security with JavaScript disabled:
```swift
let config = SLWebViewConfiguration.strict(with: url, and: ssoConfig)
```

**Relaxed Configuration** - Minimal restrictions for trusted content:
```swift
let config = SLWebViewConfiguration.relaxed(with: url, and: ssoConfig)
```

### Custom Configuration

```swift
let config = SLWebViewConfiguration(
    startUrl: url,
    securityPolicy: SecurityPolicy(
        allowedDomains: ["*.superlogic.com", "api.example.com"],
        enforceHTTPS: true,
        blockPopups: true,
        blockLocalStorage: false,
        contentSecurityPolicy: "default-src 'self'"
    ),
    ssoConfiguration: ssoConfig,
    javascriptEnabled: true,
    userAgent: "MyApp/1.0",
    allowsInlineMediaPlayback: true,
    mediaTypesRequiringUserAction: []
)
```

## SSO Integration

### Token Exchange

The SDK automatically handles token exchange with Keycloak when `enableTokenExchange` is enabled:

```swift
let ssoConfig = SSOConfiguration(
    clientId: "mobile-app-client",
    idToken: "external-provider-token",
    subjectIssuer: "google", // or "apple", "facebook", etc.
    realm: "your-realm",
    keycloakEnvironment: .production,
    enableTokenExchange: true,
    cookieDomainEnvironment: .production
)
```

### Environment Configuration

```swift
// Development environment
SSOConfiguration(
    clientId: "dev-client-id",
    idToken: token,
    subjectIssuer: "google",
    realm: "dev-realm",
    keycloakEnvironment: .development,
    cookieDomainEnvironment: .development
)

// Production environment
SSOConfiguration(
    clientId: "prod-client-id",
    idToken: token,
    subjectIssuer: "google",
    realm: "prod-realm",
    keycloakEnvironment: .production,
    cookieDomainEnvironment: .production
)
```

## Event System

### Event Categories

| Category | Events |
|----------|--------|
| **Lifecycle** | `componentLoaded`, `errorOccurred`, `reloadRequested` |
| **Session** | `userSignedIn`, `userSignedOut`, `tokenExpired`, `sessionTimedOut`, `sessionRefreshed` |
| **Commerce** | `purchaseCompleted`, `purchaseFailed`, `checkoutStarted`, `checkoutAbandoned` |
| **Navigation** | `pageChanged`, `navigationBlocked`, `externalLinkRequested`, `deepLinkRequested` |
| **Debug** | `logged` |

### Event Stream Access

```swift
struct AdvancedEventHandling: View {
    @State private var eventStream: SLWebViewEvents?

    var body: some View {
        SLWebView(configuration: configuration) { _ in }
            .eventStream($eventStream)
            .task {
                guard let stream = eventStream else { return }

                for await event in stream.commerceEvents {
                    handleCommerceEvent(event)
                }
            }
    }
}
```

## Security

### Domain Allowlisting

```swift
let securityPolicy = SecurityPolicy(
    allowedDomains: [
        "www.superlogic.com",
        "*.superlogic.com",  // Wildcard subdomain
        "api.trusted-partner.com"
    ]
)
```

### Content Security Policy

```swift
let securityPolicy = SecurityPolicy(
    contentSecurityPolicy: """
        default-src 'self';
        script-src 'self' 'unsafe-inline';
        style-src 'self' 'unsafe-inline';
        img-src 'self' data: https:;
        """
)
```

## API Reference

### SLWebView

```swift
public struct SLWebView: View {
    public init(
        configuration: SLWebViewConfiguration,
        showToolbar: Bool = true,
        toolbarPlacement: ToolbarPlacement = .bottom,
        onAction: @escaping (SLWebViewAction) -> Void
    )
}
```

### View Modifiers

```swift
extension SLWebView {
    // Subscribe to all events
    public func onEvent(_ handler: @escaping (SLWebViewEvent) -> Void) -> some View

    // Subscribe to events by category
    public func onEvent(category: SLWebViewEvent.Category, _ handler: @escaping (SLWebViewEvent) -> Void) -> some View

    // Access the event stream directly
    public func eventStream(_ binding: Binding<SLWebViewEvents?>) -> some View
}
```

### SLWebViewAction

```swift
public enum SLWebViewAction: Sendable {
    case close
    case reload
}
```

### Error Types

```swift
public enum ConfigurationError: LocalizedError {
    case invalidURL(String)
    case insecureURL(String)
    case missingRequiredParameter(String)
}

public enum NavigationError: LocalizedError {
    case domainNotAllowed(String)
    case insecureConnection(String)
    case navigationFailed(String)
}
```

## Troubleshooting

### Common Issues

**WebView not loading:**
- Ensure the URL is HTTPS
- Check domain is in allowlist
- Verify SSO token is valid

**Events not firing:**
- Confirm event subscription is set up before navigation
- Check JavaScript is enabled for web-based events
- Verify event bridge script injection

**Navigation blocked:**
- Domain not in allowlist
- HTTP URL attempted (HTTPS required)
- Pop-up blocked by security policy

### Debug Mode

```swift
.onEvent(category: .debug) { event in
    if case .logged(let level, let message, let metadata) = event.type {
        print("[\(level)] \(message)")
    }
}
```

## License

Copyright 2025 Superlogic. All rights reserved.
