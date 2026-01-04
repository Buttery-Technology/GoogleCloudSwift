import Foundation
import Testing
@testable import GoogleCloudSwift

// MARK: - Provider Tests

@Test func testGoogleCloudProvider() {
    let provider = GoogleCloudProvider(
        projectID: "test-project",
        region: .usWest1
    )

    #expect(provider.projectID == "test-project")
    #expect(provider.region == .usWest1)
    #expect(provider.zone == nil)
}

@Test func testGoogleCloudProviderWithZone() {
    let provider = GoogleCloudProvider(
        projectID: "test-project",
        region: .usCentral1,
        zone: "us-central1-b"
    )

    #expect(provider.zone == "us-central1-b")
}

@Test func testGoogleCloudRegion() {
    let region = GoogleCloudRegion.usWest1

    #expect(region.rawValue == "us-west1")
    #expect(region.displayName == "Oregon, USA")
    #expect(region.defaultZone == "us-west1-a")
}

@Test func testGoogleCloudRegionZones() {
    let region = GoogleCloudRegion.usEast1
    #expect(region.availableZones == ["us-east1-a", "us-east1-b", "us-east1-c"])
    #expect(region.availableZones.count == 3)
}

// MARK: - Machine Type Tests

@Test func testGoogleCloudMachineType() {
    let machineType = GoogleCloudMachineType.e2Micro

    #expect(machineType.isFreeTierEligible)
    #expect(machineType.approximateMonthlyCostUSD == 0)
}

@Test func testMachineTypeNotFreeTier() {
    let machineType = GoogleCloudMachineType.e2Small

    #expect(!machineType.isFreeTierEligible)
    #expect(machineType.approximateMonthlyCostUSD == 12)
}

@Test func testMachineTypeRecommendations() {
    #expect(GoogleCloudMachineType.developmentRecommended == .e2Small)
    #expect(GoogleCloudMachineType.productionRecommended == .n2Standard2)
}

@Test func testMachineTypeRawValues() {
    #expect(GoogleCloudMachineType.e2Micro.rawValue == "e2-micro")
    #expect(GoogleCloudMachineType.n2Standard4.rawValue == "n2-standard-4")
    #expect(GoogleCloudMachineType.c3Highcpu8.rawValue == "c3-highcpu-8")
}

// MARK: - Compute Instance Tests

@Test func testComputeInstanceBasic() {
    let instance = GoogleCloudComputeInstance(
        name: "test-instance",
        machineType: .e2Medium,
        zone: "us-west1-a"
    )

    #expect(instance.name == "test-instance")
    #expect(instance.machineType == .e2Medium)
    #expect(instance.zone == "us-west1-a")
    #expect(instance.deletionProtection == false)
}

@Test func testComputeInstanceBootDiskDefaults() {
    let bootDisk = GoogleCloudComputeInstance.BootDiskConfig()

    #expect(bootDisk.image == .ubuntuLTS)
    #expect(bootDisk.sizeGB == 20)
    #expect(bootDisk.diskType == .pdBalanced)
    #expect(bootDisk.autoDelete == true)
}

@Test func testComputeInstanceBootDiskCustom() {
    let bootDisk = GoogleCloudComputeInstance.BootDiskConfig(
        image: .debian12,
        sizeGB: 50,
        diskType: .pdSSD,
        autoDelete: false
    )

    #expect(bootDisk.image == .debian12)
    #expect(bootDisk.sizeGB == 50)
    #expect(bootDisk.diskType == .pdSSD)
    #expect(bootDisk.autoDelete == false)
}

@Test func testOSImageProperties() {
    let ubuntu = GoogleCloudComputeInstance.OSImage.ubuntuLTS
    #expect(ubuntu.imageFamily == "ubuntu-2204-lts")
    #expect(ubuntu.imageProject == "ubuntu-os-cloud")
    #expect(ubuntu.displayName == "Ubuntu 22.04 LTS")

    let debian = GoogleCloudComputeInstance.OSImage.debian12
    #expect(debian.imageFamily == "debian-12")
    #expect(debian.imageProject == "debian-cloud")
}

@Test func testDiskTypeRawValues() {
    #expect(GoogleCloudComputeInstance.DiskType.pdStandard.rawValue == "pd-standard")
    #expect(GoogleCloudComputeInstance.DiskType.pdBalanced.rawValue == "pd-balanced")
    #expect(GoogleCloudComputeInstance.DiskType.pdSSD.rawValue == "pd-ssd")
    #expect(GoogleCloudComputeInstance.DiskType.pdExtreme.rawValue == "pd-extreme")
}

