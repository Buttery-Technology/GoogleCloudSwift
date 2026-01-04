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

// MARK: - Service Usage Tests

@Test func testGoogleCloudService() {
    let service = GoogleCloudService(
        name: "compute.googleapis.com",
        projectID: "test-project"
    )

    #expect(service.name == "compute.googleapis.com")
    #expect(service.resourceName == "projects/test-project/services/compute.googleapis.com")
    #expect(service.state == .disabled)
}

@Test func testGoogleCloudServiceCommands() {
    let service = GoogleCloudService(
        name: "storage.googleapis.com",
        projectID: "my-project"
    )

    #expect(service.enableCommand == "gcloud services enable storage.googleapis.com --project=my-project")
    #expect(service.disableCommand == "gcloud services disable storage.googleapis.com --project=my-project")
    #expect(service.checkCommand.contains("gcloud services list"))
}

@Test func testGoogleCloudServiceBatch() {
    let batch = GoogleCloudServiceBatch(
        projectID: "test-project",
        services: ["compute.googleapis.com", "storage.googleapis.com"]
    )

    #expect(batch.batchEnableCommand.contains("gcloud services enable"))
    #expect(batch.batchEnableCommand.contains("compute.googleapis.com"))
    #expect(batch.batchEnableCommand.contains("storage.googleapis.com"))
}

@Test func testGoogleCloudAPIEnum() {
    #expect(GoogleCloudAPI.compute.rawValue == "compute.googleapis.com")
    #expect(GoogleCloudAPI.secretManager.rawValue == "secretmanager.googleapis.com")
    #expect(GoogleCloudAPI.compute.displayName == "Compute Engine")
}

@Test func testGoogleCloudAPIService() {
    let api = GoogleCloudAPI.storage
    let service = api.service(projectID: "test-project")

    #expect(service.name == "storage.googleapis.com")
    #expect(service.projectID == "test-project")
}

@Test func testDAISServiceTemplateRequired() {
    let required = DAISServiceTemplate.required
    #expect(required.contains(.compute))
    #expect(required.contains(.storage))
    #expect(required.contains(.secretManager))
    #expect(required.contains(.iam))
}

@Test func testDAISServiceTemplateEnableCommand() {
    let cmd = DAISServiceTemplate.enableCommand(for: [.compute, .storage], projectID: "test-project")
    #expect(cmd.contains("gcloud services enable"))
    #expect(cmd.contains("compute.googleapis.com"))
    #expect(cmd.contains("storage.googleapis.com"))
}

// MARK: - IAM Tests

@Test func testGoogleCloudServiceAccount() {
    let sa = GoogleCloudServiceAccount(
        name: "dais-node",
        projectID: "test-project",
        displayName: "DAIS Node"
    )

    #expect(sa.email == "dais-node@test-project.iam.gserviceaccount.com")
    #expect(sa.memberString == "serviceAccount:dais-node@test-project.iam.gserviceaccount.com")
    #expect(sa.resourceName.contains("projects/test-project/serviceAccounts"))
}

@Test func testServiceAccountCreateCommand() {
    let sa = GoogleCloudServiceAccount(
        name: "my-sa",
        projectID: "my-project",
        displayName: "My Service Account",
        description: "Test service account"
    )

    let cmd = sa.createCommand
    #expect(cmd.contains("gcloud iam service-accounts create my-sa"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--display-name=\"My Service Account\""))
    #expect(cmd.contains("--description=\"Test service account\""))
}

@Test func testServiceAccountKeyCommand() {
    let sa = GoogleCloudServiceAccount(
        name: "test-sa",
        projectID: "test-project",
        displayName: "Test"
    )

    let keyCmd = sa.createKeyCommand(outputPath: "/tmp/key.json")
    #expect(keyCmd.contains("gcloud iam service-accounts keys create"))
    #expect(keyCmd.contains("/tmp/key.json"))
    #expect(keyCmd.contains("--iam-account=test-sa@test-project.iam.gserviceaccount.com"))
}

@Test func testGoogleCloudPredefinedRole() {
    #expect(GoogleCloudPredefinedRole.owner.rawValue == "roles/owner")
    #expect(GoogleCloudPredefinedRole.computeAdmin.rawValue == "roles/compute.admin")
    #expect(GoogleCloudPredefinedRole.secretManagerAccessor.rawValue == "roles/secretmanager.secretAccessor")
    #expect(GoogleCloudPredefinedRole.loggingLogWriter.displayName == "Logs Writer")
}

@Test func testGoogleCloudIAMBinding() {
    let binding = GoogleCloudIAMBinding(
        resource: "test-project",
        resourceType: .project,
        role: "roles/viewer",
        member: "user:test@example.com"
    )

    let addCmd = binding.addBindingCommand
    #expect(addCmd.contains("gcloud projects add-iam-policy-binding test-project"))
    #expect(addCmd.contains("--member=user:test@example.com"))
    #expect(addCmd.contains("--role=roles/viewer"))
}

@Test func testIAMBindingFromServiceAccount() {
    let sa = GoogleCloudServiceAccount(
        name: "my-sa",
        projectID: "test-project",
        displayName: "My SA"
    )

    let binding = GoogleCloudIAMBinding(
        projectID: "test-project",
        role: .storageObjectViewer,
        serviceAccount: sa
    )

    #expect(binding.role == "roles/storage.objectViewer")
    #expect(binding.member == "serviceAccount:my-sa@test-project.iam.gserviceaccount.com")
}

@Test func testIAMBindingBucket() {
    let binding = GoogleCloudIAMBinding(
        resource: "my-bucket",
        resourceType: .bucket,
        role: "roles/storage.objectViewer",
        member: "allUsers"
    )

    #expect(binding.addBindingCommand.contains("gcloud storage buckets add-iam-policy-binding gs://my-bucket"))
}

@Test func testIAMCondition() {
    let condition = IAMCondition(
        title: "Expires Soon",
        description: "Temporary access",
        expression: "request.time < timestamp('2025-12-31T23:59:59Z')"
    )

    #expect(condition.asString.contains("title=Expires Soon"))
    #expect(condition.asString.contains("expression="))
}

@Test func testDAISServiceAccountTemplate() {
    let sa = DAISServiceAccountTemplate.nodeServiceAccount(projectID: "test-project", deploymentName: "prod")
    #expect(sa.name == "prod-dais-node")
    #expect(sa.displayName == "DAIS Node Service Account")

    let roles = DAISServiceAccountTemplate.nodeRoles
    #expect(roles.contains(.secretManagerAccessor))
    #expect(roles.contains(.loggingLogWriter))
}

// MARK: - Resource Manager Tests

@Test func testGoogleCloudProject() {
    let project = GoogleCloudProject(
        projectID: "my-dais-project",
        name: "My DAIS Project"
    )

    #expect(project.projectID == "my-dais-project")
    #expect(project.resourceName == "projects/my-dais-project")
    #expect(project.state == .active)
}

@Test func testProjectCreateCommand() {
    let project = GoogleCloudProject(
        projectID: "test-project",
        name: "Test Project",
        labels: ["env": "test", "team": "platform"]
    )

    let cmd = project.createCommand
    #expect(cmd.contains("gcloud projects create test-project"))
    #expect(cmd.contains("--name=\"Test Project\""))
    #expect(cmd.contains("--labels="))
}

@Test func testProjectWithParent() {
    let project = GoogleCloudProject(
        projectID: "child-project",
        name: "Child Project",
        parent: .folder(id: "123456")
    )

    #expect(project.createCommand.contains("--folder=123456"))

    let orgProject = GoogleCloudProject(
        projectID: "org-project",
        name: "Org Project",
        parent: .organization(id: "789")
    )

    #expect(orgProject.createCommand.contains("--organization=789"))
}

@Test func testProjectParentDisplayString() {
    let folderParent = GoogleCloudProject.ProjectParent.folder(id: "12345")
    #expect(folderParent.displayString == "folders/12345")

    let orgParent = GoogleCloudProject.ProjectParent.organization(id: "67890")
    #expect(orgParent.displayString == "organizations/67890")
}

@Test func testGoogleCloudOrganization() {
    let org = GoogleCloudOrganization(
        organizationID: "123456789",
        displayName: "My Organization",
        domain: "example.com"
    )

    #expect(org.resourceName == "organizations/123456789")
    #expect(org.describeCommand.contains("gcloud organizations describe 123456789"))
}

@Test func testGoogleCloudFolder() {
    let folder = GoogleCloudFolder(
        folderID: "987654321",
        displayName: "Development",
        parent: .organization(id: "123456789")
    )

    #expect(folder.resourceName == "folders/987654321")
    #expect(folder.createCommand.contains("--display-name=\"Development\""))
    #expect(folder.createCommand.contains("--organization=123456789"))
}

@Test func testFolderUnderFolder() {
    let folder = GoogleCloudFolder(
        folderID: "111",
        displayName: "Sub Folder",
        parent: .folder(id: "222")
    )

    #expect(folder.createCommand.contains("--folder=222"))
}

@Test func testGoogleCloudLien() {
    let lien = GoogleCloudLien(
        projectID: "protected-project",
        reason: "Production deployment",
        origin: "dais-deployment"
    )

    #expect(lien.createCommand.contains("gcloud resource-manager liens create"))
    #expect(lien.createCommand.contains("--reason=\"Production deployment\""))
    #expect(lien.restrictions.contains("resourcemanager.projects.delete"))
}

@Test func testDAISProjectTemplateDevelopment() {
    let project = DAISProjectTemplate.development(
        projectID: "dev-project",
        name: "Dev Project"
    )

    #expect(project.labels["environment"] == "development")
    #expect(project.labels["app"] == "butteryai")
}

@Test func testDAISProjectTemplateProduction() {
    let project = DAISProjectTemplate.production(
        projectID: "prod-project",
        name: "Prod Project"
    )

    #expect(project.labels["environment"] == "production")
    #expect(project.labels["criticality"] == "high")
}

// MARK: - New API Codable Tests

@Test func testServiceCodable() throws {
    let service = GoogleCloudService(
        name: "compute.googleapis.com",
        projectID: "test-project",
        state: .enabled
    )
    let data = try JSONEncoder().encode(service)
    let decoded = try JSONDecoder().decode(GoogleCloudService.self, from: data)

    #expect(decoded.name == service.name)
    #expect(decoded.state == service.state)
}

@Test func testServiceAccountCodable() throws {
    let sa = GoogleCloudServiceAccount(
        name: "test-sa",
        projectID: "test-project",
        displayName: "Test SA"
    )
    let data = try JSONEncoder().encode(sa)
    let decoded = try JSONDecoder().decode(GoogleCloudServiceAccount.self, from: data)

    #expect(decoded.name == sa.name)
    #expect(decoded.email == sa.email)
}

@Test func testProjectCodable() throws {
    let project = GoogleCloudProject(
        projectID: "test-project",
        name: "Test Project",
        labels: ["env": "test"]
    )
    let data = try JSONEncoder().encode(project)
    let decoded = try JSONDecoder().decode(GoogleCloudProject.self, from: data)

    #expect(decoded.projectID == project.projectID)
    #expect(decoded.labels == project.labels)
}

// MARK: - Deployment Manager Tests

@Test func testGoogleCloudDeployment() {
    let deployment = GoogleCloudDeployment(
        name: "my-deployment",
        projectID: "test-project",
        description: "Test deployment"
    )

    #expect(deployment.name == "my-deployment")
    #expect(deployment.resourceName == "projects/test-project/global/deployments/my-deployment")
    #expect(deployment.description == "Test deployment")
}

@Test func testDeploymentCreateCommand() {
    let deployment = GoogleCloudDeployment(
        name: "test-deployment",
        projectID: "my-project",
        description: "Production infrastructure",
        configPath: "/path/to/config.yaml"
    )

    let cmd = deployment.createCommand
    #expect(cmd.contains("gcloud deployment-manager deployments create test-deployment"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--config=/path/to/config.yaml"))
    #expect(cmd.contains("--description=\"Production infrastructure\""))
}

@Test func testDeploymentWithLabels() {
    let deployment = GoogleCloudDeployment(
        name: "labeled-deployment",
        projectID: "test-project",
        labels: ["env": "prod", "team": "platform"]
    )

    #expect(deployment.createCommand.contains("--labels="))
}

@Test func testDeploymentWithTemplate() {
    let deployment = GoogleCloudDeployment(
        name: "template-deployment",
        projectID: "test-project",
        templatePath: "/path/to/template.jinja",
        properties: ["zone": "us-west1-a", "machineType": "e2-medium"]
    )

    let cmd = deployment.createCommand
    #expect(cmd.contains("--template=/path/to/template.jinja"))
    #expect(cmd.contains("--properties="))
}

@Test func testDeploymentDeleteCommand() {
    let deployment = GoogleCloudDeployment(
        name: "to-delete",
        projectID: "test-project"
    )

    #expect(deployment.deleteCommand == "gcloud deployment-manager deployments delete to-delete --project=test-project --quiet")
}

@Test func testDeploymentDescribeCommand() {
    let deployment = GoogleCloudDeployment(
        name: "my-deployment",
        projectID: "test-project"
    )

    #expect(deployment.describeCommand == "gcloud deployment-manager deployments describe my-deployment --project=test-project")
}

@Test func testDeploymentPreviewCommand() {
    let deployment = GoogleCloudDeployment(
        name: "preview-deployment",
        projectID: "test-project",
        configPath: "/path/to/config.yaml"
    )

    let cmd = deployment.previewCommand
    #expect(cmd.contains("--preview"))
    #expect(cmd.contains("--config=/path/to/config.yaml"))
}

@Test func testDeploymentState() {
    #expect(GoogleCloudDeployment.DeploymentState.pending.rawValue == "PENDING")
    #expect(GoogleCloudDeployment.DeploymentState.running.rawValue == "RUNNING")
    #expect(GoogleCloudDeployment.DeploymentState.done.rawValue == "DONE")
    #expect(GoogleCloudDeployment.DeploymentState.failed.rawValue == "FAILED")
}

@Test func testDeploymentManifest() {
    let manifest = GoogleCloudDeploymentManifest(
        deploymentName: "my-deployment",
        projectID: "test-project",
        manifestID: "manifest-12345"
    )

    #expect(manifest.resourceName == "projects/test-project/global/deployments/my-deployment/manifests/manifest-12345")
    #expect(manifest.describeCommand.contains("gcloud deployment-manager manifests describe manifest-12345"))
}

@Test func testDeploymentResource() {
    let resource = GoogleCloudDeploymentResource(
        name: "my-instance",
        type: "compute.v1.instance",
        deploymentName: "my-deployment",
        projectID: "test-project"
    )

    #expect(resource.describeCommand.contains("gcloud deployment-manager resources describe my-instance"))
    #expect(resource.describeCommand.contains("--deployment=my-deployment"))
}

@Test func testDeploymentTypeEnum() {
    #expect(GoogleCloudDeploymentType.instance.rawValue == "compute.v1.instance")
    #expect(GoogleCloudDeploymentType.bucket.rawValue == "storage.v1.bucket")
    #expect(GoogleCloudDeploymentType.firewall.rawValue == "compute.v1.firewall")
    #expect(GoogleCloudDeploymentType.instance.displayName == "Compute Instance")
    #expect(GoogleCloudDeploymentType.bucket.displayName == "Storage Bucket")
}

@Test func testDAISDeploymentManagerTemplateInstanceConfig() {
    let config = DAISDeploymentManagerTemplate.instanceConfig(
        name: "dais-node-1",
        machineType: .e2Medium,
        zone: "us-west1-a",
        networkTags: ["dais-node", "allow-grpc"]
    )

    #expect(config.contains("name: dais-node-1"))
    #expect(config.contains("type: compute.v1.instance"))
    #expect(config.contains("machineType: zones/us-west1-a/machineTypes/e2-medium"))
    #expect(config.contains("- dais-node"))
    #expect(config.contains("- allow-grpc"))
}

@Test func testDAISDeploymentManagerTemplateCompleteConfig() {
    let config = DAISDeploymentManagerTemplate.completeDeploymentConfig(
        deploymentName: "test-dais",
        nodeCount: 2,
        machineType: .n2Standard2,
        zone: "us-central1-a",
        grpcPort: 9090,
        httpPort: 8080
    )

    #expect(config.contains("resources:"))
    #expect(config.contains("test-dais-allow-grpc"))
    #expect(config.contains("test-dais-allow-http"))
    #expect(config.contains("test-dais-node-1"))
    #expect(config.contains("test-dais-node-2"))
    #expect(config.contains("\"9090\""))
    #expect(config.contains("\"8080\""))
}

// MARK: - Infrastructure Manager Tests

@Test func testInfrastructureManagerDeployment() {
    let deployment = InfrastructureManagerDeployment(
        name: "my-infra",
        projectID: "test-project",
        location: "us-central1"
    )

    #expect(deployment.name == "my-infra")
    #expect(deployment.resourceName == "projects/test-project/locations/us-central1/deployments/my-infra")
}

@Test func testInfrastructureManagerDeploymentCreateCommand() {
    let deployment = InfrastructureManagerDeployment(
        name: "test-deployment",
        projectID: "my-project",
        location: "us-west1",
        serviceAccount: "infra@my-project.iam.gserviceaccount.com"
    )

    let cmd = deployment.createCommand
    #expect(cmd.contains("gcloud infra-manager deployments apply test-deployment"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--location=us-west1"))
    #expect(cmd.contains("--service-account=infra@my-project.iam.gserviceaccount.com"))
}

@Test func testInfrastructureManagerDeploymentWithLabels() {
    let deployment = InfrastructureManagerDeployment(
        name: "labeled-infra",
        projectID: "test-project",
        location: "us-central1",
        labels: ["env": "prod", "app": "dais"]
    )

    #expect(deployment.createCommand.contains("--labels="))
}

@Test func testInfrastructureManagerDeploymentWithGitBlueprint() {
    let blueprint = TerraformBlueprint(
        source: .git(repo: "https://github.com/example/infra", directory: "terraform", ref: "main")
    )

    let deployment = InfrastructureManagerDeployment(
        name: "git-infra",
        projectID: "test-project",
        location: "us-central1",
        blueprint: blueprint
    )

    let cmd = deployment.createCommand
    #expect(cmd.contains("--git-source-repo=https://github.com/example/infra"))
    #expect(cmd.contains("--git-source-directory=terraform"))
    #expect(cmd.contains("--git-source-ref=main"))
}

@Test func testInfrastructureManagerDeploymentWithGCSBlueprint() {
    let blueprint = TerraformBlueprint(
        source: .gcs(bucket: "my-tf-bucket", object: "configs/main.tar.gz")
    )

    let deployment = InfrastructureManagerDeployment(
        name: "gcs-infra",
        projectID: "test-project",
        location: "us-central1",
        blueprint: blueprint
    )

    let cmd = deployment.createCommand
    #expect(cmd.contains("--gcs-source=gs://my-tf-bucket/configs/main.tar.gz"))
}

@Test func testInfrastructureManagerDeploymentWithLocalBlueprint() {
    let blueprint = TerraformBlueprint(
        source: .local(path: "/path/to/terraform")
    )

    let deployment = InfrastructureManagerDeployment(
        name: "local-infra",
        projectID: "test-project",
        location: "us-central1",
        blueprint: blueprint
    )

    #expect(deployment.createCommand.contains("--local-source=/path/to/terraform"))
}

@Test func testInfrastructureManagerDeploymentCommands() {
    let deployment = InfrastructureManagerDeployment(
        name: "my-infra",
        projectID: "test-project",
        location: "us-west1"
    )

    #expect(deployment.deleteCommand.contains("gcloud infra-manager deployments delete my-infra"))
    #expect(deployment.describeCommand.contains("gcloud infra-manager deployments describe my-infra"))
    #expect(deployment.exportStateCommand.contains("gcloud infra-manager deployments export-state my-infra"))
    #expect(deployment.lockCommand.contains("gcloud infra-manager deployments lock my-infra"))
    #expect(deployment.unlockCommand.contains("gcloud infra-manager deployments unlock my-infra"))
}

@Test func testInfrastructureManagerListCommand() {
    let cmd = InfrastructureManagerDeployment.listCommand(projectID: "test-project", location: "us-central1")
    #expect(cmd == "gcloud infra-manager deployments list --project=test-project --location=us-central1")
}

@Test func testInfrastructureManagerDeploymentState() {
    #expect(InfrastructureManagerDeployment.DeploymentState.creating.rawValue == "CREATING")
    #expect(InfrastructureManagerDeployment.DeploymentState.active.rawValue == "ACTIVE")
    #expect(InfrastructureManagerDeployment.DeploymentState.updating.rawValue == "UPDATING")
    #expect(InfrastructureManagerDeployment.DeploymentState.failed.rawValue == "FAILED")
}

@Test func testInfrastructureManagerLockState() {
    #expect(InfrastructureManagerDeployment.LockState.unlocked.rawValue == "UNLOCKED")
    #expect(InfrastructureManagerDeployment.LockState.locked.rawValue == "LOCKED")
    #expect(InfrastructureManagerDeployment.LockState.locking.rawValue == "LOCKING")
}

@Test func testTerraformBlueprint() {
    let blueprint = TerraformBlueprint(
        source: .git(repo: "https://github.com/test/repo", directory: nil, ref: "v1.0.0"),
        inputValues: ["region": "us-west1", "node_count": "3"]
    )

    #expect(blueprint.inputValues.count == 2)
    #expect(blueprint.inputValues["region"] == "us-west1")
}

@Test func testInfrastructureManagerRevision() {
    let revision = InfrastructureManagerRevision(
        name: "revision-001",
        deploymentName: "my-infra",
        projectID: "test-project",
        location: "us-central1",
        state: .applied
    )

    #expect(revision.resourceName == "projects/test-project/locations/us-central1/deployments/my-infra/revisions/revision-001")
    #expect(revision.describeCommand.contains("gcloud infra-manager revisions describe revision-001"))
}

@Test func testInfrastructureManagerRevisionState() {
    #expect(InfrastructureManagerRevision.RevisionState.applying.rawValue == "APPLYING")
    #expect(InfrastructureManagerRevision.RevisionState.applied.rawValue == "APPLIED")
    #expect(InfrastructureManagerRevision.RevisionState.failed.rawValue == "FAILED")
}

@Test func testInfrastructureManagerPreview() {
    let preview = InfrastructureManagerPreview(
        name: "preview-001",
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "my-infra"
    )

    #expect(preview.resourceName == "projects/test-project/locations/us-central1/previews/preview-001")
    #expect(preview.createCommand.contains("--deployment=my-infra"))
}

@Test func testInfrastructureManagerPreviewCommands() {
    let preview = InfrastructureManagerPreview(
        name: "test-preview",
        projectID: "test-project",
        location: "us-west1"
    )

    #expect(preview.deleteCommand.contains("gcloud infra-manager previews delete test-preview"))
    #expect(preview.describeCommand.contains("gcloud infra-manager previews describe test-preview"))
    #expect(preview.exportCommand.contains("gcloud infra-manager previews export test-preview"))
}

@Test func testInfrastructureManagerPreviewState() {
    #expect(InfrastructureManagerPreview.PreviewState.creating.rawValue == "CREATING")
    #expect(InfrastructureManagerPreview.PreviewState.succeeded.rawValue == "SUCCEEDED")
    #expect(InfrastructureManagerPreview.PreviewState.failed.rawValue == "FAILED")
}

@Test func testDAISInfrastructureTemplateTerraformConfig() {
    let config = DAISInfrastructureTemplate.terraformConfig(
        deploymentName: "test-dais",
        projectID: "my-project",
        region: "us-west1",
        zone: "us-west1-a",
        nodeCount: 3,
        machineType: .n2Standard2,
        grpcPort: 9090,
        httpPort: 8080
    )

    #expect(config.contains("terraform {"))
    #expect(config.contains("provider \"google\""))
    #expect(config.contains("project = \"my-project\""))
    #expect(config.contains("region  = \"us-west1\""))
    #expect(config.contains("google_compute_firewall"))
    #expect(config.contains("test-dais-allow-grpc"))
    #expect(config.contains("test-dais-allow-http"))
    #expect(config.contains("google_compute_instance"))
    #expect(config.contains("count        = 3"))
    #expect(config.contains("n2-standard-2"))
}

@Test func testDAISInfrastructureTemplateDeployment() {
    let deployment = DAISInfrastructureTemplate.deployment(
        name: "prod-infra",
        projectID: "my-project",
        location: "us-central1",
        gitRepo: "https://github.com/example/infra",
        gitRef: "v1.0.0",
        serviceAccountEmail: "infra@my-project.iam.gserviceaccount.com"
    )

    #expect(deployment.name == "prod-infra")
    #expect(deployment.labels["app"] == "butteryai")
    #expect(deployment.labels["managed-by"] == "dais")
    #expect(deployment.serviceAccount == "infra@my-project.iam.gserviceaccount.com")
}

