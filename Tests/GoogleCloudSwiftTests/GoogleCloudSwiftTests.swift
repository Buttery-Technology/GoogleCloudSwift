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