@Test func testNetworkConfigDefaults() {
    let network = GoogleCloudComputeInstance.NetworkConfig()

    #expect(network.network == "default")
    #expect(network.subnetwork == nil)
    #expect(network.assignExternalIP == true)
    #expect(network.externalIP == nil)
    #expect(network.networkTier == .premium)
}

@Test func testNetworkConfigCustom() {
    let network = GoogleCloudComputeInstance.NetworkConfig(
        network: "custom-vpc",
        subnetwork: "custom-subnet",
        assignExternalIP: false,
        networkTier: .standard
    )

    #expect(network.network == "custom-vpc")
    #expect(network.subnetwork == "custom-subnet")
    #expect(network.assignExternalIP == false)
    #expect(network.networkTier == .standard)
}

@Test func testServiceAccountConfig() {
    let sa = GoogleCloudComputeInstance.ServiceAccountConfig(
        email: "test@project.iam.gserviceaccount.com"
    )

    #expect(sa.email == "test@project.iam.gserviceaccount.com")
    #expect(sa.scopes == GoogleCloudComputeInstance.ServiceAccountConfig.defaultScopes)
}

@Test func testSchedulingConfigDefaults() {
    let scheduling = GoogleCloudComputeInstance.SchedulingConfig()

    #expect(scheduling.preemptible == false)
    #expect(scheduling.spot == false)
    #expect(scheduling.automaticRestart == true)
    #expect(scheduling.onHostMaintenance == .migrate)
}

@Test func testSchedulingConfigSpot() {
    let scheduling = GoogleCloudComputeInstance.SchedulingConfig.spot

    #expect(scheduling.spot == true)
    #expect(scheduling.automaticRestart == false)
    #expect(scheduling.onHostMaintenance == .terminate)
}

// MARK: - Secret Manager Tests

@Test func testGoogleCloudSecret() {
    let secret = GoogleCloudSecret(
        name: "test-secret",
        projectID: "test-project"
    )

    #expect(secret.resourceName == "projects/test-project/secrets/test-secret")
    #expect(secret.version == "latest")
}

@Test func testSecretVersionResourceName() {
    let secret = GoogleCloudSecret(
        name: "my-secret",
        projectID: "my-project",
        version: "5"
    )

    #expect(secret.versionResourceName == "projects/my-project/secrets/my-secret/versions/5")
}

@Test func testSecretCreateCommand() {
    let secret = GoogleCloudSecret(
        name: "test-secret",
        projectID: "test-project",
        replication: .automatic
    )

    #expect(secret.createCommand.contains("gcloud secrets create test-secret"))
    #expect(secret.createCommand.contains("--project=test-project"))
    #expect(secret.createCommand.contains("--replication-policy=automatic"))
}

@Test func testSecretCreateCommandWithLabels() {
    let secret = GoogleCloudSecret(
        name: "test-secret",
        projectID: "test-project",
        labels: ["env": "prod", "app": "dais"]
    )

    #expect(secret.createCommand.contains("--labels="))
    #expect(secret.createCommand.contains("env=prod") || secret.createCommand.contains("app=dais"))
}

@Test func testSecretAccessCommand() {
    let secret = GoogleCloudSecret(
        name: "my-secret",
        projectID: "my-project"
    )

    #expect(secret.accessCommand == "gcloud secrets versions access latest --secret=my-secret --project=my-project")
}

@Test func testSecretAsEnvironmentVariable() {
    let secret = GoogleCloudSecret(
        name: "api-key",
        projectID: "test-project"
    )

    let envVar = secret.asEnvironmentVariable(variableName: "API_KEY")
    #expect(envVar.contains("export API_KEY="))
    #expect(envVar.contains("gcloud secrets versions access"))
}

@Test func testSecretVersionStates() {
    #expect(GoogleCloudSecretVersion.VersionState.enabled.rawValue == "ENABLED")
    #expect(GoogleCloudSecretVersion.VersionState.disabled.rawValue == "DISABLED")
    #expect(GoogleCloudSecretVersion.VersionState.destroyed.rawValue == "DESTROYED")
}