@Test func testDAISInfrastructureTemplateSetupScript() {
    let deployment = InfrastructureManagerDeployment(
        name: "test-infra",
        projectID: "my-project",
        location: "us-central1"
    )

    let terraformConfig = DAISInfrastructureTemplate.terraformConfig(
        deploymentName: "test",
        projectID: "my-project",
        region: "us-central1",
        zone: "us-central1-a",
        nodeCount: 2,
        machineType: .e2Medium
    )

    let script = DAISInfrastructureTemplate.setupScript(
        deployment: deployment,
        terraformConfig: terraformConfig
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable config.googleapis.com"))
    #expect(script.contains("mkdir -p /tmp/dais-terraform"))
    #expect(script.contains("TERRAFORM_EOF"))
}

// MARK: - Deployment Manager and Infrastructure Manager Codable Tests

@Test func testDeploymentCodable() throws {
    let deployment = GoogleCloudDeployment(
        name: "test-deployment",
        projectID: "test-project",
        description: "Test",
        labels: ["env": "test"]
    )
    let data = try JSONEncoder().encode(deployment)
    let decoded = try JSONDecoder().decode(GoogleCloudDeployment.self, from: data)

    #expect(decoded.name == deployment.name)
    #expect(decoded.labels == deployment.labels)
}

@Test func testInfrastructureManagerDeploymentCodable() throws {
    let deployment = InfrastructureManagerDeployment(
        name: "test-infra",
        projectID: "test-project",
        location: "us-central1",
        labels: ["env": "test"]
    )
    let data = try JSONEncoder().encode(deployment)
    let decoded = try JSONDecoder().decode(InfrastructureManagerDeployment.self, from: data)

    #expect(decoded.name == deployment.name)
    #expect(decoded.location == deployment.location)
    #expect(decoded.labels == deployment.labels)
}

@Test func testTerraformBlueprintCodable() throws {
    let blueprint = TerraformBlueprint(
        source: .git(repo: "https://github.com/test/repo", directory: "terraform", ref: "main"),
        inputValues: ["key": "value"]
    )
    let data = try JSONEncoder().encode(blueprint)
    let decoded = try JSONDecoder().decode(TerraformBlueprint.self, from: data)

    #expect(decoded.inputValues == blueprint.inputValues)
}

@Test func testInfrastructureManagerRevisionCodable() throws {
    let revision = InfrastructureManagerRevision(
        name: "rev-001",
        deploymentName: "my-deploy",
        projectID: "test-project",
        location: "us-central1"
    )
    let data = try JSONEncoder().encode(revision)
    let decoded = try JSONDecoder().decode(InfrastructureManagerRevision.self, from: data)

    #expect(decoded.name == revision.name)
    #expect(decoded.deploymentName == revision.deploymentName)
}

@Test func testInfrastructureManagerPreviewCodable() throws {
    let preview = InfrastructureManagerPreview(
        name: "preview-001",
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "my-deploy"
    )
    let data = try JSONEncoder().encode(preview)
    let decoded = try JSONDecoder().decode(InfrastructureManagerPreview.self, from: data)

    #expect(decoded.name == preview.name)
    #expect(decoded.deploymentName == preview.deploymentName)
}

// MARK: - Cloud SQL Tests

@Test func testGoogleCloudSQLInstance() {
    let instance = GoogleCloudSQLInstance(
        name: "my-postgres",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16
    )

    #expect(instance.name == "my-postgres")
    #expect(instance.resourceName == "projects/test-project/instances/my-postgres")
    #expect(instance.connectionName == "test-project:us-central1:my-postgres")
}

@Test func testSQLInstanceCreateCommand() {
    let instance = GoogleCloudSQLInstance(
        name: "test-db",
        projectID: "my-project",
        region: "us-west1",
        databaseVersion: .postgres16,
        tier: .dbCustom(cpus: 2, memoryMB: 7680),
        storageSizeGB: 50,
        availabilityType: .regional
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("gcloud sql instances create test-db"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-west1"))
    #expect(cmd.contains("--database-version=POSTGRES_16"))
    #expect(cmd.contains("--cpu=2"))
    #expect(cmd.contains("--memory=7680MB"))
    #expect(cmd.contains("--availability-type=REGIONAL"))
}

@Test func testSQLInstanceWithMySQLVersion() {
    let instance = GoogleCloudSQLInstance(
        name: "mysql-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .mysql80
    )

    #expect(instance.databaseVersion.engine == .mysql)
    #expect(instance.databaseVersion.defaultPort == 3306)
    #expect(instance.createCommand.contains("--database-version=MYSQL_8_0"))
}

@Test func testSQLInstanceWithSQLServer() {
    let instance = GoogleCloudSQLInstance(
        name: "sqlserver-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .sqlserver2022Standard
    )

    #expect(instance.databaseVersion.engine == .sqlserver)
    #expect(instance.databaseVersion.defaultPort == 1433)
    #expect(instance.databaseVersion.displayName == "SQL Server 2022 Standard")
}

@Test func testSQLInstanceCommands() {
    let instance = GoogleCloudSQLInstance(
        name: "test-instance",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16
    )

    #expect(instance.deleteCommand.contains("gcloud sql instances delete test-instance"))
    #expect(instance.describeCommand.contains("gcloud sql instances describe test-instance"))
    #expect(instance.restartCommand.contains("gcloud sql instances restart test-instance"))
    #expect(instance.createBackupCommand.contains("gcloud sql backups create"))
}

@Test func testSQLInstanceWithBackupConfig() {
    let instance = GoogleCloudSQLInstance(
        name: "backup-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16,
        backupEnabled: true,
        backupStartTime: "04:00",
        pointInTimeRecoveryEnabled: true,
        retainedBackupsCount: 14,
        transactionLogRetentionDays: 7
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("--backup"))
    #expect(cmd.contains("--backup-start-time=04:00"))
    #expect(cmd.contains("--enable-point-in-time-recovery"))
    #expect(cmd.contains("--retained-backups-count=14"))
}

@Test func testSQLInstanceWithPrivateNetwork() {
    let instance = GoogleCloudSQLInstance(
        name: "private-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16,
        privateNetwork: "projects/test-project/global/networks/my-vpc",
        publicIPEnabled: false
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("--network=projects/test-project/global/networks/my-vpc"))
    #expect(cmd.contains("--no-assign-ip"))
}

@Test func testSQLInstanceWithDatabaseFlags() {
    let instance = GoogleCloudSQLInstance(
        name: "custom-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16,
        databaseFlags: ["max_connections": "200", "log_min_duration_statement": "1000"]
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("--database-flags="))
    #expect(cmd.contains("max_connections=200") || cmd.contains("log_min_duration_statement=1000"))
}

@Test func testSQLInstanceWithMaintenanceWindow() {
    let instance = GoogleCloudSQLInstance(
        name: "maint-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16,
        maintenanceWindow: GoogleCloudSQLInstance.MaintenanceWindow(day: .sunday, hour: 3)
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("--maintenance-window-day=SUN"))
    #expect(cmd.contains("--maintenance-window-hour=3"))
}

@Test func testDatabaseVersion() {
    #expect(GoogleCloudSQLInstance.DatabaseVersion.postgres16.rawValue == "POSTGRES_16")
    #expect(GoogleCloudSQLInstance.DatabaseVersion.mysql80.rawValue == "MYSQL_8_0")
    #expect(GoogleCloudSQLInstance.DatabaseVersion.postgres16.engine == .postgresql)
    #expect(GoogleCloudSQLInstance.DatabaseVersion.postgres16.defaultPort == 5432)
    #expect(GoogleCloudSQLInstance.DatabaseVersion.postgres16.displayName == "PostgreSQL 16")
}

@Test func testMachineTier() {
    #expect(GoogleCloudSQLInstance.MachineTier.dbF1Micro.tierName == "db-f1-micro")
    #expect(GoogleCloudSQLInstance.MachineTier.dbG1Small.tierName == "db-g1-small")
    #expect(GoogleCloudSQLInstance.MachineTier.dbCustom(cpus: 4, memoryMB: 16384).tierName == "db-custom-4-16384")
    #expect(GoogleCloudSQLInstance.MachineTier.developmentRecommended.tierName == "db-f1-micro")
}

@Test func testMachineTierCost() {
    #expect(GoogleCloudSQLInstance.MachineTier.dbF1Micro.approximateMonthlyCostUSD == 8)
    #expect(GoogleCloudSQLInstance.MachineTier.dbG1Small.approximateMonthlyCostUSD == 26)
}

@Test func testGoogleCloudSQLDatabase() {
    let database = GoogleCloudSQLDatabase(
        name: "mydb",
        instanceName: "my-instance",
        projectID: "test-project",
        charset: "UTF8",
        collation: "en_US.UTF8"
    )

    #expect(database.name == "mydb")
    #expect(database.createCommand.contains("gcloud sql databases create mydb"))
    #expect(database.createCommand.contains("--instance=my-instance"))
    #expect(database.createCommand.contains("--charset=UTF8"))
    #expect(database.createCommand.contains("--collation=en_US.UTF8"))
}

@Test func testSQLDatabaseCommands() {
    let database = GoogleCloudSQLDatabase(
        name: "testdb",
        instanceName: "test-instance",
        projectID: "test-project"
    )

    #expect(database.deleteCommand.contains("gcloud sql databases delete testdb"))
    #expect(database.describeCommand.contains("gcloud sql databases describe testdb"))

    let listCmd = GoogleCloudSQLDatabase.listCommand(instanceName: "test-instance", projectID: "test-project")
    #expect(listCmd.contains("gcloud sql databases list"))
}

@Test func testGoogleCloudSQLUser() {
    let user = GoogleCloudSQLUser(
        name: "app_user",
        instanceName: "my-instance",
        projectID: "test-project",
        password: "secret123"
    )

    #expect(user.name == "app_user")
    #expect(user.createCommand.contains("gcloud sql users create app_user"))
    #expect(user.createCommand.contains("--password=secret123"))
}

@Test func testSQLUserCommands() {
    let user = GoogleCloudSQLUser(
        name: "testuser",
        instanceName: "test-instance",
        projectID: "test-project"
    )

    #expect(user.deleteCommand.contains("gcloud sql users delete testuser"))

    let setPasswordCmd = user.setPasswordCommand(newPassword: "newpass123")
    #expect(setPasswordCmd.contains("gcloud sql users set-password testuser"))
    #expect(setPasswordCmd.contains("--password=newpass123"))
}

@Test func testSQLUserWithHost() {
    let user = GoogleCloudSQLUser(
        name: "mysql_user",
        instanceName: "my-mysql",
        projectID: "test-project",
        password: "pass",
        host: "%"
    )

    #expect(user.createCommand.contains("--host=%"))
}

@Test func testSQLUserIAMType() {
    let user = GoogleCloudSQLUser(
        name: "sa@project.iam.gserviceaccount.com",
        instanceName: "my-instance",
        projectID: "test-project",
        type: .cloudIAMServiceAccount
    )

    #expect(user.createCommand.contains("--type=CLOUD_IAM_SERVICE_ACCOUNT"))
}

@Test func testAuthorizedNetwork() {
    let network = GoogleCloudSQLInstance.AuthorizedNetwork(
        name: "office",
        cidr: "203.0.113.0/24"
    )

    #expect(network.name == "office")
    #expect(network.cidr == "203.0.113.0/24")

    let allowAll = GoogleCloudSQLInstance.AuthorizedNetwork.allowAll
    #expect(allowAll.cidr == "0.0.0.0/0")
}

@Test func testMaintenanceWindow() {
    let window = GoogleCloudSQLInstance.MaintenanceWindow(day: .saturday, hour: 2)

    #expect(window.day == .saturday)
    #expect(window.hour == 2)
}

@Test func testSQLSSLCert() {
    let cert = GoogleCloudSQLSSLCert(
        commonName: "my-client",
        instanceName: "my-instance",
        projectID: "test-project"
    )

    #expect(cert.createCommand.contains("gcloud sql ssl client-certs create my-client"))
    #expect(cert.deleteCommand.contains("gcloud sql ssl client-certs delete my-client"))
}

@Test func testSQLInstanceClone() {
    let instance = GoogleCloudSQLInstance(
        name: "source-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16
    )

    let cloneCmd = instance.cloneCommand(newInstanceName: "cloned-db")
    #expect(cloneCmd.contains("gcloud sql instances clone source-db cloned-db"))
}

@Test func testSQLInstanceReplica() {
    let instance = GoogleCloudSQLInstance(
        name: "primary-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16
    )

    let replicaCmd = instance.createReplicaCommand(replicaName: "replica-db", replicaRegion: "us-west1")
    #expect(replicaCmd.contains("gcloud sql instances create replica-db"))
    #expect(replicaCmd.contains("--master-instance-name=primary-db"))
    #expect(replicaCmd.contains("--region=us-west1"))
}

@Test func testDAISSQLTemplatePostgres() {
    let instance = DAISSQLTemplate.postgresInstance(
        name: "dais-db",
        projectID: "test-project",
        region: "us-central1",
        highAvailability: true
    )

    #expect(instance.databaseVersion == .postgres16)
    #expect(instance.availabilityType == .regional)
    #expect(instance.deletionProtection == true)
    #expect(instance.labels["app"] == "butteryai")
    #expect(instance.databaseFlags["max_connections"] == "200")
}

@Test func testDAISSQLTemplateDatabase() {
    let database = DAISSQLTemplate.daisDatabase(
        instanceName: "dais-db",
        projectID: "test-project"
    )

    #expect(database.name == "dais")
    #expect(database.charset == "UTF8")
    #expect(database.collation == "en_US.UTF8")
}

@Test func testDAISSQLTemplateUser() {
    let user = DAISSQLTemplate.daisUser(
        instanceName: "dais-db",
        projectID: "test-project",
        password: "secret123"
    )

    #expect(user.name == "dais_app")
    #expect(user.password == "secret123")
}

@Test func testDAISSQLTemplateConnectionString() {
    let instance = GoogleCloudSQLInstance(
        name: "dais-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16
    )
    let database = GoogleCloudSQLDatabase(
        name: "dais",
        instanceName: "dais-db",
        projectID: "test-project"
    )
    let user = GoogleCloudSQLUser(
        name: "dais_app",
        instanceName: "dais-db",
        projectID: "test-project"
    )

    let proxyConnStr = DAISSQLTemplate.connectionString(instance: instance, database: database, user: user, useProxy: true)
    #expect(proxyConnStr.contains("postgresql://dais_app@localhost:5432/dais"))
    #expect(proxyConnStr.contains("test-project:us-central1:dais-db"))
}

@Test func testDAISSQLTemplateSetupScript() {
    let instance = DAISSQLTemplate.postgresInstance(
        name: "dais-db",
        projectID: "test-project",
        region: "us-central1"
    )
    let database = DAISSQLTemplate.daisDatabase(instanceName: "dais-db", projectID: "test-project")
    let user = DAISSQLTemplate.daisUser(instanceName: "dais-db", projectID: "test-project", password: "pass")

    let script = DAISSQLTemplate.setupScript(instance: instance, database: database, appUser: user)
    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable sqladmin.googleapis.com"))
    #expect(script.contains("gcloud sql instances create"))
    #expect(script.contains("gcloud sql databases create"))
    #expect(script.contains("gcloud sql users create"))
}

// MARK: - Cloud SQL Codable Tests

@Test func testSQLInstanceCodable() throws {
    let instance = GoogleCloudSQLInstance(
        name: "test-db",
        projectID: "test-project",
        region: "us-central1",
        databaseVersion: .postgres16,
        tier: .dbCustom(cpus: 2, memoryMB: 4096),
        labels: ["env": "test"]
    )
    let data = try JSONEncoder().encode(instance)
    let decoded = try JSONDecoder().decode(GoogleCloudSQLInstance.self, from: data)

    #expect(decoded.name == instance.name)
    #expect(decoded.databaseVersion == instance.databaseVersion)
    #expect(decoded.labels == instance.labels)
}

@Test func testSQLDatabaseCodable() throws {
    let database = GoogleCloudSQLDatabase(
        name: "testdb",
        instanceName: "test-instance",
        projectID: "test-project"
    )
    let data = try JSONEncoder().encode(database)
    let decoded = try JSONDecoder().decode(GoogleCloudSQLDatabase.self, from: data)

    #expect(decoded.name == database.name)
    #expect(decoded.instanceName == database.instanceName)
}

@Test func testSQLUserCodable() throws {
    let user = GoogleCloudSQLUser(
        name: "testuser",
        instanceName: "test-instance",
        projectID: "test-project"
    )
    let data = try JSONEncoder().encode(user)
    let decoded = try JSONDecoder().decode(GoogleCloudSQLUser.self, from: data)

    #expect(decoded.name == user.name)
    #expect(decoded.instanceName == user.instanceName)
}

// MARK: - Pub/Sub Tests

@Test func testGoogleCloudPubSubTopic() {
    let topic = GoogleCloudPubSubTopic(
        name: "my-events",
        projectID: "test-project"
    )

    #expect(topic.name == "my-events")
    #expect(topic.resourceName == "projects/test-project/topics/my-events")
}

@Test func testPubSubTopicCreateCommand() {
    let topic = GoogleCloudPubSubTopic(
        name: "test-topic",
        projectID: "my-project",
        messageRetentionDuration: "7d",
        labels: ["env": "prod"]
    )

    let cmd = topic.createCommand
    #expect(cmd.contains("gcloud pubsub topics create test-topic"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--message-retention-duration=7d"))
    #expect(cmd.contains("--labels="))
}

@Test func testPubSubTopicWithSchema() {
    let topic = GoogleCloudPubSubTopic(
        name: "schema-topic",
        projectID: "test-project",
        schemaSettings: GoogleCloudPubSubTopic.SchemaSettings(
            schemaName: "my-schema",
            encoding: .json
        )
    )

    let cmd = topic.createCommand
    #expect(cmd.contains("--schema=my-schema"))
    #expect(cmd.contains("--message-encoding=JSON"))
}

@Test func testPubSubTopicWithKMS() {
    let topic = GoogleCloudPubSubTopic(
        name: "encrypted-topic",
        projectID: "test-project",
        kmsKeyName: "projects/test/locations/us/keyRings/ring/cryptoKeys/key"
    )

    #expect(topic.createCommand.contains("--topic-encryption-key="))
}

@Test func testPubSubTopicWithStoragePolicy() {
    let topic = GoogleCloudPubSubTopic(
        name: "regional-topic",
        projectID: "test-project",
        messageStoragePolicy: GoogleCloudPubSubTopic.MessageStoragePolicy(
            allowedPersistenceRegions: ["us-central1", "us-east1"]
        )
    )

    #expect(topic.createCommand.contains("--message-storage-policy-allowed-regions=us-central1,us-east1"))
}

@Test func testPubSubTopicCommands() {
    let topic = GoogleCloudPubSubTopic(
        name: "test-topic",
        projectID: "test-project"
    )

    #expect(topic.deleteCommand.contains("gcloud pubsub topics delete test-topic"))
    #expect(topic.describeCommand.contains("gcloud pubsub topics describe test-topic"))
    #expect(topic.listSubscriptionsCommand.contains("gcloud pubsub topics list-subscriptions test-topic"))
}

@Test func testPubSubTopicPublishCommand() {
    let topic = GoogleCloudPubSubTopic(
        name: "test-topic",
        projectID: "test-project"
    )

    let cmd = topic.publishCommand(message: "Hello World", attributes: ["key": "value"])
    #expect(cmd.contains("gcloud pubsub topics publish test-topic"))
    #expect(cmd.contains("--message=\"Hello World\""))
    #expect(cmd.contains("--attribute=key=value"))
}

@Test func testPubSubTopicUpdateCommand() {
    let topic = GoogleCloudPubSubTopic(
        name: "test-topic",
        projectID: "test-project"
    )

    let cmd = topic.updateCommand(messageRetentionDuration: "14d", labels: ["updated": "true"])
    #expect(cmd.contains("gcloud pubsub topics update test-topic"))
    #expect(cmd.contains("--message-retention-duration=14d"))
    #expect(cmd.contains("--update-labels="))
}

@Test func testGoogleCloudPubSubSubscription() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "my-sub",
        topicName: "my-topic",
        projectID: "test-project"
    )

    #expect(subscription.name == "my-sub")
    #expect(subscription.resourceName == "projects/test-project/subscriptions/my-sub")
    #expect(subscription.topicResourceName == "projects/test-project/topics/my-topic")
}

@Test func testPubSubSubscriptionCreateCommand() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "test-sub",
        topicName: "test-topic",
        projectID: "my-project",
        ackDeadlineSeconds: 30,
        messageRetentionDuration: "3d"
    )

    let cmd = subscription.createCommand
    #expect(cmd.contains("gcloud pubsub subscriptions create test-sub"))
    #expect(cmd.contains("--topic=test-topic"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--ack-deadline=30"))
    #expect(cmd.contains("--message-retention-duration=3d"))
}

@Test func testPubSubSubscriptionWithFilter() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "filtered-sub",
        topicName: "test-topic",
        projectID: "test-project",
        filter: "attributes.type = \"important\""
    )

    #expect(subscription.createCommand.contains("--message-filter="))
}

@Test func testPubSubSubscriptionWithDeadLetter() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "dl-sub",
        topicName: "test-topic",
        projectID: "test-project",
        deadLetterPolicy: GoogleCloudPubSubSubscription.DeadLetterPolicy(
            deadLetterTopic: "dead-letter-topic",
            maxDeliveryAttempts: 10
        )
    )

    let cmd = subscription.createCommand
    #expect(cmd.contains("--dead-letter-topic=dead-letter-topic"))
    #expect(cmd.contains("--max-delivery-attempts=10"))
}

@Test func testPubSubSubscriptionWithRetryPolicy() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "retry-sub",
        topicName: "test-topic",
        projectID: "test-project",
        retryPolicy: GoogleCloudPubSubSubscription.RetryPolicy(
            minimumBackoff: "15s",
            maximumBackoff: "300s"
        )
    )

    let cmd = subscription.createCommand
    #expect(cmd.contains("--min-retry-delay=15s"))
    #expect(cmd.contains("--max-retry-delay=300s"))
}

@Test func testPubSubSubscriptionExactlyOnce() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "exactly-once-sub",
        topicName: "test-topic",
        projectID: "test-project",
        enableExactlyOnceDelivery: true,
        enableMessageOrdering: true
    )

    let cmd = subscription.createCommand
    #expect(cmd.contains("--enable-exactly-once-delivery"))
    #expect(cmd.contains("--enable-message-ordering"))
}

@Test func testPubSubPushSubscription() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "push-sub",
        topicName: "test-topic",
        projectID: "test-project",
        type: .push(endpoint: "https://example.com/webhook", attributes: [:])
    )

    #expect(subscription.type.isPush)
    #expect(subscription.createCommand.contains("--push-endpoint=https://example.com/webhook"))
}

@Test func testPubSubSubscriptionCommands() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "test-sub",
        topicName: "test-topic",
        projectID: "test-project"
    )

    #expect(subscription.deleteCommand.contains("gcloud pubsub subscriptions delete test-sub"))
    #expect(subscription.describeCommand.contains("gcloud pubsub subscriptions describe test-sub"))
}

@Test func testPubSubSubscriptionPullCommand() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "test-sub",
        topicName: "test-topic",
        projectID: "test-project"
    )

    let pullCmd = subscription.pullCommand(maxMessages: 100, autoAck: true)
    #expect(pullCmd.contains("gcloud pubsub subscriptions pull test-sub"))
    #expect(pullCmd.contains("--limit=100"))
    #expect(pullCmd.contains("--auto-ack"))
}

@Test func testPubSubSubscriptionAckCommand() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "test-sub",
        topicName: "test-topic",
        projectID: "test-project"
    )

    let ackCmd = subscription.ackCommand(ackIDs: ["id1", "id2"])
    #expect(ackCmd.contains("gcloud pubsub subscriptions ack test-sub"))
    #expect(ackCmd.contains("--ack-ids=id1,id2"))
}

@Test func testPubSubSubscriptionSeekCommands() {
    let subscription = GoogleCloudPubSubSubscription(
        name: "test-sub",
        topicName: "test-topic",
        projectID: "test-project"
    )

    let timeSeek = subscription.seekToTimeCommand(timestamp: "2024-01-01T00:00:00Z")
    #expect(timeSeek.contains("gcloud pubsub subscriptions seek test-sub"))
    #expect(timeSeek.contains("--time=2024-01-01T00:00:00Z"))

    let snapshotSeek = subscription.seekToSnapshotCommand(snapshotName: "my-snapshot")
    #expect(snapshotSeek.contains("--snapshot=my-snapshot"))
}

@Test func testGoogleCloudPubSubSnapshot() {
    let snapshot = GoogleCloudPubSubSnapshot(
        name: "my-snapshot",
        subscriptionName: "my-sub",
        projectID: "test-project"
    )

    #expect(snapshot.resourceName == "projects/test-project/snapshots/my-snapshot")
    #expect(snapshot.createCommand.contains("gcloud pubsub snapshots create my-snapshot"))
    #expect(snapshot.createCommand.contains("--subscription=my-sub"))
}

@Test func testPubSubSnapshotCommands() {
    let snapshot = GoogleCloudPubSubSnapshot(
        name: "test-snapshot",
        subscriptionName: "test-sub",
        projectID: "test-project"
    )

    #expect(snapshot.deleteCommand.contains("gcloud pubsub snapshots delete test-snapshot"))
    #expect(snapshot.describeCommand.contains("gcloud pubsub snapshots describe test-snapshot"))
}

@Test func testGoogleCloudPubSubSchema() {
    let schema = GoogleCloudPubSubSchema(
        name: "my-schema",
        projectID: "test-project",
        type: .avro,
        definition: "{}"
    )

    #expect(schema.resourceName == "projects/test-project/schemas/my-schema")
    #expect(schema.createCommand.contains("gcloud pubsub schemas create my-schema"))
    #expect(schema.createCommand.contains("--type=AVRO"))
}

@Test func testPubSubSchemaFromFile() {
    let schema = GoogleCloudPubSubSchema(
        name: "file-schema",
        projectID: "test-project",
        type: .protocolBuffer,
        definition: ""
    )

    let cmd = schema.createFromFileCommand(filePath: "/path/to/schema.proto")
    #expect(cmd.contains("--definition-file=/path/to/schema.proto"))
    #expect(cmd.contains("--type=PROTOCOL_BUFFER"))
}

@Test func testPubSubSchemaCommands() {
    let schema = GoogleCloudPubSubSchema(
        name: "test-schema",
        projectID: "test-project",
        type: .avro,
        definition: "{}"
    )

    #expect(schema.deleteCommand.contains("gcloud pubsub schemas delete test-schema"))
    #expect(schema.describeCommand.contains("gcloud pubsub schemas describe test-schema"))
}

@Test func testPubSubMessage() {
    let message = GoogleCloudPubSubMessage(
        data: "Hello World",
        attributes: ["key": "value"],
        orderingKey: "order-1"
    )

    #expect(message.data == "Hello World")
    #expect(message.attributes["key"] == "value")
    #expect(message.orderingKey == "order-1")
}

@Test func testPubSubTopicIAMCommands() {
    let topic = GoogleCloudPubSubTopic(
        name: "test-topic",
        projectID: "test-project"
    )

    #expect(topic.getIAMPolicyCommand.contains("gcloud pubsub topics get-iam-policy test-topic"))

    let addCmd = topic.addIAMBindingCommand(member: "user:test@example.com", role: "roles/pubsub.publisher")
    #expect(addCmd.contains("gcloud pubsub topics add-iam-policy-binding test-topic"))
    #expect(addCmd.contains("--member=user:test@example.com"))
    #expect(addCmd.contains("--role=roles/pubsub.publisher"))
}

@Test func testPubSubRole() {
    #expect(PubSubRole.admin.rawValue == "roles/pubsub.admin")
    #expect(PubSubRole.publisher.rawValue == "roles/pubsub.publisher")
    #expect(PubSubRole.subscriber.rawValue == "roles/pubsub.subscriber")
    #expect(PubSubRole.publisher.displayName == "Pub/Sub Publisher")
}

@Test func testDAISPubSubTemplateEventsTopic() {
    let topic = DAISPubSubTemplate.eventsTopic(
        name: "dais-events",
        projectID: "test-project"
    )

    #expect(topic.name == "dais-events")
    #expect(topic.messageRetentionDuration == "7d")
    #expect(topic.labels["app"] == "butteryai")
    #expect(topic.labels["type"] == "events")
}

@Test func testDAISPubSubTemplateCommandsTopic() {
    let topic = DAISPubSubTemplate.commandsTopic(
        name: "dais-commands",
        projectID: "test-project"
    )

    #expect(topic.messageRetentionDuration == "1d")
    #expect(topic.labels["type"] == "commands")
}

@Test func testDAISPubSubTemplateNodeSubscription() {
    let subscription = DAISPubSubTemplate.nodeSubscription(
        nodeName: "node-1",
        topicName: "events",
        projectID: "test-project"
    )

    #expect(subscription.name == "node-1-sub")
    #expect(subscription.enableExactlyOnceDelivery == true)
    #expect(subscription.enableMessageOrdering == true)
    #expect(subscription.labels["node"] == "node-1")
}

@Test func testDAISPubSubTemplateDeadLetterTopic() {
    let topic = DAISPubSubTemplate.deadLetterTopic(
        baseName: "dais",
        projectID: "test-project"
    )

    #expect(topic.name == "dais-dead-letter")
    #expect(topic.messageRetentionDuration == "14d")
    #expect(topic.labels["type"] == "dead-letter")
}

@Test func testDAISPubSubTemplateSubscriptionWithDeadLetter() {
    let subscription = DAISPubSubTemplate.subscriptionWithDeadLetter(
        name: "main-sub",
        topicName: "main-topic",
        deadLetterTopicName: "dead-letter",
        projectID: "test-project",
        maxDeliveryAttempts: 15
    )

    #expect(subscription.deadLetterPolicy != nil)
    #expect(subscription.deadLetterPolicy?.maxDeliveryAttempts == 15)
    #expect(subscription.retryPolicy != nil)
}

