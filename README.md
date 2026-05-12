# SuperlogicWebViewKit

A modern, secure WebView SDK for iOS applications built with SwiftUI, providing seamless SSO integration and comprehensive event handling.

## Features

- **Secure by Default**: HTTPS-only with configurable security policies
- **SwiftUI Native**: Built specifically for SwiftUI with iOS 15+ support
- **Reactive Events**: AsyncStream-based event system with category filtering
- **SSO Integration**: Built-in Single Sign-On using PKCE and cookie-based authentication
- **Onboarding Support**: Seamless onboarding flow integration for new users
- **Error Recovery**: Built-in initialization error callbacks with recovery guidance
- **Full-Featured**: Loading states, navigation controls, and error handling

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
    let idToken: String // ID token from your external identity provider

    var body: some View {
        SLWebView(
            configuration: SLWebViewConfiguration(
                ssoConfiguration: SSOConfiguration(
                    clientId: "your-client-id",
                    idToken: idToken,
                    protocolConfig: .oidc(OIDCProtocolConfiguration(
                        subjectIssuer: "google" // Your IDP alias in Keycloak
                    )),
                    realm: "your-realm",
                    environment: .custom(authServerBaseURL: "https://auth.your-domain.com")
                ),
                startUrl: URL(string: "https://app.your-domain.com")!
            )
        )
    }
}
```

### Error Handling

Handle initialization errors via the `onInitializationError` callback:

```swift
let configuration = SLWebViewConfiguration(
    ssoConfiguration: SSOConfiguration(
        clientId: "your-client-id",
        idToken: idToken,
        protocolConfig: .oidc(OIDCProtocolConfiguration(
            subjectIssuer: "google"
        )),
        realm: "your-realm",
        environment: .custom(authServerBaseURL: "https://auth.your-domain.com")
    ),
    startUrl: URL(string: "https://app.your-domain.com")!,
    onInitializationError: { error in
        print("Initialization failed: \(error.errorDescription ?? "")")
        print("Resolution: \(error.resolutionGuidance)")

        switch error {
        case .ssoAuthenticationFailed(let message):
            // SSO token exchange failed
            print(message)
        case .tokenValidationFailed(let message):
            // Token is invalid or expired
            print(message)
        case .invalidStartUrl(let message):
            // startUrl failed domain validation
            print(message)
        case .networkError(let message):
            // Network connectivity issue
            print(message)
        case .onboardingFailed(let message):
            // Onboarding flow failed
            print(message)
        case .webViewCreationFailed(let message):
            print(message)
        case .partnerEnrollmentRequired(let message):
            // Partner enrollment required
            print(message)
        }
    }
)
```

### Event Handling

```swift
SLWebView(configuration: configuration)
    .onEvent { event in
        print("[\(event.category.rawValue)] event received")
    }
```

### Category-Based Event Filtering

```swift
SLWebView(configuration: configuration)
    .onEvent(category: .commerce) { event in
        switch event.type {
        case .purchaseCompleted:
            print("Purchase completed")
        case .checkoutStarted:
            print("Checkout started")
        default:
            break
        }
    }
```

## Configuration

### SLWebViewConfiguration

```swift
SLWebViewConfiguration(
    ssoConfiguration: SSOConfiguration,  // Required
    startUrl: URL,                        // Required - initial URL after authentication
    mediaPlaybackRequiresUserAction: Bool = true,
    basicAuthHeaderValue: String? = nil,  // For dev/staging basic auth only
    onInitializationError: (@Sendable (InitializationError) -> Void)? = nil
)
```

**Note:** `SecurityPolicy` and `allowsJavaScript` parameters are deprecated. JavaScript is always enabled as required by the SDK.

**Presets:**

```swift
// Strict: media requires user action
SLWebViewConfiguration.strict(
    ssoConfiguration: ssoConfig,
    startUrl: startUrl
)