@Test func testDAISSecretTemplates() {
    let masterKey = DAISSecretTemplate.certificateMasterKey(projectID: "test-project")
    #expect(masterKey.name == "butteryai-certificate-master-key")
    #expect(masterKey.labels["sensitivity"] == "critical")

    let dbURL = DAISSecretTemplate.databaseURL(projectID: "test-project")
    #expect(dbURL.name == "butteryai-database-url")
    #expect(dbURL.labels["component"] == "database")
}

@Test func testSecretManagerIAMBinding() {
    let binding = SecretManagerIAMBinding(
        secretName: "my-secret",
        projectID: "my-project",
        role: .secretAccessor,
        member: "serviceAccount:sa@project.iam.gserviceaccount.com"
    )

    #expect(binding.secretResourceName == "projects/my-project/secrets/my-secret")
    #expect(binding.addBindingCommand.contains("gcloud secrets add-iam-policy-binding my-secret"))
    #expect(binding.addBindingCommand.contains("--project=my-project"))
    #expect(binding.addBindingCommand.contains("--role=roles/secretmanager.secretAccessor"))
}

@Test func testSecretManagerIAMBindingFromSecret() {
    let secret = GoogleCloudSecret(name: "test-secret", projectID: "test-project")
    let binding = SecretManagerIAMBinding(
        secret: secret,
        role: .secretAdmin,
        member: "user:admin@example.com"
    )

    #expect(binding.secretName == "test-secret")
    #expect(binding.projectID == "test-project")
}

// MARK: - Storage Tests

@Test func testStorageBucketBasic() {
    let bucket = GoogleCloudStorageBucket(
        name: "my-bucket",
        projectID: "test-project"
    )

    #expect(bucket.name == "my-bucket")
    #expect(bucket.gsutilURI == "gs://my-bucket")
    #expect(bucket.location == .usWest1)
    #expect(bucket.storageClass == .standard)
    #expect(bucket.versioning == true)
    #expect(bucket.uniformBucketLevelAccess == true)
}

@Test func testStorageBucketCreateCommand() {
    let bucket = GoogleCloudStorageBucket(
        name: "test-bucket",
        projectID: "test-project",
        location: .usCentral1,
        storageClass: .nearline
    )

    #expect(bucket.createCommand.contains("gcloud storage buckets create gs://test-bucket"))
    #expect(bucket.createCommand.contains("--project=test-project"))
    #expect(bucket.createCommand.contains("--location=us-central1"))
    #expect(bucket.createCommand.contains("--default-storage-class=NEARLINE"))
}

@Test func testStorageBucketCreateCommandWithVersioning() {
    let bucket = GoogleCloudStorageBucket(
        name: "test-bucket",
        projectID: "test-project",
        versioning: true
    )

    #expect(bucket.createCommand.contains("--enable-versioning"))
}

@Test func testStorageBucketCreateCommandWithLabels() {
    let bucket = GoogleCloudStorageBucket(
        name: "test-bucket",
        projectID: "test-project",
        labels: ["env": "test", "team": "platform"]
    )

    #expect(bucket.createCommand.contains("--labels="))
}

@Test func testStorageClassValues() {
    #expect(GoogleCloudStorageBucket.StorageClass.standard.rawValue == "STANDARD")
    #expect(GoogleCloudStorageBucket.StorageClass.nearline.rawValue == "NEARLINE")
    #expect(GoogleCloudStorageBucket.StorageClass.coldline.rawValue == "COLDLINE")
    #expect(GoogleCloudStorageBucket.StorageClass.archive.rawValue == "ARCHIVE")
}

@Test func testStorageClassCosts() {
    #expect(GoogleCloudStorageBucket.StorageClass.standard.approximateCostPerGBMonth == 0.020)
    #expect(GoogleCloudStorageBucket.StorageClass.archive.approximateCostPerGBMonth == 0.0012)
}

@Test func testBucketLocationMultiRegion() {
    #expect(GoogleCloudStorageBucket.BucketLocation.us.isMultiRegion == true)
    #expect(GoogleCloudStorageBucket.BucketLocation.eu.isMultiRegion == true)
    #expect(GoogleCloudStorageBucket.BucketLocation.usWest1.isMultiRegion == false)
}

@Test func testLifecycleRulePresets() {
    let nearlineRule = GoogleCloudStorageBucket.LifecycleRule.moveToNearlineAfter30Days
    #expect(nearlineRule.condition.ageDays == 30)

    let coldlineRule = GoogleCloudStorageBucket.LifecycleRule.moveToColdlineAfter90Days
    #expect(coldlineRule.condition.ageDays == 90)

    let archiveRule = GoogleCloudStorageBucket.LifecycleRule.moveToArchiveAfter365Days
    #expect(archiveRule.condition.ageDays == 365)
}