@Test func testDAISPubSubTemplateSetupScript() {
    let script = DAISPubSubTemplate.setupScript(
        deploymentName: "prod",
        projectID: "test-project",
        nodeCount: 2
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable pubsub.googleapis.com"))
    #expect(script.contains("prod-events"))
    #expect(script.contains("prod-commands"))
    #expect(script.contains("prod-dead-letter"))
    #expect(script.contains("prod-node-1-sub"))
    #expect(script.contains("prod-node-2-sub"))
}

// MARK: - Pub/Sub Codable Tests

@Test func testPubSubTopicCodable() throws {
    let topic = GoogleCloudPubSubTopic(
        name: "test-topic",
        projectID: "test-project",
        messageRetentionDuration: "7d",
        labels: ["env": "test"]
    )
    let data = try JSONEncoder().encode(topic)
    let decoded = try JSONDecoder().decode(GoogleCloudPubSubTopic.self, from: data)

    #expect(decoded.name == topic.name)
    #expect(decoded.messageRetentionDuration == topic.messageRetentionDuration)
    #expect(decoded.labels == topic.labels)
}

@Test func testPubSubSubscriptionCodable() throws {
    let subscription = GoogleCloudPubSubSubscription(
        name: "test-sub",
        topicName: "test-topic",
        projectID: "test-project",
        ackDeadlineSeconds: 30
    )
    let data = try JSONEncoder().encode(subscription)
    let decoded = try JSONDecoder().decode(GoogleCloudPubSubSubscription.self, from: data)

    #expect(decoded.name == subscription.name)
    #expect(decoded.topicName == subscription.topicName)
    #expect(decoded.ackDeadlineSeconds == subscription.ackDeadlineSeconds)
}

@Test func testPubSubSnapshotCodable() throws {
    let snapshot = GoogleCloudPubSubSnapshot(
        name: "test-snapshot",
        subscriptionName: "test-sub",
        projectID: "test-project"
    )
    let data = try JSONEncoder().encode(snapshot)
    let decoded = try JSONDecoder().decode(GoogleCloudPubSubSnapshot.self, from: data)

    #expect(decoded.name == snapshot.name)
    #expect(decoded.subscriptionName == snapshot.subscriptionName)
}

@Test func testPubSubSchemaCodable() throws {
    let schema = GoogleCloudPubSubSchema(
        name: "test-schema",
        projectID: "test-project",
        type: .avro,
        definition: "{}"
    )
    let data = try JSONEncoder().encode(schema)
    let decoded = try JSONDecoder().decode(GoogleCloudPubSubSchema.self, from: data)

    #expect(decoded.name == schema.name)
    #expect(decoded.type == schema.type)
}

// MARK: - Cloud Functions Tests

@Test func testGoogleCloudFunction() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main"
    )

    #expect(function.name == "my-function")
    #expect(function.projectID == "test-project")
    #expect(function.region == "us-central1")
    #expect(function.runtime == .python312)
    #expect(function.entryPoint == "main")
    #expect(function.memoryMB == 256)
    #expect(function.timeoutSeconds == 60)
    #expect(function.generation == .gen2)
}

@Test func testCloudFunctionResourceName() {
    let function = GoogleCloudFunction(
        name: "test-func",
        projectID: "my-project",
        region: "us-west1",
        runtime: .nodejs20,
        entryPoint: "handler"
    )

    #expect(function.resourceName == "projects/my-project/locations/us-west1/functions/test-func")
}

@Test func testCloudFunctionDeployCommand() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        trigger: .http(allowUnauthenticated: true),
        memoryMB: 512,
        timeoutSeconds: 120
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("gcloud functions deploy my-function"))
    #expect(cmd.contains("--gen2"))
    #expect(cmd.contains("--runtime=python312"))
    #expect(cmd.contains("--entry-point=main"))
    #expect(cmd.contains("--trigger-http"))
    #expect(cmd.contains("--allow-unauthenticated"))
    #expect(cmd.contains("--memory=512MB"))
    #expect(cmd.contains("--timeout=120s"))
}

@Test func testCloudFunctionGen1DeployCommand() {
    let function = GoogleCloudFunction(
        name: "legacy-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .nodejs18,
        entryPoint: "handler",
        generation: .gen1
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("gcloud functions deploy legacy-function"))
    #expect(!cmd.contains("--gen2"))
}

@Test func testCloudFunctionPubSubTrigger() {
    let function = GoogleCloudFunction(
        name: "event-processor",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "process_event",
        trigger: .pubsub(topic: "my-events")
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--trigger-topic=my-events"))
    #expect(!cmd.contains("--trigger-http"))
}

@Test func testCloudFunctionStorageTrigger() {
    let function = GoogleCloudFunction(
        name: "file-processor",
        projectID: "test-project",
        region: "us-central1",
        runtime: .go122,
        entryPoint: "ProcessFile",
        trigger: .storage(bucket: "my-bucket", event: .finalize)
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--trigger-bucket=my-bucket"))
    #expect(cmd.contains("--trigger-event=google.storage.object.finalize"))
}

@Test func testCloudFunctionWithSecrets() {
    let function = GoogleCloudFunction(
        name: "secure-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        secretEnvironmentVariables: [
            GoogleCloudFunction.SecretEnvVar(variableName: "API_KEY", secretName: "my-api-key"),
            GoogleCloudFunction.SecretEnvVar(variableName: "DB_PASSWORD", secretName: "db-pass", version: "2")
        ]
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--set-secrets=API_KEY=my-api-key:latest"))
    #expect(cmd.contains("--set-secrets=DB_PASSWORD=db-pass:2"))
}

@Test func testCloudFunctionWithEnvVars() {
    let function = GoogleCloudFunction(
        name: "configured-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        environmentVariables: ["NODE_ENV": "production", "LOG_LEVEL": "debug"]
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--set-env-vars="))
    #expect(cmd.contains("NODE_ENV=production") || cmd.contains("LOG_LEVEL=debug"))
}

@Test func testCloudFunctionWithVPCConnector() {
    let function = GoogleCloudFunction(
        name: "private-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        vpcConnector: "projects/test-project/locations/us-central1/connectors/my-connector",
        ingressSettings: .internalOnly
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--vpc-connector=projects/test-project/locations/us-central1/connectors/my-connector"))
    #expect(cmd.contains("--ingress-settings=internal-only"))
}

@Test func testCloudFunctionDeleteCommand() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main"
    )

    let cmd = function.deleteCommand
    #expect(cmd.contains("gcloud functions delete my-function"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--gen2"))
    #expect(cmd.contains("--quiet"))
}

@Test func testCloudFunctionDescribeCommand() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main"
    )

    let cmd = function.describeCommand
    #expect(cmd.contains("gcloud functions describe my-function"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testCloudFunctionLogsCommand() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main"
    )

    let cmd = function.logsCommand
    #expect(cmd.contains("gcloud functions logs read my-function"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testCloudFunctionCallCommand() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        trigger: .http(allowUnauthenticated: false)
    )

    let cmd = function.callCommand(data: "{\"key\": \"value\"}")
    #expect(cmd.contains("gcloud functions call my-function"))
    #expect(cmd.contains("--data='{\"key\": \"value\"}'"))
}

@Test func testCloudFunctionListCommand() {
    let cmd = GoogleCloudFunction.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd.contains("gcloud functions list"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testCloudFunctionHTTPURL() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        trigger: .http(allowUnauthenticated: true),
        generation: .gen1
    )

    #expect(function.httpURL == "https://us-central1-test-project.cloudfunctions.net/my-function")
}

@Test func testCloudFunctionHTTPURLNilForNonHTTP() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        trigger: .pubsub(topic: "my-topic")
    )

    #expect(function.httpURL == nil)
}

// MARK: - Cloud Function Runtime Tests

@Test func testCloudFunctionRuntime() {
    #expect(CloudFunctionRuntime.python312.rawValue == "python312")
    #expect(CloudFunctionRuntime.nodejs20.rawValue == "nodejs20")
    #expect(CloudFunctionRuntime.go122.rawValue == "go122")
    #expect(CloudFunctionRuntime.java21.rawValue == "java21")
    #expect(CloudFunctionRuntime.dotnet8.rawValue == "dotnet8")
}

@Test func testCloudFunctionRuntimeLanguage() {
    #expect(CloudFunctionRuntime.python312.language == "Python")
    #expect(CloudFunctionRuntime.nodejs20.language == "Node.js")
    #expect(CloudFunctionRuntime.go122.language == "Go")
    #expect(CloudFunctionRuntime.java21.language == "Java")
    #expect(CloudFunctionRuntime.dotnet8.language == ".NET")
    #expect(CloudFunctionRuntime.ruby33.language == "Ruby")
    #expect(CloudFunctionRuntime.php83.language == "PHP")
}

@Test func testCloudFunctionRuntimeRecommended() {
    #expect(CloudFunctionRuntime.python312.isRecommended == true)
    #expect(CloudFunctionRuntime.nodejs20.isRecommended == true)
    #expect(CloudFunctionRuntime.go122.isRecommended == true)
    #expect(CloudFunctionRuntime.python39.isRecommended == false)
    #expect(CloudFunctionRuntime.nodejs18.isRecommended == false)
}

// MARK: - Cloud Function Source Tests

@Test func testCloudFunctionSourceLocal() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        source: .localDirectory(path: "./src")
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--source=./src"))
}

@Test func testCloudFunctionSourceGCS() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        source: .gcs(bucket: "my-bucket", object: "functions/code.zip")
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--source=gs://my-bucket/functions/code.zip"))
}

// MARK: - Cloud Function Trigger Tests

@Test func testCloudFunctionFirestoreTrigger() {
    let function = GoogleCloudFunction(
        name: "firestore-handler",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "on_document_create",
        trigger: .firestore(document: "users/{userId}", event: .create)
    )

    let cmd = function.deployCommand
    #expect(cmd.contains("--trigger-event=providers/cloud.firestore/eventTypes/document.create"))
    #expect(cmd.contains("--trigger-resource=users/{userId}"))
}

@Test func testStorageEventRawValues() {
    #expect(GoogleCloudFunction.StorageEvent.finalize.rawValue == "google.storage.object.finalize")
    #expect(GoogleCloudFunction.StorageEvent.delete.rawValue == "google.storage.object.delete")
    #expect(GoogleCloudFunction.StorageEvent.archive.rawValue == "google.storage.object.archive")
    #expect(GoogleCloudFunction.StorageEvent.metadataUpdate.rawValue == "google.storage.object.metadataUpdate")
}

@Test func testFirestoreEventRawValues() {
    #expect(GoogleCloudFunction.FirestoreEvent.create.rawValue == "providers/cloud.firestore/eventTypes/document.create")
    #expect(GoogleCloudFunction.FirestoreEvent.update.rawValue == "providers/cloud.firestore/eventTypes/document.update")
    #expect(GoogleCloudFunction.FirestoreEvent.delete.rawValue == "providers/cloud.firestore/eventTypes/document.delete")
    #expect(GoogleCloudFunction.FirestoreEvent.write.rawValue == "providers/cloud.firestore/eventTypes/document.write")
}

// MARK: - Cloud Function IAM Tests

@Test func testCloudFunctionRoles() {
    #expect(GoogleCloudFunction.FunctionRole.admin.rawValue == "roles/cloudfunctions.admin")
    #expect(GoogleCloudFunction.FunctionRole.developer.rawValue == "roles/cloudfunctions.developer")
    #expect(GoogleCloudFunction.FunctionRole.viewer.rawValue == "roles/cloudfunctions.viewer")
    #expect(GoogleCloudFunction.FunctionRole.invoker.rawValue == "roles/cloudfunctions.invoker")
}

@Test func testCloudFunctionAddInvokerCommand() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main"
    )

    let cmd = function.addInvokerCommand(member: "serviceAccount:invoker@test-project.iam.gserviceaccount.com")
    #expect(cmd.contains("gcloud functions add-iam-policy-binding my-function"))
    #expect(cmd.contains("--member=serviceAccount:invoker@test-project.iam.gserviceaccount.com"))
    #expect(cmd.contains("--role=roles/cloudfunctions.invoker"))
}

@Test func testCloudFunctionGetIAMPolicyCommand() {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main"
    )

    let cmd = function.getIAMPolicyCommand
    #expect(cmd.contains("gcloud functions get-iam-policy my-function"))
    #expect(cmd.contains("--project=test-project"))
}

// MARK: - Cloud Scheduler Job Tests

@Test func testCloudSchedulerJob() {
    let job = CloudSchedulerJob(
        name: "daily-task",
        projectID: "test-project",
        location: "us-central1",
        schedule: "0 2 * * *",
        timezone: "America/Los_Angeles",
        targetFunction: "https://us-central1-test-project.cloudfunctions.net/my-function"
    )

    #expect(job.name == "daily-task")
    #expect(job.schedule == "0 2 * * *")
    #expect(job.timezone == "America/Los_Angeles")
}

@Test func testCloudSchedulerJobCreateCommand() {
    let job = CloudSchedulerJob(
        name: "daily-task",
        projectID: "test-project",
        location: "us-central1",
        schedule: "0 2 * * *",
        timezone: "UTC",
        targetFunction: "https://example.com/function",
        httpMethod: "POST",
        body: "{\"action\": \"run\"}",
        serviceAccountEmail: "scheduler@test-project.iam.gserviceaccount.com"
    )

    let cmd = job.createCommand
    #expect(cmd.contains("gcloud scheduler jobs create http daily-task"))
    #expect(cmd.contains("--schedule=\"0 2 * * *\""))
    #expect(cmd.contains("--time-zone=\"UTC\""))
    #expect(cmd.contains("--uri=https://example.com/function"))
    #expect(cmd.contains("--http-method=POST"))
    #expect(cmd.contains("--message-body='{\"action\": \"run\"}'"))
    #expect(cmd.contains("--oidc-service-account-email=scheduler@test-project.iam.gserviceaccount.com"))
}

@Test func testCloudSchedulerJobCommands() {
    let job = CloudSchedulerJob(
        name: "my-job",
        projectID: "test-project",
        location: "us-central1",
        schedule: "0 * * * *",
        targetFunction: "https://example.com/function"
    )

    #expect(job.deleteCommand.contains("gcloud scheduler jobs delete my-job"))
    #expect(job.pauseCommand.contains("gcloud scheduler jobs pause my-job"))
    #expect(job.resumeCommand.contains("gcloud scheduler jobs resume my-job"))
    #expect(job.runCommand.contains("gcloud scheduler jobs run my-job"))
}

// MARK: - VPC Connector Tests

@Test func testVPCConnector() {
    let connector = VPCConnector(
        name: "my-connector",
        projectID: "test-project",
        region: "us-central1",
        network: "default",
        ipCidrRange: "10.8.0.0/28"
    )

    #expect(connector.name == "my-connector")
    #expect(connector.network == "default")
    #expect(connector.ipCidrRange == "10.8.0.0/28")
    #expect(connector.minThroughput == 200)
    #expect(connector.maxThroughput == 300)
}

@Test func testVPCConnectorResourceName() {
    let connector = VPCConnector(
        name: "my-connector",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.8.0.0/28"
    )

    #expect(connector.resourceName == "projects/test-project/locations/us-central1/connectors/my-connector")
}

@Test func testVPCConnectorCreateCommand() {
    let connector = VPCConnector(
        name: "my-connector",
        projectID: "test-project",
        region: "us-central1",
        network: "my-vpc",
        ipCidrRange: "10.8.0.0/28",
        minThroughput: 300,
        maxThroughput: 500
    )

    let cmd = connector.createCommand
    #expect(cmd.contains("gcloud compute networks vpc-access connectors create my-connector"))
    #expect(cmd.contains("--network=my-vpc"))
    #expect(cmd.contains("--range=10.8.0.0/28"))
    #expect(cmd.contains("--min-throughput=300"))
    #expect(cmd.contains("--max-throughput=500"))
}

@Test func testVPCConnectorDeleteCommand() {
    let connector = VPCConnector(
        name: "my-connector",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.8.0.0/28"
    )

    let cmd = connector.deleteCommand
    #expect(cmd.contains("gcloud compute networks vpc-access connectors delete my-connector"))
    #expect(cmd.contains("--quiet"))
}

// MARK: - DAIS Function Template Tests

@Test func testDAISFunctionTemplateEventProcessor() {
    let function = DAISFunctionTemplate.eventProcessor(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        eventsTopic: "prod-events"
    )

    #expect(function.name == "prod-event-processor")
    #expect(function.runtime == .python312)
    #expect(function.entryPoint == "process_event")
    #expect(function.memoryMB == 512)
    #expect(function.timeoutSeconds == 120)
    #expect(function.labels["app"] == "butteryai")
    #expect(function.labels["deployment"] == "prod")
    #expect(function.labels["component"] == "event-processor")
}

@Test func testDAISFunctionTemplateHealthCheck() {
    let function = DAISFunctionTemplate.healthCheck(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod"
    )

    #expect(function.name == "prod-health-check")
    #expect(function.memoryMB == 128)
    #expect(function.timeoutSeconds == 10)

    // Health check should allow unauthenticated access
    if case .http(let allowUnauthenticated) = function.trigger {
        #expect(allowUnauthenticated == true)
    } else {
        #expect(Bool(false), "Expected HTTP trigger")
    }
}

@Test func testDAISFunctionTemplateWebhook() {
    let function = DAISFunctionTemplate.webhookHandler(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        allowUnauthenticated: false
    )

    #expect(function.name == "prod-webhook")
    #expect(function.entryPoint == "handle_webhook")
    #expect(function.memoryMB == 256)
}

@Test func testDAISFunctionTemplateScheduledMaintenance() {
    let (function, scheduler) = DAISFunctionTemplate.scheduledMaintenance(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        schedule: "0 3 * * *",
        timezone: "America/New_York"
    )

    #expect(function.name == "prod-maintenance")
    #expect(function.timeoutSeconds == 540)
    #expect(function.maxInstances == 1)

    #expect(scheduler.name == "prod-maintenance-trigger")
    #expect(scheduler.schedule == "0 3 * * *")
    #expect(scheduler.timezone == "America/New_York")
}

@Test func testDAISFunctionTemplateStorageProcessor() {
    let function = DAISFunctionTemplate.storageProcessor(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        bucket: "my-uploads"
    )

    #expect(function.name == "prod-storage-processor")
    #expect(function.entryPoint == "process_file")
    #expect(function.memoryMB == 1024)

    if case .storage(let bucket, let event) = function.trigger {
        #expect(bucket == "my-uploads")
        #expect(event == .finalize)
    } else {
        #expect(Bool(false), "Expected storage trigger")
    }
}

@Test func testDAISFunctionTemplateEventProcessorCode() {
    let code = DAISFunctionTemplate.eventProcessorCode()

    #expect(code.contains("def process_event(event, context):"))
    #expect(code.contains("base64.b64decode"))
    #expect(code.contains("DEPLOYMENT_NAME"))
    #expect(code.contains("return 'OK'"))
}

@Test func testDAISFunctionTemplateHealthCheckCode() {
    let code = DAISFunctionTemplate.healthCheckCode()

    #expect(code.contains("def health_check(request):"))
    #expect(code.contains("'status': 'healthy'"))
    #expect(code.contains("application/json"))
}

@Test func testDAISFunctionTemplateSetupScript() {
    let script = DAISFunctionTemplate.setupScript(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        eventsTopic: "prod-events"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable cloudfunctions.googleapis.com"))
    #expect(script.contains("gcloud services enable cloudbuild.googleapis.com"))
    #expect(script.contains("prod-event-processor"))
    #expect(script.contains("prod-health-check"))
    #expect(script.contains("def process_event"))
}

// MARK: - Cloud Function Codable Tests

@Test func testCloudFunctionCodable() throws {
    let function = GoogleCloudFunction(
        name: "my-function",
        projectID: "test-project",
        region: "us-central1",
        runtime: .python312,
        entryPoint: "main",
        memoryMB: 512,
        timeoutSeconds: 120,
        labels: ["env": "test"]
    )

    let data = try JSONEncoder().encode(function)
    let decoded = try JSONDecoder().decode(GoogleCloudFunction.self, from: data)

    #expect(decoded.name == function.name)
    #expect(decoded.runtime == function.runtime)
    #expect(decoded.memoryMB == function.memoryMB)
    #expect(decoded.labels == function.labels)
}

@Test func testCloudSchedulerJobCodable() throws {
    let job = CloudSchedulerJob(
        name: "my-job",
        projectID: "test-project",
        location: "us-central1",
        schedule: "0 * * * *",
        timezone: "UTC",
        targetFunction: "https://example.com/function"
    )

    let data = try JSONEncoder().encode(job)
    let decoded = try JSONDecoder().decode(CloudSchedulerJob.self, from: data)

    #expect(decoded.name == job.name)
    #expect(decoded.schedule == job.schedule)
    #expect(decoded.timezone == job.timezone)
}

@Test func testVPCConnectorCodable() throws {
    let connector = VPCConnector(
        name: "my-connector",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.8.0.0/28"
    )

    let data = try JSONEncoder().encode(connector)
    let decoded = try JSONDecoder().decode(VPCConnector.self, from: data)

    #expect(decoded.name == connector.name)
    #expect(decoded.ipCidrRange == connector.ipCidrRange)
}

@Test func testCloudFunctionEventCodable() throws {
    let event = CloudFunctionEvent.pubsub(topic: "my-topic", projectID: "test-project")

    let data = try JSONEncoder().encode(event)
    let decoded = try JSONDecoder().decode(CloudFunctionEvent.self, from: data)

    #expect(decoded.eventType == event.eventType)
    #expect(decoded.filters == event.filters)
}

@Test func testSecretEnvVarCodable() throws {
    let secretVar = GoogleCloudFunction.SecretEnvVar(
        variableName: "API_KEY",
        secretName: "my-secret",
        version: "latest"
    )

    let data = try JSONEncoder().encode(secretVar)
    let decoded = try JSONDecoder().decode(GoogleCloudFunction.SecretEnvVar.self, from: data)

    #expect(decoded.variableName == secretVar.variableName)
    #expect(decoded.secretName == secretVar.secretName)
    #expect(decoded.version == secretVar.version)
}

// MARK: - Cloud Run Service Tests

@Test func testGoogleCloudRunService() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    #expect(service.name == "my-api")
    #expect(service.projectID == "test-project")
    #expect(service.region == "us-central1")
    #expect(service.port == 8080)
    #expect(service.memoryMB == 512)
    #expect(service.cpu == "1")
    #expect(service.minInstances == 0)
    #expect(service.maxInstances == 100)
    #expect(service.concurrency == 80)
}

@Test func testCloudRunServiceResourceName() {
    let service = GoogleCloudRunService(
        name: "my-service",
        projectID: "test-project",
        region: "us-west1",
        image: "gcr.io/test-project/image:v1"
    )

    #expect(service.resourceName == "projects/test-project/locations/us-west1/services/my-service")
}

@Test func testCloudRunServiceDeployCommand() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest",
        port: 8080,
        memoryMB: 1024,
        cpu: "2",
        minInstances: 1,
        maxInstances: 10,
        allowUnauthenticated: true
    )

    let cmd = service.deployCommand
    #expect(cmd.contains("gcloud run deploy my-api"))
    #expect(cmd.contains("--image=gcr.io/test-project/my-api:latest"))
    #expect(cmd.contains("--port=8080"))
    #expect(cmd.contains("--memory=1024Mi"))
    #expect(cmd.contains("--cpu=2"))
    #expect(cmd.contains("--min-instances=1"))
    #expect(cmd.contains("--max-instances=10"))
    #expect(cmd.contains("--allow-unauthenticated"))
}

@Test func testCloudRunServiceWithEnvVars() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest",
        environmentVariables: ["NODE_ENV": "production", "LOG_LEVEL": "info"]
    )

    let cmd = service.deployCommand
    #expect(cmd.contains("--set-env-vars="))
}

@Test func testCloudRunServiceWithSecrets() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest",
        secrets: [
            .envVar(name: "API_KEY", secretName: "my-api-key"),
            .envVar(name: "DB_PASSWORD", secretName: "db-pass", version: "2")
        ]
    )

    let cmd = service.deployCommand
    #expect(cmd.contains("--set-secrets=API_KEY=my-api-key:latest"))
    #expect(cmd.contains("--set-secrets=DB_PASSWORD=db-pass:2"))
}

@Test func testCloudRunServiceWithVPCConnector() {
    let service = GoogleCloudRunService(
        name: "private-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/private-api:latest",
        vpcConnector: "projects/test-project/locations/us-central1/connectors/my-connector",
        vpcEgress: .allTraffic,
        ingress: .internal
    )

    let cmd = service.deployCommand
    #expect(cmd.contains("--vpc-connector=projects/test-project/locations/us-central1/connectors/my-connector"))
    #expect(cmd.contains("--vpc-egress=all-traffic"))
    #expect(cmd.contains("--ingress=internal"))
}

@Test func testCloudRunServiceWithCPUAlwaysAllocated() {
    let service = GoogleCloudRunService(
        name: "worker",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/worker:latest",
        cpuAllocationType: .alwaysAllocated
    )

    let cmd = service.deployCommand
    #expect(cmd.contains("--cpu-boost"))
    #expect(cmd.contains("--no-cpu-throttling"))
}

@Test func testCloudRunServiceDeleteCommand() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    let cmd = service.deleteCommand
    #expect(cmd.contains("gcloud run services delete my-api"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--quiet"))
}

@Test func testCloudRunServiceDescribeCommand() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    let cmd = service.describeCommand
    #expect(cmd.contains("gcloud run services describe my-api"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testCloudRunServiceLogsCommand() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    let cmd = service.logsCommand
    #expect(cmd.contains("gcloud run services logs read my-api"))
}

@Test func testCloudRunServiceUpdateTrafficCommand() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    let cmd = service.updateTrafficCommand(revisions: ["my-api-v1": 90, "my-api-v2": 10])
    #expect(cmd.contains("gcloud run services update-traffic my-api"))
    #expect(cmd.contains("--to-revisions="))
}

@Test func testCloudRunServiceRouteToLatest() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    let cmd = service.routeToLatestCommand
    #expect(cmd.contains("--to-latest"))
}