// Relaxed: media plays automatically
SLWebViewConfiguration.relaxed(
    ssoConfiguration: ssoConfig,
    startUrl: startUrl
)
```

### SSO Configuration

#### Token exchange (external IDP → Keycloak)

Use when the user authenticates with an external provider (Google, Apple, etc.) and you have their ID token:

```swift
let ssoConfig = SSOConfiguration(
    clientId: "mobile-app-client",
    idToken: externalIdToken,       // ID token from the external provider
    protocolConfig: .oidc(OIDCProtocolConfiguration(
        subjectIssuer: "google"     // IDP alias as configured in Keycloak
    )),
    realm: "your-realm",
    environment: .custom(authServerBaseURL: "https://auth.your-domain.com")
)
```

#### Pre-authenticated (auth code flow — app holds Keycloak tokens)

Use when your app has already completed the authorization code flow and holds Keycloak tokens directly:

```swift
let ssoConfig = SSOConfiguration(
    credentials: AuthCredentials(
        clientId: "mobile-app-client",
        idToken: keycloakIdToken,
        accessToken: keycloakAccessToken,   // Optional, enables mobile session
        refreshToken: keycloakRefreshToken  // Optional, enables mobile session
    ),
    protocolConfig: .oidc(OIDCProtocolConfiguration(
        subjectIssuer: "your-idp-alias",
        isPreAuthenticated: true
    )),
    realm: "your-realm",
    environment: .custom(authServerBaseURL: "https://auth.your-domain.com")
)
```

### Environment Configuration

The SDK provides two environment options:

```swift
// Local development (defaults to port 8200)
.local()
.local(port: 8080)

// Remote environments (staging, production, etc.)
.custom(authServerBaseURL: "https://auth.your-domain.com")
```

**Note:** Previous environment presets (`.dev`, `.staging`, `.production`) have been removed. Use `.custom(authServerBaseURL:)` for all remote environments.

### OIDC Security Options

`OIDCProtocolConfiguration` accepts an `OIDCSecurityOptions` value controlling PKCE, state, nonce, and signature validation:

```swift
// .secure is the default — all protections enabled, recommended for production
OIDCProtocolConfiguration(
    subjectIssuer: "google",
    securityOptions: .secure
)

// .relaxed disables PKCE, state, nonce, and signature validation
// WARNING: for local testing only, never use in production
OIDCProtocolConfiguration(
    subjectIssuer: "google",
    securityOptions: .relaxed
)

// Custom options
OIDCProtocolConfiguration(
    subjectIssuer: "google",
    securityOptions: OIDCSecurityOptions(
        enablePKCE: true,
        enableState: true,
        enableNonce: true,
        validateSignature: true,
        jwksURL: "https://auth.your-domain.com/realms/your-realm/protocol/openid-connect/certs",
        expectedIssuer: "https://auth.your-domain.com/realms/your-realm",
        expectedAudience: "your-client-id",
        clockSkewTolerance: 30
    )
)
```

### Onboarding Flow

The SDK automatically handles onboarding when a new user must accept terms before proceeding. When onboarding is required the SDK presents the onboarding screen, handles acceptance or decline, and continues the authentication flow.

Handle onboarding errors via the initialization error callback:

```swift
onInitializationError: { error in
    if case .onboardingFailed(let details) = error {
        print("Onboarding failed: \(details)")
    }
}
```

## Event System

### Event Categories

| Category | Event types |
|----------|-------------|
| **lifecycle** | `componentLoaded`, `errorOccurred`, `tokenExpired`, `reloadRequested`, `partnerEnrollStarted`, `partnerEnrollComplete` |
| **session** | `userSignedIn`, `userSignedOut`, `sessionTimedOut`, `sessionRefreshed` |
| **commerce** | `purchaseCompleted`, `purchaseFailed`, `checkoutStarted`, `checkoutAbandoned` |
| **navigation** | `pageChanged`, `navigationBlocked`, `externalLinkRequested`, `deepLinkRequested` |
| **debug** | `logged` |

### Subscribing via view modifiers

```swift
// All events
SLWebView(configuration: configuration)
    .onEvent { event in
        print("[\(event.category.rawValue)] event received")
    }

// Filtered by category
SLWebView(configuration: configuration)
    .onEvent(category: .session) { event in
        if case .userSignedOut = event.type {
            // handle sign-out
        }
    }
```

### Subscribing via AsyncStream binding

```swift
struct ContentView: View {
    @State private var eventStream: AsyncStream<SLWebViewEvent>?
    let configuration: SLWebViewConfiguration

    var body: some View {
        SLWebView(configuration: configuration)
            .eventStream($eventStream)
            .task {
                guard let stream = eventStream else { return }
                for await event in stream {
                    print("[\(event.category.rawValue)] event received")
                }
            }
    }
}
```

### Filtered streams on SLWebViewEvents

When using `SLWebViewViewModel` directly, the `events` property exposes pre-filtered streams:

```swift
let viewModel = SLWebViewViewModel(configuration: configuration)

