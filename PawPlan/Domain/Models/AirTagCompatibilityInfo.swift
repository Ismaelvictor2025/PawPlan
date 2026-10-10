//
//  AirTagCompatibilityInfo.swift
//  PawPlan
//
//  Created for PawPlan Care Circle AirTag & Find My Investigation.
//

import Foundation

public struct AirTagCompatibilityInfo: Sendable {
    public static let title = "Apple AirTag & Find My Compatibility Guide"

    public static let technicalSummary = """
    Apple does not provide a public, unrestricted third-party SDK or developer API that allows iOS applications to directly read live geographic coordinates from another user's AirTag.
    """

    public static let appleSecurityRationale = """
    The Apple Find My network uses end-to-end encryption with rotating public keys to prevent unwanted tracking and protect user privacy. Third-party applications cannot bypass Apple's cryptographic boundary to query AirTag locations.
    """

    public static let supportedWorkflowSteps: [String] = [
        "Open Apple's native Find My app on your iPhone.",
        "Navigate to the 'Items' tab and select your dog's AirTag or Find My collar.",
        "Tap 'Share Item Location' (iOS 17.5+ or iOS 18+).",
        "Generate a temporary, secure Find My sharing link (valid for trusted sitters).",
        "Share the link with your dog sitter via Messages or Mail. The sitter can view your dog's real-time location in Safari or Apple Maps without compromising your Apple ID security.",
        "You can stop sharing the link at any time inside the Find My app."
    ]

    public static let isThirdPartyLiveTrackingAvailable: Bool = false
    public static let limitationSummary = technicalSummary
    public static let recommendedWorkflowSteps = supportedWorkflowSteps

    public static let privacyNotice = """
    PawPlan never claims to directly track AirTags without Apple's native Find My integration. We provide voluntary in-app walk tracking via Core Location with explicit sitter consent, and recommend Apple's native Share Item Location feature for hardware tag monitoring.
    """
}