@Test func testCloudRunServiceListCommand() {
    let cmd = GoogleCloudRunService.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd.contains("gcloud run services list"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--region=us-central1"))
}

// MARK: - Cloud Run Job Tests

@Test func testGoogleCloudRunJob() {
    let job = GoogleCloudRunJob(
        name: "data-processor",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/processor:latest"
    )

    #expect(job.name == "data-processor")
    #expect(job.projectID == "test-project")
    #expect(job.taskCount == 1)
    #expect(job.parallelism == 1)
    #expect(job.taskTimeoutSeconds == 600)
    #expect(job.maxRetries == 3)
}

@Test func testCloudRunJobResourceName() {
    let job = GoogleCloudRunJob(
        name: "batch-job",
        projectID: "test-project",
        region: "us-west1",
        image: "gcr.io/test-project/batch:v1"
    )

    #expect(job.resourceName == "projects/test-project/locations/us-west1/jobs/batch-job")
}

@Test func testCloudRunJobCreateCommand() {
    let job = GoogleCloudRunJob(
        name: "data-processor",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/processor:latest",
        taskCount: 10,
        parallelism: 5,
        taskTimeoutSeconds: 1800,
        memoryMB: 2048,
        cpu: "2"
    )

    let cmd = job.createCommand
    #expect(cmd.contains("gcloud run jobs create data-processor"))
    #expect(cmd.contains("--image=gcr.io/test-project/processor:latest"))
    #expect(cmd.contains("--tasks=10"))
    #expect(cmd.contains("--parallelism=5"))
    #expect(cmd.contains("--task-timeout=1800s"))
    #expect(cmd.contains("--memory=2048Mi"))
    #expect(cmd.contains("--cpu=2"))
}

@Test func testCloudRunJobWithCommand() {
    let job = GoogleCloudRunJob(
        name: "custom-job",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/job:latest",
        command: ["python", "script.py"],
        args: ["--input", "data.csv"]
    )

    let cmd = job.createCommand
    #expect(cmd.contains("--command=python,script.py"))
    #expect(cmd.contains("--args=--input,data.csv"))
}

@Test func testCloudRunJobExecuteCommand() {
    let job = GoogleCloudRunJob(
        name: "batch-job",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/batch:latest"
    )

    let cmd = job.executeCommand
    #expect(cmd.contains("gcloud run jobs execute batch-job"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testCloudRunJobExecuteWithOverrides() {
    let job = GoogleCloudRunJob(
        name: "batch-job",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/batch:latest"
    )

    let cmd = job.executeCommand(taskCount: 5, args: ["--verbose"])
    #expect(cmd.contains("--tasks=5"))
    #expect(cmd.contains("--args=--verbose"))
}

@Test func testCloudRunJobDeleteCommand() {
    let job = GoogleCloudRunJob(
        name: "batch-job",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/batch:latest"
    )

    let cmd = job.deleteCommand
    #expect(cmd.contains("gcloud run jobs delete batch-job"))
    #expect(cmd.contains("--quiet"))
}

@Test func testCloudRunJobListExecutionsCommand() {
    let job = GoogleCloudRunJob(
        name: "batch-job",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/batch:latest"
    )

    let cmd = job.listExecutionsCommand
    #expect(cmd.contains("gcloud run jobs executions list"))
    #expect(cmd.contains("--job=batch-job"))
}

// MARK: - Cloud Run Revision Tests

@Test func testGoogleCloudRunRevision() {
    let revision = GoogleCloudRunRevision(
        name: "my-api-00001",
        serviceName: "my-api",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(revision.name == "my-api-00001")
    #expect(revision.serviceName == "my-api")
}

@Test func testCloudRunRevisionResourceName() {
    let revision = GoogleCloudRunRevision(
        name: "my-api-00001",
        serviceName: "my-api",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(revision.resourceName == "projects/test-project/locations/us-central1/services/my-api/revisions/my-api-00001")
}

@Test func testCloudRunRevisionDescribeCommand() {
    let revision = GoogleCloudRunRevision(
        name: "my-api-00001",
        serviceName: "my-api",
        projectID: "test-project",
        region: "us-central1"
    )

    let cmd = revision.describeCommand
    #expect(cmd.contains("gcloud run revisions describe my-api-00001"))
}

// MARK: - Cloud Run Domain Mapping Tests

@Test func testGoogleCloudRunDomainMapping() {
    let mapping = GoogleCloudRunDomainMapping(
        domain: "api.example.com",
        serviceName: "my-api",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(mapping.domain == "api.example.com")
    #expect(mapping.serviceName == "my-api")
}

@Test func testCloudRunDomainMappingCreateCommand() {
    let mapping = GoogleCloudRunDomainMapping(
        domain: "api.example.com",
        serviceName: "my-api",
        projectID: "test-project",
        region: "us-central1"
    )

    let cmd = mapping.createCommand
    #expect(cmd.contains("gcloud run domain-mappings create"))
    #expect(cmd.contains("--domain=api.example.com"))
    #expect(cmd.contains("--service=my-api"))
}

@Test func testCloudRunDomainMappingListCommand() {
    let cmd = GoogleCloudRunDomainMapping.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd.contains("gcloud run domain-mappings list"))
    #expect(cmd.contains("--project=test-project"))
}

// MARK: - Cloud Run Traffic Split Tests

@Test func testCloudRunTrafficSplitLatest() {
    let traffic = CloudRunTrafficSplit.latest

    #expect(traffic.routeToLatest == true)
    #expect(traffic.revisions.isEmpty)
}

@Test func testCloudRunTrafficSplitCustom() {
    let traffic = CloudRunTrafficSplit.split(["v1": 80, "v2": 20])

    #expect(traffic.routeToLatest == false)
    #expect(traffic.revisions["v1"] == 80)
    #expect(traffic.revisions["v2"] == 20)
}

@Test func testCloudRunTrafficSplitCanary() {
    let traffic = CloudRunTrafficSplit.canary(
        stableRevision: "my-api-v1",
        canaryRevision: "my-api-v2",
        canaryPercent: 10
    )

    #expect(traffic.revisions["my-api-v1"] == 90)
    #expect(traffic.revisions["my-api-v2"] == 10)
}

// MARK: - Cloud Run IAM Tests

@Test func testCloudRunRoles() {
    #expect(GoogleCloudRunService.CloudRunRole.admin.rawValue == "roles/run.admin")
    #expect(GoogleCloudRunService.CloudRunRole.developer.rawValue == "roles/run.developer")
    #expect(GoogleCloudRunService.CloudRunRole.viewer.rawValue == "roles/run.viewer")
    #expect(GoogleCloudRunService.CloudRunRole.invoker.rawValue == "roles/run.invoker")
}

@Test func testCloudRunAddInvokerCommand() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    let cmd = service.addInvokerCommand(member: "serviceAccount:invoker@test-project.iam.gserviceaccount.com")
    #expect(cmd.contains("gcloud run services add-iam-policy-binding my-api"))
    #expect(cmd.contains("--member=serviceAccount:invoker@test-project.iam.gserviceaccount.com"))
    #expect(cmd.contains("--role=roles/run.invoker"))
}

@Test func testCloudRunMakePublicCommand() {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest"
    )

    let cmd = service.makePublicCommand
    #expect(cmd.contains("--member=allUsers"))
    #expect(cmd.contains("--role=roles/run.invoker"))
}

// MARK: - DAIS Cloud Run Template Tests

@Test func testDAISCloudRunTemplateGRPCService() {
    let service = DAISCloudRunTemplate.grpcService(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        image: "gcr.io/test-project/dais-grpc:latest"
    )

    #expect(service.name == "prod-grpc")
    #expect(service.port == 9090)
    #expect(service.memoryMB == 1024)
    #expect(service.cpu == "2")
    #expect(service.minInstances == 1)
    #expect(service.cpuAllocationType == .alwaysAllocated)
    #expect(service.labels["app"] == "butteryai")
    #expect(service.labels["component"] == "grpc-service")
}

@Test func testDAISCloudRunTemplateHTTPAPI() {
    let service = DAISCloudRunTemplate.httpAPI(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        image: "gcr.io/test-project/dais-api:latest"
    )

    #expect(service.name == "prod-api")
    #expect(service.port == 8080)
    #expect(service.memoryMB == 512)
    #expect(service.minInstances == 0)
    #expect(service.allowUnauthenticated == true)
    #expect(service.labels["component"] == "http-api")
}

@Test func testDAISCloudRunTemplateWorker() {
    let service = DAISCloudRunTemplate.worker(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        image: "gcr.io/test-project/dais-worker:latest",
        concurrency: 1
    )

    #expect(service.name == "prod-worker")
    #expect(service.memoryMB == 2048)
    #expect(service.timeoutSeconds == 3600)
    #expect(service.concurrency == 1)
    #expect(service.cpuAllocationType == .alwaysAllocated)
}

@Test func testDAISCloudRunTemplateBatchJob() {
    let job = DAISCloudRunTemplate.batchJob(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        image: "gcr.io/test-project/dais-batch:latest",
        taskCount: 10,
        parallelism: 5
    )

    #expect(job.name == "prod-batch")
    #expect(job.taskCount == 10)
    #expect(job.parallelism == 5)
    #expect(job.labels["component"] == "batch-job")
}

@Test func testDAISCloudRunTemplateMaintenanceJob() {
    let job = DAISCloudRunTemplate.maintenanceJob(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        image: "gcr.io/test-project/dais-maint:latest"
    )

    #expect(job.name == "prod-maintenance")
    #expect(job.command == ["/app/maintenance"])
    #expect(job.taskTimeoutSeconds == 1800)
    #expect(job.labels["component"] == "maintenance")
}

@Test func testDAISCloudRunTemplateSetupScript() {
    let script = DAISCloudRunTemplate.setupScript(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "prod",
        grpcImage: "gcr.io/test-project/grpc:latest",
        apiImage: "gcr.io/test-project/api:latest"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable run.googleapis.com"))
    #expect(script.contains("prod-grpc"))
    #expect(script.contains("prod-api"))
}

@Test func testDAISCloudRunTemplateDockerfile() {
    let dockerfile = DAISCloudRunTemplate.dockerfile(
        baseImage: "swift:5.10-jammy",
        executableName: "dais-server",
        port: 8080
    )

    #expect(dockerfile.contains("FROM swift:5.10-jammy"))
    #expect(dockerfile.contains("swift build -c release"))
    #expect(dockerfile.contains("EXPOSE 8080"))
    #expect(dockerfile.contains("CMD [\"/app/dais-server\"]"))
}

@Test func testDAISCloudRunTemplateCloudbuildConfig() {
    let config = DAISCloudRunTemplate.cloudbuildConfig(
        projectID: "test-project",
        region: "us-central1",
        serviceName: "my-service",
        imageName: "my-image"
    )

    #expect(config.contains("gcr.io/test-project/my-image"))
    #expect(config.contains("gcloud"))
    #expect(config.contains("run"))
    #expect(config.contains("deploy"))
}

// MARK: - Container Registry Tests

@Test func testContainerRegistryGCR() {
    let registry = ContainerRegistry.gcr(
        projectID: "test-project",
        imageName: "my-app",
        tag: "v1.0.0"
    )

    #expect(registry.imageURL == "gcr.io/test-project/my-app:v1.0.0")
}

@Test func testContainerRegistryArtifactRegistry() {
    let registry = ContainerRegistry.artifactRegistry(
        projectID: "test-project",
        location: "us-central1",
        repository: "my-repo",
        imageName: "my-app",
        tag: "latest"
    )

    #expect(registry.imageURL == "us-central1-docker.pkg.dev/test-project/my-repo/my-app:latest")
}

@Test func testContainerRegistryDockerHub() {
    let registry = ContainerRegistry.dockerHub(
        imageName: "nginx",
        tag: "latest"
    )

    #expect(registry.imageURL == "nginx:latest")
}

// MARK: - Cloud Run Codable Tests

@Test func testCloudRunServiceCodable() throws {
    let service = GoogleCloudRunService(
        name: "my-api",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/my-api:latest",
        memoryMB: 1024,
        labels: ["env": "test"]
    )

    let data = try JSONEncoder().encode(service)
    let decoded = try JSONDecoder().decode(GoogleCloudRunService.self, from: data)

    #expect(decoded.name == service.name)
    #expect(decoded.image == service.image)
    #expect(decoded.memoryMB == service.memoryMB)
    #expect(decoded.labels == service.labels)
}

@Test func testCloudRunJobCodable() throws {
    let job = GoogleCloudRunJob(
        name: "batch-job",
        projectID: "test-project",
        region: "us-central1",
        image: "gcr.io/test-project/batch:latest",
        taskCount: 5
    )

    let data = try JSONEncoder().encode(job)
    let decoded = try JSONDecoder().decode(GoogleCloudRunJob.self, from: data)

    #expect(decoded.name == job.name)
    #expect(decoded.taskCount == job.taskCount)
}

@Test func testCloudRunRevisionCodable() throws {
    let revision = GoogleCloudRunRevision(
        name: "my-api-00001",
        serviceName: "my-api",
        projectID: "test-project",
        region: "us-central1"
    )

    let data = try JSONEncoder().encode(revision)
    let decoded = try JSONDecoder().decode(GoogleCloudRunRevision.self, from: data)

    #expect(decoded.name == revision.name)
    #expect(decoded.serviceName == revision.serviceName)
}

@Test func testCloudRunDomainMappingCodable() throws {
    let mapping = GoogleCloudRunDomainMapping(
        domain: "api.example.com",
        serviceName: "my-api",
        projectID: "test-project",
        region: "us-central1"
    )

    let data = try JSONEncoder().encode(mapping)
    let decoded = try JSONDecoder().decode(GoogleCloudRunDomainMapping.self, from: data)

    #expect(decoded.domain == mapping.domain)
    #expect(decoded.serviceName == mapping.serviceName)
}

@Test func testCloudRunTrafficSplitCodable() throws {
    let traffic = CloudRunTrafficSplit.canary(
        stableRevision: "v1",
        canaryRevision: "v2",
        canaryPercent: 10
    )

    let data = try JSONEncoder().encode(traffic)
    let decoded = try JSONDecoder().decode(CloudRunTrafficSplit.self, from: data)

    #expect(decoded.revisions == traffic.revisions)
    #expect(decoded.routeToLatest == traffic.routeToLatest)
}

@Test func testSecretMountCodable() throws {
    let mount = GoogleCloudRunService.SecretMount.envVar(
        name: "API_KEY",
        secretName: "my-secret",
        version: "latest"
    )

    let data = try JSONEncoder().encode(mount)
    let decoded = try JSONDecoder().decode(GoogleCloudRunService.SecretMount.self, from: data)

    #expect(decoded.secretName == mount.secretName)
    #expect(decoded.version == mount.version)
}

// MARK: - Cloud Logging Tests

@Test func testGoogleCloudLogEntry() {
    let entry = GoogleCloudLogEntry(
        logName: "my-app",
        projectID: "test-project",
        severity: .error,
        textPayload: "Connection failed"
    )

    #expect(entry.logName == "my-app")
    #expect(entry.projectID == "test-project")
    #expect(entry.severity == .error)
    #expect(entry.textPayload == "Connection failed")
}

@Test func testLogEntryResourceName() {
    let entry = GoogleCloudLogEntry(
        logName: "my-app",
        projectID: "test-project",
        severity: .info
    )

    #expect(entry.resourceName == "projects/test-project/logs/my-app")
}

@Test func testLogEntryWriteCommand() {
    let entry = GoogleCloudLogEntry(
        logName: "my-app",
        projectID: "test-project",
        severity: .warning,
        textPayload: "Disk space low"
    )

    let cmd = entry.writeCommand
    #expect(cmd.contains("gcloud logging write my-app"))
    #expect(cmd.contains("\"Disk space low\""))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--severity=WARNING"))
}

@Test func testLogEntryWithResourceType() {
    let entry = GoogleCloudLogEntry(
        logName: "my-app",
        projectID: "test-project",
        severity: .info,
        textPayload: "Started",
        resourceType: "gce_instance"
    )

    let cmd = entry.writeCommand
    #expect(cmd.contains("--resource-type=gce_instance"))
}

@Test func testLogEntryReadCommand() {
    let cmd = GoogleCloudLogEntry.readCommand(
        projectID: "test-project",
        logName: "my-app",
        limit: 50
    )

    #expect(cmd.contains("gcloud logging read"))
    #expect(cmd.contains("logName=\"projects/test-project/logs/my-app\""))
    #expect(cmd.contains("--limit=50"))
}

@Test func testLogEntryReadCommandWithFilter() {
    let cmd = GoogleCloudLogEntry.readCommand(
        projectID: "test-project",
        filter: "severity >= ERROR",
        limit: 100
    )

    #expect(cmd.contains("severity >= ERROR"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testLogEntryDeleteCommand() {
    let cmd = GoogleCloudLogEntry.deleteCommand(projectID: "test-project", logName: "my-app")
    #expect(cmd.contains("gcloud logging logs delete my-app"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--quiet"))
}

@Test func testLogEntryListCommand() {
    let cmd = GoogleCloudLogEntry.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud logging logs list"))
    #expect(cmd.contains("--project=test-project"))
}

// MARK: - Log Severity Tests

@Test func testLogSeverityValues() {
    #expect(LogSeverity.default.rawValue == "DEFAULT")
    #expect(LogSeverity.debug.rawValue == "DEBUG")
    #expect(LogSeverity.info.rawValue == "INFO")
    #expect(LogSeverity.notice.rawValue == "NOTICE")
    #expect(LogSeverity.warning.rawValue == "WARNING")
    #expect(LogSeverity.error.rawValue == "ERROR")
    #expect(LogSeverity.critical.rawValue == "CRITICAL")
    #expect(LogSeverity.alert.rawValue == "ALERT")
    #expect(LogSeverity.emergency.rawValue == "EMERGENCY")
}

@Test func testLogSeverityNumericValues() {
    #expect(LogSeverity.default.numericValue == 0)
    #expect(LogSeverity.debug.numericValue == 100)
    #expect(LogSeverity.info.numericValue == 200)
    #expect(LogSeverity.error.numericValue == 500)
    #expect(LogSeverity.emergency.numericValue == 800)
}

// MARK: - Log Sink Tests

@Test func testGoogleCloudLogSink() {
    let sink = GoogleCloudLogSink(
        name: "error-logs",
        projectID: "test-project",
        destination: .bigQuery(datasetID: "logs_dataset"),
        filter: "severity >= ERROR"
    )

    #expect(sink.name == "error-logs")
    #expect(sink.filter == "severity >= ERROR")
}

@Test func testLogSinkResourceName() {
    let sink = GoogleCloudLogSink(
        name: "my-sink",
        projectID: "test-project",
        destination: .storage(bucketName: "my-bucket")
    )

    #expect(sink.resourceName == "projects/test-project/sinks/my-sink")
}

@Test func testLogSinkCreateCommandBigQuery() {
    let sink = GoogleCloudLogSink(
        name: "bq-sink",
        projectID: "test-project",
        destination: .bigQuery(datasetID: "logs"),
        filter: "severity >= WARNING",
        description: "Export warnings to BigQuery"
    )

    let cmd = sink.createCommand
    #expect(cmd.contains("gcloud logging sinks create bq-sink"))
    #expect(cmd.contains("bigquery.googleapis.com/projects/test-project/datasets/logs"))
    #expect(cmd.contains("--log-filter='severity >= WARNING'"))
    #expect(cmd.contains("--description=\"Export warnings to BigQuery\""))
}

@Test func testLogSinkCreateCommandStorage() {
    let sink = GoogleCloudLogSink(
        name: "storage-sink",
        projectID: "test-project",
        destination: .storage(bucketName: "logs-bucket")
    )

    let cmd = sink.createCommand
    #expect(cmd.contains("storage.googleapis.com/logs-bucket"))
}

@Test func testLogSinkCreateCommandPubSub() {
    let sink = GoogleCloudLogSink(
        name: "pubsub-sink",
        projectID: "test-project",
        destination: .pubSub(topicName: "log-events")
    )

    let cmd = sink.createCommand
    #expect(cmd.contains("pubsub.googleapis.com/projects/test-project/topics/log-events"))
}

@Test func testLogSinkCreateCommandLogBucket() {
    let sink = GoogleCloudLogSink(
        name: "bucket-sink",
        projectID: "test-project",
        destination: .logBucket(bucketID: "custom-bucket", location: "us-central1")
    )

    let cmd = sink.createCommand
    #expect(cmd.contains("logging.googleapis.com/projects/test-project/locations/us-central1/buckets/custom-bucket"))
}

@Test func testLogSinkDeleteCommand() {
    let sink = GoogleCloudLogSink(
        name: "my-sink",
        projectID: "test-project",
        destination: .storage(bucketName: "bucket")
    )

    let cmd = sink.deleteCommand
    #expect(cmd.contains("gcloud logging sinks delete my-sink"))
    #expect(cmd.contains("--quiet"))
}

@Test func testLogSinkListCommand() {
    let cmd = GoogleCloudLogSink.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud logging sinks list"))
    #expect(cmd.contains("--project=test-project"))
}

// MARK: - Log Bucket Tests

@Test func testGoogleCloudLogBucket() {
    let bucket = GoogleCloudLogBucket(
        name: "long-term-logs",
        projectID: "test-project",
        location: "us-central1",
        retentionDays: 365
    )

    #expect(bucket.name == "long-term-logs")
    #expect(bucket.location == "us-central1")
    #expect(bucket.retentionDays == 365)
}

@Test func testLogBucketResourceName() {
    let bucket = GoogleCloudLogBucket(
        name: "my-bucket",
        projectID: "test-project",
        location: "us-west1",
        retentionDays: 30
    )

    #expect(bucket.resourceName == "projects/test-project/locations/us-west1/buckets/my-bucket")
}

@Test func testLogBucketCreateCommand() {
    let bucket = GoogleCloudLogBucket(
        name: "app-logs",
        projectID: "test-project",
        location: "us-central1",
        retentionDays: 90,
        description: "Application logs",
        analyticsEnabled: true
    )

    let cmd = bucket.createCommand
    #expect(cmd.contains("gcloud logging buckets create app-logs"))
    #expect(cmd.contains("--location=us-central1"))
    #expect(cmd.contains("--retention-days=90"))
    #expect(cmd.contains("--description=\"Application logs\""))
    #expect(cmd.contains("--enable-analytics"))
}

@Test func testLogBucketUpdateCommand() {
    let bucket = GoogleCloudLogBucket(
        name: "my-bucket",
        projectID: "test-project",
        location: "us-central1",
        retentionDays: 180,
        locked: true
    )

    let cmd = bucket.updateCommand
    #expect(cmd.contains("gcloud logging buckets update my-bucket"))
    #expect(cmd.contains("--retention-days=180"))
    #expect(cmd.contains("--locked"))
}

@Test func testLogBucketDeleteCommand() {
    let bucket = GoogleCloudLogBucket(
        name: "my-bucket",
        projectID: "test-project",
        location: "us-central1"
    )

    let cmd = bucket.deleteCommand
    #expect(cmd.contains("gcloud logging buckets delete my-bucket"))
    #expect(cmd.contains("--quiet"))
}

@Test func testLogBucketListCommand() {
    let cmd = GoogleCloudLogBucket.listCommand(projectID: "test-project", location: "us-central1")
    #expect(cmd.contains("gcloud logging buckets list"))
    #expect(cmd.contains("--location=us-central1"))
}

// MARK: - Log View Tests

@Test func testGoogleCloudLogView() {
    let view = GoogleCloudLogView(
        name: "error-logs",
        bucketName: "_Default",
        projectID: "test-project",
        location: "global",
        filter: "severity >= ERROR"
    )

    #expect(view.name == "error-logs")
    #expect(view.bucketName == "_Default")
    #expect(view.filter == "severity >= ERROR")
}

@Test func testLogViewResourceName() {
    let view = GoogleCloudLogView(
        name: "my-view",
        bucketName: "my-bucket",
        projectID: "test-project",
        location: "us-central1"
    )

    #expect(view.resourceName == "projects/test-project/locations/us-central1/buckets/my-bucket/views/my-view")
}

@Test func testLogViewCreateCommand() {
    let view = GoogleCloudLogView(
        name: "errors-only",
        bucketName: "_Default",
        projectID: "test-project",
        location: "global",
        filter: "severity >= ERROR",
        description: "Error logs view"
    )

    let cmd = view.createCommand
    #expect(cmd.contains("gcloud logging views create errors-only"))
    #expect(cmd.contains("--bucket=_Default"))
    #expect(cmd.contains("--log-filter='severity >= ERROR'"))
    #expect(cmd.contains("--description=\"Error logs view\""))
}

@Test func testLogViewDeleteCommand() {
    let view = GoogleCloudLogView(
        name: "my-view",
        bucketName: "_Default",
        projectID: "test-project",
        location: "global"
    )

    let cmd = view.deleteCommand
    #expect(cmd.contains("gcloud logging views delete my-view"))
    #expect(cmd.contains("--bucket=_Default"))
    #expect(cmd.contains("--quiet"))
}

@Test func testLogViewListCommand() {
    let cmd = GoogleCloudLogView.listCommand(
        bucketName: "_Default",
        projectID: "test-project",
        location: "global"
    )
    #expect(cmd.contains("gcloud logging views list"))
    #expect(cmd.contains("--bucket=_Default"))
}

// MARK: - Log Exclusion Tests

@Test func testGoogleCloudLogExclusion() {
    let exclusion = GoogleCloudLogExclusion(
        name: "exclude-debug",
        projectID: "test-project",
        filter: "severity = DEBUG",
        description: "Exclude debug logs"
    )

    #expect(exclusion.name == "exclude-debug")
    #expect(exclusion.filter == "severity = DEBUG")
}

@Test func testLogExclusionResourceName() {
    let exclusion = GoogleCloudLogExclusion(
        name: "my-exclusion",
        projectID: "test-project",
        filter: "severity = DEBUG"
    )

    #expect(exclusion.resourceName == "projects/test-project/exclusions/my-exclusion")
}

@Test func testLogExclusionCreateCommand() {
    let exclusion = GoogleCloudLogExclusion(
        name: "exclude-debug",
        projectID: "test-project",
        filter: "severity = DEBUG",
        description: "Skip debug logs"
    )

    let cmd = exclusion.createCommand
    #expect(cmd.contains("gcloud logging exclusions create exclude-debug"))
    #expect(cmd.contains("--filter='severity = DEBUG'"))
    #expect(cmd.contains("--description=\"Skip debug logs\""))
}

@Test func testLogExclusionDeleteCommand() {
    let exclusion = GoogleCloudLogExclusion(
        name: "my-exclusion",
        projectID: "test-project",
        filter: "severity = DEBUG"
    )

    let cmd = exclusion.deleteCommand
    #expect(cmd.contains("gcloud logging exclusions delete my-exclusion"))
    #expect(cmd.contains("--quiet"))
}

@Test func testLogExclusionListCommand() {
    let cmd = GoogleCloudLogExclusion.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud logging exclusions list"))
    #expect(cmd.contains("--project=test-project"))
}

// MARK: - Log-Based Metric Tests

@Test func testGoogleCloudLogMetric() {
    let metric = GoogleCloudLogMetric(
        name: "error-count",
        projectID: "test-project",
        filter: "severity >= ERROR",
        metricType: .counter
    )

    #expect(metric.name == "error-count")
    #expect(metric.filter == "severity >= ERROR")
    #expect(metric.metricType == .counter)
}

@Test func testLogMetricResourceName() {
    let metric = GoogleCloudLogMetric(
        name: "my-metric",
        projectID: "test-project",
        filter: "severity >= ERROR"
    )

    #expect(metric.resourceName == "projects/test-project/metrics/my-metric")
}

@Test func testLogMetricMonitoringName() {
    let metric = GoogleCloudLogMetric(
        name: "error-count",
        projectID: "test-project",
        filter: "severity >= ERROR"
    )

    #expect(metric.monitoringMetricName == "logging.googleapis.com/user/error-count")
}

@Test func testLogMetricCreateCommand() {
    let metric = GoogleCloudLogMetric(
        name: "http-errors",
        projectID: "test-project",
        filter: "httpRequest.status >= 500",
        description: "HTTP 5xx errors"
    )

    let cmd = metric.createCommand
    #expect(cmd.contains("gcloud logging metrics create http-errors"))
    #expect(cmd.contains("--log-filter='httpRequest.status >= 500'"))
    #expect(cmd.contains("--description=\"HTTP 5xx errors\""))
}

@Test func testLogMetricDeleteCommand() {
    let metric = GoogleCloudLogMetric(
        name: "my-metric",
        projectID: "test-project",
        filter: "severity >= ERROR"
    )

    let cmd = metric.deleteCommand
    #expect(cmd.contains("gcloud logging metrics delete my-metric"))
    #expect(cmd.contains("--quiet"))
}

@Test func testLogMetricListCommand() {
    let cmd = GoogleCloudLogMetric.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud logging metrics list"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testLogMetricDistribution() {
    let metric = GoogleCloudLogMetric(
        name: "latency",
        projectID: "test-project",
        filter: "resource.type = \"cloud_run_revision\"",
        metricType: .distribution,
        valueExtractor: "EXTRACT(jsonPayload.latency_ms)",
        bucketOptions: GoogleCloudLogMetric.BucketOptions(
            type: .exponential(numBuckets: 20, growthFactor: 2, scale: 1)
        )
    )

    #expect(metric.metricType == .distribution)
    #expect(metric.valueExtractor == "EXTRACT(jsonPayload.latency_ms)")
    #expect(metric.bucketOptions != nil)
}

// MARK: - Log Router Tests

@Test func testLogRouterResourceFilter() {
    let filter = LogRouter.resourceFilter(type: "gce_instance", labels: ["zone": "us-central1-a"])
    #expect(filter.contains("resource.type=\"gce_instance\""))
    #expect(filter.contains("resource.labels.zone=\"us-central1-a\""))
}

@Test func testLogRouterLogNameFilter() {
    let filter = LogRouter.logNameFilter(projectID: "test-project", logNames: ["app", "db"])
    #expect(filter.contains("logName=\"projects/test-project/logs/app\""))
    #expect(filter.contains("logName=\"projects/test-project/logs/db\""))
    #expect(filter.contains(" OR "))
}

@Test func testLogRouterSeverityFilter() {
    let filter = LogRouter.severityFilter(minSeverity: .warning)
    #expect(filter == "severity >= WARNING")
}

@Test func testLogRouterResourceTypes() {
    #expect(LogRouter.ResourceType.gceInstance.rawValue == "gce_instance")
    #expect(LogRouter.ResourceType.cloudFunction.rawValue == "cloud_function")
    #expect(LogRouter.ResourceType.cloudRunRevision.rawValue == "cloud_run_revision")
    #expect(LogRouter.ResourceType.gkeContainer.rawValue == "k8s_container")
}

// MARK: - Predefined Log Filter Tests

@Test func testPredefinedLogFilters() {
    #expect(PredefinedLogFilter.errorsOnly == "severity >= ERROR")
    #expect(PredefinedLogFilter.warningsAndAbove == "severity >= WARNING")
    #expect(PredefinedLogFilter.http5xxErrors == "httpRequest.status >= 500")
    #expect(PredefinedLogFilter.cloudRunRequests == "resource.type = \"cloud_run_revision\"")
    #expect(PredefinedLogFilter.cloudFunctions == "resource.type = \"cloud_function\"")
}

// MARK: - Log Alert Configuration Tests

@Test func testLogAlertConfiguration() {
    let metric = GoogleCloudLogMetric(
        name: "error-count",
        projectID: "test-project",
        filter: "severity >= ERROR"
    )

    let alert = LogAlertConfiguration(
        name: "high-error-rate",
        metric: metric,
        threshold: 100,
        comparison: .greaterThan,
        duration: "300s"
    )

    #expect(alert.name == "high-error-rate")
    #expect(alert.threshold == 100)
    #expect(alert.comparison == .greaterThan)
    #expect(alert.duration == "300s")
}

@Test func testLogAlertComparisonTypes() {
    #expect(LogAlertConfiguration.Comparison.greaterThan.rawValue == "COMPARISON_GT")
    #expect(LogAlertConfiguration.Comparison.lessThan.rawValue == "COMPARISON_LT")
    #expect(LogAlertConfiguration.Comparison.equal.rawValue == "COMPARISON_EQ")
}

// MARK: - DAIS Logging Template Tests

@Test func testDAISLoggingTemplateErrorLogsSink() {
    let sink = DAISLoggingTemplate.errorLogsSink(
        projectID: "test-project",
        deploymentName: "prod",
        datasetID: "error_logs"
    )

    #expect(sink.name == "prod-error-logs")
    #expect(sink.filter?.contains("butteryai") == true)
    #expect(sink.filter?.contains("severity >= ERROR") == true)
}

@Test func testDAISLoggingTemplateAuditLogsSink() {
    let sink = DAISLoggingTemplate.auditLogsSink(
        projectID: "test-project",
        deploymentName: "prod",
        bucketName: "audit-logs-bucket"
    )

    #expect(sink.name == "prod-audit-logs")
    #expect(sink.filter?.contains("audit") == true)
}

@Test func testDAISLoggingTemplateLogBucket() {
    let bucket = DAISLoggingTemplate.logBucket(
        projectID: "test-project",
        deploymentName: "prod",
        location: "us-central1",
        retentionDays: 90
    )

    #expect(bucket.name == "prod-logs")
    #expect(bucket.retentionDays == 90)
    #expect(bucket.analyticsEnabled == true)
}

@Test func testDAISLoggingTemplateErrorLogsView() {
    let view = DAISLoggingTemplate.errorLogsView(
        projectID: "test-project",
        deploymentName: "prod",
        location: "us-central1"
    )

    #expect(view.name == "prod-errors")
    #expect(view.filter?.contains("severity >= ERROR") == true)
}

@Test func testDAISLoggingTemplateDebugLogExclusion() {
    let exclusion = DAISLoggingTemplate.debugLogExclusion(
        projectID: "test-project",
        deploymentName: "prod"
    )

    #expect(exclusion.name == "prod-exclude-debug")
    #expect(exclusion.filter.contains("severity = DEBUG"))
}

@Test func testDAISLoggingTemplateErrorCountMetric() {
    let metric = DAISLoggingTemplate.errorCountMetric(
        projectID: "test-project",
        deploymentName: "prod"
    )

    #expect(metric.name == "prod-error-count")
    #expect(metric.metricType == .counter)
    #expect(metric.labelExtractors["node"] != nil)
}

@Test func testDAISLoggingTemplateGRPCLatencyMetric() {
    let metric = DAISLoggingTemplate.grpcLatencyMetric(
        projectID: "test-project",
        deploymentName: "prod"
    )

    #expect(metric.name == "prod-grpc-latency")
    #expect(metric.metricType == .distribution)
    #expect(metric.valueExtractor != nil)
}

@Test func testDAISLoggingTemplateSetupScript() {
    let script = DAISLoggingTemplate.setupScript(
        projectID: "test-project",
        deploymentName: "prod",
        location: "us-central1",
        bigQueryDataset: "logs",
        storageBucket: "audit-logs"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable logging.googleapis.com"))
    #expect(script.contains("prod-logs"))
    #expect(script.contains("bigquery.googleapis.com"))
    #expect(script.contains("storage.googleapis.com"))
}

@Test func testDAISLoggingTemplateLogQuery() {
    let query = DAISLoggingTemplate.daisLogQuery(
        projectID: "test-project",
        deploymentName: "prod",
        nodeName: "node-1",
        component: "grpc",
        minSeverity: .warning
    )

    #expect(query.contains("labels.app=\"butteryai\""))
    #expect(query.contains("labels.deployment=\"prod\""))
    #expect(query.contains("labels.node=\"node-1\""))
    #expect(query.contains("labels.component=\"grpc\""))
    #expect(query.contains("severity >= WARNING"))
}

// MARK: - Structured Log Entry Tests

@Test func testStructuredLogEntry() {
    let entry = StructuredLogEntry(
        message: "Request processed",
        severity: .info,
        component: "api",
        requestID: "req-123",
        latencyMs: 45.5,
        metadata: ["path": "/users"]
    )

    #expect(entry.message == "Request processed")
    #expect(entry.severity == .info)
    #expect(entry.component == "api")
    #expect(entry.latencyMs == 45.5)
}

@Test func testStructuredLogEntryJSON() {
    let entry = StructuredLogEntry(
        message: "Test message",
        severity: .error,
        errorCode: "E001"
    )

    let json = entry.jsonString
    #expect(json.contains("\"message\""))
    #expect(json.contains("Test message"))
    #expect(json.contains("ERROR"))
    #expect(json.contains("E001"))
}

// MARK: - Cloud Logging Codable Tests

@Test func testLogEntryCodable() throws {
    let entry = GoogleCloudLogEntry(
        logName: "my-app",
        projectID: "test-project",
        severity: .error,
        textPayload: "Error occurred",
        labels: ["env": "test"]
    )

    let data = try JSONEncoder().encode(entry)
    let decoded = try JSONDecoder().decode(GoogleCloudLogEntry.self, from: data)

    #expect(decoded.logName == entry.logName)
    #expect(decoded.severity == entry.severity)
    #expect(decoded.textPayload == entry.textPayload)
    #expect(decoded.labels == entry.labels)
}

@Test func testLogSinkCodable() throws {
    let sink = GoogleCloudLogSink(
        name: "my-sink",
        projectID: "test-project",
        destination: .bigQuery(datasetID: "logs"),
        filter: "severity >= ERROR"
    )

    let data = try JSONEncoder().encode(sink)
    let decoded = try JSONDecoder().decode(GoogleCloudLogSink.self, from: data)

    #expect(decoded.name == sink.name)
    #expect(decoded.filter == sink.filter)
}

@Test func testLogBucketCodable() throws {
    let bucket = GoogleCloudLogBucket(
        name: "my-bucket",
        projectID: "test-project",
        location: "us-central1",
        retentionDays: 90
    )

    let data = try JSONEncoder().encode(bucket)
    let decoded = try JSONDecoder().decode(GoogleCloudLogBucket.self, from: data)

    #expect(decoded.name == bucket.name)
    #expect(decoded.retentionDays == bucket.retentionDays)
}

@Test func testLogViewCodable() throws {
    let view = GoogleCloudLogView(
        name: "my-view",
        bucketName: "_Default",
        projectID: "test-project",
        location: "global",
        filter: "severity >= ERROR"
    )

    let data = try JSONEncoder().encode(view)
    let decoded = try JSONDecoder().decode(GoogleCloudLogView.self, from: data)

    #expect(decoded.name == view.name)
    #expect(decoded.filter == view.filter)
}

@Test func testLogExclusionCodable() throws {
    let exclusion = GoogleCloudLogExclusion(
        name: "my-exclusion",
        projectID: "test-project",
        filter: "severity = DEBUG"
    )

    let data = try JSONEncoder().encode(exclusion)
    let decoded = try JSONDecoder().decode(GoogleCloudLogExclusion.self, from: data)

    #expect(decoded.name == exclusion.name)
    #expect(decoded.filter == exclusion.filter)
}

@Test func testLogMetricCodable() throws {
    let metric = GoogleCloudLogMetric(
        name: "error-count",
        projectID: "test-project",
        filter: "severity >= ERROR",
        metricType: .counter
    )

    let data = try JSONEncoder().encode(metric)
    let decoded = try JSONDecoder().decode(GoogleCloudLogMetric.self, from: data)

    #expect(decoded.name == metric.name)
    #expect(decoded.metricType == metric.metricType)
}

@Test func testStructuredLogEntryCodable() throws {
    let entry = StructuredLogEntry(
        message: "Test",
        severity: .info,
        component: "api"
    )

    let data = try JSONEncoder().encode(entry)
    let decoded = try JSONDecoder().decode(StructuredLogEntry.self, from: data)

    #expect(decoded.message == entry.message)
    #expect(decoded.component == entry.component)
}

// MARK: - Cloud Monitoring Tests

// MARK: - Alert Policy Tests

@Test func testGoogleCloudAlertPolicy() {
    let policy = GoogleCloudAlertPolicy(
        displayName: "High CPU Usage",
        projectID: "test-project",
        conditions: [
            .threshold(
                displayName: "CPU > 80%",
                filter: "metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
                comparison: .greaterThan,
                threshold: 0.8,
                duration: "300s"
            )
        ],
        notificationChannels: ["projects/test-project/notificationChannels/123"]
    )

    #expect(policy.displayName == "High CPU Usage")
    #expect(policy.conditions.count == 1)
    #expect(policy.notificationChannels.count == 1)
}

@Test func testAlertPolicyCreateCommand() {
    let policy = GoogleCloudAlertPolicy(
        displayName: "Test Alert",
        projectID: "test-project",
        conditions: []
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("gcloud alpha monitoring policies create"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testAlertPolicyListCommand() {
    let cmd = GoogleCloudAlertPolicy.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud alpha monitoring policies list"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testAlertPolicyDescribeCommand() {
    let cmd = GoogleCloudAlertPolicy.describeCommand(policyID: "policy-123", projectID: "test-project")
    #expect(cmd.contains("gcloud alpha monitoring policies describe policy-123"))
}

@Test func testAlertPolicyDeleteCommand() {
    let cmd = GoogleCloudAlertPolicy.deleteCommand(policyID: "policy-123", projectID: "test-project")
    #expect(cmd.contains("gcloud alpha monitoring policies delete policy-123"))
    #expect(cmd.contains("--quiet"))
}

@Test func testAlertPolicyUpdateEnabledCommand() {
    let enableCmd = GoogleCloudAlertPolicy.updateEnabledCommand(policyID: "policy-123", projectID: "test-project", enabled: true)
    #expect(enableCmd.contains("--enabled"))

    let disableCmd = GoogleCloudAlertPolicy.updateEnabledCommand(policyID: "policy-123", projectID: "test-project", enabled: false)
    #expect(disableCmd.contains("--no-enabled"))
}

@Test func testConditionCombiner() {
    #expect(GoogleCloudAlertPolicy.ConditionCombiner.or.rawValue == "OR")
    #expect(GoogleCloudAlertPolicy.ConditionCombiner.and.rawValue == "AND")
    #expect(GoogleCloudAlertPolicy.ConditionCombiner.andWithMatchingResource.rawValue == "AND_WITH_MATCHING_RESOURCE")
}

@Test func testAlertSeverity() {
    #expect(GoogleCloudAlertPolicy.AlertSeverity.critical.rawValue == "CRITICAL")
    #expect(GoogleCloudAlertPolicy.AlertSeverity.error.rawValue == "ERROR")
    #expect(GoogleCloudAlertPolicy.AlertSeverity.warning.rawValue == "WARNING")
}

// MARK: - Alert Condition Tests

@Test func testAlertConditionThreshold() {
    let condition = AlertCondition.threshold(
        displayName: "High CPU",
        filter: "metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
        comparison: .greaterThan,
        threshold: 0.8,
        duration: "300s"
    )

    if case .threshold(let name, _, let comparison, let threshold, _, _) = condition {
        #expect(name == "High CPU")
        #expect(comparison == .greaterThan)
        #expect(threshold == 0.8)
    } else {
        Issue.record("Expected threshold condition")
    }
}

@Test func testAlertConditionAbsence() {
    let condition = AlertCondition.absence(
        displayName: "No Data",
        filter: "metric.type=\"custom.googleapis.com/my_metric\"",
        duration: "600s"
    )

    if case .absence(let name, _, let duration) = condition {
        #expect(name == "No Data")
        #expect(duration == "600s")
    } else {
        Issue.record("Expected absence condition")
    }
}

@Test func testAlertConditionMQL() {
    let condition = AlertCondition.mql(
        displayName: "MQL Query",
        query: "fetch gce_instance | metric cpu/utilization",
        duration: "300s"
    )

    if case .mql(let name, let query, _) = condition {
        #expect(name == "MQL Query")
        #expect(query.contains("gce_instance"))
    } else {
        Issue.record("Expected MQL condition")
    }
}

@Test func testComparisonTypes() {
    #expect(AlertCondition.ComparisonType.greaterThan.rawValue == "COMPARISON_GT")
    #expect(AlertCondition.ComparisonType.lessThan.rawValue == "COMPARISON_LT")
    #expect(AlertCondition.ComparisonType.equal.rawValue == "COMPARISON_EQ")
    #expect(AlertCondition.ComparisonType.notEqual.rawValue == "COMPARISON_NE")
}

@Test func testAggregation() {
    let agg = AlertCondition.Aggregation(
        alignmentPeriod: "60s",
        perSeriesAligner: .alignMean,
        crossSeriesReducer: .reduceSum,
        groupByFields: ["resource.label.zone"]
    )

    #expect(agg.alignmentPeriod == "60s")
    #expect(agg.perSeriesAligner == .alignMean)
    #expect(agg.crossSeriesReducer == .reduceSum)
}

@Test func testAlignerValues() {
    #expect(AlertCondition.Aggregation.Aligner.alignMean.rawValue == "ALIGN_MEAN")
    #expect(AlertCondition.Aggregation.Aligner.alignSum.rawValue == "ALIGN_SUM")
    #expect(AlertCondition.Aggregation.Aligner.alignMax.rawValue == "ALIGN_MAX")
    #expect(AlertCondition.Aggregation.Aligner.alignPercentile99.rawValue == "ALIGN_PERCENTILE_99")
}

@Test func testReducerValues() {
    #expect(AlertCondition.Aggregation.Reducer.reduceMean.rawValue == "REDUCE_MEAN")
    #expect(AlertCondition.Aggregation.Reducer.reduceSum.rawValue == "REDUCE_SUM")
    #expect(AlertCondition.Aggregation.Reducer.reduceMax.rawValue == "REDUCE_MAX")
}

// MARK: - Alert Documentation Tests

@Test func testAlertDocumentation() {
    let doc = AlertDocumentation(
        content: "This alert fires when CPU is high",
        mimeType: "text/markdown",
        subject: "High CPU Alert"
    )

    #expect(doc.content.contains("CPU"))
    #expect(doc.mimeType == "text/markdown")
    #expect(doc.subject == "High CPU Alert")
}

// MARK: - Notification Channel Tests

@Test func testGoogleCloudNotificationChannel() {
    let channel = GoogleCloudNotificationChannel(
        displayName: "On-Call Team",
        projectID: "test-project",
        type: .email,
        labels: ["email_address": "oncall@example.com"]
    )

    #expect(channel.displayName == "On-Call Team")
    #expect(channel.type == .email)
    #expect(channel.labels["email_address"] == "oncall@example.com")
}

@Test func testNotificationChannelCreateCommand() {
    let channel = GoogleCloudNotificationChannel(
        displayName: "Test Channel",
        projectID: "test-project",
        type: .email,
        labels: ["email_address": "test@example.com"],
        description: "Test channel"
    )

    let cmd = channel.createCommand
    #expect(cmd.contains("gcloud alpha monitoring channels create"))
    #expect(cmd.contains("--display-name=\"Test Channel\""))
    #expect(cmd.contains("--type=email"))
    #expect(cmd.contains("--channel-labels=email_address=test@example.com"))
}

@Test func testNotificationChannelListCommand() {
    let cmd = GoogleCloudNotificationChannel.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud alpha monitoring channels list"))
}

@Test func testNotificationChannelTypes() {
    #expect(GoogleCloudNotificationChannel.ChannelType.email.rawValue == "email")
    #expect(GoogleCloudNotificationChannel.ChannelType.slack.rawValue == "slack")
    #expect(GoogleCloudNotificationChannel.ChannelType.pagerDuty.rawValue == "pagerduty")
    #expect(GoogleCloudNotificationChannel.ChannelType.webhook.rawValue == "webhook_tokenauth")
    #expect(GoogleCloudNotificationChannel.ChannelType.pubsub.rawValue == "pubsub")
}

@Test func testNotificationChannelEmailFactory() {
    let channel = GoogleCloudNotificationChannel.email(
        displayName: "Email Alerts",
        projectID: "test-project",
        emailAddress: "alerts@example.com"
    )

    #expect(channel.type == .email)
    #expect(channel.labels["email_address"] == "alerts@example.com")
}

@Test func testNotificationChannelSlackFactory() {
    let channel = GoogleCloudNotificationChannel.slack(
        displayName: "Slack Alerts",
        projectID: "test-project",
        channelName: "#alerts",
        authToken: "xoxb-token"
    )

    #expect(channel.type == .slack)
    #expect(channel.labels["channel_name"] == "#alerts")
}

@Test func testNotificationChannelPagerDutyFactory() {
    let channel = GoogleCloudNotificationChannel.pagerDuty(
        displayName: "PagerDuty",
        projectID: "test-project",
        serviceKey: "service-key-123"
    )

    #expect(channel.type == .pagerDuty)
    #expect(channel.labels["service_key"] == "service-key-123")
}

@Test func testNotificationChannelWebhookFactory() {
    let channel = GoogleCloudNotificationChannel.webhook(
        displayName: "Webhook",
        projectID: "test-project",
        url: "https://example.com/webhook"
    )

    #expect(channel.type == .webhook)
    #expect(channel.labels["url"] == "https://example.com/webhook")
}

@Test func testNotificationChannelPubSubFactory() {
    let channel = GoogleCloudNotificationChannel.pubsub(
        displayName: "Pub/Sub",
        projectID: "test-project",
        topic: "projects/test-project/topics/alerts"
    )

    #expect(channel.type == .pubsub)
    #expect(channel.labels["topic"]?.contains("alerts") == true)
}

// MARK: - Uptime Check Tests

@Test func testGoogleCloudUptimeCheck() {
    let check = GoogleCloudUptimeCheck(
        displayName: "API Health",
        projectID: "test-project",
        monitoredResource: .uptime(host: "api.example.com"),
        httpCheck: GoogleCloudUptimeCheck.HTTPCheckConfig(
            path: "/health",
            port: 443,
            useSsl: true
        ),
        period: .oneMinute
    )

    #expect(check.displayName == "API Health")
    #expect(check.period == .oneMinute)
}

@Test func testUptimeCheckCreateCommand() {
    let check = GoogleCloudUptimeCheck(
        displayName: "Test Check",
        projectID: "test-project",
        monitoredResource: .uptime(host: "example.com"),
        httpCheck: GoogleCloudUptimeCheck.HTTPCheckConfig(
            path: "/health",
            port: 443,
            useSsl: true
        )
    )

    let cmd = check.createCommand
    #expect(cmd.contains("gcloud alpha monitoring uptime create"))
    #expect(cmd.contains("--protocol=https"))
    #expect(cmd.contains("--port=443"))
    #expect(cmd.contains("--path=/health"))
}

@Test func testUptimeCheckListCommand() {
    let cmd = GoogleCloudUptimeCheck.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud alpha monitoring uptime list-configs"))
}

@Test func testUptimeCheckTCP() {
    let check = GoogleCloudUptimeCheck(
        displayName: "TCP Check",
        projectID: "test-project",
        monitoredResource: .uptime(host: "example.com"),
        tcpCheck: GoogleCloudUptimeCheck.TCPCheckConfig(port: 9090)
    )

    let cmd = check.createCommand
    #expect(cmd.contains("--protocol=tcp"))
    #expect(cmd.contains("--port=9090"))
}

@Test func testCheckPeriod() {
    #expect(GoogleCloudUptimeCheck.CheckPeriod.oneMinute.rawValue == "60s")
    #expect(GoogleCloudUptimeCheck.CheckPeriod.fiveMinutes.rawValue == "300s")
    #expect(GoogleCloudUptimeCheck.CheckPeriod.tenMinutes.rawValue == "600s")
}

@Test func testCheckRegion() {
    #expect(GoogleCloudUptimeCheck.CheckRegion.usa.rawValue == "USA")
    #expect(GoogleCloudUptimeCheck.CheckRegion.europe.rawValue == "EUROPE")
    #expect(GoogleCloudUptimeCheck.CheckRegion.asiaPacific.rawValue == "ASIA_PACIFIC")
}

@Test func testHTTPCheckConfig() {
    let config = GoogleCloudUptimeCheck.HTTPCheckConfig(
        path: "/api/health",
        port: 8080,
        useSsl: false,
        validateSsl: false,
        requestMethod: .post,
        headers: ["Authorization": "Bearer token"]
    )

    #expect(config.path == "/api/health")
    #expect(config.port == 8080)
    #expect(config.requestMethod == .post)
}

@Test func testContentMatcher() {
    let matcher = GoogleCloudUptimeCheck.ContentMatcher(
        content: "healthy",
        matcher: .contains
    )

    #expect(matcher.content == "healthy")
    #expect(matcher.matcher == .contains)
}

@Test func testContentMatcherTypes() {
    #expect(GoogleCloudUptimeCheck.ContentMatcher.MatcherType.contains.rawValue == "CONTAINS_STRING")
    #expect(GoogleCloudUptimeCheck.ContentMatcher.MatcherType.matchesRegex.rawValue == "MATCHES_REGEX")
    #expect(GoogleCloudUptimeCheck.ContentMatcher.MatcherType.matchesJsonPath.rawValue == "MATCHES_JSON_PATH")
}

// MARK: - Metric Descriptor Tests

@Test func testGoogleCloudMetricDescriptor() {
    let metric = GoogleCloudMetricDescriptor(
        type: "custom.googleapis.com/my_app/request_count",
        projectID: "test-project",
        metricKind: .cumulative,
        valueType: .int64,
        description: "Request count"
    )

    #expect(metric.type == "custom.googleapis.com/my_app/request_count")
    #expect(metric.metricKind == .cumulative)
    #expect(metric.valueType == .int64)
}

@Test func testMetricDescriptorResourceName() {
    let metric = GoogleCloudMetricDescriptor(
        type: "custom.googleapis.com/my_metric",
        projectID: "test-project",
        metricKind: .gauge,
        valueType: .double
    )

    #expect(metric.resourceName == "projects/test-project/metricDescriptors/custom.googleapis.com/my_metric")
}

@Test func testMetricDescriptorCreateCommand() {
    let metric = GoogleCloudMetricDescriptor(
        type: "custom.googleapis.com/my_metric",
        projectID: "test-project",
        metricKind: .gauge,
        valueType: .int64,
        unit: "1",
        description: "My custom metric",
        displayName: "My Metric"
    )

    let cmd = metric.createCommand
    #expect(cmd.contains("gcloud alpha monitoring metrics-descriptors create"))
    #expect(cmd.contains("--metric-kind=GAUGE"))
    #expect(cmd.contains("--value-type=INT64"))
    #expect(cmd.contains("--unit=\"1\""))
}

@Test func testMetricDescriptorListCommand() {
    let cmd = GoogleCloudMetricDescriptor.listCommand(projectID: "test-project", filter: "metric.type=starts_with(\"custom\")")
    #expect(cmd.contains("gcloud alpha monitoring metrics-descriptors list"))
    #expect(cmd.contains("--filter"))
}

@Test func testMetricKind() {
    #expect(GoogleCloudMetricDescriptor.MetricKind.gauge.rawValue == "GAUGE")
    #expect(GoogleCloudMetricDescriptor.MetricKind.cumulative.rawValue == "CUMULATIVE")
    #expect(GoogleCloudMetricDescriptor.MetricKind.delta.rawValue == "DELTA")
}

@Test func testValueType() {
    #expect(GoogleCloudMetricDescriptor.ValueType.int64.rawValue == "INT64")
    #expect(GoogleCloudMetricDescriptor.ValueType.double.rawValue == "DOUBLE")
    #expect(GoogleCloudMetricDescriptor.ValueType.bool.rawValue == "BOOL")
    #expect(GoogleCloudMetricDescriptor.ValueType.distribution.rawValue == "DISTRIBUTION")
}

@Test func testLabelDescriptor() {
    let label = GoogleCloudMetricDescriptor.LabelDescriptor(
        key: "method",
        valueType: .string,
        description: "HTTP method"
    )

    #expect(label.key == "method")
    #expect(label.valueType == .string)
}

// MARK: - Dashboard Tests

@Test func testGoogleCloudDashboard() {
    let dashboard = GoogleCloudDashboard(
        displayName: "DAIS Dashboard",
        projectID: "test-project",
        layout: .grid(columns: 3)
    )

    #expect(dashboard.displayName == "DAIS Dashboard")
}

@Test func testDashboardCreateCommand() {
    let dashboard = GoogleCloudDashboard(
        displayName: "Test Dashboard",
        projectID: "test-project"
    )

    let cmd = dashboard.createCommand
    #expect(cmd.contains("gcloud monitoring dashboards create"))
    #expect(cmd.contains("--config-from-file"))
}

@Test func testDashboardListCommand() {
    let cmd = GoogleCloudDashboard.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud monitoring dashboards list"))
}

// MARK: - Monitoring Group Tests

@Test func testGoogleCloudMonitoringGroup() {
    let group = GoogleCloudMonitoringGroup(
        displayName: "DAIS Nodes",
        projectID: "test-project",
        filter: "resource.metadata.name=starts_with(\"dais\")",
        isCluster: true
    )

    #expect(group.displayName == "DAIS Nodes")
    #expect(group.isCluster == true)
}

@Test func testMonitoringGroupCreateCommand() {
    let group = GoogleCloudMonitoringGroup(
        displayName: "Test Group",
        projectID: "test-project",
        filter: "resource.type=\"gce_instance\"",
        isCluster: true
    )

    let cmd = group.createCommand
    #expect(cmd.contains("gcloud alpha monitoring groups create"))
    #expect(cmd.contains("--display-name=\"Test Group\""))
    #expect(cmd.contains("--is-cluster"))
}

@Test func testMonitoringGroupListCommand() {
    let cmd = GoogleCloudMonitoringGroup.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud alpha monitoring groups list"))
}

// MARK: - SLO Tests

@Test func testGoogleCloudSLO() {
    let slo = GoogleCloudSLO(
        displayName: "API Availability",
        serviceName: "my-api",
        projectID: "test-project",
        goal: 0.999,
        rollingPeriod: "30d",
        sli: .requestBased(
            goodTotalRatio: GoogleCloudSLO.ServiceLevelIndicator.GoodTotalRatio(
                goodServiceFilter: "metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class=\"2xx\"",
                totalServiceFilter: "metric.type=\"run.googleapis.com/request_count\""
            ),
            distributionCut: nil
        )
    )

    #expect(slo.displayName == "API Availability")
    #expect(slo.goal == 0.999)
}

@Test func testCalendarPeriod() {
    #expect(GoogleCloudSLO.CalendarPeriod.day.rawValue == "DAY")
    #expect(GoogleCloudSLO.CalendarPeriod.week.rawValue == "WEEK")
    #expect(GoogleCloudSLO.CalendarPeriod.month.rawValue == "MONTH")
    #expect(GoogleCloudSLO.CalendarPeriod.quarter.rawValue == "QUARTER")
}

// MARK: - Predefined Metric Filter Tests

@Test func testPredefinedMetricFilters() {
    #expect(PredefinedMetricFilter.cpuUtilization.contains("compute.googleapis.com"))
    #expect(PredefinedMetricFilter.cloudRunRequestCount.contains("run.googleapis.com"))
    #expect(PredefinedMetricFilter.functionExecutionCount.contains("cloudfunctions.googleapis.com"))
    #expect(PredefinedMetricFilter.sqlCPUUtilization.contains("cloudsql.googleapis.com"))
    #expect(PredefinedMetricFilter.pubsubSubscriptionBacklog.contains("pubsub.googleapis.com"))
}

// MARK: - DAIS Monitoring Template Tests

@Test func testDAISMonitoringTemplateEmailChannel() {
    let channel = DAISMonitoringTemplate.emailChannel(
        projectID: "test-project",
        deploymentName: "prod",
        email: "alerts@example.com"
    )

    #expect(channel.displayName == "prod Alerts")
    #expect(channel.type == .email)
}

@Test func testDAISMonitoringTemplateSlackChannel() {
    let channel = DAISMonitoringTemplate.slackChannel(
        projectID: "test-project",
        deploymentName: "prod",
        channelName: "#alerts",
        authToken: "token"
    )

    #expect(channel.displayName == "prod Slack Alerts")
    #expect(channel.type == .slack)
}

@Test func testDAISMonitoringTemplateCPUAlertPolicy() {
    let policy = DAISMonitoringTemplate.cpuAlertPolicy(
        projectID: "test-project",
        deploymentName: "prod",
        threshold: 0.8
    )

    #expect(policy.displayName == "prod High CPU Usage")
    #expect(policy.conditions.count == 1)
    #expect(policy.severity == .warning)
    #expect(policy.userLabels["app"] == "butteryai")
}

@Test func testDAISMonitoringTemplateMemoryAlertPolicy() {
    let policy = DAISMonitoringTemplate.memoryAlertPolicy(
        projectID: "test-project",
        deploymentName: "prod",
        threshold: 0.85
    )

    #expect(policy.displayName == "prod High Memory Usage")
    #expect(policy.severity == .warning)
}

@Test func testDAISMonitoringTemplateErrorRateAlertPolicy() {
    let policy = DAISMonitoringTemplate.errorRateAlertPolicy(
        projectID: "test-project",
        deploymentName: "prod",
        threshold: 0.01
    )

    #expect(policy.displayName == "prod High Error Rate")
    #expect(policy.severity == .error)
}

@Test func testDAISMonitoringTemplateHTTPUptimeCheck() {
    let check = DAISMonitoringTemplate.httpUptimeCheck(
        projectID: "test-project",
        deploymentName: "prod",
        host: "api.example.com",
        path: "/health"
    )

    #expect(check.displayName == "prod HTTP Health")
    #expect(check.httpCheck?.path == "/health")
}

@Test func testDAISMonitoringTemplateGRPCUptimeCheck() {
    let check = DAISMonitoringTemplate.grpcUptimeCheck(
        projectID: "test-project",
        deploymentName: "prod",
        host: "grpc.example.com",
        port: 9090
    )

    #expect(check.displayName == "prod gRPC Health")
    #expect(check.tcpCheck?.port == 9090)
}

@Test func testDAISMonitoringTemplateRequestLatencyMetric() {
    let metric = DAISMonitoringTemplate.requestLatencyMetric(
        projectID: "test-project",
        deploymentName: "prod"
    )

    #expect(metric.type.contains("dais/prod/request_latency"))
    #expect(metric.metricKind == .gauge)
    #expect(metric.valueType == .distribution)
}

@Test func testDAISMonitoringTemplateActiveConnectionsMetric() {
    let metric = DAISMonitoringTemplate.activeConnectionsMetric(
        projectID: "test-project",
        deploymentName: "prod"
    )

    #expect(metric.type.contains("dais/prod/active_connections"))
    #expect(metric.valueType == .int64)
}

@Test func testDAISMonitoringTemplateInstanceGroup() {
    let group = DAISMonitoringTemplate.instanceGroup(
        projectID: "test-project",
        deploymentName: "prod"
    )

    #expect(group.displayName == "prod DAIS Nodes")
    #expect(group.isCluster == true)
    #expect(group.filter.contains("prod"))
}

@Test func testDAISMonitoringTemplateSetupScript() {
    let script = DAISMonitoringTemplate.setupScript(
        projectID: "test-project",
        deploymentName: "prod",
        alertEmail: "alerts@example.com",
        httpHost: "api.example.com",
        grpcHost: "grpc.example.com"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable monitoring.googleapis.com"))
    #expect(script.contains("prod"))
    #expect(script.contains("api.example.com"))
    #expect(script.contains("grpc.example.com"))
}

// MARK: - MQL Query Builder Tests

@Test func testMQLQueryBuilderFetch() {
    let query = MQLQueryBuilder.fetch(
        metricType: "compute.googleapis.com/instance/cpu/utilization",
        resourceType: "gce_instance"
    )

    #expect(query.contains("fetch gce_instance"))
    #expect(query.contains("metric 'compute.googleapis.com/instance/cpu/utilization'"))
}

@Test func testMQLQueryBuilderFilter() {
    let query = MQLQueryBuilder.fetch(metricType: "my.metric")
    let filtered = MQLQueryBuilder.filter(query, condition: "resource.zone = 'us-central1-a'")

    #expect(filtered.contains("filter resource.zone"))
}

@Test func testMQLQueryBuilderGroupBy() {
    let query = MQLQueryBuilder.fetch(metricType: "my.metric")
    let grouped = MQLQueryBuilder.groupBy(query, fields: ["resource.zone"], reducer: "sum")

    #expect(grouped.contains("group_by [resource.zone]"))
    #expect(grouped.contains("sum(value)"))
}

@Test func testMQLQueryBuilderAlign() {
    let query = MQLQueryBuilder.fetch(metricType: "my.metric")
    let aligned = MQLQueryBuilder.align(query, aligner: "rate", period: "5m")

    #expect(aligned.contains("align rate(5m)"))
}

// MARK: - Cloud Monitoring Codable Tests

@Test func testAlertPolicyCodable() throws {
    let policy = GoogleCloudAlertPolicy(
        displayName: "Test Alert",
        projectID: "test-project",
        conditions: [
            .threshold(
                displayName: "Test",
                filter: "test",
                comparison: .greaterThan,
                threshold: 0.5,
                duration: "60s"
            )
        ]
    )

    let data = try JSONEncoder().encode(policy)
    let decoded = try JSONDecoder().decode(GoogleCloudAlertPolicy.self, from: data)

    #expect(decoded.displayName == policy.displayName)
    #expect(decoded.conditions.count == policy.conditions.count)
}

@Test func testNotificationChannelCodable() throws {
    let channel = GoogleCloudNotificationChannel(
        displayName: "Test Channel",
        projectID: "test-project",
        type: .email,
        labels: ["email_address": "test@example.com"]
    )

    let data = try JSONEncoder().encode(channel)
    let decoded = try JSONDecoder().decode(GoogleCloudNotificationChannel.self, from: data)

    #expect(decoded.displayName == channel.displayName)
    #expect(decoded.type == channel.type)
}

@Test func testUptimeCheckCodable() throws {
    let check = GoogleCloudUptimeCheck(
        displayName: "Test Check",
        projectID: "test-project",
        monitoredResource: .uptime(host: "example.com"),
        httpCheck: GoogleCloudUptimeCheck.HTTPCheckConfig(path: "/health")
    )

    let data = try JSONEncoder().encode(check)
    let decoded = try JSONDecoder().decode(GoogleCloudUptimeCheck.self, from: data)

    #expect(decoded.displayName == check.displayName)
}

@Test func testMetricDescriptorCodable() throws {
    let metric = GoogleCloudMetricDescriptor(
        type: "custom.googleapis.com/test",
        projectID: "test-project",
        metricKind: .gauge,
        valueType: .int64
    )

    let data = try JSONEncoder().encode(metric)
    let decoded = try JSONDecoder().decode(GoogleCloudMetricDescriptor.self, from: data)

    #expect(decoded.type == metric.type)
    #expect(decoded.metricKind == metric.metricKind)
}

@Test func testDashboardCodable() throws {
    let dashboard = GoogleCloudDashboard(
        displayName: "Test Dashboard",
        projectID: "test-project"
    )

    let data = try JSONEncoder().encode(dashboard)
    let decoded = try JSONDecoder().decode(GoogleCloudDashboard.self, from: data)

    #expect(decoded.displayName == dashboard.displayName)
}

@Test func testMonitoringGroupCodable() throws {
    let group = GoogleCloudMonitoringGroup(
        displayName: "Test Group",
        projectID: "test-project",
        filter: "resource.type=\"gce_instance\""
    )

    let data = try JSONEncoder().encode(group)
    let decoded = try JSONDecoder().decode(GoogleCloudMonitoringGroup.self, from: data)

    #expect(decoded.displayName == group.displayName)
    #expect(decoded.filter == group.filter)
}

@Test func testSLOCodable() throws {
    let slo = GoogleCloudSLO(
        displayName: "Test SLO",
        serviceName: "my-service",
        projectID: "test-project",
        goal: 0.99,
        sli: .requestBased(goodTotalRatio: nil, distributionCut: nil)
    )

    let data = try JSONEncoder().encode(slo)
    let decoded = try JSONDecoder().decode(GoogleCloudSLO.self, from: data)

    #expect(decoded.displayName == slo.displayName)
    #expect(decoded.goal == slo.goal)
}

// MARK: - VPC Network Tests

@Test func testVPCNetworkBasicInit() {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project"
    )

    #expect(network.name == "my-vpc")
    #expect(network.projectID == "test-project")
    #expect(network.autoCreateSubnetworks == false)
    #expect(network.routingMode == .regional)
}

@Test func testVPCNetworkWithOptions() {
    let network = GoogleCloudVPCNetwork(
        name: "global-vpc",
        projectID: "test-project",
        autoCreateSubnetworks: true,
        routingMode: .global,
        description: "Global VPC network",
        mtu: 1500
    )

    #expect(network.name == "global-vpc")
    #expect(network.autoCreateSubnetworks == true)
    #expect(network.routingMode == .global)
    #expect(network.description == "Global VPC network")
    #expect(network.mtu == 1500)
}

@Test func testVPCNetworkResourceName() {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project"
    )

    #expect(network.resourceName == "projects/test-project/global/networks/my-vpc")
    #expect(network.selfLink == "https://www.googleapis.com/compute/v1/projects/test-project/global/networks/my-vpc")
}

@Test func testVPCNetworkCreateCommand() {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project",
        autoCreateSubnetworks: false,
        routingMode: .global
    )

    #expect(network.createCommand.contains("gcloud compute networks create my-vpc"))
    #expect(network.createCommand.contains("--project=test-project"))
    #expect(network.createCommand.contains("--subnet-mode=custom"))
    #expect(network.createCommand.contains("--bgp-routing-mode=global"))
}

@Test func testVPCNetworkAutoModeCreateCommand() {
    let network = GoogleCloudVPCNetwork(
        name: "auto-vpc",
        projectID: "test-project",
        autoCreateSubnetworks: true
    )

    #expect(network.createCommand.contains("--subnet-mode=auto"))
}

@Test func testVPCNetworkDeleteCommand() {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project"
    )

    #expect(network.deleteCommand == "gcloud compute networks delete my-vpc --project=test-project --quiet")
}

@Test func testVPCNetworkDescribeCommand() {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project"
    )

    #expect(network.describeCommand == "gcloud compute networks describe my-vpc --project=test-project")
}

@Test func testVPCNetworkListCommand() {
    let cmd = GoogleCloudVPCNetwork.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud compute networks list --project=test-project")
}

@Test func testVPCNetworkUpdateCommand() {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project",
        routingMode: .global
    )

    #expect(network.updateCommand.contains("gcloud compute networks update my-vpc"))
    #expect(network.updateCommand.contains("--bgp-routing-mode=global"))
}

@Test func testVPCNetworkListSubnetsCommand() {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project"
    )

    #expect(network.listSubnetsCommand == "gcloud compute networks subnets list --network=my-vpc --project=test-project")
}

