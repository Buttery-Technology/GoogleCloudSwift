//
//  GoogleCloudProvider.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 12/9/25.
//

import Foundation

/// Represents a Google Cloud Platform configuration for running DAIS nodes.
///
/// Use this to configure your DAIS deployment on Google Cloud Platform.
/// Google Cloud offers a generous free tier and cost-effective pricing for:
/// - Compute Engine (VMs for running DAIS nodes)
/// - Secret Manager (storing encryption keys - free tier: 6 active secret versions)
/// - Cloud Storage (backups and artifacts)
///
/// ## Example Usage
/// ```swift
/// let provider = GoogleCloudProvider(
///     projectID: "my-butteryai-project",
///     region: .usWest1,
///     credentials: .serviceAccount(path: "/path/to/service-account.json")
/// )
/// ```
public struct GoogleCloudProvider: Codable, Sendable, Equatable {
    /// The Google Cloud project ID
    public let projectID: String

    /// The default region for resources
    public let region: GoogleCloudRegion

    /// Optional default zone within the region
    public let zone: String?

    /// The credential type used for authentication
    public let credentialType: GoogleCloudCredentialType

    /// Optional service account email (for impersonation or verification)
    public let serviceAccountEmail: String?

    /// Labels to apply to all created resources
    public let defaultLabels: [String: String]

    public init(
        projectID: String,
        region: GoogleCloudRegion,
        zone: String? = nil,
        credentials credentialType: GoogleCloudCredentialType = .applicationDefault,
        serviceAccountEmail: String? = nil,
        defaultLabels: [String: String] = [:]
    ) {
        self.projectID = projectID
        self.region = region
        self.zone = zone
        self.credentialType = credentialType
        self.serviceAccountEmail = serviceAccountEmail
        self.defaultLabels = defaultLabels
    }
}

// MARK: - Credential Types

/// Represents the authentication method for Google Cloud APIs
public enum GoogleCloudCredentialType: Codable, Sendable, Equatable {
    /// Use Application Default Credentials (ADC)
    /// Automatically discovers credentials from:
    /// 1. GOOGLE_APPLICATION_CREDENTIALS environment variable
    /// 2. gcloud CLI default credentials
    /// 3. Compute Engine/Cloud Run metadata service
    case applicationDefault

    /// Use a service account key file
    case serviceAccount(path: String)

    /// Use a service account key from JSON string (for secrets)
    case serviceAccountJSON(json: String)

    /// Use workload identity (for GKE)
    case workloadIdentity

    /// Environment variable name containing the credential type
    public static let environmentVariable = "GOOGLE_APPLICATION_CREDENTIALS"
}

// MARK: - Regions

/// Google Cloud Platform regions
public enum GoogleCloudRegion: String, Codable, Sendable, CaseIterable {
    // Americas
    case usWest1 = "us-west1"           // Oregon
    case usWest2 = "us-west2"           // Los Angeles
    case usWest3 = "us-west3"           // Salt Lake City
    case usWest4 = "us-west4"           // Las Vegas
    case usCentral1 = "us-central1"     // Iowa
    case usEast1 = "us-east1"           // South Carolina
    case usEast4 = "us-east4"           // Northern Virginia
    case usEast5 = "us-east5"           // Columbus
    case usSouth1 = "us-south1"         // Dallas
    case northamericaNortheast1 = "northamerica-northeast1" // Montreal
    case northamericaNortheast2 = "northamerica-northeast2" // Toronto
    case southamericaEast1 = "southamerica-east1"           // Sao Paulo
    case southamericaWest1 = "southamerica-west1"           // Santiago

    // Europe
    case europeWest1 = "europe-west1"   // Belgium
    case europeWest2 = "europe-west2"   // London
    case europeWest3 = "europe-west3"   // Frankfurt
    case europeWest4 = "europe-west4"   // Netherlands
    case europeWest6 = "europe-west6"   // Zurich
    case europeWest8 = "europe-west8"   // Milan
    case europeWest9 = "europe-west9"   // Paris
    case europeNorth1 = "europe-north1" // Finland
    case europeCentral2 = "europe-central2" // Warsaw

    // Asia Pacific
    case asiaSoutheast1 = "asia-southeast1" // Singapore
    case asiaSoutheast2 = "asia-southeast2" // Jakarta
    case asiaEast1 = "asia-east1"           // Taiwan
    case asiaEast2 = "asia-east2"           // Hong Kong
    case asiaNortheast1 = "asia-northeast1" // Tokyo
    case asiaNortheast2 = "asia-northeast2" // Osaka
    case asiaNortheast3 = "asia-northeast3" // Seoul
    case asiaSouth1 = "asia-south1"         // Mumbai
    case asiaSouth2 = "asia-south2"         // Delhi

    // Australia
    case australiaSoutheast1 = "australia-southeast1" // Sydney
    case australiaSoutheast2 = "australia-southeast2" // Melbourne

    // Middle East
    case meWest1 = "me-west1"           // Tel Aviv
    case meCentral1 = "me-central1"     // Doha

    /// Human-readable location name
    public var displayName: String {
        switch self {
        case .usWest1: return "Oregon, USA"
        case .usWest2: return "Los Angeles, USA"
        case .usWest3: return "Salt Lake City, USA"
        case .usWest4: return "Las Vegas, USA"
        case .usCentral1: return "Iowa, USA"
        case .usEast1: return "South Carolina, USA"
        case .usEast4: return "Northern Virginia, USA"
        case .usEast5: return "Columbus, USA"
        case .usSouth1: return "Dallas, USA"
        case .northamericaNortheast1: return "Montreal, Canada"
        case .northamericaNortheast2: return "Toronto, Canada"
        case .southamericaEast1: return "Sao Paulo, Brazil"
        case .southamericaWest1: return "Santiago, Chile"
        case .europeWest1: return "Belgium"
        case .europeWest2: return "London, UK"
        case .europeWest3: return "Frankfurt, Germany"
        case .europeWest4: return "Netherlands"
        case .europeWest6: return "Zurich, Switzerland"
        case .europeWest8: return "Milan, Italy"
        case .europeWest9: return "Paris, France"
        case .europeNorth1: return "Finland"
        case .europeCentral2: return "Warsaw, Poland"
        case .asiaSoutheast1: return "Singapore"
        case .asiaSoutheast2: return "Jakarta, Indonesia"
        case .asiaEast1: return "Taiwan"
        case .asiaEast2: return "Hong Kong"
        case .asiaNortheast1: return "Tokyo, Japan"
        case .asiaNortheast2: return "Osaka, Japan"
        case .asiaNortheast3: return "Seoul, South Korea"
        case .asiaSouth1: return "Mumbai, India"
        case .asiaSouth2: return "Delhi, India"
        case .australiaSoutheast1: return "Sydney, Australia"
        case .australiaSoutheast2: return "Melbourne, Australia"
        case .meWest1: return "Tel Aviv, Israel"
        case .meCentral1: return "Doha, Qatar"
        }
    }

    /// Default zone for this region (typically zone 'a')
    public var defaultZone: String {
        "\(rawValue)-a"
    }

    /// All available zones for this region
    public var availableZones: [String] {
        ["\(rawValue)-a", "\(rawValue)-b", "\(rawValue)-c"]
    }
}
