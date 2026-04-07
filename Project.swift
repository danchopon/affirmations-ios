import ProjectDescription

let deploymentTargets = DeploymentTargets.iOS("17.0")
let developmentTeam = Environment.developmentTeam.getString(default: "")

let project = Project(
    name: "Affirmations",
    organizationName: "danchopon.affirmations",
    options: .options(
        automaticSchemesOptions: .enabled(),
        developmentRegion: "en"
    ),
    settings: .settings(base: [
        "DEVELOPMENT_TEAM": "\(developmentTeam)"
    ]),
    targets: [

        // MARK: - App

        .target(
            name: "Affirmations",
            destinations: .iOS,
            product: .app,
            bundleId: "danchopon.affirmations.app",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "CFBundleDisplayName": "Affirmations"
            ]),
            sources: ["App/**"],
            entitlements: .file(path: "App/Affirmations.entitlements"),
            dependencies: [
                .target(name: "CheckIn"),
                .target(name: "Affirmation"),
                .target(name: "History"),
                .target(name: "Insights"),
                .target(name: "Settings"),
                .target(name: "Paywall"),
                .target(name: "CoreAnalytics"),
                .target(name: "CoreAI"),
                .target(name: "CorePersistence"),
                .target(name: "CoreNotifications"),
                .target(name: "CorePurchases"),
                .target(name: "DesignSystem"),
                .target(name: "AffirmationsWidget"),
                .sdk(name: "SwiftData", type: .framework, status: .required)
            ]
        ),

        // MARK: - Widget Extension

        .target(
            name: "AffirmationsWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "com.affirmations.app.widget",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "NSExtension": .dictionary([
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                ])
            ]),
            sources: ["Widgets/Sources/**"],
            entitlements: .file(path: "Widgets/Affirmations-Widget.entitlements"),
            dependencies: [
                .target(name: "CorePersistence"),
                .sdk(name: "SwiftData", type: .framework, status: .required),
                .sdk(name: "WidgetKit", type: .framework, status: .required)
            ]
        ),

        // MARK: - Features

        .target(
            name: "CheckIn",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.checkin",
            deploymentTargets: deploymentTargets,
            sources: ["Features/CheckIn/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics"),
                .target(name: "CorePersistence"),
                .target(name: "CoreAI"),
                .target(name: "DesignSystem")
            ]
        ),

        .target(
            name: "Affirmation",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.affirmation",
            deploymentTargets: deploymentTargets,
            sources: ["Features/Affirmation/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics"),
                .target(name: "CorePersistence"),
                .target(name: "CoreAI"),
                .target(name: "DesignSystem")
            ]
        ),

        .target(
            name: "History",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.history",
            deploymentTargets: deploymentTargets,
            sources: ["Features/History/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics"),
                .target(name: "CorePersistence"),
                .target(name: "DesignSystem")
            ]
        ),

        .target(
            name: "Insights",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.insights",
            deploymentTargets: deploymentTargets,
            sources: ["Features/Insights/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics"),
                .target(name: "CorePersistence"),
                .target(name: "DesignSystem"),
                .sdk(name: "Charts", type: .framework, status: .required)
            ]
        ),

        .target(
            name: "Settings",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.settings",
            deploymentTargets: deploymentTargets,
            sources: ["Features/Settings/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics"),
                .target(name: "CorePersistence"),
                .target(name: "CorePurchases"),
                .target(name: "DesignSystem")
            ]
        ),

        .target(
            name: "Paywall",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.paywall",
            deploymentTargets: deploymentTargets,
            sources: ["Features/Paywall/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics"),
                .target(name: "CorePurchases"),
                .target(name: "DesignSystem")
            ]
        ),

        // MARK: - Core

        .target(
            name: "CoreAnalytics",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.core.analytics",
            deploymentTargets: deploymentTargets,
            sources: ["Core/CoreAnalytics/Sources/**"]
        ),

        .target(
            name: "CorePersistence",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.core.persistence",
            deploymentTargets: deploymentTargets,
            sources: ["Core/CorePersistence/Sources/**"],
            dependencies: [
                .sdk(name: "SwiftData", type: .framework, status: .required)
            ]
        ),

        .target(
            name: "CoreAI",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.core.ai",
            deploymentTargets: deploymentTargets,
            sources: ["Core/CoreAI/Sources/**"],
            dependencies: [
                .target(name: "CorePersistence")
            ]
        ),

        .target(
            name: "CoreNotifications",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.core.notifications",
            deploymentTargets: deploymentTargets,
            sources: ["Core/CoreNotifications/Sources/**"]
        ),

        .target(
            name: "CorePurchases",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.core.purchases",
            deploymentTargets: deploymentTargets,
            sources: ["Core/CorePurchases/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics")
            ]
        ),

        // MARK: - DesignSystem

        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .framework,
            bundleId: "danchopon.affirmations.designsystem",
            deploymentTargets: deploymentTargets,
            sources: ["DesignSystem/Sources/**"]
        )
    ]
)