@Test func testVPCNetworkCodable() throws {
    let network = GoogleCloudVPCNetwork(
        name: "my-vpc",
        projectID: "test-project",
        autoCreateSubnetworks: false,
        routingMode: .global,
        description: "Test network",
        mtu: 1460
    )

    let data = try JSONEncoder().encode(network)
    let decoded = try JSONDecoder().decode(GoogleCloudVPCNetwork.self, from: data)

    #expect(decoded.name == network.name)
    #expect(decoded.routingMode == network.routingMode)
    #expect(decoded.mtu == network.mtu)
}

@Test func testRoutingModeValues() {
    #expect(GoogleCloudVPCNetwork.RoutingMode.regional.rawValue == "regional")
    #expect(GoogleCloudVPCNetwork.RoutingMode.global.rawValue == "global")
}

// MARK: - Subnet Tests

@Test func testSubnetBasicInit() {
    let subnet = GoogleCloudSubnet(
        name: "my-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24"
    )

    #expect(subnet.name == "my-subnet")
    #expect(subnet.networkName == "my-vpc")
    #expect(subnet.projectID == "test-project")
    #expect(subnet.region == "us-central1")
    #expect(subnet.ipCidrRange == "10.0.0.0/24")
    #expect(subnet.privateIpGoogleAccess == true)
    #expect(subnet.enableFlowLogs == false)
}

