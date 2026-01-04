// GoogleCloudHealthcare.swift
// Cloud Healthcare API - Healthcare data storage and management
// Service #57

import Foundation

// MARK: - Healthcare Dataset

/// A healthcare dataset containing FHIR, HL7v2, and DICOM stores
public struct GoogleCloudHealthcareDataset: Codable, Sendable, Equatable {
    public let name: String
    public let projectID: String
    public let location: String
    public let timeZone: String?
    public let labels: [String: String]?

    public init(
        name: String,
        projectID: String,
        location: String,
        timeZone: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.projectID = projectID
        self.location = location
        self.timeZone = timeZone
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/datasets/\(name)"
    }

    /// Create dataset command
    public var createCommand: String {
        var cmd = "gcloud healthcare datasets create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        if let tz = timeZone {
            cmd += " --time-zone=\(tz)"
        }
        return cmd
    }

    /// Describe dataset command
    public var describeCommand: String {
        "gcloud healthcare datasets describe \(name) --project=\(projectID) --location=\(location)"
    }

    /// Delete dataset command
    public var deleteCommand: String {
        "gcloud healthcare datasets delete \(name) --project=\(projectID) --location=\(location)"
    }

    /// List datasets command
    public static func listCommand(projectID: String, location: String) -> String {
        "gcloud healthcare datasets list --project=\(projectID) --location=\(location)"
    }
}

// MARK: - FHIR Store

/// A FHIR (Fast Healthcare Interoperability Resources) store
public struct GoogleCloudFHIRStore: Codable, Sendable, Equatable {
    public let name: String
    public let dataset: String
    public let projectID: String
    public let location: String
    public let version: FHIRVersion
    public let enableUpdateCreate: Bool?
    public let disableReferentialIntegrity: Bool?
    public let disableResourceVersioning: Bool?
    public let enableHistoryImport: Bool?
    public let notificationConfig: NotificationConfig?
    public let streamConfigs: [StreamConfig]?
    public let validationConfig: ValidationConfig?
    public let labels: [String: String]?

    public init(
        name: String,
        dataset: String,
        projectID: String,
        location: String,
        version: FHIRVersion = .r4,
        enableUpdateCreate: Bool? = nil,
        disableReferentialIntegrity: Bool? = nil,
        disableResourceVersioning: Bool? = nil,
        enableHistoryImport: Bool? = nil,
        notificationConfig: NotificationConfig? = nil,
        streamConfigs: [StreamConfig]? = nil,
        validationConfig: ValidationConfig? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.dataset = dataset
        self.projectID = projectID
        self.location = location
        self.version = version
        self.enableUpdateCreate = enableUpdateCreate
        self.disableReferentialIntegrity = disableReferentialIntegrity
        self.disableResourceVersioning = disableResourceVersioning
        self.enableHistoryImport = enableHistoryImport
        self.notificationConfig = notificationConfig
        self.streamConfigs = streamConfigs
        self.validationConfig = validationConfig
        self.labels = labels
    }

    /// FHIR version
    public enum FHIRVersion: String, Codable, Sendable {
        case dstu2 = "DSTU2"
        case stu3 = "STU3"
        case r4 = "R4"
    }

    /// Notification configuration
    public struct NotificationConfig: Codable, Sendable, Equatable {
        public let pubsubTopic: String
        public let sendForBulkImport: Bool?

        public init(pubsubTopic: String, sendForBulkImport: Bool? = nil) {
            self.pubsubTopic = pubsubTopic
            self.sendForBulkImport = sendForBulkImport
        }
    }

    /// Stream configuration for BigQuery export
    public struct StreamConfig: Codable, Sendable, Equatable {
        public let bigQueryDestination: BigQueryDestination?
        public let resourceTypes: [String]?

        public init(bigQueryDestination: BigQueryDestination? = nil, resourceTypes: [String]? = nil) {
            self.bigQueryDestination = bigQueryDestination
            self.resourceTypes = resourceTypes
        }

        public struct BigQueryDestination: Codable, Sendable, Equatable {
            public let datasetUri: String
            public let schemaConfig: SchemaConfig?
            public let force: Bool?

            public init(datasetUri: String, schemaConfig: SchemaConfig? = nil, force: Bool? = nil) {
                self.datasetUri = datasetUri
                self.schemaConfig = schemaConfig
                self.force = force
            }