Task {
    for await event in viewModel.events.commerceEvents {
        // only commerce events
    }
}

// Available streams:
// viewModel.events.events          — all events
// viewModel.events.lifecycleEvents
// viewModel.events.sessionEvents
// viewModel.events.commerceEvents
// viewModel.events.navigationEvents
// viewModel.events.debugEvents
```

### Loading Progress

```swift
struct ContentView: View {
    @State private var progressStream: AsyncStream<Double>?
    let configuration: SLWebViewConfiguration

    var body: some View {
        SLWebView(configuration: configuration)
            .loadingProgressStream($progressStream)
            .task {
                guard let stream = progressStream else { return }
                for await progress in stream {
                    print("Loading: \(Int(progress * 100))%")
                }
            }
    }
}
```

## Navigation

Access navigation controls via the `navigation` property:

```swift
let webView = SLWebView(configuration: configuration)

webView.navigation.goBack()
webView.navigation.goForward()
webView.navigation.refresh()

webView.navigation.canGoBack      // Bool
webView.navigation.canGoForward   // Bool
webView.navigation.loadingProgress // Double (0.0–1.0)
```

### Swipe Gestures

The SDK enables swipe-to-navigate gestures by default, matching Mobile Safari behavior:
- **Swipe right** to go back in navigation history
- **Swipe left** to go forward in navigation history

This provides a natural, familiar navigation experience for users.

## Using SLWebViewViewModel directly

For advanced use cases you can create and hold a `SLWebViewViewModel` independently:

```swift
@StateObject var viewModel = SLWebViewViewModel(configuration: configuration)

var body: some View {
    SLWebView(viewModel: viewModel)
}

// Published state
viewModel.isLoading          // Bool
viewModel.loadingProgress    // Double
viewModel.connectionState    // ConnectionState
viewModel.ssoStatus          // SSOStatus
viewModel.onboardingState    // OnboardingState

// Actions
viewModel.reload()
viewModel.goBack()
viewModel.goForward()
viewModel.clearSSO()
```

## Security

### HTTPS enforcement

- HTTPS is required for all `startUrl` values except `http://localhost` and `http://127.0.0.1`
- The SDK validates the `startUrl` during initialization and reports errors via the `onInitializationError` callback

### PKCE

The SDK uses PKCE (Proof Key for Code Exchange) for secure token exchange. Configure your Keycloak client as a public client (no client secret required).

## Device Permissions

### Geolocation

WKWebView handles geolocation natively — no code changes are required in the library or your app. The system location permission dialog appears automatically the first time an embedded site calls `navigator.geolocation`.

**Required:** add `NSLocationWhenInUseUsageDescription` to your app's `Info.plist`. Without it the system will not show the permission dialog and geolocation requests will fail silently.

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses your location for the embedded site.</string>
```

Use a description that makes sense for your app's context.

## Deep Link Handling

The SDK automatically intercepts custom URL scheme links encountered during WebView navigation (for example, `myapp://payment?...` from a third-party checkout flow) and routes them to the system launcher so the correct app can open.

### How It Works

At first use the SDK reads `CFBundleURLTypes` from the host app's `Info.plist` and builds the set of custom schemes the app has registered. When the WebView encounters a URL whose scheme is in that set, the SDK:

1. Cancels default WebView navigation
2. Calls `UIApplication.shared.open(_:)` to hand off to the system
3. Emits a `deepLinkRequested` event with the URL and an `opened` flag

Standard schemes are never intercepted: `http`, `https`, `about`, `javascript`, `file`, `data`.

### Setup

No SDK configuration required. Register the scheme in your `Info.plist` (which you must do anyway to receive URLs from other apps):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.myscheme</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myscheme</string>
        </array>
    </dict>
</array>
```

The SDK picks this up automatically — no changes to `SLWebViewConfiguration` are needed.

### Event

```swift
SLWebView(configuration: config)
    .onEvent { event in
        if case .deepLinkRequested(let url) = event.type {
            let opened = event.data["opened"] as? Bool ?? false
            print("Deep link \(url) — opened: \(opened)")
        }
    }
```

## API Reference

### SLWebView

```swift
public struct SLWebView: View {
    public init(configuration: SLWebViewConfiguration)
    public init(viewModel: SLWebViewViewModel)
    public var navigation: SLWebViewNavigation { get }
}