@Test func testSubnetWithAllOptions() {
    let subnet = GoogleCloudSubnet(
        name: "my-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24",
        description: "Primary subnet",
        privateIpGoogleAccess: true,
        enableFlowLogs: true,
        flowLogAggregationInterval: .interval5Min,
        secondaryIpRanges: [
            .init(rangeName: "pods", ipCidrRange: "10.4.0.0/14"),
            .init(rangeName: "services", ipCidrRange: "10.0.32.0/20")
        ],
        purpose: .privateDefault,
        stackType: .ipv4Ipv6
    )

    #expect(subnet.enableFlowLogs == true)
    #expect(subnet.flowLogAggregationInterval == .interval5Min)
    #expect(subnet.secondaryIpRanges.count == 2)
    #expect(subnet.stackType == .ipv4Ipv6)
}

@Test func testSubnetResourceName() {
    let subnet = GoogleCloudSubnet(
        name: "my-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24"
    )

    #expect(subnet.resourceName == "projects/test-project/regions/us-central1/subnetworks/my-subnet")
}

@Test func testSubnetCreateCommand() {
    let subnet = GoogleCloudSubnet(
        name: "my-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24",
        privateIpGoogleAccess: true,
        enableFlowLogs: true,
        flowLogAggregationInterval: .interval5Min
    )

    #expect(subnet.createCommand.contains("gcloud compute networks subnets create my-subnet"))
    #expect(subnet.createCommand.contains("--network=my-vpc"))
    #expect(subnet.createCommand.contains("--region=us-central1"))
    #expect(subnet.createCommand.contains("--range=10.0.0.0/24"))
    #expect(subnet.createCommand.contains("--enable-private-ip-google-access"))
    #expect(subnet.createCommand.contains("--enable-flow-logs"))
    #expect(subnet.createCommand.contains("--logging-aggregation-interval=INTERVAL_5_MIN"))
}

@Test func testSubnetWithSecondaryRanges() {
    let subnet = GoogleCloudSubnet(
        name: "gke-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24",
        secondaryIpRanges: [
            .init(rangeName: "pods", ipCidrRange: "10.4.0.0/14")
        ]
    )

    #expect(subnet.createCommand.contains("--secondary-range=pods=10.4.0.0/14"))
}

@Test func testSubnetDeleteCommand() {
    let subnet = GoogleCloudSubnet(
        name: "my-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24"
    )

    #expect(subnet.deleteCommand == "gcloud compute networks subnets delete my-subnet --project=test-project --region=us-central1 --quiet")
}

@Test func testSubnetListCommand() {
    let cmd = GoogleCloudSubnet.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud compute networks subnets list --project=test-project")
}

@Test func testSubnetListCommandWithRegion() {
    let cmd = GoogleCloudSubnet.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd.contains("--regions=us-central1"))
}

@Test func testSubnetExpandIpRangeCommand() {
    let subnet = GoogleCloudSubnet(
        name: "my-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24"
    )

    let cmd = subnet.expandIpRangeCommand(newRange: "20")
    #expect(cmd.contains("expand-ip-range my-subnet"))
    #expect(cmd.contains("--prefix-length=20"))
}

@Test func testSecondaryIPRange() {
    let range = GoogleCloudSubnet.SecondaryIPRange(
        rangeName: "pods",
        ipCidrRange: "10.4.0.0/14"
    )

    #expect(range.rangeName == "pods")
    #expect(range.ipCidrRange == "10.4.0.0/14")
}

@Test func testFlowLogIntervalValues() {
    #expect(GoogleCloudSubnet.FlowLogInterval.interval5Sec.rawValue == "INTERVAL_5_SEC")
    #expect(GoogleCloudSubnet.FlowLogInterval.interval30Sec.rawValue == "INTERVAL_30_SEC")
    #expect(GoogleCloudSubnet.FlowLogInterval.interval1Min.rawValue == "INTERVAL_1_MIN")
    #expect(GoogleCloudSubnet.FlowLogInterval.interval5Min.rawValue == "INTERVAL_5_MIN")
}

@Test func testSubnetPurposeValues() {
    #expect(GoogleCloudSubnet.SubnetPurpose.privateDefault.rawValue == "PRIVATE")
    #expect(GoogleCloudSubnet.SubnetPurpose.regionalManagedProxy.rawValue == "REGIONAL_MANAGED_PROXY")
    #expect(GoogleCloudSubnet.SubnetPurpose.privateServiceConnect.rawValue == "PRIVATE_SERVICE_CONNECT")
}

@Test func testStackTypeValues() {
    #expect(GoogleCloudSubnet.StackType.ipv4Only.rawValue == "IPV4_ONLY")
    #expect(GoogleCloudSubnet.StackType.ipv4Ipv6.rawValue == "IPV4_IPV6")
}

@Test func testSubnetCodable() throws {
    let subnet = GoogleCloudSubnet(
        name: "my-subnet",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        ipCidrRange: "10.0.0.0/24",
        enableFlowLogs: true,
        secondaryIpRanges: [.init(rangeName: "pods", ipCidrRange: "10.4.0.0/14")]
    )

    let data = try JSONEncoder().encode(subnet)
    let decoded = try JSONDecoder().decode(GoogleCloudSubnet.self, from: data)

    #expect(decoded.name == subnet.name)
    #expect(decoded.secondaryIpRanges.count == 1)
}

// MARK: - Firewall Rule Tests

@Test func testFirewallRuleBasicInit() {
    let rule = GoogleCloudFirewallRule(
        name: "allow-http",
        networkName: "my-vpc",
        projectID: "test-project",
        direction: .ingress,
        allowed: [.init(protocol: .tcp, ports: ["80", "443"])],
        sourceRanges: ["0.0.0.0/0"],
        targetTags: ["web-server"]
    )

    #expect(rule.name == "allow-http")
    #expect(rule.networkName == "my-vpc")
    #expect(rule.direction == .ingress)
    #expect(rule.allowed.count == 1)
    #expect(rule.targetTags.contains("web-server"))
}

@Test func testFirewallRuleDefaults() {
    let rule = GoogleCloudFirewallRule(
        name: "test-rule",
        networkName: "my-vpc",
        projectID: "test-project"
    )

    #expect(rule.direction == .ingress)
    #expect(rule.priority == 1000)
    #expect(rule.disabled == false)
    #expect(rule.enableLogging == false)
}

@Test func testFirewallRuleResourceName() {
    let rule = GoogleCloudFirewallRule(
        name: "allow-http",
        networkName: "my-vpc",
        projectID: "test-project"
    )

    #expect(rule.resourceName == "projects/test-project/global/firewalls/allow-http")
}

@Test func testVPCFirewallRuleCreateCommand() {
    let rule = GoogleCloudFirewallRule(
        name: "allow-http",
        networkName: "my-vpc",
        projectID: "test-project",
        direction: .ingress,
        allowed: [.init(protocol: .tcp, ports: ["80", "443"])],
        priority: 900,
        sourceRanges: ["0.0.0.0/0"],
        targetTags: ["web-server"]
    )

    #expect(rule.createCommand.contains("gcloud compute firewall-rules create allow-http"))
    #expect(rule.createCommand.contains("--network=my-vpc"))
    #expect(rule.createCommand.contains("--direction=INGRESS"))
    #expect(rule.createCommand.contains("--priority=900"))
    #expect(rule.createCommand.contains("--allow=tcp:80,443"))
    #expect(rule.createCommand.contains("--source-ranges=0.0.0.0/0"))
    #expect(rule.createCommand.contains("--target-tags=web-server"))
}

@Test func testFirewallRuleEgressDirection() {
    let rule = GoogleCloudFirewallRule(
        name: "deny-outbound",
        networkName: "my-vpc",
        projectID: "test-project",
        direction: .egress,
        denied: [.init(protocol: .all)],
        destinationRanges: ["0.0.0.0/0"]
    )

    #expect(rule.createCommand.contains("--direction=EGRESS"))
    #expect(rule.createCommand.contains("--destination-ranges=0.0.0.0/0"))
}

@Test func testFirewallRuleWithLogging() {
    let rule = GoogleCloudFirewallRule(
        name: "logged-rule",
        networkName: "my-vpc",
        projectID: "test-project",
        enableLogging: true
    )

    #expect(rule.createCommand.contains("--enable-logging"))
}

@Test func testFirewallRuleDeleteCommand() {
    let rule = GoogleCloudFirewallRule(
        name: "allow-http",
        networkName: "my-vpc",
        projectID: "test-project"
    )

    #expect(rule.deleteCommand == "gcloud compute firewall-rules delete allow-http --project=test-project --quiet")
}

@Test func testFirewallRuleListCommand() {
    let cmd = GoogleCloudFirewallRule.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud compute firewall-rules list --project=test-project")
}

@Test func testFirewallRuleUpdateCommand() {
    let rule = GoogleCloudFirewallRule(
        name: "allow-http",
        networkName: "my-vpc",
        projectID: "test-project",
        disabled: true
    )

    #expect(rule.updateCommand.contains("gcloud compute firewall-rules update allow-http"))
    #expect(rule.updateCommand.contains("--disabled"))
}

@Test func testTrafficSpec() {
    let spec = GoogleCloudFirewallRule.TrafficSpec(protocol: .tcp, ports: ["22", "80", "443"])
    #expect(spec.ipProtocol == .tcp)
    #expect(spec.ports?.count == 3)
}

@Test func testTrafficSpecAllProtocol() {
    let spec = GoogleCloudFirewallRule.TrafficSpec(protocol: .all)
    #expect(spec.ipProtocol == .all)
    #expect(spec.ports == nil)
}

@Test func testIPProtocolValues() {
    #expect(GoogleCloudFirewallRule.TrafficSpec.IPProtocol.tcp.rawValue == "tcp")
    #expect(GoogleCloudFirewallRule.TrafficSpec.IPProtocol.udp.rawValue == "udp")
    #expect(GoogleCloudFirewallRule.TrafficSpec.IPProtocol.icmp.rawValue == "icmp")
    #expect(GoogleCloudFirewallRule.TrafficSpec.IPProtocol.all.rawValue == "all")
}

@Test func testFirewallRuleCodable() throws {
    let rule = GoogleCloudFirewallRule(
        name: "allow-http",
        networkName: "my-vpc",
        projectID: "test-project",
        direction: .ingress,
        allowed: [.init(protocol: .tcp, ports: ["80"])],
        sourceRanges: ["0.0.0.0/0"]
    )

    let data = try JSONEncoder().encode(rule)
    let decoded = try JSONDecoder().decode(GoogleCloudFirewallRule.self, from: data)

    #expect(decoded.name == rule.name)
    #expect(decoded.allowed.count == 1)
}

// MARK: - Route Tests

@Test func testRouteBasicInit() {
    let route = GoogleCloudRoute(
        name: "my-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "10.1.0.0/16",
        nextHop: .gateway("default-internet-gateway")
    )

    #expect(route.name == "my-route")
    #expect(route.networkName == "my-vpc")
    #expect(route.destRange == "10.1.0.0/16")
    #expect(route.priority == 1000)
}

@Test func testRouteResourceName() {
    let route = GoogleCloudRoute(
        name: "my-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "0.0.0.0/0",
        nextHop: .gateway("default-internet-gateway")
    )

    #expect(route.resourceName == "projects/test-project/global/routes/my-route")
}

@Test func testRouteCreateCommandGateway() {
    let route = GoogleCloudRoute(
        name: "default-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "0.0.0.0/0",
        nextHop: .gateway("default-internet-gateway")
    )

    #expect(route.createCommand.contains("gcloud compute routes create default-route"))
    #expect(route.createCommand.contains("--destination-range=0.0.0.0/0"))
    #expect(route.createCommand.contains("--next-hop-gateway=default-internet-gateway"))
}

@Test func testRouteCreateCommandInstance() {
    let route = GoogleCloudRoute(
        name: "nat-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "0.0.0.0/0",
        nextHop: .instance(name: "nat-instance", zone: "us-central1-a")
    )

    #expect(route.createCommand.contains("--next-hop-instance=nat-instance"))
    #expect(route.createCommand.contains("--next-hop-instance-zone=us-central1-a"))
}

@Test func testRouteCreateCommandIP() {
    let route = GoogleCloudRoute(
        name: "ip-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "10.0.0.0/8",
        nextHop: .ip(address: "10.0.0.1")
    )

    #expect(route.createCommand.contains("--next-hop-address=10.0.0.1"))
}

@Test func testRouteCreateCommandVpnTunnel() {
    let route = GoogleCloudRoute(
        name: "vpn-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "192.168.0.0/16",
        nextHop: .vpnTunnel(name: "my-tunnel", region: "us-central1")
    )

    #expect(route.createCommand.contains("--next-hop-vpn-tunnel=my-tunnel"))
    #expect(route.createCommand.contains("--next-hop-vpn-tunnel-region=us-central1"))
}

