# SuperlogicWebViewKit

A modern, secure WebView SDK for iOS applications built with SwiftUI, providing seamless SSO integration and comprehensive event handling.

## Features

- **Secure by Default**: HTTPS-only, domain allowlisting, and configurable security policies
- **SwiftUI Native**: Built specifically for SwiftUI with iOS 15+ support
- **Reactive Events**: Modern AsyncStream-based event system with category filtering
- **SSO Integration**: Built-in Single Sign-On using PKCE and cookie-based authentication
- **Onboarding Support**: Seamless onboarding flow integration for new users
- **Error Recovery**: Built-in initialization error callbacks with recovery guidance
- **Full-Featured**: Loading states, error handling, and customizable toolbar

## Requirements

- iOS 15.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Superlogic/public-ios-sdk", from: "2.0.0")
]
```

Or in Xcode:

1. **File > Add Package Dependencies**
2. Enter: `https://github.com/Superlogic/public-ios-sdk`
3. Select version `2.0.0` or later

## Quick Start

### Basic Usage

```swift
import SwiftUI
import SuperlogicWebViewKit

struct ContentView: View {
    let externalToken: String // Token from your authentication provider

    var body: some View {
        SLWebView(
            configuration: SLWebViewConfiguration(
                securityPolicy: SecurityPolicy(
                    allowedDomains: ["*.your-domain.com"]
                ),
                ssoConfiguration: SSOConfiguration(
                    clientId: "your-client-id",
                    externalToken: externalToken,
                    protocolConfig: .oidc(OIDCProtocolConfiguration(
                        subjectIssuer: "google" // Your IDP identifier
                    )),
                    realm: "your-realm",
                    environment: .production
                ),
                startUrl: URL(string: "https://app.your-domain.com")!
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

**Note:** The `startUrl` must be included in `allowedDomains` to ensure users only navigate to approved destinations.

### Error Handling

Handle initialization errors with built-in error callbacks:

```swift
let securityPolicy = SecurityPolicy(
    allowedDomains: ["*.your-domain.com"]
)

let ssoConfiguration = SSOConfiguration(
    clientId: "your-client-id",
    externalToken: externalToken,
    protocolConfig: .oidc(OIDCProtocolConfiguration(
        subjectIssuer: "google"
    )),
    realm: "your-realm",
    environment: .production
)

let configuration = SLWebViewConfiguration(
    securityPolicy: securityPolicy,
    ssoConfiguration: ssoConfiguration,
    startUrl: URL(string: "https://app.your-domain.com")!,
    onInitializationError: { error in
        // Handle the error appropriately
        print("Initialization failed: \(error.errorDescription ?? "")")
        print("Resolution: \(error.resolutionGuidance)")

        // You can show an alert, log to analytics, or retry
        switch error {
        case .invalidAppStartUrl:
            // startUrl domain not in allowedDomains
            break
        case .tokenValidationFailed:
            // Token is invalid or expired
            break
        case .networkError:
            // Network connectivity issue
            break
        default:
            break
        }
    }
)
```

### Event Handling

```swift
struct WebViewWithEvents: View {
    @State private var events: [SLWebViewEvent] = []
    let configuration: SLWebViewConfiguration // Your configured instance

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
            // Handle purchase completion
            print("Purchase completed: \(data)")
        case .checkoutStarted:
            // Track checkout initiation
            print("Checkout started")
        default:
            break
        }
    }
```

## Configuration

The SDK requires two main components: security policy and SSO configuration.

### Security Policy

Configure domain restrictions and security settings:

```swift
let securityPolicy = SecurityPolicy(
    allowedDomains: [
        "*.your-domain.com",    // Wildcard subdomain
        "api.example.com",      // Specific domain
        "secure.partner.com"
    ],
    enforceHTTPS: true,         // Default: true
    blockPopups: true,          // Default: false
    blockLocalStorage: false,   // Default: false
    contentSecurityPolicy: "default-src 'self'"  // Optional CSP header
)
```

### SSO Configuration

#### Using OIDC

```swift
let ssoConfig = SSOConfiguration(
    clientId: "mobile-app-client",
    externalToken: googleIdToken,  // Token from external provider
    protocolConfig: .oidc(OIDCProtocolConfiguration(
        subjectIssuer: "google"     // Identifier for your IDP
    )),
    realm: "your-realm",
    environment: .production
)
```

#### Using SAML

```swift
let ssoConfig = SSOConfiguration(
    clientId: "mobile-app-client",
    externalToken: samlAssertion,  // SAML assertion from provider
    protocolConfig: .saml(SAMLProtocolConfiguration(
        entityId: "your-entity-id"
    )),
    realm: "your-realm",
    environment: .production
)
```

## SSO Integration

### Token Exchange with PKCE

The SDK uses PKCE (Proof Key for Code Exchange) for secure token exchange. Configure your authentication client as a public client (no client secret required).

### startUrl Configuration

The destination URL is provided by the integrator via the `startUrl` parameter on `SLWebViewConfiguration`. The `startUrl` domain must be included in the `allowedDomains` list.

### Environment Configuration

Configure the SDK to connect to your authentication server:

```swift
// Production
environment: .production