@Test func testLifecycleJSON() {
    let bucket = GoogleCloudStorageBucket(
        name: "test-bucket",
        projectID: "test-project",
        lifecycleRules: [.moveToColdlineAfter90Days]
    )

    let json = bucket.lifecycleJSON
    #expect(json != nil)
    #expect(json!.contains("\"age\" : 90"))
    #expect(json!.contains("SetStorageClass"))
    #expect(json!.contains("COLDLINE"))
}

@Test func testLifecycleJSONEmpty() {
    let bucket = GoogleCloudStorageBucket(
        name: "test-bucket",
        projectID: "test-project",
        lifecycleRules: []
    )

    #expect(bucket.lifecycleJSON == nil)
    #expect(bucket.lifecycleCommand == nil)
}

@Test func testDAISBucketTemplates() {
    let certBucket = DAISBucketTemplate.certificateBackups(projectID: "test", bucketSuffix: "abc")
    #expect(certBucket.name == "butteryai-cert-backups-abc")
    #expect(certBucket.versioning == true)
    #expect(certBucket.lifecycleRules.count == 2)

    let logBucket = DAISBucketTemplate.logArchives(projectID: "test", bucketSuffix: "abc")
    #expect(logBucket.storageClass == .nearline)
    #expect(logBucket.versioning == false)

    let artifactBucket = DAISBucketTemplate.artifacts(projectID: "test", bucketSuffix: "abc")
    #expect(artifactBucket.storageClass == .standard)
}

// MARK: - DAIS Deployment Tests

@Test func testDAISDeploymentBasic() {
    let provider = GoogleCloudProvider(projectID: "test-project", region: .usWest1)
    let deployment = GoogleCloudDAISDeployment(
        name: "test-deployment",
        provider: provider
    )

    #expect(deployment.name == "test-deployment")
    #expect(deployment.nodeCount == 1)
    #expect(deployment.machineType == .e2Medium)
    #expect(deployment.grpcPort == 9090)
    #expect(deployment.httpPort == 8080)
    #expect(deployment.useSpotInstances == false)
}

@Test func testDAISDeploymentCustom() {
    let provider = GoogleCloudProvider(projectID: "test-project", region: .usCentral1)
    let deployment = GoogleCloudDAISDeployment(
        name: "prod",
        provider: provider,
        nodeCount: 3,
        machineType: .n2Standard4,
        grpcPort: 50051,
        httpPort: 8000,
        useSpotInstances: true
    )

    #expect(deployment.nodeCount == 3)
    #expect(deployment.machineType == .n2Standard4)
    #expect(deployment.grpcPort == 50051)
    #expect(deployment.httpPort == 8000)
    #expect(deployment.useSpotInstances == true)
}

@Test func testDAISDeploymentEstimatedCost() {
    let provider = GoogleCloudProvider(projectID: "test-project", region: .usWest1)

    let standardDeployment = GoogleCloudDAISDeployment(
        name: "standard",
        provider: provider,
        nodeCount: 2,
        machineType: .e2Medium,
        useSpotInstances: false
    )
    // e2Medium = $24/month * 2 nodes + $5 storage = $53
    #expect(standardDeployment.estimatedMonthlyCostUSD == 53)

    let spotDeployment = GoogleCloudDAISDeployment(
        name: "spot",
        provider: provider,
        nodeCount: 2,
        machineType: .e2Medium,
        useSpotInstances: true
    )
    // With 70% discount: ($24 * 2 * 0.3) + $5 = $19.40
    #expect(spotDeployment.estimatedMonthlyCostUSD == 19.4)
}

@Test func testDAISDeploymentFirewallRules() {
    let provider = GoogleCloudProvider(projectID: "test-project", region: .usWest1)
    let deployment = GoogleCloudDAISDeployment(
        name: "test",
        provider: provider,
        grpcPort: 9090,
        httpPort: 8080
    )

    let rules = deployment.firewallRules
    #expect(rules.count == 3)

    // Check internal gRPC rule
    let internalGrpc = rules.first { $0.name == "test-allow-grpc-internal" }
    #expect(internalGrpc != nil)
    #expect(internalGrpc?.allowedPorts == ["9090"])
    #expect(internalGrpc?.sourceTags == ["test-dais"])

    // Check HTTP rule
    let httpRule = rules.first { $0.name == "test-allow-http" }
    #expect(httpRule != nil)
    #expect(httpRule?.allowedPorts == ["8080"])
    #expect(httpRule?.sourceRanges == ["0.0.0.0/0"])
}