@Test func testRouteCreateCommandILB() {
    let route = GoogleCloudRoute(
        name: "ilb-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "10.0.0.0/8",
        nextHop: .ilb(forwardingRule: "my-ilb", region: "us-central1")
    )

    #expect(route.createCommand.contains("--next-hop-ilb=my-ilb"))
    #expect(route.createCommand.contains("--next-hop-ilb-region=us-central1"))
}

@Test func testRouteWithTags() {
    let route = GoogleCloudRoute(
        name: "tagged-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "10.0.0.0/8",
        nextHop: .gateway("default-internet-gateway"),
        tags: ["web-server", "app-server"]
    )

    #expect(route.createCommand.contains("--tags=web-server,app-server"))
}

@Test func testRouteDeleteCommand() {
    let route = GoogleCloudRoute(
        name: "my-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "0.0.0.0/0",
        nextHop: .gateway("default-internet-gateway")
    )

    #expect(route.deleteCommand == "gcloud compute routes delete my-route --project=test-project --quiet")
}

@Test func testRouteListCommand() {
    let cmd = GoogleCloudRoute.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud compute routes list --project=test-project")
}

@Test func testRouteCodable() throws {
    let route = GoogleCloudRoute(
        name: "my-route",
        networkName: "my-vpc",
        projectID: "test-project",
        destRange: "10.0.0.0/8",
        nextHop: .ip(address: "10.0.0.1")
    )

    let data = try JSONEncoder().encode(route)
    let decoded = try JSONDecoder().decode(GoogleCloudRoute.self, from: data)

    #expect(decoded.name == route.name)
    #expect(decoded.destRange == route.destRange)
}

// MARK: - VPC Peering Tests

@Test func testVPCPeeringBasicInit() {
    let peering = GoogleCloudVPCPeering(
        name: "peer-to-shared",
        networkName: "my-vpc",
        projectID: "test-project",
        peerNetwork: "projects/shared-project/global/networks/shared-vpc"
    )

    #expect(peering.name == "peer-to-shared")
    #expect(peering.networkName == "my-vpc")
    #expect(peering.peerNetwork == "projects/shared-project/global/networks/shared-vpc")
    #expect(peering.exportCustomRoutes == false)
    #expect(peering.importCustomRoutes == false)
}

@Test func testVPCPeeringWithRouteExchange() {
    let peering = GoogleCloudVPCPeering(
        name: "peer-with-routes",
        networkName: "my-vpc",
        projectID: "test-project",
        peerNetwork: "projects/other/global/networks/other-vpc",
        exportCustomRoutes: true,
        importCustomRoutes: true
    )

    #expect(peering.exportCustomRoutes == true)
    #expect(peering.importCustomRoutes == true)
}

@Test func testVPCPeeringCreateCommand() {
    let peering = GoogleCloudVPCPeering(
        name: "peer-to-shared",
        networkName: "my-vpc",
        projectID: "test-project",
        peerNetwork: "projects/shared-project/global/networks/shared-vpc",
        exportCustomRoutes: true,
        importCustomRoutes: true
    )

    #expect(peering.createCommand.contains("gcloud compute networks peerings create peer-to-shared"))
    #expect(peering.createCommand.contains("--network=my-vpc"))
    #expect(peering.createCommand.contains("--peer-network=projects/shared-project/global/networks/shared-vpc"))
    #expect(peering.createCommand.contains("--export-custom-routes"))
    #expect(peering.createCommand.contains("--import-custom-routes"))
}

@Test func testVPCPeeringDeleteCommand() {
    let peering = GoogleCloudVPCPeering(
        name: "peer-to-shared",
        networkName: "my-vpc",
        projectID: "test-project",
        peerNetwork: "projects/shared/global/networks/shared-vpc"
    )

    #expect(peering.deleteCommand == "gcloud compute networks peerings delete peer-to-shared --network=my-vpc --project=test-project --quiet")
}

@Test func testVPCPeeringListCommand() {
    let cmd = GoogleCloudVPCPeering.listCommand(networkName: "my-vpc", projectID: "test-project")
    #expect(cmd == "gcloud compute networks peerings list --network=my-vpc --project=test-project")
}

@Test func testVPCPeeringUpdateCommand() {
    let peering = GoogleCloudVPCPeering(
        name: "peer-to-shared",
        networkName: "my-vpc",
        projectID: "test-project",
        peerNetwork: "projects/shared/global/networks/shared-vpc",
        exportCustomRoutes: true,
        importCustomRoutes: false
    )

    #expect(peering.updateCommand.contains("--export-custom-routes"))
    #expect(peering.updateCommand.contains("--no-import-custom-routes"))
}

@Test func testVPCPeeringCodable() throws {
    let peering = GoogleCloudVPCPeering(
        name: "peer-to-shared",
        networkName: "my-vpc",
        projectID: "test-project",
        peerNetwork: "projects/shared/global/networks/shared-vpc"
    )

    let data = try JSONEncoder().encode(peering)
    let decoded = try JSONDecoder().decode(GoogleCloudVPCPeering.self, from: data)

    #expect(decoded.name == peering.name)
    #expect(decoded.peerNetwork == peering.peerNetwork)
}

// MARK: - Cloud Router Tests

@Test func testCloudRouterBasicInit() {
    let router = GoogleCloudRouter(
        name: "my-router",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(router.name == "my-router")
    #expect(router.networkName == "my-vpc")
    #expect(router.region == "us-central1")
    #expect(router.bgpAsn == 64512)
    #expect(router.advertiseMode == .default)
}

@Test func testCloudRouterWithCustomASN() {
    let router = GoogleCloudRouter(
        name: "my-router",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        bgpAsn: 65000,
        description: "Custom router",
        advertisedIpRanges: ["10.0.0.0/8", "172.16.0.0/12"],
        advertiseMode: .custom
    )

    #expect(router.bgpAsn == 65000)
    #expect(router.advertiseMode == .custom)
    #expect(router.advertisedIpRanges.count == 2)
}

@Test func testCloudRouterResourceName() {
    let router = GoogleCloudRouter(
        name: "my-router",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(router.resourceName == "projects/test-project/regions/us-central1/routers/my-router")
}

@Test func testCloudRouterCreateCommand() {
    let router = GoogleCloudRouter(
        name: "my-router",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        bgpAsn: 64512
    )

    #expect(router.createCommand.contains("gcloud compute routers create my-router"))
    #expect(router.createCommand.contains("--network=my-vpc"))
    #expect(router.createCommand.contains("--region=us-central1"))
    #expect(router.createCommand.contains("--asn=64512"))
}

@Test func testCloudRouterWithCustomAdvertisement() {
    let router = GoogleCloudRouter(
        name: "my-router",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        advertisedIpRanges: ["10.0.0.0/8"],
        advertiseMode: .custom
    )

    #expect(router.createCommand.contains("--advertisement-mode=CUSTOM"))
    #expect(router.createCommand.contains("--set-advertisement-ranges=10.0.0.0/8"))
}

@Test func testCloudRouterDeleteCommand() {
    let router = GoogleCloudRouter(
        name: "my-router",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(router.deleteCommand == "gcloud compute routers delete my-router --project=test-project --region=us-central1 --quiet")
}

@Test func testCloudRouterListCommand() {
    let cmd = GoogleCloudRouter.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud compute routers list --project=test-project")
}

@Test func testCloudRouterListCommandWithRegion() {
    let cmd = GoogleCloudRouter.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd.contains("--regions=us-central1"))
}

@Test func testCloudRouterCodable() throws {
    let router = GoogleCloudRouter(
        name: "my-router",
        networkName: "my-vpc",
        projectID: "test-project",
        region: "us-central1",
        bgpAsn: 65000
    )

    let data = try JSONEncoder().encode(router)
    let decoded = try JSONDecoder().decode(GoogleCloudRouter.self, from: data)

    #expect(decoded.name == router.name)
    #expect(decoded.bgpAsn == router.bgpAsn)
}

@Test func testAdvertiseModeValues() {
    #expect(GoogleCloudRouter.AdvertiseMode.default.rawValue == "DEFAULT")
    #expect(GoogleCloudRouter.AdvertiseMode.custom.rawValue == "CUSTOM")
}

// MARK: - Cloud NAT Tests

@Test func testNATGatewayBasicInit() {
    let nat = GoogleCloudNATGateway(
        name: "my-nat",
        routerName: "my-router",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(nat.name == "my-nat")
    #expect(nat.routerName == "my-router")
    #expect(nat.region == "us-central1")
    #expect(nat.natIpAllocateOption == .autoOnly)
    #expect(nat.enableEndpointIndependentMapping == true)
}

@Test func testNATGatewayWithOptions() {
    let nat = GoogleCloudNATGateway(
        name: "my-nat",
        routerName: "my-router",
        projectID: "test-project",
        region: "us-central1",
        minPortsPerVm: 128,
        enableDynamicPortAllocation: true,
        logFilter: .errorsOnly
    )

    #expect(nat.minPortsPerVm == 128)
    #expect(nat.enableDynamicPortAllocation == true)
    #expect(nat.logFilter == .errorsOnly)
}

@Test func testNATGatewayCreateCommand() {
    let nat = GoogleCloudNATGateway(
        name: "my-nat",
        routerName: "my-router",
        projectID: "test-project",
        region: "us-central1",
        minPortsPerVm: 64,
        enableDynamicPortAllocation: true,
        logFilter: .all
    )

    #expect(nat.createCommand.contains("gcloud compute routers nats create my-nat"))
    #expect(nat.createCommand.contains("--router=my-router"))
    #expect(nat.createCommand.contains("--region=us-central1"))
    #expect(nat.createCommand.contains("--min-ports-per-vm=64"))
    #expect(nat.createCommand.contains("--enable-dynamic-port-allocation"))
    #expect(nat.createCommand.contains("--enable-logging"))
    #expect(nat.createCommand.contains("--log-filter=ALL"))
}

@Test func testNATGatewayDeleteCommand() {
    let nat = GoogleCloudNATGateway(
        name: "my-nat",
        routerName: "my-router",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(nat.deleteCommand == "gcloud compute routers nats delete my-nat --router=my-router --project=test-project --region=us-central1 --quiet")
}

@Test func testNATGatewayDescribeCommand() {
    let nat = GoogleCloudNATGateway(
        name: "my-nat",
        routerName: "my-router",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(nat.describeCommand == "gcloud compute routers nats describe my-nat --router=my-router --project=test-project --region=us-central1")
}

@Test func testNATGatewayListCommand() {
    let cmd = GoogleCloudNATGateway.listCommand(routerName: "my-router", projectID: "test-project", region: "us-central1")
    #expect(cmd == "gcloud compute routers nats list --router=my-router --project=test-project --region=us-central1")
}

@Test func testNATIPAllocateOptionValues() {
    #expect(GoogleCloudNATGateway.NATIPAllocateOption.autoOnly.rawValue == "AUTO_ONLY")
    #expect(GoogleCloudNATGateway.NATIPAllocateOption.manualOnly.rawValue == "MANUAL_ONLY")
}

@Test func testSourceSubnetworkOptionValues() {
    #expect(GoogleCloudNATGateway.SourceSubnetworkOption.allSubnetworksAllIpRanges.rawValue == "ALL_SUBNETWORKS_ALL_IP_RANGES")
    #expect(GoogleCloudNATGateway.SourceSubnetworkOption.allSubnetworksAllPrimaryIpRanges.rawValue == "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES")
    #expect(GoogleCloudNATGateway.SourceSubnetworkOption.listOfSubnetworks.rawValue == "LIST_OF_SUBNETWORKS")
}

@Test func testSubnetNATConfig() {
    let config = GoogleCloudNATGateway.SubnetNATConfig(
        subnetName: "my-subnet",
        sourceIpRangesToNat: ["PRIMARY_IP_RANGE", "pods"]
    )

    #expect(config.subnetName == "my-subnet")
    #expect(config.sourceIpRangesToNat.count == 2)
}

@Test func testNATLogFilterValues() {
    #expect(GoogleCloudNATGateway.LogFilter.all.rawValue == "ALL")
    #expect(GoogleCloudNATGateway.LogFilter.errorsOnly.rawValue == "ERRORS_ONLY")
    #expect(GoogleCloudNATGateway.LogFilter.translationsOnly.rawValue == "TRANSLATIONS_ONLY")
}

@Test func testNATGatewayCodable() throws {
    let nat = GoogleCloudNATGateway(
        name: "my-nat",
        routerName: "my-router",
        projectID: "test-project",
        region: "us-central1",
        enableDynamicPortAllocation: true
    )

    let data = try JSONEncoder().encode(nat)
    let decoded = try JSONDecoder().decode(GoogleCloudNATGateway.self, from: data)

    #expect(decoded.name == nat.name)
    #expect(decoded.enableDynamicPortAllocation == true)
}

// MARK: - Reserved IP Address Tests

@Test func testReservedAddressBasicInit() {
    let address = GoogleCloudReservedAddress(
        name: "my-ip",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(address.name == "my-ip")
    #expect(address.projectID == "test-project")
    #expect(address.region == "us-central1")
    #expect(address.addressType == .external)
    #expect(address.ipVersion == .ipv4)
    #expect(address.networkTier == .premium)
}

@Test func testReservedAddressGlobal() {
    let address = GoogleCloudReservedAddress(
        name: "global-ip",
        projectID: "test-project",
        region: nil
    )

    #expect(address.region == nil)
}

@Test func testReservedAddressInternal() {
    let address = GoogleCloudReservedAddress(
        name: "internal-ip",
        projectID: "test-project",
        region: "us-central1",
        addressType: .internal,
        subnetwork: "my-subnet"
    )

    #expect(address.addressType == .internal)
    #expect(address.subnetwork == "my-subnet")
}

@Test func testReservedAddressCreateCommandRegional() {
    let address = GoogleCloudReservedAddress(
        name: "my-ip",
        projectID: "test-project",
        region: "us-central1",
        networkTier: .premium
    )

    #expect(address.createCommand.contains("gcloud compute addresses create my-ip"))
    #expect(address.createCommand.contains("--project=test-project"))
    #expect(address.createCommand.contains("--region=us-central1"))
    #expect(address.createCommand.contains("--ip-version=IPV4"))
    #expect(address.createCommand.contains("--network-tier=PREMIUM"))
}

@Test func testReservedAddressCreateCommandGlobal() {
    let address = GoogleCloudReservedAddress(
        name: "global-ip",
        projectID: "test-project",
        region: nil
    )

    #expect(address.createCommand.contains("--global"))
    #expect(!address.createCommand.contains("--region"))
}

@Test func testReservedAddressCreateCommandInternal() {
    let address = GoogleCloudReservedAddress(
        name: "internal-ip",
        projectID: "test-project",
        region: "us-central1",
        addressType: .internal,
        subnetwork: "my-subnet"
    )

    #expect(address.createCommand.contains("--address-type=INTERNAL"))
    #expect(address.createCommand.contains("--subnet=my-subnet"))
}

@Test func testReservedAddressDeleteCommandRegional() {
    let address = GoogleCloudReservedAddress(
        name: "my-ip",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(address.deleteCommand == "gcloud compute addresses delete my-ip --project=test-project --region=us-central1 --quiet")
}

@Test func testReservedAddressDeleteCommandGlobal() {
    let address = GoogleCloudReservedAddress(
        name: "global-ip",
        projectID: "test-project",
        region: nil
    )

    #expect(address.deleteCommand == "gcloud compute addresses delete global-ip --project=test-project --global --quiet")
}

@Test func testReservedAddressDescribeCommandRegional() {
    let address = GoogleCloudReservedAddress(
        name: "my-ip",
        projectID: "test-project",
        region: "us-central1"
    )

    #expect(address.describeCommand == "gcloud compute addresses describe my-ip --project=test-project --region=us-central1")
}

@Test func testReservedAddressDescribeCommandGlobal() {
    let address = GoogleCloudReservedAddress(
        name: "global-ip",
        projectID: "test-project",
        region: nil
    )

    #expect(address.describeCommand == "gcloud compute addresses describe global-ip --project=test-project --global")
}

@Test func testReservedAddressListCommand() {
    let cmd = GoogleCloudReservedAddress.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud compute addresses list --project=test-project")
}

@Test func testReservedAddressListCommandWithRegion() {
    let cmd = GoogleCloudReservedAddress.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd.contains("--regions=us-central1"))
}

@Test func testAddressTypeValues() {
    #expect(GoogleCloudReservedAddress.AddressType.external.rawValue == "EXTERNAL")
    #expect(GoogleCloudReservedAddress.AddressType.internal.rawValue == "INTERNAL")
}

@Test func testIPVersionValues() {
    #expect(GoogleCloudReservedAddress.IPVersion.ipv4.rawValue == "IPV4")
    #expect(GoogleCloudReservedAddress.IPVersion.ipv6.rawValue == "IPV6")
}

@Test func testNetworkTierValues() {
    #expect(GoogleCloudReservedAddress.NetworkTier.premium.rawValue == "PREMIUM")
    #expect(GoogleCloudReservedAddress.NetworkTier.standard.rawValue == "STANDARD")
}

@Test func testAddressPurposeValues() {
    #expect(GoogleCloudReservedAddress.AddressPurpose.gceEndpoint.rawValue == "GCE_ENDPOINT")
    #expect(GoogleCloudReservedAddress.AddressPurpose.sharedLoadbalancerVip.rawValue == "SHARED_LOADBALANCER_VIP")
    #expect(GoogleCloudReservedAddress.AddressPurpose.vpcPeering.rawValue == "VPC_PEERING")
    #expect(GoogleCloudReservedAddress.AddressPurpose.privateServiceConnect.rawValue == "PRIVATE_SERVICE_CONNECT")
}

@Test func testReservedAddressCodable() throws {
    let address = GoogleCloudReservedAddress(
        name: "my-ip",
        projectID: "test-project",
        region: "us-central1",
        addressType: .external,
        ipVersion: .ipv4
    )

    let data = try JSONEncoder().encode(address)
    let decoded = try JSONDecoder().decode(GoogleCloudReservedAddress.self, from: data)

    #expect(decoded.name == address.name)
    #expect(decoded.addressType == address.addressType)
}

// MARK: - Predefined CIDR Range Tests

@Test func testPredefinedCIDRRangesPrivate() {
    #expect(PredefinedCIDRRange.private10 == "10.0.0.0/8")
    #expect(PredefinedCIDRRange.private172 == "172.16.0.0/12")
    #expect(PredefinedCIDRRange.private192 == "192.168.0.0/16")
}

@Test func testPredefinedCIDRRangesSubnetSizes() {
    #expect(PredefinedCIDRRange.subnet24 == "/24")
    #expect(PredefinedCIDRRange.subnet23 == "/23")
    #expect(PredefinedCIDRRange.subnet22 == "/22")
    #expect(PredefinedCIDRRange.subnet20 == "/20")
    #expect(PredefinedCIDRRange.subnet16 == "/16")
}

@Test func testPredefinedCIDRRangesGKE() {
    #expect(PredefinedCIDRRange.gkePods == "10.4.0.0/14")
    #expect(PredefinedCIDRRange.gkeServices == "10.0.32.0/20")
    #expect(PredefinedCIDRRange.gkeMaster == "172.16.0.0/28")
}

@Test func testPredefinedCIDRRangesGoogleAccess() {
    #expect(PredefinedCIDRRange.privateGoogleAccess == "199.36.153.8/30")
    #expect(PredefinedCIDRRange.restrictedGoogleAccess == "199.36.153.4/30")
}

// MARK: - DAIS VPC Template Tests

@Test func testDAISVPCTemplateNetwork() {
    let network = DAISVPCTemplate.network(projectID: "test-project", deploymentName: "dais-prod")

    #expect(network.name == "dais-prod-vpc")
    #expect(network.projectID == "test-project")
    #expect(network.autoCreateSubnetworks == false)
    #expect(network.routingMode == .global)
    #expect(network.description?.contains("dais-prod") == true)
}

@Test func testDAISVPCTemplateNodeSubnet() {
    let subnet = DAISVPCTemplate.nodeSubnet(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1"
    )

    #expect(subnet.name == "dais-prod-nodes")
    #expect(subnet.networkName == "dais-prod-vpc")
    #expect(subnet.region == "us-central1")
    #expect(subnet.ipCidrRange == "10.0.0.0/24")
    #expect(subnet.privateIpGoogleAccess == true)
    #expect(subnet.enableFlowLogs == true)
}

@Test func testDAISVPCTemplateNodeSubnetCustomCIDR() {
    let subnet = DAISVPCTemplate.nodeSubnet(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1",
        cidrRange: "10.1.0.0/20"
    )

    #expect(subnet.ipCidrRange == "10.1.0.0/20")
}

@Test func testDAISVPCTemplateGRPCFirewallRule() {
    let rule = DAISVPCTemplate.grpcFirewallRule(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(rule.name == "dais-prod-allow-grpc")
    #expect(rule.networkName == "dais-prod-vpc")
    #expect(rule.direction == .ingress)
    #expect(rule.allowed.count == 1)
    #expect(rule.allowed[0].ipProtocol == .tcp)
    #expect(rule.allowed[0].ports?.contains("9090") == true)
    #expect(rule.targetTags.contains("dais-prod-node"))
}

@Test func testDAISVPCTemplateGRPCFirewallRuleCustomPort() {
    let rule = DAISVPCTemplate.grpcFirewallRule(
        projectID: "test-project",
        deploymentName: "dais-prod",
        port: 50051
    )

    #expect(rule.allowed[0].ports?.contains("50051") == true)
}

@Test func testDAISVPCTemplateHealthCheckFirewallRule() {
    let rule = DAISVPCTemplate.healthCheckFirewallRule(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(rule.name == "dais-prod-allow-health-check")
    #expect(rule.sourceRanges.contains("35.191.0.0/16"))
    #expect(rule.sourceRanges.contains("130.211.0.0/22"))
}

@Test func testDAISVPCTemplateSSHFirewallRule() {
    let rule = DAISVPCTemplate.sshFirewallRule(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(rule.name == "dais-prod-allow-ssh")
    #expect(rule.allowed[0].ports?.contains("22") == true)
    #expect(rule.sourceRanges.contains("35.235.240.0/20"))
}

@Test func testDAISVPCTemplateInternalFirewallRule() {
    let rule = DAISVPCTemplate.internalFirewallRule(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(rule.name == "dais-prod-allow-internal")
    #expect(rule.allowed.count == 3)
    #expect(rule.sourceTags.contains("dais-prod-node"))
    #expect(rule.targetTags.contains("dais-prod-node"))
}

@Test func testDAISVPCTemplateRouter() {
    let router = DAISVPCTemplate.router(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1"
    )

    #expect(router.name == "dais-prod-router")
    #expect(router.networkName == "dais-prod-vpc")
    #expect(router.region == "us-central1")
}

@Test func testDAISVPCTemplateNATGateway() {
    let nat = DAISVPCTemplate.natGateway(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1"
    )

    #expect(nat.name == "dais-prod-nat")
    #expect(nat.routerName == "dais-prod-router")
    #expect(nat.enableDynamicPortAllocation == true)
    #expect(nat.logFilter == .errorsOnly)
}

@Test func testDAISVPCTemplateSetupScript() {
    let script = DAISVPCTemplate.setupScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("DAIS VPC Network Setup Script"))
    #expect(script.contains("gcloud compute networks create dais-prod-vpc"))
    #expect(script.contains("gcloud compute networks subnets create dais-prod-nodes"))
    #expect(script.contains("gcloud compute firewall-rules create dais-prod-allow-grpc"))
    #expect(script.contains("gcloud compute routers create dais-prod-router"))
    #expect(script.contains("gcloud compute routers nats create dais-prod-nat"))
}

@Test func testDAISVPCTemplateSetupScriptCustomCIDR() {
    let script = DAISVPCTemplate.setupScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1",
        nodeSubnetCidr: "10.1.0.0/20"
    )

    #expect(script.contains("--range=10.1.0.0/20"))
    #expect(script.contains("Subnet: dais-prod-nodes (10.1.0.0/20)"))
}

@Test func testDAISVPCTemplateTeardownScript() {
    let script = DAISVPCTemplate.teardownScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("DAIS VPC Network Teardown Script"))
    #expect(script.contains("Deleting Cloud NAT"))
    #expect(script.contains("Deleting Cloud Router"))
    #expect(script.contains("Deleting firewall rules"))
    #expect(script.contains("Deleting subnet"))
    #expect(script.contains("gcloud compute routers nats delete dais-prod-nat"))
    #expect(script.contains("gcloud compute routers delete dais-prod-router"))
}

// MARK: - Cloud DNS Tests

@Test func testManagedZoneBasicInit() {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com",
        projectID: "test-project"
    )

    #expect(zone.name == "example-zone")
    #expect(zone.dnsName == "example.com.")
    #expect(zone.projectID == "test-project")
    #expect(zone.visibility == .public)
}

@Test func testManagedZoneWithDot() {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com.",
        projectID: "test-project"
    )

    #expect(zone.dnsName == "example.com.")
}

@Test func testManagedZonePrivate() {
    let zone = GoogleCloudManagedZone(
        name: "internal-zone",
        dnsName: "internal.example.com",
        projectID: "test-project",
        visibility: .private,
        networks: ["my-vpc", "other-vpc"]
    )

    #expect(zone.visibility == .private)
    #expect(zone.networks.count == 2)
}

@Test func testManagedZoneWithDNSSEC() {
    let zone = GoogleCloudManagedZone(
        name: "secure-zone",
        dnsName: "secure.example.com",
        projectID: "test-project",
        dnssecConfig: .init(state: .on, nonExistence: .nsec3)
    )

    #expect(zone.dnssecConfig?.state == .on)
    #expect(zone.dnssecConfig?.nonExistence == .nsec3)
}

@Test func testManagedZoneWithForwarding() {
    let zone = GoogleCloudManagedZone(
        name: "forwarding-zone",
        dnsName: "forward.example.com",
        projectID: "test-project",
        visibility: .private,
        forwardingConfig: .init(targetNameServers: [
            .init(ipv4Address: "10.0.0.53"),
            .init(ipv4Address: "10.0.0.54", forwardingPath: .private)
        ])
    )

    #expect(zone.forwardingConfig?.targetNameServers.count == 2)
}

@Test func testManagedZoneResourceName() {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com",
        projectID: "test-project"
    )

    #expect(zone.resourceName == "projects/test-project/managedZones/example-zone")
}

@Test func testManagedZoneCreateCommand() {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com",
        projectID: "test-project",
        description: "Example zone",
        visibility: .public,
        dnssecConfig: .init(state: .on)
    )

    #expect(zone.createCommand.contains("gcloud dns managed-zones create example-zone"))
    #expect(zone.createCommand.contains("--dns-name=example.com."))
    #expect(zone.createCommand.contains("--visibility=public"))
    #expect(zone.createCommand.contains("--dnssec-state=on"))
}

@Test func testManagedZoneCreateCommandPrivate() {
    let zone = GoogleCloudManagedZone(
        name: "private-zone",
        dnsName: "internal.example.com",
        projectID: "test-project",
        visibility: .private,
        networks: ["my-vpc"]
    )

    #expect(zone.createCommand.contains("--visibility=private"))
    #expect(zone.createCommand.contains("--networks=my-vpc"))
}

@Test func testManagedZoneDeleteCommand() {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com",
        projectID: "test-project"
    )

    #expect(zone.deleteCommand == "gcloud dns managed-zones delete example-zone --project=test-project --quiet")
}

@Test func testManagedZoneDescribeCommand() {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com",
        projectID: "test-project"
    )

    #expect(zone.describeCommand == "gcloud dns managed-zones describe example-zone --project=test-project")
}

@Test func testManagedZoneListCommand() {
    let cmd = GoogleCloudManagedZone.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud dns managed-zones list --project=test-project")
}

@Test func testManagedZoneUpdateCommand() {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com",
        projectID: "test-project"
    )

    let cmd = zone.updateCommand(newDescription: "Updated description")
    #expect(cmd.contains("gcloud dns managed-zones update example-zone"))
    #expect(cmd.contains("--description=\"Updated description\""))
}