// Staging
environment: .staging

// Development
environment: .development

// Local Development
environment: .local(port: 8080)

// Custom Server
environment: .custom(authServerBaseURL: "https://your-auth-server.com")
```

### Onboarding Flow Support

The SDK includes built-in support for user onboarding flows. When a new user needs to be onboarded, the SDK:

1. Detects the onboarding requirement from the authentication server response
2. Presents an onboarding WebView automatically
3. Handles the onboarding completion
4. Continues with normal authentication flow

Handle onboarding errors through the initialization error callback:

```swift
onInitializationError: { error in
    if case .onboardingFailed(let details) = error {
        // Handle onboarding failure
        print("Onboarding failed: \(details)")
    }
}
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
    let configuration: SLWebViewConfiguration // Your configured instance

    var body: some View {
        SLWebView(configuration: configuration) { _ in }
            .eventStream($eventStream)
            .task {
                guard let stream = eventStream else { return }

                for await event in stream.commerceEvents {
                    // Process commerce events as they arrive
                    print("Commerce event: \(event)")
                }
            }
    }
}
```

## Security

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
public enum SSOError: LocalizedError {
    case invalidAppStartUrl(String)  // startUrl validation failed
    case tokenValidationFailed        // Token signature/expiry validation failed
    case ssoAuthenticationFailed      // SSO authentication process failed
    case onboardingFailed(String)     // User onboarding flow failed
    case networkError(String)         // Network connectivity issues
    case invalidConfiguration         // Invalid SSO configuration
}

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
- Ensure `startUrl` domain is in `allowedDomains` list
- Verify external token is valid
- Check network connectivity

**Token validation failed:**
- Check token expiry
- Verify client is configured as public (no client secret)
- Ensure PKCE is enabled for the client
- Verify the external token is from the correct IDP

**Events not firing:**
- Confirm event subscription is set up before navigation
- Check JavaScript is enabled for web-based events

**Navigation blocked:**
- Domain not in `allowedDomains` list
- HTTP URL attempted (HTTPS required except localhost)
- Pop-up blocked by security policy

**Onboarding flow issues:**
- Ensure onboarding URL is in `allowedDomains`
- Check authentication server has onboarding configured
- Verify user attributes are properly set

### Debug Mode

```swift
.onEvent(category: .debug) { event in
    if case .logged(let level, let message, let metadata) = event.type {
        print("[\(level)] \(message)")
    }
}
```

## Migration Guide

### Migrating from 1.x to 2.0

Version 2.0 introduces several breaking changes to improve security and functionality:

#### 1. Removed Direct URL Configuration
```swift
// OLD (1.x)
SLWebViewConfiguration.default(
    with: URL(string: "https://app.com")!,
    and: ssoConfig
)

// NEW (2.0)
SLWebViewConfiguration(
    securityPolicy: SecurityPolicy(allowedDomains: ["*.app.com"]),
    ssoConfiguration: ssoConfig,
    startUrl: URL(string: "https://app.example.com")!
)
```

#### 2. Updated SSO Configuration
```swift
// OLD (1.x)
SSOConfiguration(
    clientId: "client",
    idToken: token,
    subjectIssuer: "google",
    realm: "realm"
)

// NEW (2.0)
SSOConfiguration(
    clientId: "client",
    externalToken: token,
    protocolConfig: .oidc(OIDCProtocolConfiguration(
        subjectIssuer: "google"
    )),
    realm: "realm",
    environment: .production
)
```

#### 3. Added Error Handling
```swift
// NEW (2.0) - Add initialization error callback
SLWebViewConfiguration(
    securityPolicy: securityPolicy,
    ssoConfiguration: ssoConfiguration,
    onInitializationError: { error in
        // Handle initialization errors
    }
)
```

#### 4. iOS Support
- Now supports iOS 15+ (previously iOS 17+)

#### 5. Security Enhancements
- PKCE implementation for OAuth flows
- No client secret required (public client)
- startUrl domain validation against allowedDomains

## License

Copyright 2026 Superlogic. All rights reserved.
