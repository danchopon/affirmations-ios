import ProjectDescription

let deploymentTargets = DeploymentTargets.iOS("17.0")

let project = Project(
    name: "Affirmations",
    organizationName: "com.affirmations",
    options: .options(
        automaticSchemesOptions: .enabled(),
        developmentRegion: "en"
    ),
    targets: [

        // MARK: - App

        .target(
            name: "Affirmations",
            destinations: .iOS,
            product: .app,
            bundleId: "com.affirmations.app",
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
                .sdk(name: "SwiftData", type: .framework, status: .required)
            ]
        ),

        // MARK: - Features

        .target(
            name: "CheckIn",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.affirmations.checkin",
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
            bundleId: "com.affirmations.affirmation",
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
            bundleId: "com.affirmations.history",
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
            bundleId: "com.affirmations.insights",
            deploymentTargets: deploymentTargets,
            sources: ["Features/Insights/Sources/**"],
            dependencies: [
                .target(name: "CoreAnalytics"),
                .target(name: "CorePersistence"),
                .target(name: "DesignSystem")
            ]
        ),

        .target(
            name: "Settings",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.affirmations.settings",
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
            bundleId: "com.affirmations.paywall",
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
            bundleId: "com.affirmations.core.analytics",
            deploymentTargets: deploymentTargets,
            sources: ["Core/CoreAnalytics/Sources/**"]
        ),

        .target(
            name: "CorePersistence",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.affirmations.core.persistence",
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
            bundleId: "com.affirmations.core.ai",
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
            bundleId: "com.affirmations.core.notifications",
            deploymentTargets: deploymentTargets,
            sources: ["Core/CoreNotifications/Sources/**"]
        ),

        .target(
            name: "CorePurchases",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.affirmations.core.purchases",
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
            bundleId: "com.affirmations.designsystem",
            deploymentTargets: deploymentTargets,
            sources: ["DesignSystem/Sources/**"]
        )
    ]
)