@Test func testManagedZoneCodable() throws {
    let zone = GoogleCloudManagedZone(
        name: "example-zone",
        dnsName: "example.com",
        projectID: "test-project",
        visibility: .public,
        dnssecConfig: .init(state: .on)
    )

    let data = try JSONEncoder().encode(zone)
    let decoded = try JSONDecoder().decode(GoogleCloudManagedZone.self, from: data)

    #expect(decoded.name == zone.name)
    #expect(decoded.dnsName == zone.dnsName)
    #expect(decoded.dnssecConfig?.state == .on)
}

@Test func testVisibilityValues() {
    #expect(GoogleCloudManagedZone.Visibility.public.rawValue == "public")
    #expect(GoogleCloudManagedZone.Visibility.private.rawValue == "private")
}

@Test func testDNSSECStateValues() {
    #expect(GoogleCloudManagedZone.DNSSECConfig.State.on.rawValue == "on")
    #expect(GoogleCloudManagedZone.DNSSECConfig.State.off.rawValue == "off")
    #expect(GoogleCloudManagedZone.DNSSECConfig.State.transfer.rawValue == "transfer")
}

// MARK: - DNS Record Tests

@Test func testDNSRecordBasicInit() {
    let record = GoogleCloudDNSRecord(
        name: "www.example.com",
        type: .a,
        ttl: 300,
        rrdatas: ["192.0.2.1"]
    )

    #expect(record.name == "www.example.com.")
    #expect(record.type == .a)
    #expect(record.ttl == 300)
    #expect(record.rrdatas.count == 1)
}

@Test func testDNSRecordWithDot() {
    let record = GoogleCloudDNSRecord(
        name: "www.example.com.",
        type: .a,
        ttl: 300,
        rrdatas: ["192.0.2.1"]
    )

    #expect(record.name == "www.example.com.")
}

@Test func testDNSRecordTypes() {
    #expect(GoogleCloudDNSRecord.RecordType.a.rawValue == "A")
    #expect(GoogleCloudDNSRecord.RecordType.aaaa.rawValue == "AAAA")
    #expect(GoogleCloudDNSRecord.RecordType.cname.rawValue == "CNAME")
    #expect(GoogleCloudDNSRecord.RecordType.mx.rawValue == "MX")
    #expect(GoogleCloudDNSRecord.RecordType.txt.rawValue == "TXT")
    #expect(GoogleCloudDNSRecord.RecordType.ns.rawValue == "NS")
    #expect(GoogleCloudDNSRecord.RecordType.srv.rawValue == "SRV")
    #expect(GoogleCloudDNSRecord.RecordType.caa.rawValue == "CAA")
    #expect(GoogleCloudDNSRecord.RecordType.ptr.rawValue == "PTR")
}

@Test func testDNSRecordWithRoutingPolicy() {
    let record = GoogleCloudDNSRecord(
        name: "www.example.com",
        type: .a,
        ttl: 300,
        rrdatas: [],
        routingPolicy: .init(wrr: .init(items: [
            .init(weight: 0.7, rrdatas: ["192.0.2.1"]),
            .init(weight: 0.3, rrdatas: ["192.0.2.2"])
        ]))
    )

    #expect(record.routingPolicy?.wrr?.items.count == 2)
}

@Test func testDNSRecordGeoPolicy() {
    let record = GoogleCloudDNSRecord(
        name: "www.example.com",
        type: .a,
        ttl: 300,
        rrdatas: [],
        routingPolicy: .init(geo: .init(items: [
            .init(location: "us-east1", rrdatas: ["192.0.2.1"]),
            .init(location: "europe-west1", rrdatas: ["192.0.2.2"])
        ]))
    )

    #expect(record.routingPolicy?.geo?.items.count == 2)
}

@Test func testDNSRecordCodable() throws {
    let record = GoogleCloudDNSRecord(
        name: "www.example.com",
        type: .a,
        ttl: 300,
        rrdatas: ["192.0.2.1", "192.0.2.2"]
    )

    let data = try JSONEncoder().encode(record)
    let decoded = try JSONDecoder().decode(GoogleCloudDNSRecord.self, from: data)

    #expect(decoded.name == record.name)
    #expect(decoded.type == record.type)
    #expect(decoded.rrdatas.count == 2)
}

// MARK: - DNS Transaction Tests

@Test func testDNSTransactionInit() {
    let transaction = GoogleCloudDNSTransaction(
        zoneName: "example-zone",
        projectID: "test-project"
    )

    #expect(transaction.zoneName == "example-zone")
    #expect(transaction.projectID == "test-project")
    #expect(transaction.additions.isEmpty)
    #expect(transaction.deletions.isEmpty)
}

@Test func testDNSTransactionStartCommand() {
    let transaction = GoogleCloudDNSTransaction(
        zoneName: "example-zone",
        projectID: "test-project"
    )

    #expect(transaction.startCommand == "gcloud dns record-sets transaction start --zone=example-zone --project=test-project")
}

@Test func testDNSTransactionExecuteCommand() {
    let transaction = GoogleCloudDNSTransaction(
        zoneName: "example-zone",
        projectID: "test-project"
    )

    #expect(transaction.executeCommand == "gcloud dns record-sets transaction execute --zone=example-zone --project=test-project")
}

@Test func testDNSTransactionAbortCommand() {
    let transaction = GoogleCloudDNSTransaction(
        zoneName: "example-zone",
        projectID: "test-project"
    )

    #expect(transaction.abortCommand == "gcloud dns record-sets transaction abort --zone=example-zone --project=test-project")
}

@Test func testDNSTransactionAddCommands() {
    var transaction = GoogleCloudDNSTransaction(
        zoneName: "example-zone",
        projectID: "test-project"
    )

    transaction.additions = [
        GoogleCloudDNSRecord(name: "www.example.com", type: .a, ttl: 300, rrdatas: ["192.0.2.1"])
    ]

    #expect(transaction.addCommands.count == 1)
    #expect(transaction.addCommands[0].contains("transaction add"))
    #expect(transaction.addCommands[0].contains("--name=www.example.com."))
    #expect(transaction.addCommands[0].contains("--type=A"))
}

@Test func testDNSTransactionRemoveCommands() {
    var transaction = GoogleCloudDNSTransaction(
        zoneName: "example-zone",
        projectID: "test-project"
    )

    transaction.deletions = [
        GoogleCloudDNSRecord(name: "old.example.com", type: .a, ttl: 300, rrdatas: ["192.0.2.100"])
    ]

    #expect(transaction.removeCommands.count == 1)
    #expect(transaction.removeCommands[0].contains("transaction remove"))
}

@Test func testDNSTransactionScript() {
    var transaction = GoogleCloudDNSTransaction(
        zoneName: "example-zone",
        projectID: "test-project"
    )

    transaction.additions = [
        GoogleCloudDNSRecord(name: "www.example.com", type: .a, ttl: 300, rrdatas: ["192.0.2.1"])
    ]

    let script = transaction.transactionScript
    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("Starting DNS transaction"))
    #expect(script.contains("Adding records"))
    #expect(script.contains("Executing transaction"))
}

// MARK: - DNS Record Commands Tests

@Test func testDNSRecordCommandsCreate() {
    let record = GoogleCloudDNSRecord(
        name: "www.example.com",
        type: .a,
        ttl: 300,
        rrdatas: ["192.0.2.1"]
    )

    let cmd = GoogleCloudDNSRecordCommands.createCommand(
        zoneName: "example-zone",
        projectID: "test-project",
        record: record
    )

    #expect(cmd.contains("gcloud dns record-sets create www.example.com."))
    #expect(cmd.contains("--zone=example-zone"))
    #expect(cmd.contains("--type=A"))
    #expect(cmd.contains("--ttl=300"))
}

@Test func testDNSRecordCommandsUpdate() {
    let record = GoogleCloudDNSRecord(
        name: "www.example.com",
        type: .a,
        ttl: 600,
        rrdatas: ["192.0.2.2"]
    )

    let cmd = GoogleCloudDNSRecordCommands.updateCommand(
        zoneName: "example-zone",
        projectID: "test-project",
        record: record
    )

    #expect(cmd.contains("gcloud dns record-sets update"))
    #expect(cmd.contains("--ttl=600"))
}

@Test func testDNSRecordCommandsDelete() {
    let cmd = GoogleCloudDNSRecordCommands.deleteCommand(
        zoneName: "example-zone",
        projectID: "test-project",
        name: "www.example.com.",
        type: .a
    )

    #expect(cmd == "gcloud dns record-sets delete www.example.com. --zone=example-zone --project=test-project --type=A --quiet")
}

@Test func testDNSRecordCommandsDescribe() {
    let cmd = GoogleCloudDNSRecordCommands.describeCommand(
        zoneName: "example-zone",
        projectID: "test-project",
        name: "www.example.com.",
        type: .a
    )

    #expect(cmd == "gcloud dns record-sets describe www.example.com. --zone=example-zone --project=test-project --type=A")
}

@Test func testDNSRecordCommandsList() {
    let cmd = GoogleCloudDNSRecordCommands.listCommand(zoneName: "example-zone", projectID: "test-project")
    #expect(cmd == "gcloud dns record-sets list --zone=example-zone --project=test-project")
}

@Test func testDNSRecordCommandsListWithFilter() {
    let cmd = GoogleCloudDNSRecordCommands.listCommand(
        zoneName: "example-zone",
        projectID: "test-project",
        filter: "type=A"
    )
    #expect(cmd.contains("--filter=\"type=A\""))
}

// MARK: - DNS Policy Tests

@Test func testDNSPolicyBasicInit() {
    let policy = GoogleCloudDNSPolicy(
        name: "my-policy",
        projectID: "test-project"
    )

    #expect(policy.name == "my-policy")
    #expect(policy.projectID == "test-project")
    #expect(policy.enableInboundForwarding == false)
    #expect(policy.enableLogging == false)
}

@Test func testDNSPolicyWithOptions() {
    let policy = GoogleCloudDNSPolicy(
        name: "my-policy",
        projectID: "test-project",
        description: "Test policy",
        enableInboundForwarding: true,
        enableLogging: true,
        networks: ["my-vpc"],
        alternativeNameServerConfig: .init(targetNameServers: ["10.0.0.53", "10.0.0.54"])
    )

    #expect(policy.enableInboundForwarding == true)
    #expect(policy.enableLogging == true)
    #expect(policy.networks.count == 1)
    #expect(policy.alternativeNameServerConfig?.targetNameServers.count == 2)
}

@Test func testDNSPolicyResourceName() {
    let policy = GoogleCloudDNSPolicy(
        name: "my-policy",
        projectID: "test-project"
    )

    #expect(policy.resourceName == "projects/test-project/policies/my-policy")
}

@Test func testDNSPolicyCreateCommand() {
    let policy = GoogleCloudDNSPolicy(
        name: "my-policy",
        projectID: "test-project",
        enableInboundForwarding: true,
        enableLogging: true,
        networks: ["my-vpc"]
    )

    #expect(policy.createCommand.contains("gcloud dns policies create my-policy"))
    #expect(policy.createCommand.contains("--enable-inbound-forwarding"))
    #expect(policy.createCommand.contains("--enable-logging"))
    #expect(policy.createCommand.contains("--networks=my-vpc"))
}

@Test func testDNSPolicyDeleteCommand() {
    let policy = GoogleCloudDNSPolicy(
        name: "my-policy",
        projectID: "test-project"
    )

    #expect(policy.deleteCommand == "gcloud dns policies delete my-policy --project=test-project --quiet")
}

@Test func testDNSPolicyListCommand() {
    let cmd = GoogleCloudDNSPolicy.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud dns policies list --project=test-project")
}

@Test func testDNSPolicyCodable() throws {
    let policy = GoogleCloudDNSPolicy(
        name: "my-policy",
        projectID: "test-project",
        enableLogging: true
    )

    let data = try JSONEncoder().encode(policy)
    let decoded = try JSONDecoder().decode(GoogleCloudDNSPolicy.self, from: data)

    #expect(decoded.name == policy.name)
    #expect(decoded.enableLogging == true)
}

// MARK: - Response Policy Tests

@Test func testResponsePolicyBasicInit() {
    let policy = GoogleCloudDNSResponsePolicy(
        name: "my-response-policy",
        projectID: "test-project"
    )

    #expect(policy.name == "my-response-policy")
    #expect(policy.projectID == "test-project")
}

@Test func testResponsePolicyWithNetworks() {
    let policy = GoogleCloudDNSResponsePolicy(
        name: "my-response-policy",
        projectID: "test-project",
        description: "Block malware domains",
        networks: ["my-vpc", "other-vpc"]
    )

    #expect(policy.networks.count == 2)
}

@Test func testResponsePolicyWithGKE() {
    let policy = GoogleCloudDNSResponsePolicy(
        name: "my-response-policy",
        projectID: "test-project",
        gkeClusters: ["projects/test-project/locations/us-central1/clusters/my-cluster"]
    )

    #expect(policy.gkeClusters.count == 1)
}

@Test func testResponsePolicyResourceName() {
    let policy = GoogleCloudDNSResponsePolicy(
        name: "my-response-policy",
        projectID: "test-project"
    )

    #expect(policy.resourceName == "projects/test-project/responsePolicies/my-response-policy")
}

@Test func testResponsePolicyCreateCommand() {
    let policy = GoogleCloudDNSResponsePolicy(
        name: "my-response-policy",
        projectID: "test-project",
        networks: ["my-vpc"]
    )

    #expect(policy.createCommand.contains("gcloud dns response-policies create my-response-policy"))
    #expect(policy.createCommand.contains("--networks=my-vpc"))
}

@Test func testResponsePolicyDeleteCommand() {
    let policy = GoogleCloudDNSResponsePolicy(
        name: "my-response-policy",
        projectID: "test-project"
    )

    #expect(policy.deleteCommand == "gcloud dns response-policies delete my-response-policy --project=test-project --quiet")
}

@Test func testResponsePolicyListCommand() {
    let cmd = GoogleCloudDNSResponsePolicy.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud dns response-policies list --project=test-project")
}

@Test func testResponsePolicyCodable() throws {
    let policy = GoogleCloudDNSResponsePolicy(
        name: "my-response-policy",
        projectID: "test-project",
        networks: ["my-vpc"]
    )

    let data = try JSONEncoder().encode(policy)
    let decoded = try JSONDecoder().decode(GoogleCloudDNSResponsePolicy.self, from: data)

    #expect(decoded.name == policy.name)
    #expect(decoded.networks.count == 1)
}

// MARK: - Response Policy Rule Tests

@Test func testResponsePolicyRuleBypass() {
    let rule = GoogleCloudDNSResponsePolicyRule(
        name: "allow-google",
        responsePolicyName: "my-policy",
        projectID: "test-project",
        dnsName: "google.com",
        behavior: .bypassResponsePolicy
    )

    #expect(rule.name == "allow-google")
    #expect(rule.dnsName == "google.com.")
    #expect(rule.behavior == .bypassResponsePolicy)
}

@Test func testResponsePolicyRuleLocalData() {
    let rule = GoogleCloudDNSResponsePolicyRule(
        name: "block-malware",
        responsePolicyName: "my-policy",
        projectID: "test-project",
        dnsName: "malware.com",
        behavior: .localData,
        localData: .init(localDatas: [
            .init(name: "malware.com.", type: .a, ttl: 300, rrdatas: ["0.0.0.0"])
        ])
    )

    #expect(rule.behavior == .localData)
    #expect(rule.localData?.localDatas.count == 1)
}

@Test func testResponsePolicyRuleCreateCommand() {
    let rule = GoogleCloudDNSResponsePolicyRule(
        name: "allow-google",
        responsePolicyName: "my-policy",
        projectID: "test-project",
        dnsName: "google.com",
        behavior: .bypassResponsePolicy
    )

    #expect(rule.createCommand.contains("gcloud dns response-policies rules create allow-google"))
    #expect(rule.createCommand.contains("--response-policy=my-policy"))
    #expect(rule.createCommand.contains("--dns-name=google.com."))
    #expect(rule.createCommand.contains("--behavior=bypassResponsePolicy"))
}

@Test func testResponsePolicyRuleDeleteCommand() {
    let rule = GoogleCloudDNSResponsePolicyRule(
        name: "allow-google",
        responsePolicyName: "my-policy",
        projectID: "test-project",
        dnsName: "google.com",
        behavior: .bypassResponsePolicy
    )

    #expect(rule.deleteCommand == "gcloud dns response-policies rules delete allow-google --response-policy=my-policy --project=test-project --quiet")
}

@Test func testResponsePolicyRuleListCommand() {
    let cmd = GoogleCloudDNSResponsePolicyRule.listCommand(responsePolicyName: "my-policy", projectID: "test-project")
    #expect(cmd == "gcloud dns response-policies rules list --response-policy=my-policy --project=test-project")
}

@Test func testResponsePolicyRuleCodable() throws {
    let rule = GoogleCloudDNSResponsePolicyRule(
        name: "test-rule",
        responsePolicyName: "my-policy",
        projectID: "test-project",
        dnsName: "example.com",
        behavior: .bypassResponsePolicy
    )

    let data = try JSONEncoder().encode(rule)
    let decoded = try JSONDecoder().decode(GoogleCloudDNSResponsePolicyRule.self, from: data)

    #expect(decoded.name == rule.name)
    #expect(decoded.behavior == rule.behavior)
}

// MARK: - Common DNS Records Tests

@Test func testCommonDNSRecordsA() {
    let record = CommonDNSRecords.aRecord(name: "www.example.com", ipAddresses: ["192.0.2.1", "192.0.2.2"])

    #expect(record.type == .a)
    #expect(record.rrdatas.count == 2)
    #expect(record.ttl == 300)
}

@Test func testCommonDNSRecordsAAAA() {
    let record = CommonDNSRecords.aaaaRecord(name: "www.example.com", ipv6Addresses: ["2001:db8::1"])

    #expect(record.type == .aaaa)
    #expect(record.rrdatas.count == 1)
}

@Test func testCommonDNSRecordsCNAME() {
    let record = CommonDNSRecords.cnameRecord(name: "www.example.com", target: "example.com")

    #expect(record.type == .cname)
    #expect(record.rrdatas[0] == "example.com.")
}

@Test func testCommonDNSRecordsMX() {
    let record = CommonDNSRecords.mxRecord(name: "example.com", mailServers: [
        (10, "mail1.example.com"),
        (20, "mail2.example.com")
    ])

    #expect(record.type == .mx)
    #expect(record.rrdatas.count == 2)
    #expect(record.rrdatas[0].contains("10"))
}

@Test func testCommonDNSRecordsTXT() {
    let record = CommonDNSRecords.txtRecord(name: "example.com", values: ["v=spf1 include:_spf.google.com ~all"])

    #expect(record.type == .txt)
    #expect(record.rrdatas[0].contains("v=spf1"))
}

@Test func testCommonDNSRecordsNS() {
    let record = CommonDNSRecords.nsRecord(name: "example.com", nameServers: ["ns1.example.com", "ns2.example.com"])

    #expect(record.type == .ns)
    #expect(record.rrdatas.count == 2)
}

@Test func testCommonDNSRecordsSRV() {
    let record = CommonDNSRecords.srvRecord(
        name: "_grpc._tcp.example.com",
        services: [(10, 5, 9090, "grpc1.example.com")]
    )

    #expect(record.type == .srv)
    #expect(record.rrdatas[0].contains("9090"))
}

@Test func testCommonDNSRecordsCAA() {
    let record = CommonDNSRecords.caaRecord(name: "example.com", entries: [
        (0, "issue", "letsencrypt.org")
    ])

    #expect(record.type == .caa)
    #expect(record.rrdatas[0].contains("letsencrypt.org"))
}

@Test func testCommonDNSRecordsPTR() {
    let record = CommonDNSRecords.ptrRecord(name: "1.2.0.192.in-addr.arpa", hostname: "www.example.com")

    #expect(record.type == .ptr)
    #expect(record.rrdatas[0] == "www.example.com.")
}

@Test func testCommonDNSRecordsSPF() {
    let record = CommonDNSRecords.spfRecord(name: "example.com", spfValue: "v=spf1 include:_spf.google.com ~all")

    #expect(record.type == .txt)
}

@Test func testCommonDNSRecordsDKIM() {
    let record = CommonDNSRecords.dkimRecord(
        selector: "google",
        domain: "example.com",
        publicKey: "MIGfMA0GCSqGSIb3DQEBAQUAA4GN..."
    )

    #expect(record.name == "google._domainkey.example.com.")
    #expect(record.type == .txt)
    #expect(record.rrdatas[0].contains("v=DKIM1"))
}

@Test func testCommonDNSRecordsDMARC() {
    let record = CommonDNSRecords.dmarcRecord(
        domain: "example.com",
        policy: "reject",
        rua: "dmarc@example.com"
    )

    #expect(record.name == "_dmarc.example.com.")
    #expect(record.type == .txt)
    #expect(record.rrdatas[0].contains("p=reject"))
    #expect(record.rrdatas[0].contains("rua=mailto:dmarc@example.com"))
}

@Test func testCommonDNSRecordsGoogleWorkspaceMX() {
    let record = CommonDNSRecords.googleWorkspaceMX(domain: "example.com")

    #expect(record.type == .mx)
    #expect(record.rrdatas.count == 5)
    #expect(record.rrdatas[0].contains("aspmx.l.google.com"))
}

@Test func testCommonDNSRecordsGoogleSiteVerification() {
    let record = CommonDNSRecords.googleSiteVerification(
        domain: "example.com",
        verificationCode: "abc123"
    )

    #expect(record.type == .txt)
    #expect(record.rrdatas[0].contains("google-site-verification=abc123"))
}

// MARK: - DAIS DNS Template Tests

@Test func testDAISDNSTemplateManagedZone() {
    let zone = DAISDNSTemplate.managedZone(
        projectID: "test-project",
        deploymentName: "dais-prod",
        domain: "example.com"
    )

    #expect(zone.name == "dais-prod-zone")
    #expect(zone.dnsName == "example.com.")
    #expect(zone.visibility == .public)
    #expect(zone.dnssecConfig?.state == .on)
}

@Test func testDAISDNSTemplatePrivateZone() {
    let zone = DAISDNSTemplate.privateZone(
        projectID: "test-project",
        deploymentName: "dais-prod",
        domain: "internal.example.com",
        networks: ["my-vpc"]
    )

    #expect(zone.name == "dais-prod-internal")
    #expect(zone.visibility == .private)
    #expect(zone.networks.count == 1)
}

@Test func testDAISDNSTemplateAPIRecord() {
    let record = DAISDNSTemplate.apiRecord(
        domain: "example.com",
        ipAddress: "192.0.2.1"
    )

    #expect(record.name == "api.example.com.")
    #expect(record.type == .a)
    #expect(record.rrdatas[0] == "192.0.2.1")
}

@Test func testDAISDNSTemplateGRPCRecord() {
    let record = DAISDNSTemplate.grpcRecord(
        domain: "example.com",
        ipAddress: "192.0.2.2"
    )

    #expect(record.name == "grpc.example.com.")
    #expect(record.type == .a)
}

@Test func testDAISDNSTemplateWildcardCNAME() {
    let record = DAISDNSTemplate.wildcardCname(
        domain: "example.com",
        target: "lb.example.com"
    )

    #expect(record.name == "*.example.com.")
    #expect(record.type == .cname)
}

@Test func testDAISDNSTemplateGRPCSRVRecord() {
    let record = DAISDNSTemplate.grpcSrvRecord(
        domain: "example.com",
        serviceName: "myservice",
        targets: [(priority: 10, weight: 5, port: 9090, target: "grpc1.example.com")]
    )

    #expect(record.name == "_grpc._tcp.myservice.example.com.")
    #expect(record.type == .srv)
}

@Test func testDAISDNSTemplateHealthCheckRecord() {
    let record = DAISDNSTemplate.healthCheckRecord(
        domain: "example.com",
        target: "lb.example.com"
    )

    #expect(record.name == "health.example.com.")
    #expect(record.type == .cname)
    #expect(record.ttl == 60)
}

@Test func testDAISDNSTemplateInternalPolicy() {
    let policy = DAISDNSTemplate.internalPolicy(
        projectID: "test-project",
        deploymentName: "dais-prod",
        networks: ["my-vpc"]
    )

    #expect(policy.name == "dais-prod-internal-policy")
    #expect(policy.enableInboundForwarding == true)
    #expect(policy.enableLogging == true)
}

@Test func testDAISDNSTemplateSetupScript() {
    let script = DAISDNSTemplate.setupScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        domain: "example.com",
        apiIP: "192.0.2.1",
        grpcIP: "192.0.2.2"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("DAIS DNS Setup Script"))
    #expect(script.contains("gcloud dns managed-zones create dais-prod-zone"))
    #expect(script.contains("api.example.com"))
    #expect(script.contains("grpc.example.com"))
    #expect(script.contains("192.0.2.1"))
    #expect(script.contains("192.0.2.2"))
}

@Test func testDAISDNSTemplateTeardownScript() {
    let script = DAISDNSTemplate.teardownScript(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("DAIS DNS Teardown Script"))
    #expect(script.contains("Deleting all record sets"))
    #expect(script.contains("Deleting managed zone"))
}

// MARK: - DNSSEC Operations Tests

@Test func testDNSSECOperationsGetDSRecords() {
    let cmd = DNSSECOperations.getDSRecordsCommand(zoneName: "example-zone", projectID: "test-project")
    #expect(cmd.contains("gcloud dns dnskeys list"))
    #expect(cmd.contains("--filter=\"type=keySigning\""))
}

@Test func testDNSSECOperationsEnable() {
    let cmd = DNSSECOperations.enableCommand(zoneName: "example-zone", projectID: "test-project")
    #expect(cmd == "gcloud dns managed-zones update example-zone --project=test-project --dnssec-state=on")
}

@Test func testDNSSECOperationsDisable() {
    let cmd = DNSSECOperations.disableCommand(zoneName: "example-zone", projectID: "test-project")
    #expect(cmd == "gcloud dns managed-zones update example-zone --project=test-project --dnssec-state=off")
}

@Test func testDNSSECOperationsListKeys() {
    let cmd = DNSSECOperations.listKeysCommand(zoneName: "example-zone", projectID: "test-project")
    #expect(cmd == "gcloud dns dnskeys list --zone=example-zone --project=test-project")
}

// MARK: - DNS Operations Tests

@Test func testDNSOperationsExport() {
    let cmd = DNSOperations.exportCommand(zoneName: "example-zone", projectID: "test-project", outputFile: "zone.txt")
    #expect(cmd.contains("gcloud dns record-sets export zone.txt"))
    #expect(cmd.contains("--zone-file-format"))
}

@Test func testDNSOperationsImport() {
    let cmd = DNSOperations.importCommand(zoneName: "example-zone", projectID: "test-project", inputFile: "zone.txt")
    #expect(cmd.contains("gcloud dns record-sets import zone.txt"))
}

@Test func testDNSOperationsGetNameServers() {
    let cmd = DNSOperations.getNameServersCommand(zoneName: "example-zone", projectID: "test-project")
    #expect(cmd.contains("gcloud dns managed-zones describe"))
    #expect(cmd.contains("--format=\"value(nameServers)\""))
}

@Test func testDNSOperationsCheckPropagation() {
    let cmd = DNSOperations.checkPropagationCommand(domain: "example.com", recordType: "A")
    #expect(cmd == "dig @8.8.8.8 example.com A +short")
}

@Test func testDNSOperationsFlushCache() {
    #expect(DNSOperations.flushLocalCacheCommand.contains("dscacheutil -flushcache"))
}