            public struct SchemaConfig: Codable, Sendable, Equatable {
                public let schemaType: SchemaType?
                public let recursiveStructureDepth: Int?

                public init(schemaType: SchemaType? = nil, recursiveStructureDepth: Int? = nil) {
                    self.schemaType = schemaType
                    self.recursiveStructureDepth = recursiveStructureDepth
                }

                public enum SchemaType: String, Codable, Sendable {
                    case schemaTypeUnspecified = "SCHEMA_TYPE_UNSPECIFIED"
                    case lossless = "LOSSLESS"
                    case analytics = "ANALYTICS"
                    case analyticsV2 = "ANALYTICS_V2"
                }
            }
        }
    }

    /// Validation configuration
    public struct ValidationConfig: Codable, Sendable, Equatable {
        public let disableProfileValidation: Bool?
        public let enabledImplementationGuides: [String]?

        public init(disableProfileValidation: Bool? = nil, enabledImplementationGuides: [String]? = nil) {
            self.disableProfileValidation = disableProfileValidation
            self.enabledImplementationGuides = enabledImplementationGuides
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/datasets/\(dataset)/fhirStores/\(name)"
    }

    /// Create FHIR store command
    public var createCommand: String {
        var cmd = "gcloud healthcare fhir-stores create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --dataset=\(dataset)"
        cmd += " --version=\(version.rawValue)"
        if enableUpdateCreate == true {
            cmd += " --enable-update-create"
        }
        if disableReferentialIntegrity == true {
            cmd += " --disable-referential-integrity"
        }
        return cmd
    }