@Test func testFirewallRuleCreateCommand() {
    let rule = GoogleCloudDAISDeployment.FirewallRule(
        name: "test-rule",
        network: "default",
        direction: "INGRESS",
        priority: 1000,
        targetTags: ["web-server"],
        sourceTags: nil,
        sourceRanges: ["10.0.0.0/8"],
        allowedPorts: ["80", "443"],
        protocol_: "tcp"
    )

    let cmd = rule.createCommand
    #expect(cmd.contains("gcloud compute firewall-rules create test-rule"))
    #expect(cmd.contains("--network=default"))
    #expect(cmd.contains("--direction=INGRESS"))
    #expect(cmd.contains("--rules=tcp:80,443"))
    #expect(cmd.contains("--source-ranges=10.0.0.0/8"))
}

@Test func testDAISDeploymentSetupScript() {
    let provider = GoogleCloudProvider(projectID: "test-project", region: .usWest1)
    let deployment = GoogleCloudDAISDeployment(
        name: "test",
        provider: provider
    )

    let script = deployment.setupScript
    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("PROJECT_ID=\"test-project\""))
    #expect(script.contains("gcloud services enable compute.googleapis.com"))
    #expect(script.contains("gcloud secrets create"))
    #expect(script.contains("gcloud storage buckets create"))
    #expect(script.contains("gcloud compute instances create"))
}

@Test func testDAISDeploymentTeardownScript() {
    let provider = GoogleCloudProvider(projectID: "test-project", region: .usWest1)
    let deployment = GoogleCloudDAISDeployment(
        name: "test",
        provider: provider,
        nodeCount: 2
    )

    let script = deployment.teardownScript
    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud compute instances delete"))
    #expect(script.contains("gcloud compute firewall-rules delete"))
    #expect(script.contains("for i in $(seq 1 2)"))
}

@Test func testDAISDeploymentInstanceConfig() {
    let provider = GoogleCloudProvider(projectID: "test-project", region: .usWest1)
    let deployment = GoogleCloudDAISDeployment(
        name: "myapp",
        provider: provider,
        machineType: .n2Standard2,
        useSpotInstances: true
    )

    let instance = deployment.instanceConfig
    #expect(instance.name == "myapp-dais-node")
    #expect(instance.machineType == .n2Standard2)
    #expect(instance.scheduling.spot == true)
    #expect(instance.networkTags.contains("myapp-dais"))
    #expect(instance.labels["app"] == "butteryai")
}

// MARK: - Codable Tests

@Test func testProviderCodable() throws {
    let provider = GoogleCloudProvider(projectID: "test", region: .europeWest1)
    let data = try JSONEncoder().encode(provider)
    let decoded = try JSONDecoder().decode(GoogleCloudProvider.self, from: data)

    #expect(decoded.projectID == provider.projectID)
    #expect(decoded.region == provider.region)
}

@Test func testSecretCodable() throws {
    let secret = GoogleCloudSecret(
        name: "test-secret",
        projectID: "test-project",
        labels: ["env": "test"]
    )
    let data = try JSONEncoder().encode(secret)
    let decoded = try JSONDecoder().decode(GoogleCloudSecret.self, from: data)

    #expect(decoded.name == secret.name)
    #expect(decoded.labels == secret.labels)
}

@Test func testStorageBucketCodable() throws {
    let bucket = GoogleCloudStorageBucket(
        name: "test-bucket",
        projectID: "test-project",
        storageClass: .coldline
    )
    let data = try JSONEncoder().encode(bucket)
    let decoded = try JSONDecoder().decode(GoogleCloudStorageBucket.self, from: data)

    #expect(decoded.name == bucket.name)
    #expect(decoded.storageClass == bucket.storageClass)
}

@Test func testComputeInstanceCodable() throws {
    let instance = GoogleCloudComputeInstance(
        name: "test-instance",
        machineType: .c3Highcpu4,
        zone: "us-west1-a",
        networkTags: ["web", "api"]
    )
    let data = try JSONEncoder().encode(instance)
    let decoded = try JSONDecoder().decode(GoogleCloudComputeInstance.self, from: data)

    #expect(decoded.name == instance.name)
    #expect(decoded.machineType == instance.machineType)
    #expect(decoded.networkTags == instance.networkTags)
}