extension SLWebView {
    public func onEvent(
        perform action: @escaping (SLWebViewEvent) async -> Void
    ) -> some View

    public func onEvent(
        category: SLWebViewEvent.EventCategory,
        perform action: @escaping (SLWebViewEvent) async -> Void
    ) -> some View

    public func eventStream(
        _ binding: Binding<AsyncStream<SLWebViewEvent>?>
    ) -> some View

    public func loadingProgressStream(
        _ binding: Binding<AsyncStream<Double>?>
    ) -> some View
}
```

### SLWebViewNavigation

```swift
@MainActor
public struct SLWebViewNavigation {
    public func goBack()
    public func goForward()
    public func refresh()
    public var canGoBack: Bool { get }
    public var canGoForward: Bool { get }
    public var loadingProgress: Double { get }
    public var loadingProgressStream: AsyncStream<Double> { get }
}
```

### SLWebViewConfiguration.InitializationError

Delivered to the `onInitializationError` callback:

```swift
public enum InitializationError: LocalizedError, Sendable {
    case ssoAuthenticationFailed(String)  // SSO token exchange failed
    case tokenValidationFailed(String)    // Token is invalid or expired
    case invalidStartUrl(String)          // Start URL validation failed
    case webViewCreationFailed(String)    // WebView setup failed
    case networkError(String)             // Network connectivity issue during init
    case onboardingFailed(String)         // Onboarding flow failed
    case partnerEnrollmentRequired(String) // Partner enrollment is required
}
```

Each case exposes `errorDescription` and `resolutionGuidance` strings.

### SSOError

Internal errors surfaced via the event system (`.errorOccurred`) and `onInitializationError`:

```swift
public enum SSOError: Error, LocalizedError {
    case noValidToken
    case invalidToken
    case injectionFailed(Error)
    case invalidConfiguration(String)
    case onboardingRequired(previewUrl: String, consentDefinitions: [ConsentDefinition]?)
    case onboardingDeclined
    case onboardingFailed(String)
    case onboardingExpired
    case partnerEnrollmentRequired(accessToken: String)
}
```

### SLWebViewEvent

```swift
public struct SLWebViewEvent: Sendable {
    public let type: EventType
    public let category: EventCategory
    public let data: [String: SendableValue]
    public let timestamp: Date

    // Data accessors
    public func string(for key: String) -> String?
    public func double(for key: String) -> Double?
    public func url(for key: String) -> URL?
    public var rawData: [String: Any] { get }
}

public enum EventCategory: String, CaseIterable, Sendable {
    case lifecycle, commerce, session, navigation, debug
}

public enum EventType: Sendable, Equatable {
    // Lifecycle
    case componentLoaded
    case errorOccurred(Error?)
    case tokenExpired
    case reloadRequested
    case partnerEnrollStarted
    case partnerEnrollComplete
    // Commerce
    case purchaseCompleted
    case purchaseFailed(Error?)
    case checkoutStarted
    case checkoutAbandoned
    // Session
    case sessionTimedOut
    case userSignedOut
    case userSignedIn
    case sessionRefreshed
    // Navigation
    case externalLinkRequested(URL)
    case navigationBlocked(URL)
    case deepLinkRequested(URL)
    case pageChanged(String)
    // Debug
    case logged(String, level: SLLogLevel)
}

public enum SLLogLevel: String, CaseIterable, Sendable {
    case debug, info, warn, error
}
```

## Troubleshooting

### Common Issues

**WebView not loading:**
- Ensure `startUrl` uses HTTPS (HTTP only allowed for `localhost` / `127.0.0.1`)
- Verify the `idToken` is valid and not expired
- Check the `onInitializationError` callback for specific error details

**SSO authentication failed:**
- Verify `clientId` matches the Keycloak client
- Confirm `subjectIssuer` matches the IDP alias configured in Keycloak
- Ensure the Keycloak client has token exchange enabled
- Verify `realm` is correct

**Token validation failed:**
- Check token expiry
- Ensure the Keycloak client is configured as a public client (no client secret)
- Verify PKCE is enabled for the client

**Events not firing:**
- Set up the event subscription before the view appears
- JavaScript is always enabled in the SDK (required for web-based events)

**Navigation issues:**
- HTTP URL attempted (HTTPS required except localhost)
- Check the `onInitializationError` callback for validation errors

**Onboarding issues:**
- Check authentication server has onboarding configured
- Verify the user completes the onboarding flow

### Debug Mode

```swift
SLWebView(configuration: configuration)
    .onEvent(category: .debug) { event in
        if case .logged(let message, let level) = event.type {
            print("[\(level.rawValue.uppercased())] \(message)")
        }
    }