    /// Describe FHIR store command
    public var describeCommand: String {
        "gcloud healthcare fhir-stores describe \(name) --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// Delete FHIR store command
    public var deleteCommand: String {
        "gcloud healthcare fhir-stores delete \(name) --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// FHIR API endpoint
    public var fhirEndpoint: String {
        "https://healthcare.googleapis.com/v1/\(resourceName)/fhir"
    }
}

// MARK: - HL7v2 Store

/// An HL7v2 store for healthcare messaging
public struct GoogleCloudHL7v2Store: Codable, Sendable, Equatable {
    public let name: String
    public let dataset: String
    public let projectID: String
    public let location: String
    public let parserConfig: ParserConfig?
    public let notificationConfigs: [NotificationConfig]?
    public let labels: [String: String]?

    public init(
        name: String,
        dataset: String,
        projectID: String,
        location: String,
        parserConfig: ParserConfig? = nil,
        notificationConfigs: [NotificationConfig]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.dataset = dataset
        self.projectID = projectID
        self.location = location
        self.parserConfig = parserConfig
        self.notificationConfigs = notificationConfigs
        self.labels = labels
    }

    /// Parser configuration
    public struct ParserConfig: Codable, Sendable, Equatable {
        public let allowNullHeader: Bool?
        public let segmentTerminator: String?
        public let version: Version?

        public init(
            allowNullHeader: Bool? = nil,
            segmentTerminator: String? = nil,
            version: Version? = nil
        ) {
            self.allowNullHeader = allowNullHeader
            self.segmentTerminator = segmentTerminator
            self.version = version
        }

        public enum Version: String, Codable, Sendable {
            case v1 = "V1"
            case v2 = "V2"
            case v3 = "V3"
        }
    }

    /// Notification configuration
    public struct NotificationConfig: Codable, Sendable, Equatable {
        public let pubsubTopic: String
        public let filter: String?

        public init(pubsubTopic: String, filter: String? = nil) {
            self.pubsubTopic = pubsubTopic
            self.filter = filter
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/datasets/\(dataset)/hl7V2Stores/\(name)"
    }

    /// Create HL7v2 store command
    public var createCommand: String {
        var cmd = "gcloud healthcare hl7v2-stores create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --dataset=\(dataset)"
        return cmd
    }

    /// Describe HL7v2 store command
    public var describeCommand: String {
        "gcloud healthcare hl7v2-stores describe \(name) --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// Delete HL7v2 store command
    public var deleteCommand: String {
        "gcloud healthcare hl7v2-stores delete \(name) --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }
}

// MARK: - DICOM Store

/// A DICOM (Digital Imaging and Communications in Medicine) store
public struct GoogleCloudDICOMStore: Codable, Sendable, Equatable {
    public let name: String
    public let dataset: String
    public let projectID: String
    public let location: String
    public let notificationConfig: NotificationConfig?
    public let streamConfigs: [StreamConfig]?
    public let labels: [String: String]?

    public init(
        name: String,
        dataset: String,
        projectID: String,
        location: String,
        notificationConfig: NotificationConfig? = nil,
        streamConfigs: [StreamConfig]? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.dataset = dataset
        self.projectID = projectID
        self.location = location
        self.notificationConfig = notificationConfig
        self.streamConfigs = streamConfigs
        self.labels = labels
    }

    /// Notification configuration
    public struct NotificationConfig: Codable, Sendable, Equatable {
        public let pubsubTopic: String
        public let sendForBulkImport: Bool?

        public init(pubsubTopic: String, sendForBulkImport: Bool? = nil) {
            self.pubsubTopic = pubsubTopic
            self.sendForBulkImport = sendForBulkImport
        }
    }

    /// Stream configuration for BigQuery export
    public struct StreamConfig: Codable, Sendable, Equatable {
        public let bigQueryDestination: BigQueryDestination?

        public init(bigQueryDestination: BigQueryDestination? = nil) {
            self.bigQueryDestination = bigQueryDestination
        }

        public struct BigQueryDestination: Codable, Sendable, Equatable {
            public let tableUri: String
            public let force: Bool?

            public init(tableUri: String, force: Bool? = nil) {
                self.tableUri = tableUri
                self.force = force
            }
        }
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/datasets/\(dataset)/dicomStores/\(name)"
    }

    /// Create DICOM store command
    public var createCommand: String {
        var cmd = "gcloud healthcare dicom-stores create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --dataset=\(dataset)"
        return cmd
    }

    /// Describe DICOM store command
    public var describeCommand: String {
        "gcloud healthcare dicom-stores describe \(name) --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// Delete DICOM store command
    public var deleteCommand: String {
        "gcloud healthcare dicom-stores delete \(name) --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// DICOMweb API endpoint
    public var dicomWebEndpoint: String {
        "https://healthcare.googleapis.com/v1/\(resourceName)/dicomWeb"
    }
}

// MARK: - Consent Store

/// A consent store for managing patient consent
public struct GoogleCloudConsentStore: Codable, Sendable, Equatable {
    public let name: String
    public let dataset: String
    public let projectID: String
    public let location: String
    public let enableConsentCreateOnUpdate: Bool?
    public let defaultConsentTtl: String?
    public let labels: [String: String]?

    public init(
        name: String,
        dataset: String,
        projectID: String,
        location: String,
        enableConsentCreateOnUpdate: Bool? = nil,
        defaultConsentTtl: String? = nil,
        labels: [String: String]? = nil
    ) {
        self.name = name
        self.dataset = dataset
        self.projectID = projectID
        self.location = location
        self.enableConsentCreateOnUpdate = enableConsentCreateOnUpdate
        self.defaultConsentTtl = defaultConsentTtl
        self.labels = labels
    }

    /// Resource name
    public var resourceName: String {
        "projects/\(projectID)/locations/\(location)/datasets/\(dataset)/consentStores/\(name)"
    }

    /// Create consent store command
    public var createCommand: String {
        var cmd = "gcloud healthcare consent-stores create \(name)"
        cmd += " --project=\(projectID)"
        cmd += " --location=\(location)"
        cmd += " --dataset=\(dataset)"
        if let ttl = defaultConsentTtl {
            cmd += " --default-consent-ttl=\(ttl)"
        }
        return cmd
    }

    /// Describe consent store command
    public var describeCommand: String {
        "gcloud healthcare consent-stores describe \(name) --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }
}

// MARK: - FHIR Resources

/// Common FHIR resource types
public enum FHIRResourceType: String, Codable, Sendable {
    case patient = "Patient"
    case observation = "Observation"
    case condition = "Condition"
    case medicationRequest = "MedicationRequest"
    case procedure = "Procedure"
    case encounter = "Encounter"
    case diagnosticReport = "DiagnosticReport"
    case immunization = "Immunization"
    case allergyIntolerance = "AllergyIntolerance"
    case carePlan = "CarePlan"
    case practitioner = "Practitioner"
    case organization = "Organization"
    case location = "Location"
    case device = "Device"
    case claim = "Claim"
    case coverage = "Coverage"
    case explanationOfBenefit = "ExplanationOfBenefit"
}

/// FHIR operations helper
public struct FHIROperations: Sendable {
    public let store: GoogleCloudFHIRStore

    public init(store: GoogleCloudFHIRStore) {
        self.store = store
    }

    /// Read a FHIR resource
    public func readCommand(resourceType: FHIRResourceType, resourceID: String) -> String {
        "curl -X GET \"\(store.fhirEndpoint)/\(resourceType.rawValue)/\(resourceID)\" -H \"Authorization: Bearer $(gcloud auth print-access-token)\""
    }

    /// Search FHIR resources
    public func searchCommand(resourceType: FHIRResourceType, parameters: [String: String] = [:]) -> String {
        var url = "\(store.fhirEndpoint)/\(resourceType.rawValue)"
        if !parameters.isEmpty {
            let queryString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            url += "?\(queryString)"
        }
        return "curl -X GET \"\(url)\" -H \"Authorization: Bearer $(gcloud auth print-access-token)\""
    }

    /// Create a FHIR resource
    public func createCommand(resourceType: FHIRResourceType, dataFile: String) -> String {
        "curl -X POST \"\(store.fhirEndpoint)/\(resourceType.rawValue)\" -H \"Authorization: Bearer $(gcloud auth print-access-token)\" -H \"Content-Type: application/fhir+json\" -d @\(dataFile)"
    }

    /// Update a FHIR resource
    public func updateCommand(resourceType: FHIRResourceType, resourceID: String, dataFile: String) -> String {
        "curl -X PUT \"\(store.fhirEndpoint)/\(resourceType.rawValue)/\(resourceID)\" -H \"Authorization: Bearer $(gcloud auth print-access-token)\" -H \"Content-Type: application/fhir+json\" -d @\(dataFile)"
    }

    /// Delete a FHIR resource
    public func deleteCommand(resourceType: FHIRResourceType, resourceID: String) -> String {
        "curl -X DELETE \"\(store.fhirEndpoint)/\(resourceType.rawValue)/\(resourceID)\" -H \"Authorization: Bearer $(gcloud auth print-access-token)\""
    }

    /// Bulk export command
    public var bulkExportCommand: String {
        "curl -X GET \"\(store.fhirEndpoint)/$export\" -H \"Authorization: Bearer $(gcloud auth print-access-token)\" -H \"Accept: application/fhir+json\" -H \"Prefer: respond-async\""
    }
}

// MARK: - Healthcare Operations

/// Operations for Cloud Healthcare API
public struct HealthcareOperations: Sendable {
    public let projectID: String
    public let location: String

    public init(projectID: String, location: String = "us-central1") {
        self.projectID = projectID
        self.location = location
    }

    /// Enable Healthcare API
    public var enableAPICommand: String {
        "gcloud services enable healthcare.googleapis.com --project=\(projectID)"
    }

    /// List datasets
    public var listDatasetsCommand: String {
        "gcloud healthcare datasets list --project=\(projectID) --location=\(location)"
    }

    /// List FHIR stores in a dataset
    public func listFHIRStoresCommand(dataset: String) -> String {
        "gcloud healthcare fhir-stores list --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// List HL7v2 stores in a dataset
    public func listHL7v2StoresCommand(dataset: String) -> String {
        "gcloud healthcare hl7v2-stores list --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// List DICOM stores in a dataset
    public func listDICOMStoresCommand(dataset: String) -> String {
        "gcloud healthcare dicom-stores list --project=\(projectID) --location=\(location) --dataset=\(dataset)"
    }

    /// Import FHIR data from GCS
    public func importFHIRCommand(dataset: String, fhirStore: String, gcsUri: String, contentStructure: String = "BUNDLE") -> String {
        """
        gcloud healthcare fhir-stores import gcs \(fhirStore) \\
            --project=\(projectID) \\
            --location=\(location) \\
            --dataset=\(dataset) \\
            --gcs-uri=\(gcsUri) \\
            --content-structure=\(contentStructure)
        """
    }

    /// Export FHIR data to GCS
    public func exportFHIRCommand(dataset: String, fhirStore: String, gcsUri: String) -> String {
        """
        gcloud healthcare fhir-stores export gcs \(fhirStore) \\
            --project=\(projectID) \\
            --location=\(location) \\
            --dataset=\(dataset) \\
            --gcs-uri=\(gcsUri)
        """
    }

    /// Import DICOM data from GCS
    public func importDICOMCommand(dataset: String, dicomStore: String, gcsUri: String) -> String {
        """
        gcloud healthcare dicom-stores import gcs \(dicomStore) \\
            --project=\(projectID) \\
            --location=\(location) \\
            --dataset=\(dataset) \\
            --gcs-uri=\(gcsUri)
        """
    }

    /// Export DICOM data to GCS
    public func exportDICOMCommand(dataset: String, dicomStore: String, gcsUri: String) -> String {
        """
        gcloud healthcare dicom-stores export gcs \(dicomStore) \\
            --project=\(projectID) \\
            --location=\(location) \\
            --dataset=\(dataset) \\
            --gcs-uri=\(gcsUri)
        """
    }

    /// De-identify a dataset
    public func deidentifyDatasetCommand(sourceDataset: String, destinationDataset: String) -> String {
        """
        gcloud healthcare datasets deidentify \(sourceDataset) \\
            --project=\(projectID) \\
            --location=\(location) \\
            --destination-dataset=\(destinationDataset)
        """
    }

    /// IAM roles for Healthcare
    public enum HealthcareRole: String, Sendable {
        case healthcareDatasetAdmin = "roles/healthcare.datasetAdmin"
        case healthcareDatasetViewer = "roles/healthcare.datasetViewer"
        case healthcareFhirStoreAdmin = "roles/healthcare.fhirStoreAdmin"
        case healthcareFhirResourceReader = "roles/healthcare.fhirResourceReader"
        case healthcareFhirResourceEditor = "roles/healthcare.fhirResourceEditor"
        case healthcareDicomStoreAdmin = "roles/healthcare.dicomStoreAdmin"
        case healthcareDicomEditor = "roles/healthcare.dicomEditor"
        case healthcareHl7v2StoreAdmin = "roles/healthcare.hl7V2StoreAdmin"
    }

    /// Add IAM binding
    public func addIAMBindingCommand(member: String, role: HealthcareRole, dataset: String) -> String {
        "gcloud healthcare datasets add-iam-policy-binding \(dataset) --project=\(projectID) --location=\(location) --member=\(member) --role=\(role.rawValue)"
    }
}

// MARK: - DAIS Healthcare Template

/// DAIS template for Healthcare configurations
public struct DAISHealthcareTemplate: Sendable {
    public let projectID: String
    public let location: String

    public init(projectID: String, location: String = "us-central1") {
        self.projectID = projectID
        self.location = location
    }

    /// Create a healthcare dataset
    public func dataset(name: String, timeZone: String = "America/Los_Angeles") -> GoogleCloudHealthcareDataset {
        GoogleCloudHealthcareDataset(
            name: name,
            projectID: projectID,
            location: location,
            timeZone: timeZone
        )
    }

    /// Create an R4 FHIR store with BigQuery streaming
    public func fhirStoreR4(
        name: String,
        dataset: String,
        bigQueryDataset: String? = nil
    ) -> GoogleCloudFHIRStore {
        var streamConfigs: [GoogleCloudFHIRStore.StreamConfig]? = nil
        if let bqDataset = bigQueryDataset {
            streamConfigs = [
                GoogleCloudFHIRStore.StreamConfig(
                    bigQueryDestination: .init(
                        datasetUri: "bq://\(projectID).\(bqDataset)",
                        schemaConfig: .init(schemaType: .analyticsV2, recursiveStructureDepth: 3)
                    )
                )
            ]
        }

        return GoogleCloudFHIRStore(
            name: name,
            dataset: dataset,
            projectID: projectID,
            location: location,
            version: .r4,
            enableUpdateCreate: true,
            streamConfigs: streamConfigs
        )
    }

    /// Create an HL7v2 store with Pub/Sub notification
    public func hl7v2Store(
        name: String,
        dataset: String,
        pubsubTopic: String? = nil
    ) -> GoogleCloudHL7v2Store {
        var notificationConfigs: [GoogleCloudHL7v2Store.NotificationConfig]? = nil
        if let topic = pubsubTopic {
            notificationConfigs = [
                GoogleCloudHL7v2Store.NotificationConfig(pubsubTopic: topic)
            ]
        }

        return GoogleCloudHL7v2Store(
            name: name,
            dataset: dataset,
            projectID: projectID,
            location: location,
            parserConfig: .init(version: .v3),
            notificationConfigs: notificationConfigs
        )
    }

    /// Create a DICOM store
    public func dicomStore(
        name: String,
        dataset: String,
        pubsubTopic: String? = nil
    ) -> GoogleCloudDICOMStore {
        var notificationConfig: GoogleCloudDICOMStore.NotificationConfig? = nil
        if let topic = pubsubTopic {
            notificationConfig = GoogleCloudDICOMStore.NotificationConfig(pubsubTopic: topic)
        }

        return GoogleCloudDICOMStore(
            name: name,
            dataset: dataset,
            projectID: projectID,
            location: location,
            notificationConfig: notificationConfig
        )
    }

    /// Create a consent store
    public func consentStore(
        name: String,
        dataset: String,
        consentTtl: String = "31536000s"
    ) -> GoogleCloudConsentStore {
        GoogleCloudConsentStore(
            name: name,
            dataset: dataset,
            projectID: projectID,
            location: location,
            enableConsentCreateOnUpdate: true,
            defaultConsentTtl: consentTtl
        )
    }

    /// Operations helper
    public var operations: HealthcareOperations {
        HealthcareOperations(projectID: projectID, location: location)
    }

    /// Generate healthcare setup script
    public func setupScript(
        datasetName: String,
        fhirStoreName: String,
        dicomStoreName: String? = nil,
        hl7v2StoreName: String? = nil
    ) -> String {
        var script = """
        #!/bin/bash
        # Cloud Healthcare API Setup
        # Project: \(projectID)
        # Location: \(location)

        set -e

        PROJECT="\(projectID)"
        LOCATION="\(location)"
        DATASET="\(datasetName)"

        echo "=== Enabling Healthcare API ==="
        gcloud services enable healthcare.googleapis.com --project=$PROJECT

        echo ""
        echo "=== Creating Healthcare Dataset ==="
        gcloud healthcare datasets create $DATASET \\
            --project=$PROJECT \\
            --location=$LOCATION \\
            --time-zone=America/Los_Angeles

        echo ""
        echo "=== Creating FHIR R4 Store ==="
        gcloud healthcare fhir-stores create \(fhirStoreName) \\
            --project=$PROJECT \\
            --location=$LOCATION \\
            --dataset=$DATASET \\
            --version=R4 \\
            --enable-update-create

        """

        if let dicom = dicomStoreName {
            script += """

            echo ""
            echo "=== Creating DICOM Store ==="
            gcloud healthcare dicom-stores create \(dicom) \\
                --project=$PROJECT \\
                --location=$LOCATION \\
                --dataset=$DATASET

            """
        }

        if let hl7 = hl7v2StoreName {
            script += """

            echo ""
            echo "=== Creating HL7v2 Store ==="
            gcloud healthcare hl7v2-stores create \(hl7) \\
                --project=$PROJECT \\
                --location=$LOCATION \\
                --dataset=$DATASET

            """
        }

        script += """

        echo ""
        echo "=== Setup Complete ==="
        echo "Dataset: projects/$PROJECT/locations/$LOCATION/datasets/$DATASET"
        echo ""
        echo "FHIR Endpoint:"
        echo "https://healthcare.googleapis.com/v1/projects/$PROJECT/locations/$LOCATION/datasets/$DATASET/fhirStores/\(fhirStoreName)/fhir"
        """

        return script
    }

    /// Generate FHIR bulk import script
    public func fhirBulkImportScript(
        dataset: String,
        fhirStore: String,
        gcsUri: String
    ) -> String {
        """
        #!/bin/bash
        # FHIR Bulk Import Script
        # Project: \(projectID)

        set -e

        PROJECT="\(projectID)"
        LOCATION="\(location)"
        DATASET="\(dataset)"
        FHIR_STORE="\(fhirStore)"
        GCS_URI="\(gcsUri)"

        echo "=== Starting FHIR Bulk Import ==="
        echo "Source: $GCS_URI"
        echo "Destination: projects/$PROJECT/locations/$LOCATION/datasets/$DATASET/fhirStores/$FHIR_STORE"

        gcloud healthcare fhir-stores import gcs $FHIR_STORE \\
            --project=$PROJECT \\
            --location=$LOCATION \\
            --dataset=$DATASET \\
            --gcs-uri=$GCS_URI \\
            --content-structure=BUNDLE

        echo ""
        echo "=== Import Complete ==="
        """
    }
}