```

## Migration Guide

### Migrating from previous versions

#### 1. `SecurityPolicy` is now deprecated (3.0+)

```swift
// OLD (2.x) — required SecurityPolicy with allowedDomains
SLWebViewConfiguration(
    securityPolicy: SecurityPolicy(allowedDomains: ["*.your-domain.com"]),
    ssoConfiguration: ssoConfig,
    startUrl: URL(string: "https://app.your-domain.com")!
)

// NEW (3.0+) — SecurityPolicy deprecated, remove it
SLWebViewConfiguration(
    ssoConfiguration: ssoConfig,
    startUrl: URL(string: "https://app.your-domain.com")!
)
```

#### 2. `startUrl` is now a required parameter on `SLWebViewConfiguration` (2.0+)

```swift
// OLD (1.x) — no startUrl, URL was determined server-side
SLWebViewConfiguration(
    securityPolicy: securityPolicy,
    ssoConfiguration: ssoConfig
)

// NEW (2.0+) — startUrl required
SLWebViewConfiguration(
    ssoConfiguration: ssoConfig,
    startUrl: URL(string: "https://app.your-domain.com")!
)
```

#### 3. `SLWebView` init no longer takes an action closure

```swift
// OLD (2.0.x) — required onAction closure, showToolbar, toolbarPlacement
SLWebView(configuration: configuration, showToolbar: true) { action in
    switch action {
    case .close: dismiss()
    case .reload: break
    }
}

// NEW — no closure; use .onEvent for reactions
SLWebView(configuration: configuration)
    .onEvent(category: .lifecycle) { event in
        if case .reloadRequested = event.type { /* handle */ }
    }
```

#### 4. Updated SSO Configuration

```swift
// OLD (2.0.x)
SSOConfiguration(
    clientId: "client",
    externalToken: token,   // was externalToken
    subjectIssuer: "google",
    realm: "realm",
    environment: .production
)

// NEW
SSOConfiguration(
    clientId: "client",
    idToken: token,         // renamed to idToken
    protocolConfig: .oidc(OIDCProtocolConfiguration(
        subjectIssuer: "google"
    )),
    realm: "realm",
    environment: .custom(authServerBaseURL: "https://auth.your-domain.com")
)
```

#### 5. `SecurityPolicy` parameters removed (3.0+)

`SecurityPolicy` is now deprecated. The SDK no longer requires explicit domain allowlisting - security is managed internally.

```swift
// OLD (2.x) — SecurityPolicy with domain configuration
SecurityPolicy(
    allowedDomains: ["*.your-domain.com"],
    allowsLocalStorage: false
)

// NEW (3.0+) — SecurityPolicy deprecated, no replacement needed
// Remove SecurityPolicy from your configuration
```

#### 6. Added initialization error callback

```swift
SLWebViewConfiguration(
    ssoConfiguration: ssoConfiguration,
    startUrl: startUrl,
    onInitializationError: { error in
        print(error.errorDescription ?? "")
        print(error.resolutionGuidance)
    }
)
```

#### 7. iOS 15+ support (previously iOS 17+)

#### 8. `EnvironmentConfig` presets removed (3.0+)

```swift
// OLD (2.x) — built-in presets
environment: .production
environment: .staging
environment: .development

// NEW (3.0+) — use .custom() for all remote environments
environment: .custom(authServerBaseURL: "https://auth.your-domain.com")
environment: .local()         // local dev (port 8200)
environment: .local(port: 8080)
```

#### 9. `eventStream` binding type changed

```swift
// OLD (2.0.x)
@State private var eventStream: SLWebViewEvents?
// ...
.eventStream($eventStream)
for await event in stream.commerceEvents { }

// NEW
@State private var eventStream: AsyncStream<SLWebViewEvent>?
// ...
.eventStream($eventStream)
for await event in stream { }
// For filtered streams, use viewModel.events.commerceEvents directly
```

## License

Copyright 2026 Superlogic. All rights reserved.
