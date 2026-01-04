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

// MARK: - Cloud Load Balancing Tests

// MARK: Health Check Tests

@Test func testGoogleCloudHealthCheck() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "my-http-hc",
        projectID: "test-project",
        type: .http,
        checkIntervalSec: 10,
        timeoutSec: 5,
        healthyThreshold: 2,
        unhealthyThreshold: 3,
        description: "HTTP health check",
        httpHealthCheck: .init(port: 8080, requestPath: "/health")
    )

    #expect(healthCheck.name == "my-http-hc")
    #expect(healthCheck.type == .http)
    #expect(healthCheck.checkIntervalSec == 10)
    #expect(healthCheck.timeoutSec == 5)
    #expect(healthCheck.healthyThreshold == 2)
    #expect(healthCheck.unhealthyThreshold == 3)
    #expect(healthCheck.resourceName == "projects/test-project/global/healthChecks/my-http-hc")
}

@Test func testHealthCheckCreateCommand() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "api-hc",
        projectID: "my-project",
        type: .http,
        checkIntervalSec: 5,
        timeoutSec: 5,
        healthyThreshold: 2,
        unhealthyThreshold: 3,
        httpHealthCheck: .init(port: 8080, requestPath: "/health", host: "api.example.com")
    )

    let cmd = healthCheck.createCommand
    #expect(cmd.contains("gcloud compute health-checks create http api-hc"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--check-interval=5s"))
    #expect(cmd.contains("--timeout=5s"))
    #expect(cmd.contains("--healthy-threshold=2"))
    #expect(cmd.contains("--unhealthy-threshold=3"))
    #expect(cmd.contains("--port=8080"))
    #expect(cmd.contains("--request-path=/health"))
    #expect(cmd.contains("--host=api.example.com"))
}

@Test func testHealthCheckHTTPS() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "https-hc",
        projectID: "test-project",
        type: .https,
        httpsHealthCheck: .init(port: 443, requestPath: "/healthz")
    )

    let cmd = healthCheck.createCommand
    #expect(cmd.contains("gcloud compute health-checks create https https-hc"))
    #expect(cmd.contains("--port=443"))
    #expect(cmd.contains("--request-path=/healthz"))
}

@Test func testHealthCheckTCP() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "tcp-hc",
        projectID: "test-project",
        type: .tcp,
        tcpHealthCheck: .init(port: 3306)
    )

    let cmd = healthCheck.createCommand
    #expect(cmd.contains("gcloud compute health-checks create tcp tcp-hc"))
    #expect(cmd.contains("--port=3306"))
}

@Test func testHealthCheckGRPC() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "grpc-hc",
        projectID: "test-project",
        type: .grpc,
        grpcHealthCheck: .init(port: 9090, grpcServiceName: "grpc.health.v1.Health")
    )

    let cmd = healthCheck.createCommand
    #expect(cmd.contains("gcloud compute health-checks create grpc grpc-hc"))
    #expect(cmd.contains("--port=9090"))
    #expect(cmd.contains("--grpc-service-name=grpc.health.v1.Health"))
}

@Test func testHealthCheckRegional() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "regional-hc",
        projectID: "test-project",
        type: .http,
        isGlobal: false,
        region: "us-central1"
    )

    #expect(healthCheck.resourceName == "projects/test-project/regions/us-central1/healthChecks/regional-hc")

    let cmd = healthCheck.createCommand
    #expect(cmd.contains("--region=us-central1"))
    #expect(!cmd.contains("--global"))
}

@Test func testHealthCheckDeleteCommand() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "to-delete-hc",
        projectID: "test-project",
        type: .http
    )

    let cmd = healthCheck.deleteCommand
    #expect(cmd.contains("gcloud compute health-checks delete to-delete-hc"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--quiet"))
}

@Test func testHealthCheckDescribeCommand() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "describe-hc",
        projectID: "test-project",
        type: .http
    )

    let cmd = healthCheck.describeCommand
    #expect(cmd.contains("gcloud compute health-checks describe describe-hc"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--global"))
}

@Test func testHealthCheckListCommand() {
    let cmd = GoogleCloudHealthCheck.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud compute health-checks list"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testHealthCheckHTTP2() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "http2-hc",
        projectID: "test-project",
        type: .http2,
        httpHealthCheck: .init(port: 443, requestPath: "/")
    )

    let cmd = healthCheck.createCommand
    #expect(cmd.contains("gcloud compute health-checks create http2 http2-hc"))
}

@Test func testHealthCheckSSL() {
    let healthCheck = GoogleCloudHealthCheck(
        name: "ssl-hc",
        projectID: "test-project",
        type: .ssl,
        tcpHealthCheck: .init(port: 443)
    )

    let cmd = healthCheck.createCommand
    #expect(cmd.contains("gcloud compute health-checks create ssl ssl-hc"))
}

// MARK: Backend Service Tests

@Test func testGoogleCloudBackendService() {
    let backendService = GoogleCloudBackendService(
        name: "my-backend",
        projectID: "test-project",
        protocol: .http,
        portName: "http",
        timeoutSec: 30,
        healthChecks: ["my-hc"],
        loadBalancingScheme: .external,
        sessionAffinity: .none,
        connectionDrainingTimeoutSec: 300
    )

    #expect(backendService.name == "my-backend")
    #expect(backendService.protocol == .http)
    #expect(backendService.timeoutSec == 30)
    #expect(backendService.resourceName == "projects/test-project/global/backendServices/my-backend")
}

@Test func testBackendServiceCreateCommand() {
    let backendService = GoogleCloudBackendService(
        name: "api-backend",
        projectID: "my-project",
        protocol: .https,
        portName: "https",
        timeoutSec: 60,
        healthChecks: ["api-hc"],
        description: "API backend service",
        loadBalancingScheme: .externalManaged,
        sessionAffinity: .clientIp,
        connectionDrainingTimeoutSec: 600
    )

    let cmd = backendService.createCommand
    #expect(cmd.contains("gcloud compute backend-services create api-backend"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--protocol=HTTPS"))
    #expect(cmd.contains("--timeout=60s"))
    #expect(cmd.contains("--connection-draining-timeout=600s"))
    #expect(cmd.contains("--port-name=https"))
    #expect(cmd.contains("--health-checks=api-hc"))
    #expect(cmd.contains("--global-health-checks"))
    #expect(cmd.contains("--load-balancing-scheme=EXTERNAL_MANAGED"))
    #expect(cmd.contains("--session-affinity=CLIENT_IP"))
}

@Test func testBackendServiceWithCDN() {
    let backendService = GoogleCloudBackendService(
        name: "cdn-backend",
        projectID: "test-project",
        protocol: .http,
        enableCDN: true,
        cdnPolicy: .init(cacheMode: .cacheAllStatic, defaultTtl: 3600, maxTtl: 86400)
    )

    let cmd = backendService.createCommand
    #expect(cmd.contains("--enable-cdn"))
}

@Test func testBackendServiceGRPC() {
    let backendService = GoogleCloudBackendService(
        name: "grpc-backend",
        projectID: "test-project",
        protocol: .grpc,
        portName: "grpc"
    )

    let cmd = backendService.createCommand
    #expect(cmd.contains("--protocol=GRPC"))
    #expect(cmd.contains("--port-name=grpc"))
}

@Test func testBackendServiceRegional() {
    let backendService = GoogleCloudBackendService(
        name: "regional-backend",
        projectID: "test-project",
        protocol: .http,
        loadBalancingScheme: .internal,
        isGlobal: false,
        region: "us-central1"
    )

    #expect(backendService.resourceName == "projects/test-project/regions/us-central1/backendServices/regional-backend")

    let cmd = backendService.createCommand
    #expect(cmd.contains("--region=us-central1"))
    #expect(!cmd.contains("--global"))
}

@Test func testBackendServiceAddBackendInstanceGroup() {
    let backendService = GoogleCloudBackendService(
        name: "test-backend",
        projectID: "test-project",
        protocol: .http
    )

    let backend = GoogleCloudBackendService.Backend(
        group: .instanceGroup(name: "my-ig", zone: "us-central1-a"),
        balancingMode: .rate,
        capacityScaler: 0.8,
        maxRatePerInstance: 100.0
    )

    let cmd = backendService.addBackendCommand(backend: backend)
    #expect(cmd.contains("gcloud compute backend-services add-backend test-backend"))
    #expect(cmd.contains("--instance-group=my-ig"))
    #expect(cmd.contains("--instance-group-zone=us-central1-a"))
    #expect(cmd.contains("--balancing-mode=RATE"))
    #expect(cmd.contains("--capacity-scaler=0.8"))
    #expect(cmd.contains("--max-rate-per-instance=100.0"))
}

@Test func testBackendServiceAddBackendNEG() {
    let backendService = GoogleCloudBackendService(
        name: "test-backend",
        projectID: "test-project",
        protocol: .http
    )

    let backend = GoogleCloudBackendService.Backend(
        group: .networkEndpointGroup(name: "my-neg", zone: "us-central1-a"),
        balancingMode: .rate,
        maxRate: 10000
    )

    let cmd = backendService.addBackendCommand(backend: backend)
    #expect(cmd.contains("--network-endpoint-group=my-neg"))
    #expect(cmd.contains("--network-endpoint-group-zone=us-central1-a"))
    #expect(cmd.contains("--max-rate=10000"))
}

@Test func testBackendServiceAddBackendServerlessNEG() {
    let backendService = GoogleCloudBackendService(
        name: "test-backend",
        projectID: "test-project",
        protocol: .http
    )

    let backend = GoogleCloudBackendService.Backend(
        group: .serverlessNEG(name: "cloudrun-neg", region: "us-central1")
    )

    let cmd = backendService.addBackendCommand(backend: backend)
    #expect(cmd.contains("--network-endpoint-group=cloudrun-neg"))
    #expect(cmd.contains("--network-endpoint-group-region=us-central1"))
}

@Test func testBackendServiceDeleteCommand() {
    let backendService = GoogleCloudBackendService(
        name: "to-delete",
        projectID: "test-project",
        protocol: .http
    )

    let cmd = backendService.deleteCommand
    #expect(cmd.contains("gcloud compute backend-services delete to-delete"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--quiet"))
}

@Test func testBackendServiceDescribeCommand() {
    let backendService = GoogleCloudBackendService(
        name: "describe-backend",
        projectID: "test-project",
        protocol: .http
    )

    let cmd = backendService.describeCommand
    #expect(cmd.contains("gcloud compute backend-services describe describe-backend"))
}

@Test func testBackendServiceListCommand() {
    let cmd = GoogleCloudBackendService.listCommand(projectID: "test-project", global: true)
    #expect(cmd.contains("gcloud compute backend-services list"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--global"))
}

// MARK: URL Map Tests

@Test func testGoogleCloudURLMap() {
    let urlMap = GoogleCloudURLMap(
        name: "my-url-map",
        projectID: "test-project",
        defaultService: "default-backend",
        description: "My URL map"
    )

    #expect(urlMap.name == "my-url-map")
    #expect(urlMap.defaultService == "default-backend")
    #expect(urlMap.resourceName == "projects/test-project/global/urlMaps/my-url-map")
}

@Test func testURLMapCreateCommand() {
    let urlMap = GoogleCloudURLMap(
        name: "api-url-map",
        projectID: "my-project",
        defaultService: "api-backend",
        description: "API routing"
    )

    let cmd = urlMap.createCommand
    #expect(cmd.contains("gcloud compute url-maps create api-url-map"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--default-service=api-backend"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--description=\"API routing\""))
}

@Test func testURLMapAddPathMatcher() {
    let urlMap = GoogleCloudURLMap(
        name: "my-url-map",
        projectID: "test-project",
        defaultService: "default-backend"
    )

    let pathMatcher = GoogleCloudURLMap.PathMatcher(
        name: "api-paths",
        defaultService: "api-backend",
        pathRules: [
            .init(paths: ["/api/v1/*"], service: "api-v1-backend"),
            .init(paths: ["/api/v2/*"], service: "api-v2-backend")
        ]
    )

    let cmd = urlMap.addPathMatcherCommand(pathMatcher: pathMatcher, hosts: ["api.example.com"])
    #expect(cmd.contains("gcloud compute url-maps add-path-matcher my-url-map"))
    #expect(cmd.contains("--path-matcher-name=api-paths"))
    #expect(cmd.contains("--default-service=api-backend"))
    #expect(cmd.contains("--new-hosts=api.example.com"))
    #expect(cmd.contains("--path-rules="))
}

@Test func testURLMapRegional() {
    let urlMap = GoogleCloudURLMap(
        name: "regional-url-map",
        projectID: "test-project",
        defaultService: "backend",
        isGlobal: false,
        region: "us-central1"
    )

    #expect(urlMap.resourceName == "projects/test-project/regions/us-central1/urlMaps/regional-url-map")

    let cmd = urlMap.createCommand
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testURLMapDeleteCommand() {
    let urlMap = GoogleCloudURLMap(
        name: "to-delete",
        projectID: "test-project",
        defaultService: "backend"
    )

    let cmd = urlMap.deleteCommand
    #expect(cmd.contains("gcloud compute url-maps delete to-delete"))
    #expect(cmd.contains("--quiet"))
}

@Test func testURLMapDescribeCommand() {
    let urlMap = GoogleCloudURLMap(
        name: "describe-map",
        projectID: "test-project",
        defaultService: "backend"
    )

    let cmd = urlMap.describeCommand
    #expect(cmd.contains("gcloud compute url-maps describe describe-map"))
}

@Test func testURLMapListCommand() {
    let cmd = GoogleCloudURLMap.listCommand(projectID: "test-project", global: true)
    #expect(cmd.contains("gcloud compute url-maps list"))
    #expect(cmd.contains("--global"))
}

// MARK: Target Proxy Tests

@Test func testGoogleCloudTargetProxyHTTP() {
    let proxy = GoogleCloudTargetProxy(
        name: "http-proxy",
        projectID: "test-project",
        type: .http,
        urlMap: "my-url-map"
    )

    #expect(proxy.name == "http-proxy")
    #expect(proxy.type == .http)
    #expect(proxy.resourceName.contains("targetHttpProxies"))
}

@Test func testTargetProxyHTTPCreateCommand() {
    let proxy = GoogleCloudTargetProxy(
        name: "http-proxy",
        projectID: "my-project",
        type: .http,
        urlMap: "my-url-map",
        description: "HTTP proxy"
    )

    let cmd = proxy.createCommand
    #expect(cmd.contains("gcloud compute target-http-proxies create http-proxy"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--url-map=my-url-map"))
    #expect(cmd.contains("--global-url-map"))
}

@Test func testTargetProxyHTTPSCreateCommand() {
    let proxy = GoogleCloudTargetProxy(
        name: "https-proxy",
        projectID: "my-project",
        type: .https,
        urlMap: "my-url-map",
        sslCertificates: ["my-cert"],
        sslPolicy: "my-ssl-policy"
    )

    let cmd = proxy.createCommand
    #expect(cmd.contains("gcloud compute target-https-proxies create https-proxy"))
    #expect(cmd.contains("--url-map=my-url-map"))
    #expect(cmd.contains("--ssl-certificates=my-cert"))
    #expect(cmd.contains("--ssl-policy=my-ssl-policy"))
}

@Test func testTargetProxyHTTPSMultipleCerts() {
    let proxy = GoogleCloudTargetProxy(
        name: "multi-cert-proxy",
        projectID: "test-project",
        type: .https,
        urlMap: "url-map",
        sslCertificates: ["cert1", "cert2", "cert3"]
    )

    let cmd = proxy.createCommand
    #expect(cmd.contains("--ssl-certificates=cert1,cert2,cert3"))
}

@Test func testTargetProxyTCP() {
    let proxy = GoogleCloudTargetProxy(
        name: "tcp-proxy",
        projectID: "test-project",
        type: .tcp,
        backendService: "tcp-backend"
    )

    let cmd = proxy.createCommand
    #expect(cmd.contains("gcloud compute target-tcp-proxies create tcp-proxy"))
    #expect(cmd.contains("--backend-service=tcp-backend"))
}

@Test func testTargetProxySSL() {
    let proxy = GoogleCloudTargetProxy(
        name: "ssl-proxy",
        projectID: "test-project",
        type: .ssl,
        sslCertificates: ["my-cert"],
        backendService: "ssl-backend"
    )

    let cmd = proxy.createCommand
    #expect(cmd.contains("gcloud compute target-ssl-proxies create ssl-proxy"))
    #expect(cmd.contains("--backend-service=ssl-backend"))
    #expect(cmd.contains("--ssl-certificates=my-cert"))
}

@Test func testTargetProxyGRPC() {
    let proxy = GoogleCloudTargetProxy(
        name: "grpc-proxy",
        projectID: "test-project",
        type: .grpc,
        urlMap: "grpc-url-map"
    )

    let cmd = proxy.createCommand
    #expect(cmd.contains("gcloud compute target-grpc-proxies create grpc-proxy"))
    #expect(cmd.contains("--url-map=grpc-url-map"))
}

@Test func testTargetProxyRegional() {
    let proxy = GoogleCloudTargetProxy(
        name: "regional-proxy",
        projectID: "test-project",
        type: .http,
        urlMap: "regional-url-map",
        isGlobal: false,
        region: "us-central1"
    )

    let cmd = proxy.createCommand
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testTargetProxyDeleteCommand() {
    let proxy = GoogleCloudTargetProxy(
        name: "to-delete",
        projectID: "test-project",
        type: .https,
        urlMap: "url-map",
        sslCertificates: ["cert"]
    )

    let cmd = proxy.deleteCommand
    #expect(cmd.contains("gcloud compute target-https-proxies delete to-delete"))
    #expect(cmd.contains("--quiet"))
}

// MARK: Forwarding Rule Tests

@Test func testGoogleCloudForwardingRule() {
    let rule = GoogleCloudForwardingRule(
        name: "https-rule",
        projectID: "test-project",
        ipProtocol: .tcp,
        portRange: "443",
        target: "https-proxy",
        loadBalancingScheme: .external
    )

    #expect(rule.name == "https-rule")
    #expect(rule.ipProtocol == .tcp)
    #expect(rule.portRange == "443")
    #expect(rule.resourceName == "projects/test-project/global/forwardingRules/https-rule")
}

@Test func testForwardingRuleCreateCommand() {
    let rule = GoogleCloudForwardingRule(
        name: "api-https-rule",
        projectID: "my-project",
        ipAddress: "34.120.0.1",
        ipProtocol: .tcp,
        portRange: "443",
        target: "https-proxy",
        loadBalancingScheme: .externalManaged,
        description: "HTTPS forwarding rule",
        networkTier: .premium
    )

    let cmd = rule.createCommand
    #expect(cmd.contains("gcloud compute forwarding-rules create api-https-rule"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--address=34.120.0.1"))
    #expect(cmd.contains("--ports=443"))
    #expect(cmd.contains("--load-balancing-scheme=EXTERNAL_MANAGED"))
    #expect(cmd.contains("--network-tier=PREMIUM"))
}

@Test func testForwardingRuleHTTP() {
    let rule = GoogleCloudForwardingRule(
        name: "http-rule",
        projectID: "test-project",
        portRange: "80",
        target: "http-proxy"
    )

    let cmd = rule.createCommand
    #expect(cmd.contains("--ports=80"))
}

@Test func testForwardingRuleRegional() {
    let rule = GoogleCloudForwardingRule(
        name: "regional-rule",
        projectID: "test-project",
        target: "regional-proxy",
        loadBalancingScheme: .internal,
        network: "my-vpc",
        subnetwork: "my-subnet",
        isGlobal: false,
        region: "us-central1",
        allowGlobalAccess: true
    )

    #expect(rule.resourceName == "projects/test-project/regions/us-central1/forwardingRules/regional-rule")

    let cmd = rule.createCommand
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--network=my-vpc"))
    #expect(cmd.contains("--subnet=my-subnet"))
    #expect(cmd.contains("--allow-global-access"))
}

@Test func testForwardingRuleWithPorts() {
    let rule = GoogleCloudForwardingRule(
        name: "multi-port-rule",
        projectID: "test-project",
        ports: ["80", "443", "8080"],
        target: "proxy",
        loadBalancingScheme: .internal,
        isGlobal: false,
        region: "us-central1"
    )

    let cmd = rule.createCommand
    #expect(cmd.contains("--ports=80,443,8080"))
}

@Test func testForwardingRuleDeleteCommand() {
    let rule = GoogleCloudForwardingRule(
        name: "to-delete",
        projectID: "test-project",
        target: "proxy"
    )

    let cmd = rule.deleteCommand
    #expect(cmd.contains("gcloud compute forwarding-rules delete to-delete"))
    #expect(cmd.contains("--quiet"))
}

@Test func testForwardingRuleDescribeCommand() {
    let rule = GoogleCloudForwardingRule(
        name: "describe-rule",
        projectID: "test-project",
        target: "proxy"
    )

    let cmd = rule.describeCommand
    #expect(cmd.contains("gcloud compute forwarding-rules describe describe-rule"))
}

@Test func testForwardingRuleListCommand() {
    let cmd = GoogleCloudForwardingRule.listCommand(projectID: "test-project", global: true)
    #expect(cmd.contains("gcloud compute forwarding-rules list"))
    #expect(cmd.contains("--global"))
}

@Test func testForwardingRuleNetworkTierStandard() {
    let rule = GoogleCloudForwardingRule(
        name: "standard-tier-rule",
        projectID: "test-project",
        target: "proxy",
        networkTier: .standard
    )

    let cmd = rule.createCommand
    #expect(cmd.contains("--network-tier=STANDARD"))
}

// MARK: SSL Certificate Tests

@Test func testGoogleCloudSSLCertificateManaged() {
    let cert = GoogleCloudSSLCertificate(
        name: "my-cert",
        projectID: "test-project",
        type: .managed,
        domains: ["example.com", "www.example.com"],
        description: "Managed certificate"
    )

    #expect(cert.name == "my-cert")
    #expect(cert.type == .managed)
    #expect(cert.domains.count == 2)
    #expect(cert.resourceName == "projects/test-project/global/sslCertificates/my-cert")
}

@Test func testSSLCertificateManagedCreateCommand() {
    let cert = GoogleCloudSSLCertificate(
        name: "api-cert",
        projectID: "my-project",
        type: .managed,
        domains: ["api.example.com", "www.api.example.com"],
        description: "API certificate"
    )

    let cmd = cert.createCommand
    #expect(cmd.contains("gcloud compute ssl-certificates create api-cert"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--domains=api.example.com,www.api.example.com"))
}

@Test func testSSLCertificateSelfManaged() {
    let cert = GoogleCloudSSLCertificate(
        name: "self-cert",
        projectID: "test-project",
        type: .selfManaged,
        certificatePath: "/path/to/cert.pem",
        privateKeyPath: "/path/to/key.pem"
    )

    let cmd = cert.createCommand
    #expect(cmd.contains("gcloud compute ssl-certificates create self-cert"))
    #expect(cmd.contains("--certificate=/path/to/cert.pem"))
    #expect(cmd.contains("--private-key=/path/to/key.pem"))
}

@Test func testSSLCertificateRegional() {
    let cert = GoogleCloudSSLCertificate(
        name: "regional-cert",
        projectID: "test-project",
        type: .managed,
        domains: ["example.com"],
        isGlobal: false,
        region: "us-central1"
    )

    #expect(cert.resourceName == "projects/test-project/regions/us-central1/sslCertificates/regional-cert")

    let cmd = cert.createCommand
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testSSLCertificateDeleteCommand() {
    let cert = GoogleCloudSSLCertificate(
        name: "to-delete",
        projectID: "test-project",
        type: .managed,
        domains: ["example.com"]
    )

    let cmd = cert.deleteCommand
    #expect(cmd.contains("gcloud compute ssl-certificates delete to-delete"))
    #expect(cmd.contains("--quiet"))
}

@Test func testSSLCertificateDescribeCommand() {
    let cert = GoogleCloudSSLCertificate(
        name: "describe-cert",
        projectID: "test-project",
        type: .managed,
        domains: ["example.com"]
    )

    let cmd = cert.describeCommand
    #expect(cmd.contains("gcloud compute ssl-certificates describe describe-cert"))
}

@Test func testSSLCertificateListCommand() {
    let cmd = GoogleCloudSSLCertificate.listCommand(projectID: "test-project", global: true)
    #expect(cmd.contains("gcloud compute ssl-certificates list"))
    #expect(cmd.contains("--global"))
}

// MARK: SSL Policy Tests

@Test func testGoogleCloudSSLPolicy() {
    let policy = GoogleCloudSSLPolicy(
        name: "my-ssl-policy",
        projectID: "test-project",
        minTlsVersion: .tls12,
        profile: .modern,
        description: "Modern SSL policy"
    )

    #expect(policy.name == "my-ssl-policy")
    #expect(policy.minTlsVersion == .tls12)
    #expect(policy.profile == .modern)
    #expect(policy.resourceName == "projects/test-project/global/sslPolicies/my-ssl-policy")
}

@Test func testSSLPolicyCreateCommand() {
    let policy = GoogleCloudSSLPolicy(
        name: "secure-policy",
        projectID: "my-project",
        minTlsVersion: .tls12,
        profile: .modern,
        description: "Secure TLS policy"
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("gcloud compute ssl-policies create secure-policy"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--min-tls-version=TLS_1_2"))
    #expect(cmd.contains("--profile=MODERN"))
}

@Test func testSSLPolicyRestricted() {
    let policy = GoogleCloudSSLPolicy(
        name: "restricted-policy",
        projectID: "test-project",
        minTlsVersion: .tls13,
        profile: .restricted
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("--min-tls-version=TLS_1_3"))
    #expect(cmd.contains("--profile=RESTRICTED"))
}

@Test func testSSLPolicyCustom() {
    let policy = GoogleCloudSSLPolicy(
        name: "custom-policy",
        projectID: "test-project",
        minTlsVersion: .tls12,
        profile: .custom,
        customFeatures: ["TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"]
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("--profile=CUSTOM"))
    #expect(cmd.contains("--custom-features=TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"))
}

@Test func testSSLPolicyCompatible() {
    let policy = GoogleCloudSSLPolicy(
        name: "compat-policy",
        projectID: "test-project",
        minTlsVersion: .tls10,
        profile: .compatible
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("--min-tls-version=TLS_1_0"))
    #expect(cmd.contains("--profile=COMPATIBLE"))
}

@Test func testSSLPolicyDeleteCommand() {
    let policy = GoogleCloudSSLPolicy(
        name: "to-delete",
        projectID: "test-project",
        minTlsVersion: .tls12,
        profile: .modern
    )

    let cmd = policy.deleteCommand
    #expect(cmd.contains("gcloud compute ssl-policies delete to-delete"))
    #expect(cmd.contains("--quiet"))
}

@Test func testSSLPolicyDescribeCommand() {
    let policy = GoogleCloudSSLPolicy(
        name: "describe-policy",
        projectID: "test-project",
        minTlsVersion: .tls12,
        profile: .modern
    )

    let cmd = policy.describeCommand
    #expect(cmd.contains("gcloud compute ssl-policies describe describe-policy"))
}

@Test func testSSLPolicyListCommand() {
    let cmd = GoogleCloudSSLPolicy.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud compute ssl-policies list"))
}

// MARK: Network Endpoint Group Tests

@Test func testGoogleCloudNEGZonalGCE() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "my-neg",
        projectID: "test-project",
        type: .zonalGCE,
        network: "my-vpc",
        subnetwork: "my-subnet",
        defaultPort: 8080,
        zone: "us-central1-a"
    )

    #expect(neg.name == "my-neg")
    #expect(neg.type == .zonalGCE)
    #expect(neg.resourceName == "projects/test-project/zones/us-central1-a/networkEndpointGroups/my-neg")
}

@Test func testNEGZonalGCECreateCommand() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "gce-neg",
        projectID: "my-project",
        type: .zonalGCE,
        network: "my-vpc",
        subnetwork: "my-subnet",
        defaultPort: 80,
        zone: "us-central1-a",
        description: "GCE VM NEG"
    )

    let cmd = neg.createCommand
    #expect(cmd.contains("gcloud compute network-endpoint-groups create gce-neg"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--zone=us-central1-a"))
    #expect(cmd.contains("--network-endpoint-type=GCE_VM_IP_PORT"))
    #expect(cmd.contains("--network=my-vpc"))
    #expect(cmd.contains("--subnet=my-subnet"))
    #expect(cmd.contains("--default-port=80"))
}

@Test func testNEGZonalNonGCP() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "external-neg",
        projectID: "test-project",
        type: .zonalNonGCP,
        network: "my-vpc",
        zone: "us-central1-a"
    )

    let cmd = neg.createCommand
    #expect(cmd.contains("--network-endpoint-type=NON_GCP_PRIVATE_IP_PORT"))
}

@Test func testNEGServerlessCloudRun() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "cloudrun-neg",
        projectID: "test-project",
        type: .serverless,
        region: "us-central1",
        cloudRunService: "my-service"
    )

    #expect(neg.resourceName == "projects/test-project/regions/us-central1/networkEndpointGroups/cloudrun-neg")

    let cmd = neg.createCommand
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--network-endpoint-type=SERVERLESS"))
    #expect(cmd.contains("--cloud-run-service=my-service"))
}

@Test func testNEGServerlessCloudFunctions() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "functions-neg",
        projectID: "test-project",
        type: .serverless,
        region: "us-central1",
        cloudFunction: "my-function"
    )

    let cmd = neg.createCommand
    #expect(cmd.contains("--cloud-function-name=my-function"))
}

@Test func testNEGServerlessAppEngine() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "appengine-neg",
        projectID: "test-project",
        type: .serverless,
        region: "us-central1",
        appEngineService: "default"
    )

    let cmd = neg.createCommand
    #expect(cmd.contains("--app-engine-service=default"))
}

@Test func testNEGInternet() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "internet-neg",
        projectID: "test-project",
        type: .internet
    )

    #expect(neg.resourceName == "projects/test-project/global/networkEndpointGroups/internet-neg")

    let cmd = neg.createCommand
    #expect(cmd.contains("--global"))
    #expect(cmd.contains("--network-endpoint-type=INTERNET_FQDN_PORT"))
}

@Test func testNEGPrivateServiceConnect() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "psc-neg",
        projectID: "test-project",
        type: .privateServiceConnect,
        subnetwork: "target-service-attachment",
        region: "us-central1"
    )

    let cmd = neg.createCommand
    #expect(cmd.contains("--network-endpoint-type=PRIVATE_SERVICE_CONNECT"))
    #expect(cmd.contains("--psc-target-service=target-service-attachment"))
}

@Test func testNEGDeleteCommand() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "to-delete",
        projectID: "test-project",
        type: .serverless,
        region: "us-central1"
    )

    let cmd = neg.deleteCommand
    #expect(cmd.contains("gcloud compute network-endpoint-groups delete to-delete"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--quiet"))
}

@Test func testNEGDeleteZonal() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "zonal-neg",
        projectID: "test-project",
        type: .zonalGCE,
        zone: "us-central1-a"
    )

    let cmd = neg.deleteCommand
    #expect(cmd.contains("--zone=us-central1-a"))
}

@Test func testNEGDeleteGlobal() {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "global-neg",
        projectID: "test-project",
        type: .internet
    )

    let cmd = neg.deleteCommand
    #expect(cmd.contains("--global"))
}

@Test func testNEGListCommand() {
    let cmd = GoogleCloudNetworkEndpointGroup.listCommand(projectID: "test-project", zone: "us-central1-a")
    #expect(cmd.contains("gcloud compute network-endpoint-groups list"))
    #expect(cmd.contains("--zones=us-central1-a"))
}

@Test func testNEGListCommandRegional() {
    let cmd = GoogleCloudNetworkEndpointGroup.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd.contains("--regions=us-central1"))
}

// MARK: DAIS Load Balancing Template Tests

@Test func testDAISLoadBalancingTemplateHTTPHealthCheck() {
    let healthCheck = DAISLoadBalancingTemplate.httpHealthCheck(
        projectID: "test-project",
        deploymentName: "dais-prod",
        port: 8080,
        path: "/health"
    )

    #expect(healthCheck.name == "dais-prod-http-hc")
    #expect(healthCheck.type == .http)
    #expect(healthCheck.httpHealthCheck?.port == 8080)
    #expect(healthCheck.httpHealthCheck?.requestPath == "/health")
    #expect(healthCheck.description == "HTTP health check for dais-prod")
}

@Test func testDAISLoadBalancingTemplateGRPCHealthCheck() {
    let healthCheck = DAISLoadBalancingTemplate.grpcHealthCheck(
        projectID: "test-project",
        deploymentName: "dais-prod",
        port: 9090
    )

    #expect(healthCheck.name == "dais-prod-grpc-hc")
    #expect(healthCheck.type == .grpc)
    #expect(healthCheck.grpcHealthCheck?.port == 9090)
    #expect(healthCheck.grpcHealthCheck?.grpcServiceName == "grpc.health.v1.Health")
}

@Test func testDAISLoadBalancingTemplateHTTPBackendService() {
    let backendService = DAISLoadBalancingTemplate.httpBackendService(
        projectID: "test-project",
        deploymentName: "dais-prod",
        healthCheckName: "dais-prod-http-hc"
    )

    #expect(backendService.name == "dais-prod-http-backend")
    #expect(backendService.protocol == .http)
    #expect(backendService.portName == "http")
    #expect(backendService.healthChecks.contains("dais-prod-http-hc"))
    #expect(backendService.loadBalancingScheme == .externalManaged)
    #expect(backendService.logConfig?.enable == true)
}

@Test func testDAISLoadBalancingTemplateGRPCBackendService() {
    let backendService = DAISLoadBalancingTemplate.grpcBackendService(
        projectID: "test-project",
        deploymentName: "dais-prod",
        healthCheckName: "dais-prod-grpc-hc"
    )

    #expect(backendService.name == "dais-prod-grpc-backend")
    #expect(backendService.protocol == .grpc)
    #expect(backendService.portName == "grpc")
    #expect(backendService.timeoutSec == 60)
}

@Test func testDAISLoadBalancingTemplateURLMap() {
    let urlMap = DAISLoadBalancingTemplate.urlMap(
        projectID: "test-project",
        deploymentName: "dais-prod",
        defaultBackendService: "dais-prod-http-backend"
    )

    #expect(urlMap.name == "dais-prod-url-map")
    #expect(urlMap.defaultService == "dais-prod-http-backend")
    #expect(urlMap.description == "URL map for dais-prod")
}

@Test func testDAISLoadBalancingTemplateSSLCertificate() {
    let cert = DAISLoadBalancingTemplate.sslCertificate(
        projectID: "test-project",
        deploymentName: "dais-prod",
        domains: ["api.example.com", "www.example.com"]
    )

    #expect(cert.name == "dais-prod-cert")
    #expect(cert.type == .managed)
    #expect(cert.domains.count == 2)
    #expect(cert.domains.contains("api.example.com"))
}

@Test func testDAISLoadBalancingTemplateSSLPolicy() {
    let policy = DAISLoadBalancingTemplate.sslPolicy(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(policy.name == "dais-prod-ssl-policy")
    #expect(policy.minTlsVersion == .tls12)
    #expect(policy.profile == .modern)
}

@Test func testDAISLoadBalancingTemplateHTTPSTargetProxy() {
    let proxy = DAISLoadBalancingTemplate.httpsTargetProxy(
        projectID: "test-project",
        deploymentName: "dais-prod",
        urlMapName: "dais-prod-url-map",
        sslCertificateName: "dais-prod-cert",
        sslPolicyName: "dais-prod-ssl-policy"
    )

    #expect(proxy.name == "dais-prod-https-proxy")
    #expect(proxy.type == .https)
    #expect(proxy.urlMap == "dais-prod-url-map")
    #expect(proxy.sslCertificates.contains("dais-prod-cert"))
    #expect(proxy.sslPolicy == "dais-prod-ssl-policy")
}

@Test func testDAISLoadBalancingTemplateHTTPTargetProxy() {
    let proxy = DAISLoadBalancingTemplate.httpTargetProxy(
        projectID: "test-project",
        deploymentName: "dais-prod",
        urlMapName: "dais-prod-url-map"
    )

    #expect(proxy.name == "dais-prod-http-proxy")
    #expect(proxy.type == .http)
    #expect(proxy.description == "HTTP proxy for dais-prod (redirect)")
}

@Test func testDAISLoadBalancingTemplateHTTPSForwardingRule() {
    let rule = DAISLoadBalancingTemplate.httpsForwardingRule(
        projectID: "test-project",
        deploymentName: "dais-prod",
        targetProxyName: "dais-prod-https-proxy",
        ipAddress: "34.120.0.1"
    )

    #expect(rule.name == "dais-prod-https-rule")
    #expect(rule.portRange == "443")
    #expect(rule.target == "dais-prod-https-proxy")
    #expect(rule.ipAddress == "34.120.0.1")
    #expect(rule.loadBalancingScheme == .externalManaged)
    #expect(rule.networkTier == .premium)
}

@Test func testDAISLoadBalancingTemplateHTTPForwardingRule() {
    let rule = DAISLoadBalancingTemplate.httpForwardingRule(
        projectID: "test-project",
        deploymentName: "dais-prod",
        targetProxyName: "dais-prod-http-proxy"
    )

    #expect(rule.name == "dais-prod-http-rule")
    #expect(rule.portRange == "80")
}

@Test func testDAISLoadBalancingTemplateCloudRunNEG() {
    let neg = DAISLoadBalancingTemplate.cloudRunNEG(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1",
        cloudRunServiceName: "my-service"
    )

    #expect(neg.name == "dais-prod-cloudrun-neg")
    #expect(neg.type == .serverless)
    #expect(neg.region == "us-central1")
    #expect(neg.cloudRunService == "my-service")
    #expect(neg.description == "Serverless NEG for Cloud Run service")
}

@Test func testDAISLoadBalancingTemplateSetupScript() {
    let script = DAISLoadBalancingTemplate.setupScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        domains: ["api.example.com"],
        cloudRunServiceName: "api-service",
        region: "us-central1"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("DAIS Load Balancer Setup Script"))
    #expect(script.contains("dais-prod"))
    #expect(script.contains("api.example.com"))
    #expect(script.contains("gcloud compute addresses create dais-prod-ip"))
    #expect(script.contains("gcloud compute network-endpoint-groups create dais-prod-cloudrun-neg"))
    #expect(script.contains("gcloud compute health-checks create http dais-prod-http-hc"))
    #expect(script.contains("gcloud compute backend-services create dais-prod-http-backend"))
    #expect(script.contains("gcloud compute url-maps create dais-prod-url-map"))
    #expect(script.contains("gcloud compute ssl-certificates create dais-prod-cert"))
    #expect(script.contains("gcloud compute ssl-policies create dais-prod-ssl-policy"))
    #expect(script.contains("gcloud compute target-https-proxies create dais-prod-https-proxy"))
    #expect(script.contains("Load Balancer Setup Complete!"))
}

@Test func testDAISLoadBalancingTemplateTeardownScript() {
    let script = DAISLoadBalancingTemplate.teardownScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        region: "us-central1"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("DAIS Load Balancer Teardown Script"))
    #expect(script.contains("Deleting forwarding rules"))
    #expect(script.contains("gcloud compute forwarding-rules delete dais-prod-https-rule"))
    #expect(script.contains("Deleting target proxies"))
    #expect(script.contains("Deleting SSL policy"))
    #expect(script.contains("Deleting SSL certificate"))
    #expect(script.contains("Deleting URL map"))
    #expect(script.contains("Deleting backend service"))
    #expect(script.contains("Deleting health checks"))
    #expect(script.contains("Deleting serverless NEG"))
    #expect(script.contains("Releasing static IP"))
    #expect(script.contains("Load balancer teardown complete!"))
}

// MARK: Load Balancing Codable Tests

@Test func testHealthCheckCodable() throws {
    let healthCheck = GoogleCloudHealthCheck(
        name: "test-hc",
        projectID: "test-project",
        type: .http,
        httpHealthCheck: .init(port: 8080, requestPath: "/health")
    )
    let data = try JSONEncoder().encode(healthCheck)
    let decoded = try JSONDecoder().decode(GoogleCloudHealthCheck.self, from: data)

    #expect(decoded.name == healthCheck.name)
    #expect(decoded.type == healthCheck.type)
    #expect(decoded.httpHealthCheck?.port == 8080)
}

@Test func testBackendServiceCodable() throws {
    let backendService = GoogleCloudBackendService(
        name: "test-backend",
        projectID: "test-project",
        protocol: .http,
        healthChecks: ["test-hc"]
    )
    let data = try JSONEncoder().encode(backendService)
    let decoded = try JSONDecoder().decode(GoogleCloudBackendService.self, from: data)

    #expect(decoded.name == backendService.name)
    #expect(decoded.protocol == .http)
}

@Test func testURLMapCodable() throws {
    let urlMap = GoogleCloudURLMap(
        name: "test-url-map",
        projectID: "test-project",
        defaultService: "default-backend"
    )
    let data = try JSONEncoder().encode(urlMap)
    let decoded = try JSONDecoder().decode(GoogleCloudURLMap.self, from: data)

    #expect(decoded.name == urlMap.name)
    #expect(decoded.defaultService == urlMap.defaultService)
}

@Test func testTargetProxyCodable() throws {
    let proxy = GoogleCloudTargetProxy(
        name: "test-proxy",
        projectID: "test-project",
        type: .https,
        urlMap: "test-url-map",
        sslCertificates: ["test-cert"]
    )
    let data = try JSONEncoder().encode(proxy)
    let decoded = try JSONDecoder().decode(GoogleCloudTargetProxy.self, from: data)

    #expect(decoded.name == proxy.name)
    #expect(decoded.type == .https)
}

@Test func testForwardingRuleCodable() throws {
    let rule = GoogleCloudForwardingRule(
        name: "test-rule",
        projectID: "test-project",
        portRange: "443",
        target: "test-proxy"
    )
    let data = try JSONEncoder().encode(rule)
    let decoded = try JSONDecoder().decode(GoogleCloudForwardingRule.self, from: data)

    #expect(decoded.name == rule.name)
    #expect(decoded.portRange == "443")
}

@Test func testSSLCertificateCodable() throws {
    let cert = GoogleCloudSSLCertificate(
        name: "test-cert",
        projectID: "test-project",
        type: .managed,
        domains: ["example.com"]
    )
    let data = try JSONEncoder().encode(cert)
    let decoded = try JSONDecoder().decode(GoogleCloudSSLCertificate.self, from: data)

    #expect(decoded.name == cert.name)
    #expect(decoded.type == .managed)
    #expect(decoded.domains == ["example.com"])
}

@Test func testSSLPolicyCodable() throws {
    let policy = GoogleCloudSSLPolicy(
        name: "test-policy",
        projectID: "test-project",
        minTlsVersion: .tls12,
        profile: .modern
    )
    let data = try JSONEncoder().encode(policy)
    let decoded = try JSONDecoder().decode(GoogleCloudSSLPolicy.self, from: data)

    #expect(decoded.name == policy.name)
    #expect(decoded.minTlsVersion == .tls12)
    #expect(decoded.profile == .modern)
}

@Test func testNEGCodable() throws {
    let neg = GoogleCloudNetworkEndpointGroup(
        name: "test-neg",
        projectID: "test-project",
        type: .serverless,
        region: "us-central1",
        cloudRunService: "my-service"
    )
    let data = try JSONEncoder().encode(neg)
    let decoded = try JSONDecoder().decode(GoogleCloudNetworkEndpointGroup.self, from: data)

    #expect(decoded.name == neg.name)
    #expect(decoded.type == .serverless)
    #expect(decoded.cloudRunService == "my-service")
}

// MARK: - Artifact Registry Tests

// MARK: Repository Tests

@Test func testGoogleCloudArtifactRegistryRepository() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "my-docker-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker,
        description: "My Docker repository",
        labels: ["env": "production"]
    )

    #expect(repo.name == "my-docker-repo")
    #expect(repo.format == .docker)
    #expect(repo.location == "us-central1")
    #expect(repo.resourceName == "projects/test-project/locations/us-central1/repositories/my-docker-repo")
    #expect(repo.dockerHost == "us-central1-docker.pkg.dev")
    #expect(repo.dockerImagePrefix == "us-central1-docker.pkg.dev/test-project/my-docker-repo")
}

@Test func testRepositoryCreateCommand() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "docker-repo",
        projectID: "my-project",
        location: "us-west1",
        format: .docker,
        description: "Docker images",
        labels: ["app": "dais"]
    )

    let cmd = repo.createCommand
    #expect(cmd.contains("gcloud artifacts repositories create docker-repo"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--location=us-west1"))
    #expect(cmd.contains("--repository-format=docker"))
    #expect(cmd.contains("--description=\"Docker images\""))
    #expect(cmd.contains("--labels=app=dais"))
}

@Test func testRepositoryMavenFormat() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "maven-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .maven
    )

    #expect(repo.mavenRepositoryURL == "https://us-central1-maven.pkg.dev/test-project/maven-repo")

    let cmd = repo.createCommand
    #expect(cmd.contains("--repository-format=maven"))
}

@Test func testRepositoryNpmFormat() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "npm-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .npm
    )

    #expect(repo.npmRegistryURL == "https://us-central1-npm.pkg.dev/test-project/npm-repo")

    let cmd = repo.createCommand
    #expect(cmd.contains("--repository-format=npm"))
}

@Test func testRepositoryPythonFormat() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "python-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .python
    )

    #expect(repo.pythonRepositoryURL == "https://us-central1-python.pkg.dev/test-project/python-repo")

    let cmd = repo.createCommand
    #expect(cmd.contains("--repository-format=python"))
}

@Test func testRepositoryWithKMSKey() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "encrypted-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker,
        kmsKeyName: "projects/test-project/locations/us-central1/keyRings/my-ring/cryptoKeys/my-key"
    )

    let cmd = repo.createCommand
    #expect(cmd.contains("--kms-key=projects/test-project/locations/us-central1/keyRings/my-ring/cryptoKeys/my-key"))
}

@Test func testRepositoryVirtualMode() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "virtual-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker,
        mode: .virtualRepository
    )

    let cmd = repo.createCommand
    #expect(cmd.contains("--mode=virtual-repository"))
}

@Test func testRepositoryRemoteMode() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "remote-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker,
        mode: .remoteRepository
    )

    let cmd = repo.createCommand
    #expect(cmd.contains("--mode=remote-repository"))
}

@Test func testRepositoryDeleteCommand() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "to-delete",
        projectID: "test-project",
        location: "us-central1",
        format: .docker
    )

    let cmd = repo.deleteCommand
    #expect(cmd.contains("gcloud artifacts repositories delete to-delete"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--location=us-central1"))
    #expect(cmd.contains("--quiet"))
}

@Test func testRepositoryDescribeCommand() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "describe-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker
    )

    let cmd = repo.describeCommand
    #expect(cmd.contains("gcloud artifacts repositories describe describe-repo"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testRepositoryUpdateCommand() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "update-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker
    )

    let cmd = repo.updateCommand(description: "Updated description", labels: ["env": "staging"])
    #expect(cmd.contains("gcloud artifacts repositories update update-repo"))
    #expect(cmd.contains("--description=\"Updated description\""))
    #expect(cmd.contains("--update-labels=env=staging"))
}

@Test func testRepositoryListCommand() {
    let cmd = GoogleCloudArtifactRegistryRepository.listCommand(projectID: "test-project", location: "us-central1")
    #expect(cmd.contains("gcloud artifacts repositories list"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testRepositoryListCommandAllLocations() {
    let cmd = GoogleCloudArtifactRegistryRepository.listCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud artifacts repositories list"))
    #expect(cmd.contains("--project=test-project"))
    #expect(!cmd.contains("--location"))
}

@Test func testRepositoryAddIAMBindingCommand() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "my-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker
    )

    let cmd = repo.addIAMBindingCommand(member: "user:dev@example.com", role: "roles/artifactregistry.reader")
    #expect(cmd.contains("gcloud artifacts repositories add-iam-policy-binding my-repo"))
    #expect(cmd.contains("--member=user:dev@example.com"))
    #expect(cmd.contains("--role=roles/artifactregistry.reader"))
}

@Test func testRepositoryGetIAMPolicyCommand() {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "my-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker
    )

    let cmd = repo.getIAMPolicyCommand
    #expect(cmd.contains("gcloud artifacts repositories get-iam-policy my-repo"))
}

@Test func testRepositoryCleanupPolicy() {
    let policy = GoogleCloudArtifactRegistryRepository.CleanupPolicy(
        id: "delete-old-untagged",
        action: .delete,
        condition: .init(tagState: .untagged, olderThan: "604800s")
    )

    #expect(policy.id == "delete-old-untagged")
    #expect(policy.action == .delete)
    #expect(policy.condition?.tagState == .untagged)
    #expect(policy.condition?.olderThan == "604800s")
}

@Test func testRepositoryCleanupPolicyKeepRecent() {
    let policy = GoogleCloudArtifactRegistryRepository.CleanupPolicy(
        id: "keep-recent",
        action: .keep,
        mostRecentVersions: .init(keepCount: 10)
    )

    #expect(policy.action == .keep)
    #expect(policy.mostRecentVersions?.keepCount == 10)
}

@Test func testRepositoryVulnerabilityScanningConfig() {
    let config = GoogleCloudArtifactRegistryRepository.VulnerabilityScanningConfig(
        enablementConfig: .automatic
    )

    #expect(config.enablementConfig == .automatic)
}

@Test func testRepositoryFormats() {
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.docker.rawValue == "DOCKER")
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.maven.rawValue == "MAVEN")
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.npm.rawValue == "NPM")
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.python.rawValue == "PYTHON")
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.apt.rawValue == "APT")
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.yum.rawValue == "YUM")
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.go.rawValue == "GO")
    #expect(GoogleCloudArtifactRegistryRepository.RepositoryFormat.generic.rawValue == "GENERIC")
}

// MARK: Docker Image Tests

@Test func testGoogleCloudDockerImage() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1",
        tag: "v1.0.0"
    )

    #expect(image.name == "my-app")
    #expect(image.tag == "v1.0.0")
    #expect(image.imageURL == "us-central1-docker.pkg.dev/test-project/docker-repo/my-app:v1.0.0")
}

@Test func testDockerImageWithDigest() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1",
        digest: "sha256:abc123"
    )

    #expect(image.imageURL == "us-central1-docker.pkg.dev/test-project/docker-repo/my-app@sha256:abc123")
}

@Test func testDockerImageURLWithTag() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1"
    )

    let url = image.imageURL(tag: "latest")
    #expect(url == "us-central1-docker.pkg.dev/test-project/docker-repo/my-app:latest")
}

@Test func testDockerImageURLWithDigest() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1"
    )

    let url = image.imageURL(digest: "sha256:def456")
    #expect(url == "us-central1-docker.pkg.dev/test-project/docker-repo/my-app@sha256:def456")
}

@Test func testDockerImageListTagsCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1"
    )

    let cmd = image.listTagsCommand
    #expect(cmd.contains("gcloud artifacts docker tags list"))
    #expect(cmd.contains("us-central1-docker.pkg.dev/test-project/docker-repo/my-app"))
}

@Test func testDockerImageAddTagCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1"
    )

    let cmd = image.addTagCommand(sourceTag: "v1.0.0", newTag: "latest")
    #expect(cmd.contains("gcloud artifacts docker tags add"))
    #expect(cmd.contains("my-app:v1.0.0"))
    #expect(cmd.contains("my-app:latest"))
}

@Test func testDockerImageDeleteTagCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1"
    )

    let cmd = image.deleteTagCommand(tag: "old-tag")
    #expect(cmd.contains("gcloud artifacts docker tags delete"))
    #expect(cmd.contains("my-app:old-tag"))
    #expect(cmd.contains("--quiet"))
}

@Test func testDockerImageDeleteCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1",
        tag: "v1.0.0"
    )

    let cmd = image.deleteCommand
    #expect(cmd.contains("gcloud artifacts docker images delete"))
    #expect(cmd.contains("my-app:v1.0.0"))
    #expect(cmd.contains("--quiet"))
}

@Test func testDockerImageDescribeCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1",
        tag: "latest"
    )

    let cmd = image.describeCommand
    #expect(cmd.contains("gcloud artifacts docker images describe"))
    #expect(cmd.contains("my-app:latest"))
}

@Test func testDockerImageListCommand() {
    let cmd = GoogleCloudDockerImage.listCommand(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "docker-repo"
    )
    #expect(cmd.contains("gcloud artifacts docker images list"))
    #expect(cmd.contains("us-central1-docker.pkg.dev/test-project/docker-repo"))
}

@Test func testDockerImagePullCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1",
        tag: "latest"
    )

    #expect(image.dockerPullCommand == "docker pull us-central1-docker.pkg.dev/test-project/docker-repo/my-app:latest")
}

@Test func testDockerImagePushCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1",
        tag: "v1.0.0"
    )

    #expect(image.dockerPushCommand == "docker push us-central1-docker.pkg.dev/test-project/docker-repo/my-app:v1.0.0")
}

@Test func testDockerImageTagCommand() {
    let image = GoogleCloudDockerImage(
        name: "my-app",
        repositoryName: "docker-repo",
        projectID: "test-project",
        location: "us-central1",
        tag: "v1.0.0"
    )

    let cmd = image.dockerTagCommand(sourceImage: "local-image:latest")
    #expect(cmd == "docker tag local-image:latest us-central1-docker.pkg.dev/test-project/docker-repo/my-app:v1.0.0")
}

// MARK: Package Tests

@Test func testGoogleCloudPackage() {
    let pkg = GoogleCloudPackage(
        name: "my-package",
        repositoryName: "npm-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .npm
    )

    #expect(pkg.name == "my-package")
    #expect(pkg.format == .npm)
    #expect(pkg.resourceName == "projects/test-project/locations/us-central1/repositories/npm-repo/packages/my-package")
}

@Test func testPackageListCommand() {
    let cmd = GoogleCloudPackage.listCommand(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "npm-repo"
    )
    #expect(cmd.contains("gcloud artifacts packages list"))
    #expect(cmd.contains("--repository=npm-repo"))
}

@Test func testPackageDeleteCommand() {
    let pkg = GoogleCloudPackage(
        name: "my-package",
        repositoryName: "npm-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .npm
    )

    let cmd = pkg.deleteCommand
    #expect(cmd.contains("gcloud artifacts packages delete my-package"))
    #expect(cmd.contains("--quiet"))
}

@Test func testPackageDescribeCommand() {
    let pkg = GoogleCloudPackage(
        name: "my-package",
        repositoryName: "npm-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .npm
    )

    let cmd = pkg.describeCommand
    #expect(cmd.contains("gcloud artifacts packages describe my-package"))
}

// MARK: Package Version Tests

@Test func testGoogleCloudPackageVersion() {
    let version = GoogleCloudPackageVersion(
        version: "1.0.0",
        packageName: "my-package",
        repositoryName: "npm-repo",
        projectID: "test-project",
        location: "us-central1"
    )

    #expect(version.version == "1.0.0")
    #expect(version.resourceName.contains("versions/1.0.0"))
}

@Test func testPackageVersionListCommand() {
    let cmd = GoogleCloudPackageVersion.listCommand(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "npm-repo",
        packageName: "my-package"
    )
    #expect(cmd.contains("gcloud artifacts versions list"))
    #expect(cmd.contains("--package=my-package"))
}

@Test func testPackageVersionDeleteCommand() {
    let version = GoogleCloudPackageVersion(
        version: "1.0.0",
        packageName: "my-package",
        repositoryName: "npm-repo",
        projectID: "test-project",
        location: "us-central1"
    )

    let cmd = version.deleteCommand
    #expect(cmd.contains("gcloud artifacts versions delete 1.0.0"))
    #expect(cmd.contains("--package=my-package"))
    #expect(cmd.contains("--quiet"))
}

// MARK: Remote Repository Config Tests

@Test func testRemoteRepositoryConfigDockerHub() {
    let config = GoogleCloudRemoteRepositoryConfig(
        upstream: .dockerHub(publicRepository: true),
        description: "Docker Hub mirror"
    )

    #expect(config.upstream.uri == "https://registry-1.docker.io")
}

@Test func testRemoteRepositoryConfigMavenCentral() {
    let config = GoogleCloudRemoteRepositoryConfig(upstream: .mavenCentral)
    #expect(config.upstream.uri == "https://repo.maven.apache.org/maven2")
}

@Test func testRemoteRepositoryConfigNpmRegistry() {
    let config = GoogleCloudRemoteRepositoryConfig(upstream: .npmRegistry)
    #expect(config.upstream.uri == "https://registry.npmjs.org")
}

@Test func testRemoteRepositoryConfigPyPI() {
    let config = GoogleCloudRemoteRepositoryConfig(upstream: .pypi)
    #expect(config.upstream.uri == "https://pypi.org")
}

@Test func testRemoteRepositoryConfigCustom() {
    let config = GoogleCloudRemoteRepositoryConfig(
        upstream: .custom(uri: "https://custom.registry.example.com")
    )
    #expect(config.upstream.uri == "https://custom.registry.example.com")
}

// MARK: Virtual Repository Config Tests

@Test func testVirtualRepositoryConfig() {
    let config = GoogleCloudVirtualRepositoryConfig(
        upstreamPolicies: [
            .init(id: "policy1", repository: "primary-repo", priority: 100),
            .init(id: "policy2", repository: "secondary-repo", priority: 50)
        ]
    )

    #expect(config.upstreamPolicies.count == 2)
    #expect(config.upstreamPolicies[0].priority == 100)
    #expect(config.upstreamPolicies[1].priority == 50)
}

// MARK: Artifact Registry Roles Tests

@Test func testArtifactRegistryRoles() {
    #expect(ArtifactRegistryRole.admin.rawValue == "roles/artifactregistry.admin")
    #expect(ArtifactRegistryRole.writer.rawValue == "roles/artifactregistry.writer")
    #expect(ArtifactRegistryRole.reader.rawValue == "roles/artifactregistry.reader")
    #expect(ArtifactRegistryRole.repoAdmin.rawValue == "roles/artifactregistry.repoAdmin")
    #expect(ArtifactRegistryRole.createOnPushWriter.rawValue == "roles/artifactregistry.createOnPushWriter")
}

// MARK: Docker Auth Configuration Tests

@Test func testArtifactRegistryDockerAuth() {
    let auth = ArtifactRegistryDockerAuth(location: "us-central1")

    #expect(auth.host == "us-central1-docker.pkg.dev")
    #expect(auth.configureDockerCommand == "gcloud auth configure-docker us-central1-docker.pkg.dev")
}

@Test func testDockerAuthPrintAccessTokenCommand() {
    let auth = ArtifactRegistryDockerAuth(location: "us-central1")
    #expect(auth.printAccessTokenCommand == "gcloud auth print-access-token")
}

@Test func testDockerAuthLoginCommand() {
    let auth = ArtifactRegistryDockerAuth(location: "us-west1")
    let cmd = auth.dockerLoginCommand
    #expect(cmd.contains("gcloud auth print-access-token"))
    #expect(cmd.contains("docker login"))
    #expect(cmd.contains("https://us-west1-docker.pkg.dev"))
}

@Test func testDockerAuthCredentialHelperConfig() {
    let auth = ArtifactRegistryDockerAuth(location: "europe-west1")
    let config = auth.credentialHelperConfig
    #expect(config.contains("credHelpers"))
    #expect(config.contains("europe-west1-docker.pkg.dev"))
    #expect(config.contains("gcloud"))
}

// MARK: npm Configuration Tests

@Test func testArtifactRegistryNpmConfig() {
    let config = ArtifactRegistryNpmConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "npm-repo"
    )

    #expect(config.registryURL == "https://us-central1-npm.pkg.dev/test-project/npm-repo/")
}

@Test func testNpmConfigWithScope() {
    let config = ArtifactRegistryNpmConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "npm-repo",
        scope: "@myorg"
    )

    let cmd = config.printCredentialsCommand
    #expect(cmd.contains("--scope=@myorg"))
}

@Test func testNpmConfigPrintCredentialsCommand() {
    let config = ArtifactRegistryNpmConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "npm-repo"
    )

    let cmd = config.printCredentialsCommand
    #expect(cmd.contains("gcloud artifacts print-settings npm"))
    #expect(cmd.contains("--repository=npm-repo"))
}

@Test func testNpmConfigNpmrcConfig() {
    let config = ArtifactRegistryNpmConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "npm-repo"
    )

    let npmrc = config.npmrcConfig
    #expect(npmrc.contains("registry="))
    #expect(npmrc.contains("us-central1-npm.pkg.dev"))
    #expect(npmrc.contains("always-auth=true"))
}

// MARK: Maven Configuration Tests

@Test func testArtifactRegistryMavenConfig() {
    let config = ArtifactRegistryMavenConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "maven-repo"
    )

    #expect(config.repositoryURL == "https://us-central1-maven.pkg.dev/test-project/maven-repo")
}

@Test func testMavenConfigPrintSettingsCommand() {
    let config = ArtifactRegistryMavenConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "maven-repo"
    )

    let cmd = config.printSettingsCommand
    #expect(cmd.contains("gcloud artifacts print-settings mvn"))
    #expect(cmd.contains("--repository=maven-repo"))
}

@Test func testMavenConfigPomRepositoryConfig() {
    let config = ArtifactRegistryMavenConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "maven-repo"
    )

    let pom = config.pomRepositoryConfig
    #expect(pom.contains("<repository>"))
    #expect(pom.contains("<id>artifact-registry</id>"))
    #expect(pom.contains("artifactregistry://"))
}

@Test func testMavenConfigPomDistributionConfig() {
    let config = ArtifactRegistryMavenConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "maven-repo"
    )

    let pom = config.pomDistributionConfig
    #expect(pom.contains("<distributionManagement>"))
    #expect(pom.contains("<snapshotRepository>"))
}

// MARK: Python Configuration Tests

@Test func testArtifactRegistryPythonConfig() {
    let config = ArtifactRegistryPythonConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "python-repo"
    )

    #expect(config.repositoryURL == "https://us-central1-python.pkg.dev/test-project/python-repo/simple/")
}

@Test func testPythonConfigPrintSettingsCommand() {
    let config = ArtifactRegistryPythonConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "python-repo"
    )

    let cmd = config.printSettingsCommand
    #expect(cmd.contains("gcloud artifacts print-settings python"))
    #expect(cmd.contains("--repository=python-repo"))
}

@Test func testPythonConfigPipInstallCommand() {
    let config = ArtifactRegistryPythonConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "python-repo"
    )

    let cmd = config.pipInstallCommand(package: "my-package")
    #expect(cmd.contains("pip install"))
    #expect(cmd.contains("--index-url"))
    #expect(cmd.contains("my-package"))
}

@Test func testPythonConfigPipConfig() {
    let config = ArtifactRegistryPythonConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "python-repo"
    )

    let pipconf = config.pipConfig
    #expect(pipconf.contains("[global]"))
    #expect(pipconf.contains("index-url"))
}

@Test func testPythonConfigTwineUploadCommand() {
    let config = ArtifactRegistryPythonConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "python-repo"
    )

    let cmd = config.twineUploadCommand()
    #expect(cmd.contains("twine upload"))
    #expect(cmd.contains("--repository-url"))
    #expect(cmd.contains("dist/*"))
}

// MARK: Vulnerability Scanning Tests

@Test func testGoogleCloudVulnerabilityScan() {
    let scan = GoogleCloudVulnerabilityScan(
        imageURL: "us-central1-docker.pkg.dev/test-project/repo/image:latest",
        projectID: "test-project"
    )

    let scanCmd = scan.scanCommand
    #expect(scanCmd.contains("gcloud artifacts docker images scan"))
    #expect(scanCmd.contains("image:latest"))
}

@Test func testVulnerabilityScanListCommand() {
    let scan = GoogleCloudVulnerabilityScan(
        imageURL: "us-central1-docker.pkg.dev/test-project/repo/image:latest",
        projectID: "test-project"
    )

    let cmd = scan.listVulnerabilitiesCommand
    #expect(cmd.contains("gcloud artifacts docker images list-vulnerabilities"))
}

@Test func testVulnerabilityScanGetStatusCommand() {
    let cmd = GoogleCloudVulnerabilityScan.getScanStatusCommand(
        operationID: "operation-123",
        location: "us-central1"
    )
    #expect(cmd.contains("gcloud artifacts operations describe operation-123"))
    #expect(cmd.contains("--location=us-central1"))
}

// MARK: Operations Tests

@Test func testArtifactRegistryOperationsListLocations() {
    let cmd = ArtifactRegistryOperations.listLocationsCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud artifacts locations list"))
    #expect(cmd.contains("--project=test-project"))
}

@Test func testArtifactRegistryOperationsListRepositories() {
    let cmd = ArtifactRegistryOperations.listRepositoriesCommand(projectID: "test-project", location: "us-central1")
    #expect(cmd.contains("gcloud artifacts repositories list"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testArtifactRegistryOperationsEnableAPI() {
    let cmd = ArtifactRegistryOperations.enableAPICommand(projectID: "test-project")
    #expect(cmd.contains("gcloud services enable artifactregistry.googleapis.com"))
}

@Test func testArtifactRegistryOperationsSetDefaultRepo() {
    let cmd = ArtifactRegistryOperations.setDefaultRepoCommand(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "my-repo"
    )
    #expect(cmd.contains("gcloud config set artifacts/repository my-repo"))
    #expect(cmd.contains("gcloud config set artifacts/location us-central1"))
}

// MARK: DAIS Artifact Registry Template Tests

@Test func testDAISArtifactRegistryTemplateDockerRepository() {
    let repo = DAISArtifactRegistryTemplate.dockerRepository(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(repo.name == "dais-prod-docker")
    #expect(repo.format == .docker)
    #expect(repo.labels["app"] == "dais")
    #expect(repo.labels["deployment"] == "dais-prod")
    #expect(repo.cleanupPolicies.count == 2)
    #expect(repo.vulnerabilityScanningConfig?.enablementConfig == .automatic)
}

@Test func testDAISArtifactRegistryTemplateNpmRepository() {
    let repo = DAISArtifactRegistryTemplate.npmRepository(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(repo.name == "dais-prod-npm")
    #expect(repo.format == .npm)
}

@Test func testDAISArtifactRegistryTemplatePythonRepository() {
    let repo = DAISArtifactRegistryTemplate.pythonRepository(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(repo.name == "dais-prod-python")
    #expect(repo.format == .python)
}

@Test func testDAISArtifactRegistryTemplateDockerImage() {
    let image = DAISArtifactRegistryTemplate.dockerImage(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        imageName: "my-service",
        tag: "v1.0.0"
    )

    #expect(image.name == "my-service")
    #expect(image.repositoryName == "dais-prod-docker")
    #expect(image.tag == "v1.0.0")
}

@Test func testDAISArtifactRegistryTemplateAPIServiceImage() {
    let image = DAISArtifactRegistryTemplate.apiServiceImage(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        tag: "v2.0.0"
    )

    #expect(image.name == "api-service")
    #expect(image.tag == "v2.0.0")
}

@Test func testDAISArtifactRegistryTemplateGRPCServiceImage() {
    let image = DAISArtifactRegistryTemplate.grpcServiceImage(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(image.name == "grpc-service")
    #expect(image.tag == "latest")
}

@Test func testDAISArtifactRegistryTemplateWorkerServiceImage() {
    let image = DAISArtifactRegistryTemplate.workerServiceImage(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(image.name == "worker")
}

@Test func testDAISArtifactRegistryTemplateDockerAuth() {
    let auth = DAISArtifactRegistryTemplate.dockerAuth(location: "us-central1")
    #expect(auth.host == "us-central1-docker.pkg.dev")
}

@Test func testDAISArtifactRegistryTemplateSwiftDockerfile() {
    let dockerfile = DAISArtifactRegistryTemplate.swiftDockerfile(
        executableName: "dais-server",
        port: 8080
    )

    #expect(dockerfile.contains("FROM swift:5.10-jammy"))
    #expect(dockerfile.contains("swift build -c release"))
    #expect(dockerfile.contains("dais-server"))
    #expect(dockerfile.contains("EXPOSE 8080"))
}

@Test func testDAISArtifactRegistryTemplateCloudbuildConfig() {
    let config = DAISArtifactRegistryTemplate.cloudbuildConfig(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        serviceName: "api-service",
        cloudRunRegion: "us-central1"
    )

    #expect(config.contains("steps:"))
    #expect(config.contains("gcr.io/cloud-builders/docker"))
    #expect(config.contains("dais-prod-docker"))
    #expect(config.contains("api-service"))
    #expect(config.contains("$COMMIT_SHA"))
    #expect(config.contains("gcloud"))
    #expect(config.contains("run"))
    #expect(config.contains("deploy"))
}

@Test func testDAISArtifactRegistryTemplateSetupScript() {
    let script = DAISArtifactRegistryTemplate.setupScript(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable artifactregistry.googleapis.com"))
    #expect(script.contains("gcloud artifacts repositories create dais-prod-docker"))
    #expect(script.contains("gcloud auth configure-docker"))
    #expect(script.contains("Artifact Registry Setup Complete!"))
}

@Test func testDAISArtifactRegistryTemplateTeardownScript() {
    let script = DAISArtifactRegistryTemplate.teardownScript(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud artifacts repositories delete dais-prod-docker"))
    #expect(script.contains("teardown complete"))
}

@Test func testDAISArtifactRegistryTemplateCICDSetupScript() {
    let script = DAISArtifactRegistryTemplate.cicdSetupScript(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        repoOwner: "myorg",
        repoName: "my-repo"
    )

    #expect(script.contains("gcloud services enable cloudbuild.googleapis.com"))
    #expect(script.contains("gcloud builds triggers create github"))
    #expect(script.contains("--repo-owner=myorg"))
    #expect(script.contains("--repo-name=my-repo"))
    #expect(script.contains("--branch-pattern"))
}

// MARK: Artifact Registry Codable Tests

@Test func testRepositoryCodable() throws {
    let repo = GoogleCloudArtifactRegistryRepository(
        name: "test-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .docker
    )
    let data = try JSONEncoder().encode(repo)
    let decoded = try JSONDecoder().decode(GoogleCloudArtifactRegistryRepository.self, from: data)

    #expect(decoded.name == repo.name)
    #expect(decoded.format == .docker)
    #expect(decoded.location == "us-central1")
}

@Test func testDockerImageCodable() throws {
    let image = GoogleCloudDockerImage(
        name: "test-image",
        repositoryName: "test-repo",
        projectID: "test-project",
        location: "us-central1",
        tag: "latest"
    )
    let data = try JSONEncoder().encode(image)
    let decoded = try JSONDecoder().decode(GoogleCloudDockerImage.self, from: data)

    #expect(decoded.name == image.name)
    #expect(decoded.tag == "latest")
}

@Test func testPackageCodable() throws {
    let pkg = GoogleCloudPackage(
        name: "test-package",
        repositoryName: "npm-repo",
        projectID: "test-project",
        location: "us-central1",
        format: .npm
    )
    let data = try JSONEncoder().encode(pkg)
    let decoded = try JSONDecoder().decode(GoogleCloudPackage.self, from: data)

    #expect(decoded.name == pkg.name)
    #expect(decoded.format == .npm)
}

@Test func testPackageVersionCodable() throws {
    let version = GoogleCloudPackageVersion(
        version: "1.0.0",
        packageName: "test-package",
        repositoryName: "npm-repo",
        projectID: "test-project",
        location: "us-central1"
    )
    let data = try JSONEncoder().encode(version)
    let decoded = try JSONDecoder().decode(GoogleCloudPackageVersion.self, from: data)

    #expect(decoded.version == "1.0.0")
    #expect(decoded.packageName == "test-package")
}

@Test func testNpmConfigCodable() throws {
    let config = ArtifactRegistryNpmConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "npm-repo",
        scope: "@myorg"
    )
    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(ArtifactRegistryNpmConfig.self, from: data)

    #expect(decoded.scope == "@myorg")
    #expect(decoded.repositoryName == "npm-repo")
}

@Test func testMavenConfigCodable() throws {
    let config = ArtifactRegistryMavenConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "maven-repo"
    )
    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(ArtifactRegistryMavenConfig.self, from: data)

    #expect(decoded.repositoryName == "maven-repo")
}

@Test func testPythonConfigCodable() throws {
    let config = ArtifactRegistryPythonConfig(
        projectID: "test-project",
        location: "us-central1",
        repositoryName: "python-repo"
    )
    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(ArtifactRegistryPythonConfig.self, from: data)

    #expect(decoded.repositoryName == "python-repo")
}

// MARK: - Cloud Build Tests

@Test func testGoogleCloudBuildBasicInit() {
    let step = GoogleCloudBuild.BuildStep(
        name: "gcr.io/cloud-builders/docker",
        args: ["build", "-t", "my-image", "."]
    )
    let build = GoogleCloudBuild(
        projectID: "test-project",
        steps: [step]
    )

    #expect(build.projectID == "test-project")
    #expect(build.steps.count == 1)
    #expect(build.steps[0].name == "gcr.io/cloud-builders/docker")
    #expect(build.timeout == "600s")
}

@Test func testBuildStepWithAllOptions() {
    let volume = GoogleCloudBuild.BuildStep.Volume(name: "vol1", path: "/workspace/vol")
    let step = GoogleCloudBuild.BuildStep(
        name: "gcr.io/cloud-builders/docker",
        args: ["build", "."],
        env: ["ENV_VAR=value"],
        dir: "subdir",
        id: "build-step",
        waitFor: ["previous-step"],
        entrypoint: "bash",
        secretEnv: ["SECRET_KEY"],
        volumes: [volume],
        timeout: "300s",
        script: "echo hello"
    )

    #expect(step.name == "gcr.io/cloud-builders/docker")
    #expect(step.args == ["build", "."])
    #expect(step.env == ["ENV_VAR=value"])
    #expect(step.dir == "subdir")
    #expect(step.id == "build-step")
    #expect(step.waitFor == ["previous-step"])
    #expect(step.entrypoint == "bash")
    #expect(step.secretEnv == ["SECRET_KEY"])
    #expect(step.volumes.count == 1)
    #expect(step.volumes[0].name == "vol1")
    #expect(step.timeout == "300s")
    #expect(step.script == "echo hello")
}

@Test func testBuildSourceStorageSource() {
    let source = GoogleCloudBuild.BuildSource.storageSource(
        bucket: "my-bucket",
        object: "source.tar.gz",
        generation: 12345
    )

    if case .storageSource(let bucket, let object, let generation) = source {
        #expect(bucket == "my-bucket")
        #expect(object == "source.tar.gz")
        #expect(generation == 12345)
    } else {
        Issue.record("Expected storageSource")
    }
}

@Test func testBuildSourceRepoSource() {
    let source = GoogleCloudBuild.BuildSource.repoSource(
        repoName: "my-repo",
        branchName: "main",
        tagName: nil,
        commitSha: nil,
        dir: "src"
    )

    if case .repoSource(let repoName, let branchName, _, _, let dir) = source {
        #expect(repoName == "my-repo")
        #expect(branchName == "main")
        #expect(dir == "src")
    } else {
        Issue.record("Expected repoSource")
    }
}

@Test func testBuildSourceGitSource() {
    let source = GoogleCloudBuild.BuildSource.gitSource(
        url: "https://github.com/owner/repo.git",
        revision: "main",
        dir: nil
    )

    if case .gitSource(let url, let revision, _) = source {
        #expect(url == "https://github.com/owner/repo.git")
        #expect(revision == "main")
    } else {
        Issue.record("Expected gitSource")
    }
}

@Test func testBuildSourceConnectedRepository() {
    let source = GoogleCloudBuild.BuildSource.connectedRepository(
        repository: "projects/p/locations/l/connections/c/repositories/r",
        revision: "main",
        dir: nil
    )

    if case .connectedRepository(let repository, let revision, _) = source {
        #expect(repository == "projects/p/locations/l/connections/c/repositories/r")
        #expect(revision == "main")
    } else {
        Issue.record("Expected connectedRepository")
    }
}

@Test func testBuildArtifacts() {
    let objects = GoogleCloudBuild.Artifacts.Objects(
        location: "gs://my-bucket/artifacts",
        paths: ["output/*.jar"]
    )
    let mavenArtifact = GoogleCloudBuild.Artifacts.MavenArtifact(
        repository: "projects/p/locations/l/repositories/maven-repo",
        path: "target/*.jar",
        artifactId: "my-artifact",
        groupId: "com.example",
        version: "1.0.0"
    )
    let pythonPackage = GoogleCloudBuild.Artifacts.PythonPackage(
        repository: "projects/p/locations/l/repositories/python-repo",
        paths: ["dist/*.whl"]
    )
    let npmPackage = GoogleCloudBuild.Artifacts.NpmPackage(
        repository: "projects/p/locations/l/repositories/npm-repo",
        packagePath: "package"
    )
    let artifacts = GoogleCloudBuild.Artifacts(
        images: ["gcr.io/project/image"],
        objects: objects,
        mavenArtifacts: [mavenArtifact],
        pythonPackages: [pythonPackage],
        npmPackages: [npmPackage]
    )

    #expect(artifacts.images == ["gcr.io/project/image"])
    #expect(artifacts.objects?.location == "gs://my-bucket/artifacts")
    #expect(artifacts.mavenArtifacts.count == 1)
    #expect(artifacts.pythonPackages.count == 1)
    #expect(artifacts.npmPackages.count == 1)
}

@Test func testBuildOptionsMachineTypes() {
    #expect(GoogleCloudBuild.BuildOptions.MachineType.n1Highcpu8.rawValue == "N1_HIGHCPU_8")
    #expect(GoogleCloudBuild.BuildOptions.MachineType.n1Highcpu32.rawValue == "N1_HIGHCPU_32")
    #expect(GoogleCloudBuild.BuildOptions.MachineType.e2Highcpu8.rawValue == "E2_HIGHCPU_8")
    #expect(GoogleCloudBuild.BuildOptions.MachineType.e2Highcpu32.rawValue == "E2_HIGHCPU_32")
    #expect(GoogleCloudBuild.BuildOptions.MachineType.e2Medium.rawValue == "E2_MEDIUM")
}

@Test func testBuildOptionsInit() {
    let poolOption = GoogleCloudBuild.BuildOptions.PoolOption(name: "my-pool")
    let options = GoogleCloudBuild.BuildOptions(
        machineType: .e2Highcpu8,
        diskSizeGb: 200,
        substitutionOption: .allowLoose,
        dynamicSubstitutions: true,
        logStreamingOption: .streamOn,
        logging: .cloudLoggingOnly,
        env: ["MY_VAR=value"],
        secretEnv: ["SECRET"],
        pool: poolOption,
        requestedVerifyOption: .verified
    )

    #expect(options.machineType == .e2Highcpu8)
    #expect(options.diskSizeGb == 200)
    #expect(options.substitutionOption == .allowLoose)
    #expect(options.dynamicSubstitutions == true)
    #expect(options.logStreamingOption == .streamOn)
    #expect(options.logging == .cloudLoggingOnly)
    #expect(options.env == ["MY_VAR=value"])
    #expect(options.pool?.name == "my-pool")
}

@Test func testAvailableSecrets() {
    let smSecret = GoogleCloudBuild.AvailableSecrets.SecretManagerSecret(
        versionName: "projects/p/secrets/s/versions/1",
        env: "MY_SECRET"
    )
    let inlineSecret = GoogleCloudBuild.AvailableSecrets.InlineSecret(
        kmsKeyName: "projects/p/locations/l/keyRings/k/cryptoKeys/c",
        envMap: ["KEY": "encrypted-value"]
    )
    let secrets = GoogleCloudBuild.AvailableSecrets(
        secretManager: [smSecret],
        inline: [inlineSecret]
    )

    #expect(secrets.secretManager.count == 1)
    #expect(secrets.secretManager[0].env == "MY_SECRET")
    #expect(secrets.inline.count == 1)
    #expect(secrets.inline[0].envMap["KEY"] == "encrypted-value")
}

@Test func testBuildSubmitCommand() {
    let build = GoogleCloudBuild(
        projectID: "test-project",
        steps: []
    )

    #expect(build.submitCommand == "gcloud builds submit --project=test-project")
}

@Test func testBuildDescribeCommand() {
    let build = GoogleCloudBuild(projectID: "test-project", steps: [])

    let cmd = build.describeCommand(buildID: "build-123")
    #expect(cmd == "gcloud builds describe build-123 --project=test-project")

    let cmdWithRegion = build.describeCommand(buildID: "build-123", region: "us-central1")
    #expect(cmdWithRegion.contains("--region=us-central1"))
}

@Test func testBuildListCommand() {
    let cmd = GoogleCloudBuild.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud builds list --project=test-project")

    let cmdWithRegion = GoogleCloudBuild.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmdWithRegion.contains("--region=us-central1"))

    let cmdOngoing = GoogleCloudBuild.listCommand(projectID: "test-project", ongoing: true)
    #expect(cmdOngoing.contains("--ongoing"))
}

@Test func testBuildCancelCommand() {
    let cmd = GoogleCloudBuild.cancelCommand(buildID: "build-123", projectID: "test-project")
    #expect(cmd == "gcloud builds cancel build-123 --project=test-project")

    let cmdWithRegion = GoogleCloudBuild.cancelCommand(buildID: "build-123", projectID: "test-project", region: "us-central1")
    #expect(cmdWithRegion.contains("--region=us-central1"))
}

@Test func testBuildLogCommand() {
    let cmd = GoogleCloudBuild.logCommand(buildID: "build-123", projectID: "test-project")
    #expect(cmd == "gcloud builds log build-123 --project=test-project")

    let cmdStream = GoogleCloudBuild.logCommand(buildID: "build-123", projectID: "test-project", stream: true)
    #expect(cmdStream.contains("--stream"))
}

// MARK: - Build Trigger Tests

@Test func testBuildTriggerGitHubPush() {
    let trigger = GoogleCloudBuildTrigger(
        name: "my-trigger",
        projectID: "test-project",
        description: "Deploy on push",
        triggerSource: .github(
            owner: "myorg",
            name: "myrepo",
            eventConfig: .push(branch: "^main$", tag: nil, invertRegex: false)
        ),
        buildConfig: .filename("cloudbuild.yaml")
    )

    #expect(trigger.name == "my-trigger")
    #expect(trigger.resourceName == "projects/test-project/triggers/my-trigger")

    let cmd = trigger.createCommandGitHub
    #expect(cmd != nil)
    #expect(cmd!.contains("gcloud builds triggers create github"))
    #expect(cmd!.contains("--repo-owner=myorg"))
    #expect(cmd!.contains("--repo-name=myrepo"))
    #expect(cmd!.contains("--branch-pattern=\"^main$\""))
    #expect(cmd!.contains("--build-config=cloudbuild.yaml"))
}

@Test func testBuildTriggerGitHubPullRequest() {
    let trigger = GoogleCloudBuildTrigger(
        name: "pr-trigger",
        projectID: "test-project",
        triggerSource: .github(
            owner: "myorg",
            name: "myrepo",
            eventConfig: .pullRequest(
                branch: "^main$",
                commentControl: .commentsEnabledForExternalContributorsOnly,
                invertRegex: false
            )
        ),
        buildConfig: .filename("cloudbuild.yaml")
    )

    let cmd = trigger.createCommandGitHub!
    #expect(cmd.contains("--pull-request-pattern=\"^main$\""))
    #expect(cmd.contains("--comment-control=COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"))
}

@Test func testBuildTriggerCSR() {
    let trigger = GoogleCloudBuildTrigger(
        name: "csr-trigger",
        projectID: "test-project",
        triggerSource: .cloudSourceRepository(
            repoName: "my-csr-repo",
            eventConfig: .push(branch: "main", tag: nil, invertRegex: false)
        ),
        buildConfig: .filename("cloudbuild.yaml")
    )

    let cmd = trigger.createCommandCSR!
    #expect(cmd.contains("gcloud builds triggers create cloud-source-repositories"))
    #expect(cmd.contains("--repo=my-csr-repo"))
}

@Test func testBuildTriggerPubSub() {
    let trigger = GoogleCloudBuildTrigger(
        name: "pubsub-trigger",
        projectID: "test-project",
        triggerSource: .pubsub(
            topic: "projects/test-project/topics/my-topic",
            serviceAccountEmail: "sa@test-project.iam.gserviceaccount.com"
        ),
        buildConfig: .filename("cloudbuild.yaml")
    )

    let cmd = trigger.createCommandPubSub!
    #expect(cmd.contains("gcloud builds triggers create pubsub"))
    #expect(cmd.contains("--topic=projects/test-project/topics/my-topic"))
    #expect(cmd.contains("--service-account=sa@test-project.iam.gserviceaccount.com"))
}

@Test func testBuildTriggerWebhook() {
    let trigger = GoogleCloudBuildTrigger(
        name: "webhook-trigger",
        projectID: "test-project",
        triggerSource: .webhook(secretName: "projects/test-project/secrets/webhook-secret/versions/1"),
        buildConfig: .filename("cloudbuild.yaml")
    )

    let cmd = trigger.createCommandWebhook!
    #expect(cmd.contains("gcloud builds triggers create webhook"))
    #expect(cmd.contains("--secret=projects/test-project/secrets/webhook-secret/versions/1"))
}

@Test func testBuildTriggerManual() {
    let trigger = GoogleCloudBuildTrigger(
        name: "manual-trigger",
        projectID: "test-project",
        triggerSource: .manual,
        buildConfig: .filename("cloudbuild.yaml")
    )

    let cmd = trigger.createCommandManual!
    #expect(cmd.contains("gcloud builds triggers create manual"))
    #expect(cmd.contains("--name=manual-trigger"))
}

@Test func testBuildTriggerWithRegion() {
    let trigger = GoogleCloudBuildTrigger(
        name: "regional-trigger",
        projectID: "test-project",
        triggerSource: .manual,
        buildConfig: .filename("cloudbuild.yaml"),
        region: "us-central1"
    )

    #expect(trigger.resourceName == "projects/test-project/locations/us-central1/triggers/regional-trigger")

    let cmd = trigger.createCommandManual!
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testBuildTriggerDeleteCommand() {
    let trigger = GoogleCloudBuildTrigger(
        name: "my-trigger",
        projectID: "test-project",
        triggerSource: .manual,
        buildConfig: .filename("cloudbuild.yaml"),
        region: "us-central1"
    )

    #expect(trigger.deleteCommand.contains("gcloud builds triggers delete my-trigger"))
    #expect(trigger.deleteCommand.contains("--project=test-project"))
    #expect(trigger.deleteCommand.contains("--region=us-central1"))
    #expect(trigger.deleteCommand.contains("--quiet"))
}

@Test func testBuildTriggerDescribeCommand() {
    let trigger = GoogleCloudBuildTrigger(
        name: "my-trigger",
        projectID: "test-project",
        triggerSource: .manual,
        buildConfig: .filename("cloudbuild.yaml")
    )

    #expect(trigger.describeCommand == "gcloud builds triggers describe my-trigger --project=test-project")
}

@Test func testBuildTriggerRunCommand() {
    let trigger = GoogleCloudBuildTrigger(
        name: "my-trigger",
        projectID: "test-project",
        triggerSource: .manual,
        buildConfig: .filename("cloudbuild.yaml")
    )

    let cmd = trigger.runCommand(branchName: "main")
    #expect(cmd.contains("gcloud builds triggers run my-trigger"))
    #expect(cmd.contains("--branch=main"))

    let cmdWithTag = trigger.runCommand(tagName: "v1.0.0")
    #expect(cmdWithTag.contains("--tag=v1.0.0"))

    let cmdWithSha = trigger.runCommand(sha: "abc123")
    #expect(cmdWithSha.contains("--sha=abc123"))
}

@Test func testBuildTriggerListCommand() {
    let cmd = GoogleCloudBuildTrigger.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud builds triggers list --project=test-project")

    let cmdWithRegion = GoogleCloudBuildTrigger.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmdWithRegion.contains("--region=us-central1"))
}

@Test func testBuildTriggerWithSubstitutions() {
    let trigger = GoogleCloudBuildTrigger(
        name: "my-trigger",
        projectID: "test-project",
        triggerSource: .github(
            owner: "myorg",
            name: "myrepo",
            eventConfig: .push(branch: "^main$", tag: nil, invertRegex: false)
        ),
        buildConfig: .filename("cloudbuild.yaml"),
        substitutions: ["DEPLOY_ENV": "production", "VERSION": "1.0"]
    )

    let cmd = trigger.createCommandGitHub!
    #expect(cmd.contains("--substitutions="))
    #expect(cmd.contains("_DEPLOY_ENV=production"))
    #expect(cmd.contains("_VERSION=1.0"))
}

@Test func testBuildTriggerWithIncludedIgnoredFiles() {
    let trigger = GoogleCloudBuildTrigger(
        name: "my-trigger",
        projectID: "test-project",
        triggerSource: .github(
            owner: "myorg",
            name: "myrepo",
            eventConfig: .push(branch: "^main$", tag: nil, invertRegex: false)
        ),
        buildConfig: .filename("cloudbuild.yaml"),
        ignoredFiles: ["docs/**", "*.md"],
        includedFiles: ["src/**", "*.swift"]
    )

    let cmd = trigger.createCommandGitHub!
    #expect(cmd.contains("--included-files=src/**,*.swift"))
    #expect(cmd.contains("--ignored-files=docs/**,*.md"))
}

@Test func testBuildTriggerWithApprovalRequired() {
    let trigger = GoogleCloudBuildTrigger(
        name: "prod-trigger",
        projectID: "test-project",
        triggerSource: .github(
            owner: "myorg",
            name: "myrepo",
            eventConfig: .push(branch: "^main$", tag: nil, invertRegex: false)
        ),
        buildConfig: .filename("cloudbuild.yaml"),
        approvalRequired: true
    )

    let cmd = trigger.createCommandGitHub!
    #expect(cmd.contains("--require-approval"))
}

// MARK: - Worker Pool Tests

@Test func testWorkerPoolBasic() {
    let pool = GoogleCloudBuildWorkerPool(
        name: "my-pool",
        projectID: "test-project",
        region: "us-central1",
        privatePoolConfig: .init(
            workerConfig: .init(machineType: "e2-standard-4", diskSizeGb: 100)
        )
    )

    #expect(pool.name == "my-pool")
    #expect(pool.resourceName == "projects/test-project/locations/us-central1/workerPools/my-pool")

    let cmd = pool.createCommand
    #expect(cmd.contains("gcloud builds worker-pools create my-pool"))
    #expect(cmd.contains("--worker-machine-type=e2-standard-4"))
    #expect(cmd.contains("--worker-disk-size=100GB"))
}

@Test func testWorkerPoolWithNetwork() {
    let pool = GoogleCloudBuildWorkerPool(
        name: "private-pool",
        projectID: "test-project",
        region: "us-central1",
        privatePoolConfig: .init(
            workerConfig: .init(machineType: "e2-highcpu-8", diskSizeGb: 200),
            networkConfig: .init(
                peeredNetwork: "projects/test-project/global/networks/my-vpc",
                peeredNetworkIPRange: "10.0.0.0/24",
                egressOption: .noPublicEgress
            )
        )
    )

    let cmd = pool.createCommand
    #expect(cmd.contains("--peered-network=projects/test-project/global/networks/my-vpc"))
    #expect(cmd.contains("--peered-network-ip-range=10.0.0.0/24"))
    #expect(cmd.contains("--no-public-egress=true"))
}

@Test func testWorkerPoolDeleteCommand() {
    let pool = GoogleCloudBuildWorkerPool(
        name: "my-pool",
        projectID: "test-project",
        region: "us-central1",
        privatePoolConfig: .init(workerConfig: .init())
    )

    #expect(pool.deleteCommand == "gcloud builds worker-pools delete my-pool --project=test-project --region=us-central1 --quiet")
}

@Test func testWorkerPoolDescribeCommand() {
    let pool = GoogleCloudBuildWorkerPool(
        name: "my-pool",
        projectID: "test-project",
        region: "us-central1",
        privatePoolConfig: .init(workerConfig: .init())
    )

    #expect(pool.describeCommand == "gcloud builds worker-pools describe my-pool --project=test-project --region=us-central1")
}

@Test func testWorkerPoolUpdateCommand() {
    let pool = GoogleCloudBuildWorkerPool(
        name: "my-pool",
        projectID: "test-project",
        region: "us-central1",
        privatePoolConfig: .init(workerConfig: .init())
    )

    let cmd = pool.updateCommand(machineType: "e2-highcpu-32", diskSizeGb: 500)
    #expect(cmd.contains("gcloud builds worker-pools update my-pool"))
    #expect(cmd.contains("--worker-machine-type=e2-highcpu-32"))
    #expect(cmd.contains("--worker-disk-size=500GB"))
}

@Test func testWorkerPoolListCommand() {
    let cmd = GoogleCloudBuildWorkerPool.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd == "gcloud builds worker-pools list --project=test-project --region=us-central1")
}

// MARK: - Connection Tests

@Test func testConnectionGitHub() {
    let conn = GoogleCloudBuildConnection(
        name: "github-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .github(appInstallationId: 12345)
    )

    #expect(conn.name == "github-conn")
    #expect(conn.resourceName == "projects/test-project/locations/us-central1/connections/github-conn")

    let cmd = conn.createCommand!
    #expect(cmd.contains("gcloud builds connections create github github-conn"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testConnectionGitHubEnterprise() {
    let conn = GoogleCloudBuildConnection(
        name: "ghe-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .githubEnterprise(hostUri: "https://github.mycompany.com", appInstallationId: nil)
    )

    let cmd = conn.createCommand!
    #expect(cmd.contains("gcloud builds connections create github-enterprise ghe-conn"))
    #expect(cmd.contains("--host-uri=https://github.mycompany.com"))
}

@Test func testConnectionGitLab() {
    let conn = GoogleCloudBuildConnection(
        name: "gitlab-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .gitlab(hostUri: "https://gitlab.mycompany.com", authorizerCredential: nil, readAuthorizerCredential: nil)
    )

    let cmd = conn.createCommand!
    #expect(cmd.contains("gcloud builds connections create gitlab gitlab-conn"))
    #expect(cmd.contains("--host-uri=https://gitlab.mycompany.com"))
}

@Test func testConnectionBitbucketDataCenter() {
    let conn = GoogleCloudBuildConnection(
        name: "bdc-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .bitbucketDataCenter(hostUri: "https://bitbucket.mycompany.com", authorizerCredential: nil, readAuthorizerCredential: nil)
    )

    let cmd = conn.createCommand!
    #expect(cmd.contains("gcloud builds connections create bitbucket-data-center bdc-conn"))
    #expect(cmd.contains("--host-uri=https://bitbucket.mycompany.com"))
}

@Test func testConnectionBitbucketCloud() {
    let conn = GoogleCloudBuildConnection(
        name: "bbc-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .bitbucketCloud(workspace: "my-workspace", authorizerCredential: nil, readAuthorizerCredential: nil)
    )

    let cmd = conn.createCommand!
    #expect(cmd.contains("gcloud builds connections create bitbucket-cloud bbc-conn"))
    #expect(cmd.contains("--workspace=my-workspace"))
}

@Test func testConnectionDeleteCommand() {
    let conn = GoogleCloudBuildConnection(
        name: "my-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .github(appInstallationId: nil)
    )

    #expect(conn.deleteCommand == "gcloud builds connections delete my-conn --project=test-project --region=us-central1 --quiet")
}

@Test func testConnectionDescribeCommand() {
    let conn = GoogleCloudBuildConnection(
        name: "my-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .github(appInstallationId: nil)
    )

    #expect(conn.describeCommand == "gcloud builds connections describe my-conn --project=test-project --region=us-central1")
}

@Test func testConnectionListCommand() {
    let cmd = GoogleCloudBuildConnection.listCommand(projectID: "test-project", region: "us-central1")
    #expect(cmd == "gcloud builds connections list --project=test-project --region=us-central1")
}

// MARK: - Cloud Build Repository Tests

@Test func testBuildRepositoryCreate() {
    let repo = GoogleCloudBuildRepository(
        name: "my-repo",
        projectID: "test-project",
        region: "us-central1",
        connectionName: "github-conn",
        remoteUri: "https://github.com/owner/repo.git"
    )

    #expect(repo.name == "my-repo")
    #expect(repo.resourceName == "projects/test-project/locations/us-central1/connections/github-conn/repositories/my-repo")

    let cmd = repo.createCommand
    #expect(cmd.contains("gcloud builds repositories create my-repo"))
    #expect(cmd.contains("--connection=github-conn"))
    #expect(cmd.contains("--remote-uri=https://github.com/owner/repo.git"))
}

@Test func testBuildRepositoryDeleteCommand() {
    let repo = GoogleCloudBuildRepository(
        name: "my-repo",
        projectID: "test-project",
        region: "us-central1",
        connectionName: "github-conn",
        remoteUri: "https://github.com/owner/repo.git"
    )

    #expect(repo.deleteCommand.contains("gcloud builds repositories delete my-repo"))
    #expect(repo.deleteCommand.contains("--connection=github-conn"))
    #expect(repo.deleteCommand.contains("--quiet"))
}

@Test func testBuildRepositoryDescribeCommand() {
    let repo = GoogleCloudBuildRepository(
        name: "my-repo",
        projectID: "test-project",
        region: "us-central1",
        connectionName: "github-conn",
        remoteUri: "https://github.com/owner/repo.git"
    )

    #expect(repo.describeCommand.contains("gcloud builds repositories describe my-repo"))
    #expect(repo.describeCommand.contains("--connection=github-conn"))
}

@Test func testBuildRepositoryListCommand() {
    let cmd = GoogleCloudBuildRepository.listCommand(
        projectID: "test-project",
        region: "us-central1",
        connectionName: "github-conn"
    )
    #expect(cmd.contains("gcloud builds repositories list"))
    #expect(cmd.contains("--connection=github-conn"))
}

// MARK: - Cloud Build Operations Tests

@Test func testEnableAPICommand() {
    let cmd = CloudBuildOperations.enableAPICommand(projectID: "test-project")
    #expect(cmd == "gcloud services enable cloudbuild.googleapis.com --project=test-project")
}

@Test func testSubmitCommandBasic() {
    let cmd = CloudBuildOperations.submitCommand(projectID: "test-project")
    #expect(cmd == "gcloud builds submit --project=test-project")
}

@Test func testSubmitCommandWithOptions() {
    let cmd = CloudBuildOperations.submitCommand(
        projectID: "test-project",
        configFile: "cloudbuild.yaml",
        tag: "gcr.io/test-project/image:latest",
        substitutions: ["ENV": "prod"],
        timeout: "1800s",
        machineType: .e2Highcpu8,
        region: "us-central1",
        workerPool: "projects/test-project/locations/us-central1/workerPools/my-pool",
        gcsLogDir: "gs://my-bucket/logs",
        gcsSourceStagingDir: "gs://my-bucket/source",
        ignoreFile: ".gcloudignore",
        noCache: true,
        async: true
    )

    #expect(cmd.contains("--config=cloudbuild.yaml"))
    #expect(cmd.contains("--tag=gcr.io/test-project/image:latest"))
    #expect(cmd.contains("--substitutions=_ENV=prod"))
    #expect(cmd.contains("--timeout=1800s"))
    #expect(cmd.contains("--machine-type=E2_HIGHCPU_8"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--worker-pool=projects/test-project/locations/us-central1/workerPools/my-pool"))
    #expect(cmd.contains("--gcs-log-dir=gs://my-bucket/logs"))
    #expect(cmd.contains("--gcs-source-staging-dir=gs://my-bucket/source"))
    #expect(cmd.contains("--ignore-file=.gcloudignore"))
    #expect(cmd.contains("--no-cache"))
    #expect(cmd.contains("--async"))
}

@Test func testGetServiceAccountCommand() {
    let cmd = CloudBuildOperations.getServiceAccountCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud projects describe test-project"))
    #expect(cmd.contains("@cloudbuild.gserviceaccount.com"))
}

@Test func testGrantCloudRunDeployerCommand() {
    let cmd = CloudBuildOperations.grantCloudRunDeployerCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud projects add-iam-policy-binding test-project"))
    #expect(cmd.contains("roles/run.admin"))
    #expect(cmd.contains("roles/iam.serviceAccountUser"))
}

@Test func testGrantGKEDeployerCommand() {
    let cmd = CloudBuildOperations.grantGKEDeployerCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud projects add-iam-policy-binding test-project"))
    #expect(cmd.contains("roles/container.developer"))
}

@Test func testGrantArtifactRegistryWriterCommand() {
    let cmd = CloudBuildOperations.grantArtifactRegistryWriterCommand(projectID: "test-project")
    #expect(cmd.contains("gcloud projects add-iam-policy-binding test-project"))
    #expect(cmd.contains("roles/artifactregistry.writer"))
}

@Test func testApproveCommand() {
    let cmd = CloudBuildOperations.approveCommand(buildID: "build-123", projectID: "test-project")
    #expect(cmd == "gcloud builds approve build-123 --project=test-project")

    let cmdWithRegion = CloudBuildOperations.approveCommand(buildID: "build-123", projectID: "test-project", region: "us-central1")
    #expect(cmdWithRegion.contains("--region=us-central1"))
}

@Test func testRejectCommand() {
    let cmd = CloudBuildOperations.rejectCommand(buildID: "build-123", projectID: "test-project")
    #expect(cmd == "gcloud builds reject build-123 --project=test-project")

    let cmdWithComment = CloudBuildOperations.rejectCommand(buildID: "build-123", projectID: "test-project", comment: "Reason for rejection")
    #expect(cmdWithComment.contains("--comment=\"Reason for rejection\""))
}

// MARK: - Config Generator Tests

@Test func testDockerBuildPush() {
    let config = CloudBuildConfigGenerator.dockerBuildPush(
        imageName: "gcr.io/test-project/my-image"
    )

    #expect(config.contains("steps:"))
    #expect(config.contains("gcr.io/cloud-builders/docker"))
    #expect(config.contains("gcr.io/test-project/my-image:$COMMIT_SHA"))
    #expect(config.contains("gcr.io/test-project/my-image:latest"))
    #expect(config.contains("images:"))
}

@Test func testDockerBuildDeployCloudRun() {
    let config = CloudBuildConfigGenerator.dockerBuildDeployCloudRun(
        imageName: "us-central1-docker.pkg.dev/test-project/repo/image",
        serviceName: "my-service",
        region: "us-central1",
        envVars: ["ENV": "prod"],
        memory: "512Mi",
        cpu: "1",
        minInstances: 1,
        maxInstances: 10,
        allowUnauthenticated: true
    )

    #expect(config.contains("gcr.io/cloud-builders/docker"))
    #expect(config.contains("gcloud"))
    #expect(config.contains("run"))
    #expect(config.contains("deploy"))
    #expect(config.contains("my-service"))
    #expect(config.contains("--region=us-central1"))
    #expect(config.contains("--allow-unauthenticated"))
    #expect(config.contains("--memory=512Mi"))
    #expect(config.contains("--cpu=1"))
    #expect(config.contains("--min-instances=1"))
    #expect(config.contains("--max-instances=10"))
    #expect(config.contains("--set-env-vars=ENV=prod"))
}

@Test func testSwiftBuildTest() {
    let config = CloudBuildConfigGenerator.swiftBuildTest()

    #expect(config.contains("swift:5.10"))
    #expect(config.contains("swift build"))
    #expect(config.contains("swift test"))
}

@Test func testSwiftDockerCloudRun() {
    let config = CloudBuildConfigGenerator.swiftDockerCloudRun(
        imageName: "us-central1-docker.pkg.dev/test-project/repo/swift-app",
        serviceName: "swift-service",
        region: "us-central1",
        executableName: "my-server",
        port: 8080
    )

    #expect(config.contains("swift:5.10"))
    #expect(config.contains("swift build"))
    #expect(config.contains("swift test"))
    #expect(config.contains("gcr.io/cloud-builders/docker"))
    #expect(config.contains("swift-service"))
    #expect(config.contains("--port=8080"))
    #expect(config.contains("waitFor: ['test']"))
}

@Test func testMultiServiceDeploy() {
    let config = CloudBuildConfigGenerator.multiServiceDeploy(
        services: [
            (name: "api", imageName: "gcr.io/p/api", dockerfile: "api/Dockerfile", region: "us-central1"),
            (name: "web", imageName: "gcr.io/p/web", dockerfile: "web/Dockerfile", region: "us-central1")
        ]
    )

    #expect(config.contains("build-api"))
    #expect(config.contains("build-web"))
    #expect(config.contains("push-api"))
    #expect(config.contains("push-web"))
    #expect(config.contains("deploy-api"))
    #expect(config.contains("deploy-web"))
    #expect(config.contains("api/Dockerfile"))
    #expect(config.contains("web/Dockerfile"))
}

// MARK: - DAIS Cloud Build Template Tests

@Test func testDAISGitHubTrigger() {
    let trigger = DAISCloudBuildTemplate.githubTrigger(
        projectID: "test-project",
        deploymentName: "dais-prod",
        owner: "myorg",
        repo: "my-repo"
    )

    #expect(trigger.name == "dais-prod-deploy")
    #expect(trigger.tags.contains("dais"))
    #expect(trigger.tags.contains("dais-prod"))
    #expect(trigger.substitutions["DEPLOYMENT_NAME"] == "dais-prod")

    if case .github(let owner, let name, _) = trigger.triggerSource {
        #expect(owner == "myorg")
        #expect(name == "my-repo")
    }
}

@Test func testDAISPRPreviewTrigger() {
    let trigger = DAISCloudBuildTemplate.prPreviewTrigger(
        projectID: "test-project",
        deploymentName: "dais-prod",
        owner: "myorg",
        repo: "my-repo"
    )

    #expect(trigger.name == "dais-prod-pr-preview")
    #expect(trigger.tags.contains("preview"))

    if case .github(_, _, let eventConfig) = trigger.triggerSource {
        if case .pullRequest = eventConfig {
            // Expected
        } else {
            Issue.record("Expected pullRequest event config")
        }
    }
}

@Test func testDAISManualTrigger() {
    let trigger = DAISCloudBuildTemplate.manualTrigger(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(trigger.name == "dais-prod-manual")
    #expect(trigger.tags.contains("manual"))

    if case .manual = trigger.triggerSource {
        // Expected
    } else {
        Issue.record("Expected manual trigger source")
    }
}

@Test func testDAISCloudbuildYaml() {
    let yaml = DAISCloudBuildTemplate.cloudbuildYaml(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        cloudRunRegion: "us-central1",
        services: [
            (name: "api", port: 8080),
            (name: "worker", port: 8081)
        ]
    )

    #expect(yaml.contains("DAIS Cloud Build Configuration"))
    #expect(yaml.contains("dais-prod"))
    #expect(yaml.contains("build-api"))
    #expect(yaml.contains("build-worker"))
    #expect(yaml.contains("push-api"))
    #expect(yaml.contains("push-worker"))
    #expect(yaml.contains("deploy-api"))
    #expect(yaml.contains("deploy-worker"))
    #expect(yaml.contains("--port=8080"))
    #expect(yaml.contains("--port=8081"))
    #expect(yaml.contains("E2_HIGHCPU_8"))
    #expect(yaml.contains("timeout: '1800s'"))
}

@Test func testDAISSetupScript() {
    let script = DAISCloudBuildTemplate.setupScript(
        projectID: "test-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        githubOwner: "myorg",
        githubRepo: "my-repo",
        cloudRunRegion: "us-central1"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud services enable cloudbuild.googleapis.com"))
    #expect(script.contains("roles/artifactregistry.writer"))
    #expect(script.contains("roles/run.admin"))
    #expect(script.contains("roles/iam.serviceAccountUser"))
    #expect(script.contains("gcloud builds triggers create github"))
    #expect(script.contains("--repo-owner=myorg"))
    #expect(script.contains("--repo-name=my-repo"))
    #expect(script.contains("dais-prod-deploy"))
    #expect(script.contains("Cloud Build Setup Complete!"))
}

@Test func testDAISTeardownScript() {
    let script = DAISCloudBuildTemplate.teardownScript(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud builds triggers delete dais-prod-deploy"))
    #expect(script.contains("gcloud builds triggers delete dais-prod-pr-preview"))
    #expect(script.contains("gcloud builds triggers delete dais-prod-manual"))
    #expect(script.contains("teardown complete"))
}

@Test func testDAISWorkerPool() {
    let pool = DAISCloudBuildTemplate.workerPool(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(pool.name == "dais-prod-pool")
    #expect(pool.displayName == "DAIS dais-prod Worker Pool")
    #expect(pool.privatePoolConfig.workerConfig.machineType == "e2-standard-4")
    #expect(pool.privatePoolConfig.workerConfig.diskSizeGb == 100)
}

@Test func testDAISWorkerPoolWithVPC() {
    let pool = DAISCloudBuildTemplate.workerPool(
        projectID: "test-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        vpcNetwork: "projects/test-project/global/networks/my-vpc"
    )

    #expect(pool.privatePoolConfig.networkConfig != nil)
    #expect(pool.privatePoolConfig.networkConfig?.peeredNetwork == "projects/test-project/global/networks/my-vpc")
    #expect(pool.privatePoolConfig.networkConfig?.egressOption == .noPublicEgress)
}

// MARK: - Cloud Build Codable Tests

@Test func testBuildCodable() throws {
    let step = GoogleCloudBuild.BuildStep(name: "gcr.io/cloud-builders/docker", args: ["build", "."])
    let build = GoogleCloudBuild(
        projectID: "test-project",
        steps: [step],
        timeout: "600s"
    )
    let data = try JSONEncoder().encode(build)
    let decoded = try JSONDecoder().decode(GoogleCloudBuild.self, from: data)

    #expect(decoded.projectID == "test-project")
    #expect(decoded.steps.count == 1)
    #expect(decoded.timeout == "600s")
}

@Test func testBuildStepCodable() throws {
    let step = GoogleCloudBuild.BuildStep(
        name: "gcr.io/cloud-builders/docker",
        args: ["build", "."],
        env: ["KEY=value"],
        id: "build"
    )
    let data = try JSONEncoder().encode(step)
    let decoded = try JSONDecoder().decode(GoogleCloudBuild.BuildStep.self, from: data)

    #expect(decoded.name == "gcr.io/cloud-builders/docker")
    #expect(decoded.args == ["build", "."])
    #expect(decoded.id == "build")
}

@Test func testBuildTriggerCodable() throws {
    let trigger = GoogleCloudBuildTrigger(
        name: "my-trigger",
        projectID: "test-project",
        triggerSource: .manual,
        buildConfig: .filename("cloudbuild.yaml")
    )
    let data = try JSONEncoder().encode(trigger)
    let decoded = try JSONDecoder().decode(GoogleCloudBuildTrigger.self, from: data)

    #expect(decoded.name == "my-trigger")
    #expect(decoded.projectID == "test-project")
}

@Test func testWorkerPoolCodable() throws {
    let pool = GoogleCloudBuildWorkerPool(
        name: "my-pool",
        projectID: "test-project",
        region: "us-central1",
        privatePoolConfig: .init(workerConfig: .init(machineType: "e2-standard-4", diskSizeGb: 100))
    )
    let data = try JSONEncoder().encode(pool)
    let decoded = try JSONDecoder().decode(GoogleCloudBuildWorkerPool.self, from: data)

    #expect(decoded.name == "my-pool")
    #expect(decoded.privatePoolConfig.workerConfig.machineType == "e2-standard-4")
}

@Test func testConnectionCodable() throws {
    let conn = GoogleCloudBuildConnection(
        name: "github-conn",
        projectID: "test-project",
        region: "us-central1",
        connectionType: .github(appInstallationId: 12345)
    )
    let data = try JSONEncoder().encode(conn)
    let decoded = try JSONDecoder().decode(GoogleCloudBuildConnection.self, from: data)

    #expect(decoded.name == "github-conn")
    #expect(decoded.region == "us-central1")
}

@Test func testBuildRepositoryCodable() throws {
    let repo = GoogleCloudBuildRepository(
        name: "my-repo",
        projectID: "test-project",
        region: "us-central1",
        connectionName: "github-conn",
        remoteUri: "https://github.com/owner/repo.git"
    )
    let data = try JSONEncoder().encode(repo)
    let decoded = try JSONDecoder().decode(GoogleCloudBuildRepository.self, from: data)

    #expect(decoded.name == "my-repo")
    #expect(decoded.remoteUri == "https://github.com/owner/repo.git")
}

// MARK: - Cloud Armor Tests

@Test func testSecurityPolicyBasicInit() {
    let policy = GoogleCloudSecurityPolicy(
        name: "test-policy",
        projectID: "test-project",
        description: "Test security policy"
    )

    #expect(policy.name == "test-policy")
    #expect(policy.projectID == "test-project")
    #expect(policy.type == .cloudArmor)
    #expect(policy.resourceName == "projects/test-project/global/securityPolicies/test-policy")
}

@Test func testSecurityPolicyTypes() {
    #expect(GoogleCloudSecurityPolicy.PolicyType.cloudArmor.rawValue == "CLOUD_ARMOR")
    #expect(GoogleCloudSecurityPolicy.PolicyType.cloudArmorEdge.rawValue == "CLOUD_ARMOR_EDGE")
    #expect(GoogleCloudSecurityPolicy.PolicyType.cloudArmorNetwork.rawValue == "CLOUD_ARMOR_NETWORK")
}

@Test func testSecurityPolicyCreateCommand() {
    let policy = GoogleCloudSecurityPolicy(
        name: "my-policy",
        projectID: "test-project",
        description: "My security policy"
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("gcloud compute security-policies create my-policy"))
    #expect(cmd.contains("--project=test-project"))
    #expect(cmd.contains("--description=\"My security policy\""))
}

@Test func testSecurityPolicyDeleteCommand() {
    let policy = GoogleCloudSecurityPolicy(
        name: "my-policy",
        projectID: "test-project"
    )

    #expect(policy.deleteCommand == "gcloud compute security-policies delete my-policy --project=test-project --quiet")
}

@Test func testSecurityPolicyDescribeCommand() {
    let policy = GoogleCloudSecurityPolicy(
        name: "my-policy",
        projectID: "test-project"
    )

    #expect(policy.describeCommand == "gcloud compute security-policies describe my-policy --project=test-project")
}

@Test func testSecurityPolicyListCommand() {
    let cmd = GoogleCloudSecurityPolicy.listCommand(projectID: "test-project")
    #expect(cmd == "gcloud compute security-policies list --project=test-project")
}

@Test func testSecurityPolicyUpdateCommand() {
    let policy = GoogleCloudSecurityPolicy(
        name: "my-policy",
        projectID: "test-project"
    )

    let cmd = policy.updateCommand(
        enableAdaptiveProtection: true,
        logLevel: .verbose,
        jsonParsing: .standard
    )

    #expect(cmd.contains("gcloud compute security-policies update my-policy"))
    #expect(cmd.contains("--enable-layer7-ddos-defense=true"))
    #expect(cmd.contains("--log-level=VERBOSE"))
    #expect(cmd.contains("--json-parsing=STANDARD"))
}

@Test func testSecurityPolicyExportCommand() {
    let policy = GoogleCloudSecurityPolicy(
        name: "my-policy",
        projectID: "test-project"
    )

    #expect(policy.exportCommand.contains("gcloud compute security-policies export my-policy"))
    #expect(policy.exportCommand.contains("--file-name=my-policy-policy.yaml"))
}

@Test func testSecurityPolicyImportCommand() {
    let cmd = GoogleCloudSecurityPolicy.importCommand(
        name: "my-policy",
        projectID: "test-project",
        fileName: "policy.yaml"
    )

    #expect(cmd.contains("gcloud compute security-policies import my-policy"))
    #expect(cmd.contains("--file-name=policy.yaml"))
}

@Test func testAdaptiveProtectionConfig() {
    let config = GoogleCloudSecurityPolicy.AdaptiveProtectionConfig(
        layer7DdosDefenseConfig: .init(enable: true, ruleVisibility: .premium)
    )

    #expect(config.layer7DdosDefenseConfig?.enable == true)
    #expect(config.layer7DdosDefenseConfig?.ruleVisibility == .premium)
}

@Test func testAdvancedOptionsConfig() {
    let config = GoogleCloudSecurityPolicy.AdvancedOptionsConfig(
        jsonParsing: .standardWithGraphql,
        jsonCustomConfig: .init(contentTypes: ["application/json"]),
        logLevel: .verbose,
        userIpRequestHeaders: ["X-Forwarded-For"]
    )

    #expect(config.jsonParsing == .standardWithGraphql)
    #expect(config.logLevel == .verbose)
    #expect(config.userIpRequestHeaders == ["X-Forwarded-For"])
}

@Test func testDDoSProtectionConfig() {
    let standard = GoogleCloudSecurityPolicy.DDoSProtectionConfig(ddosProtection: .standard)
    let advanced = GoogleCloudSecurityPolicy.DDoSProtectionConfig(ddosProtection: .advanced)

    #expect(standard.ddosProtection == .standard)
    #expect(advanced.ddosProtection == .advanced)
}

@Test func testSecurityPolicyRuleIPRanges() {
    let rule = SecurityPolicyRule(
        priority: 1000,
        description: "Block bad IPs",
        match: .ipRanges(["192.168.1.0/24", "10.0.0.0/8"]),
        action: .deny403
    )

    #expect(rule.priority == 1000)
    #expect(rule.action == .deny403)
    #expect(rule.match.config?.srcIpRanges.count == 2)
}

@Test func testSecurityPolicyRuleExpression() {
    let rule = SecurityPolicyRule(
        priority: 2000,
        description: "Block countries",
        match: .expression("origin.region_code in ['CN', 'RU']"),
        action: .deny403
    )

    #expect(rule.match.expr?.expression == "origin.region_code in ['CN', 'RU']")
}

@Test func testSecurityPolicyRuleActions() {
    #expect(SecurityPolicyRule.Action.allow.rawValue == "allow")
    #expect(SecurityPolicyRule.Action.deny403.rawValue == "deny(403)")
    #expect(SecurityPolicyRule.Action.deny404.rawValue == "deny(404)")
    #expect(SecurityPolicyRule.Action.deny502.rawValue == "deny(502)")
    #expect(SecurityPolicyRule.Action.redirect.rawValue == "redirect")
    #expect(SecurityPolicyRule.Action.rateBased.rawValue == "rate_based_ban")
    #expect(SecurityPolicyRule.Action.throttle.rawValue == "throttle")
}

@Test func testSecurityPolicyRuleAddCommand() {
    let rule = SecurityPolicyRule(
        priority: 1000,
        description: "Test rule",
        match: .ipRanges(["10.0.0.0/8"]),
        action: .deny403,
        preview: true
    )

    let cmd = rule.addRuleCommand(policyName: "my-policy", projectID: "test-project")
    #expect(cmd.contains("gcloud compute security-policies rules create 1000"))
    #expect(cmd.contains("--security-policy=my-policy"))
    #expect(cmd.contains("--action=deny(403)"))
    #expect(cmd.contains("--src-ip-ranges=10.0.0.0/8"))
    #expect(cmd.contains("--preview"))
}

@Test func testSecurityPolicyRuleExpressionCommand() {
    let rule = SecurityPolicyRule(
        priority: 1000,
        match: .expression("origin.region_code == 'US'"),
        action: .allow
    )

    let cmd = rule.addRuleCommand(policyName: "my-policy", projectID: "test-project")
    #expect(cmd.contains("--expression=\"origin.region_code == 'US'\""))
}

@Test func testSecurityPolicyRuleDeleteCommand() {
    let rule = SecurityPolicyRule(
        priority: 1000,
        match: .ipRanges(["*"]),
        action: .allow
    )

    let cmd = rule.deleteRuleCommand(policyName: "my-policy", projectID: "test-project")
    #expect(cmd == "gcloud compute security-policies rules delete 1000 --security-policy=my-policy --project=test-project --quiet")
}

@Test func testRateLimitOptions() {
    let options = SecurityPolicyRule.RateLimitOptions(
        rateLimitThreshold: .init(count: 100, intervalSec: 60),
        conformAction: "allow",
        exceedAction: "deny(429)",
        enforceOnKey: .ip,
        banThreshold: .init(count: 200, intervalSec: 60),
        banDurationSec: 600
    )

    #expect(options.rateLimitThreshold?.count == 100)
    #expect(options.rateLimitThreshold?.intervalSec == 60)
    #expect(options.enforceOnKey == .ip)
    #expect(options.banDurationSec == 600)
}

@Test func testEnforceOnKeyTypes() {
    #expect(SecurityPolicyRule.RateLimitOptions.EnforceOnKey.all.rawValue == "ALL")
    #expect(SecurityPolicyRule.RateLimitOptions.EnforceOnKey.ip.rawValue == "IP")
    #expect(SecurityPolicyRule.RateLimitOptions.EnforceOnKey.httpHeader.rawValue == "HTTP_HEADER")
    #expect(SecurityPolicyRule.RateLimitOptions.EnforceOnKey.xffIP.rawValue == "XFF_IP")
    #expect(SecurityPolicyRule.RateLimitOptions.EnforceOnKey.httpCookie.rawValue == "HTTP_COOKIE")
    #expect(SecurityPolicyRule.RateLimitOptions.EnforceOnKey.regionCode.rawValue == "REGION_CODE")
}

@Test func testRedirectOptions() {
    let external = SecurityPolicyRule.RedirectOptions(type: .externalRedirect302, target: "https://example.com/blocked")
    let recaptcha = SecurityPolicyRule.RedirectOptions(type: .googleRecaptcha)

    #expect(external.type == .externalRedirect302)
    #expect(external.target == "https://example.com/blocked")
    #expect(recaptcha.type == .googleRecaptcha)
}

@Test func testHeaderAction() {
    let action = SecurityPolicyRule.HeaderAction(
        requestHeadersToAdds: [
            .init(headerName: "X-Cloud-Armor", headerValue: "protected"),
            .init(headerName: "X-Request-ID", headerValue: "abc123")
        ]
    )

    #expect(action.requestHeadersToAdds.count == 2)
    #expect(action.requestHeadersToAdds[0].headerName == "X-Cloud-Armor")
}

// MARK: - WAF Rules Tests

@Test func testWAFRuleSQLi() {
    #expect(WAFRule.sqli.rawValue.contains("sqli-v33-stable"))
    #expect(WAFRule.sqli.description == "SQL Injection protection")
    #expect(WAFRule.sqli.recommendedSensitivity == 1)
}

@Test func testWAFRuleXSS() {
    #expect(WAFRule.xss.rawValue.contains("xss-v33-stable"))
    #expect(WAFRule.xss.description == "Cross-Site Scripting (XSS) protection")
}

@Test func testWAFRuleRCE() {
    #expect(WAFRule.rce.rawValue.contains("rce-v33-stable"))
    #expect(WAFRule.rce.description == "Remote Code Execution protection")
}

@Test func testWAFRuleLFI() {
    #expect(WAFRule.lfi.rawValue.contains("lfi-v33-stable"))
    #expect(WAFRule.lfi.description == "Local File Inclusion protection")
}

@Test func testWAFRuleRFI() {
    #expect(WAFRule.rfi.rawValue.contains("rfi-v33-stable"))
    #expect(WAFRule.rfi.description == "Remote File Inclusion protection")
}

@Test func testWAFRuleLog4j() {
    #expect(WAFRule.cve202144228.rawValue.contains("cve-canary"))
    #expect(WAFRule.cve202144228.description == "Log4j CVE protection")
    #expect(WAFRule.cve202144228.recommendedSensitivity == 1)
}

@Test func testWAFRuleCanaryVersions() {
    #expect(WAFRule.sqliCanary.rawValue.contains("canary"))
    #expect(WAFRule.xssCanary.rawValue.contains("canary"))
    #expect(WAFRule.sqliCanary.recommendedSensitivity == 4)
}

// MARK: - Security Expressions Tests

@Test func testBlockCountriesExpression() {
    let expr = SecurityExpressions.blockCountries(["CN", "RU", "KP"])
    #expect(expr == "origin.region_code in ['CN', 'RU', 'KP']")
}

@Test func testAllowOnlyCountriesExpression() {
    let expr = SecurityExpressions.allowOnlyCountries(["US", "CA", "GB"])
    #expect(expr == "!(origin.region_code in ['US', 'CA', 'GB'])")
}

@Test func testBlockPathsExpression() {
    let expr = SecurityExpressions.blockPaths(["/admin.*", "/wp-admin.*"])
    #expect(expr.contains("request.path.matches('/admin.*')"))
    #expect(expr.contains("request.path.matches('/wp-admin.*')"))
}

@Test func testBlockUserAgentsExpression() {
    let expr = SecurityExpressions.blockUserAgents([".*curl.*", ".*wget.*"])
    #expect(expr.contains("request.headers['user-agent'].matches('.*curl.*')"))
}

@Test func testBlockBadBotsExpression() {
    let expr = SecurityExpressions.blockBadBots
    #expect(expr.contains("bot"))
    #expect(expr.contains("googlebot"))
}

@Test func testBlockEmptyUserAgentExpression() {
    let expr = SecurityExpressions.blockEmptyUserAgent
    #expect(expr.contains("request.headers['user-agent']"))
}

@Test func testMatchMethodsExpression() {
    let expr = SecurityExpressions.matchMethods(["POST", "PUT", "DELETE"])
    #expect(expr.contains("request.method == 'POST'"))
    #expect(expr.contains("request.method == 'PUT'"))
    #expect(expr.contains("request.method == 'DELETE'"))
}

@Test func testMatchAPIPathsExpression() {
    let expr = SecurityExpressions.matchAPIPaths(prefix: "/api/v1")
    #expect(expr == "request.path.startsWith('/api/v1')")
}

@Test func testCombineWAFRulesExpression() {
    let expr = SecurityExpressions.combineWAFRules([.sqli, .xss])
    #expect(expr.contains("sqli-v33-stable"))
    #expect(expr.contains("xss-v33-stable"))
    #expect(expr.contains(" || "))
}

// MARK: - Cloud Armor Operations Tests

@Test func testCloudArmorEnableAPICommand() {
    let cmd = CloudArmorOperations.enableAPICommand(projectID: "test-project")
    #expect(cmd == "gcloud services enable compute.googleapis.com --project=test-project")
}

@Test func testAttachToBackendServiceCommand() {
    let cmd = CloudArmorOperations.attachToBackendService(
        policyName: "my-policy",
        backendServiceName: "my-backend",
        projectID: "test-project"
    )

    #expect(cmd.contains("gcloud compute backend-services update my-backend"))
    #expect(cmd.contains("--security-policy=my-policy"))
    #expect(cmd.contains("--global"))
}

@Test func testDetachFromBackendServiceCommand() {
    let cmd = CloudArmorOperations.detachFromBackendService(
        backendServiceName: "my-backend",
        projectID: "test-project"
    )

    #expect(cmd.contains("gcloud compute backend-services update my-backend"))
    #expect(cmd.contains("--security-policy="))
}

@Test func testAttachEdgePolicyCommand() {
    let cmd = CloudArmorOperations.attachEdgePolicy(
        policyName: "edge-policy",
        backendServiceName: "my-backend",
        projectID: "test-project"
    )

    #expect(cmd.contains("--edge-security-policy=edge-policy"))
}

@Test func testArmorListRulesCommand() {
    let cmd = CloudArmorOperations.listRulesCommand(policyName: "my-policy", projectID: "test-project")
    #expect(cmd == "gcloud compute security-policies rules list --security-policy=my-policy --project=test-project")
}

@Test func testArmorDescribeRuleCommand() {
    let cmd = CloudArmorOperations.describeRuleCommand(priority: 1000, policyName: "my-policy", projectID: "test-project")
    #expect(cmd == "gcloud compute security-policies rules describe 1000 --security-policy=my-policy --project=test-project")
}

@Test func testViewLogsCommand() {
    let cmd = CloudArmorOperations.viewLogsCommand(projectID: "test-project", policyName: "my-policy")
    #expect(cmd.contains("gcloud logging read"))
    #expect(cmd.contains("http_load_balancer"))
    #expect(cmd.contains("my-policy"))
}

@Test func testViewBlockedRequestsCommand() {
    let cmd = CloudArmorOperations.viewBlockedRequestsCommand(projectID: "test-project")
    #expect(cmd.contains("DENY"))
}

@Test func testCreateRateLimitRuleCommand() {
    let cmd = CloudArmorOperations.createRateLimitRule(
        policyName: "my-policy",
        projectID: "test-project",
        priority: 2000,
        requestsPerInterval: 100,
        intervalSec: 60,
        enforceOnKey: .ip,
        banDurationSec: 600
    )

    #expect(cmd.contains("gcloud compute security-policies rules create 2000"))
    #expect(cmd.contains("--action=throttle"))
    #expect(cmd.contains("--rate-limit-threshold-count=100"))
    #expect(cmd.contains("--rate-limit-threshold-interval-sec=60"))
    #expect(cmd.contains("--enforce-on-key=IP"))
    #expect(cmd.contains("--ban-duration-sec=600"))
}

@Test func testAddWAFRuleCommand() {
    let cmd = CloudArmorOperations.addWAFRule(
        policyName: "my-policy",
        projectID: "test-project",
        priority: 1000,
        wafRule: .sqli,
        action: .deny403,
        preview: true
    )

    #expect(cmd.contains("gcloud compute security-policies rules create 1000"))
    #expect(cmd.contains("--action=deny(403)"))
    #expect(cmd.contains("sqli-v33-stable"))
    #expect(cmd.contains("--preview"))
}

// MARK: - DAIS Cloud Armor Template Tests

@Test func testDAISSecurityPolicy() {
    let policy = DAISCloudArmorTemplate.securityPolicy(
        projectID: "test-project",
        deploymentName: "dais-prod"
    )

    #expect(policy.name == "dais-prod-security-policy")
    #expect(policy.adaptiveProtectionConfig?.layer7DdosDefenseConfig?.enable == true)
    #expect(policy.advancedOptionsConfig?.jsonParsing == .standard)
    #expect(policy.labels["deployment"] == "dais-prod")
}

@Test func testDAISDefaultAllowRule() {
    let rule = DAISCloudArmorTemplate.defaultAllowRule()

    #expect(rule.priority == 2147483647)
    #expect(rule.action == .allow)
}

@Test func testDAISOWASPProtectionRule() {
    let rule = DAISCloudArmorTemplate.owaspProtectionRule(priority: 1000)

    #expect(rule.priority == 1000)
    #expect(rule.action == .deny403)
    #expect(rule.match.expr?.expression.contains("sqli") == true)
    #expect(rule.match.expr?.expression.contains("xss") == true)
}

@Test func testDAISRCEProtectionRule() {
    let rule = DAISCloudArmorTemplate.rceProtectionRule()

    #expect(rule.action == .deny403)
    #expect(rule.match.expr?.expression.contains("rce") == true)
    #expect(rule.match.expr?.expression.contains("lfi") == true)
    #expect(rule.match.expr?.expression.contains("rfi") == true)
}

@Test func testDAISLog4jProtectionRule() {
    let rule = DAISCloudArmorTemplate.log4jProtectionRule()

    #expect(rule.priority == 900)
    #expect(rule.match.expr?.expression.contains("cve") == true)
}

@Test func testDAISAPIRateLimitRule() {
    let rule = DAISCloudArmorTemplate.apiRateLimitRule(priority: 2000, requestsPerMinute: 100)

    #expect(rule.priority == 2000)
    #expect(rule.action == .throttle)
    #expect(rule.rateLimitOptions?.rateLimitThreshold?.count == 100)
    #expect(rule.rateLimitOptions?.rateLimitThreshold?.intervalSec == 60)
    #expect(rule.rateLimitOptions?.enforceOnKey == .ip)
}

@Test func testDAISGeoBlockRule() {
    let rule = DAISCloudArmorTemplate.geoBlockRule(
        priority: 500,
        blockedCountries: ["CN", "RU"]
    )

    #expect(rule.priority == 500)
    #expect(rule.action == .deny403)
    #expect(rule.match.expr?.expression.contains("CN") == true)
    #expect(rule.match.expr?.expression.contains("RU") == true)
}

@Test func testDAISGeoAllowRule() {
    let rule = DAISCloudArmorTemplate.geoAllowRule(
        priority: 500,
        allowedCountries: ["US", "CA"]
    )

    #expect(rule.match.expr?.expression.contains("!(origin.region_code in") == true)
}

@Test func testDAISBotProtectionRule() {
    let rule = DAISCloudArmorTemplate.botProtectionRule()

    #expect(rule.priority == 1500)
    #expect(rule.action == .deny403)
}

@Test func testDAISLoginRateLimitRule() {
    let rule = DAISCloudArmorTemplate.loginRateLimitRule(
        priority: 1800,
        loginPath: "/auth/login",
        requestsPerMinute: 5,
        banDurationSec: 300
    )

    #expect(rule.priority == 1800)
    #expect(rule.action == .rateBased)
    #expect(rule.rateLimitOptions?.banDurationSec == 300)
    #expect(rule.match.expr?.expression.contains("/auth/login") == true)
}

@Test func testDAISArmorSetupScript() {
    let script = DAISCloudArmorTemplate.setupScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        backendServiceName: "dais-backend",
        enableGeoBlocking: true,
        blockedCountries: ["CN", "RU"]
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud compute security-policies create"))
    #expect(script.contains("dais-prod-security-policy"))
    #expect(script.contains("--enable-layer7-ddos-defense"))
    #expect(script.contains("sqli"))
    #expect(script.contains("xss"))
    #expect(script.contains("'CN', 'RU'"))
    #expect(script.contains("dais-backend"))
    #expect(script.contains("Cloud Armor Setup Complete!"))
}

@Test func testDAISArmorTeardownScript() {
    let script = DAISCloudArmorTemplate.teardownScript(
        projectID: "test-project",
        deploymentName: "dais-prod",
        backendServiceName: "dais-backend"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("gcloud compute backend-services update dais-backend"))
    #expect(script.contains("--security-policy="))
    #expect(script.contains("gcloud compute security-policies delete"))
    #expect(script.contains("teardown complete"))
}

@Test func testDAISPolicyYAML() {
    let yaml = DAISCloudArmorTemplate.policyYAML(
        projectID: "test-project",
        deploymentName: "dais-prod",
        enableAdaptiveProtection: true,
        enableWAF: true,
        enableRateLimiting: true,
        rateLimit: 200
    )

    #expect(yaml.contains("name: dais-prod-security-policy"))
    #expect(yaml.contains("layer7DdosDefenseConfig"))
    #expect(yaml.contains("enable: true"))
    #expect(yaml.contains("Log4j CVE"))
    #expect(yaml.contains("SQL Injection"))
    #expect(yaml.contains("XSS"))
    #expect(yaml.contains("count: 200"))
    #expect(yaml.contains("priority: 2147483647"))
}

// MARK: - Cloud Armor Codable Tests

@Test func testSecurityPolicyCodable() throws {
    let policy = GoogleCloudSecurityPolicy(
        name: "test-policy",
        projectID: "test-project",
        description: "Test",
        type: .cloudArmor
    )
    let data = try JSONEncoder().encode(policy)
    let decoded = try JSONDecoder().decode(GoogleCloudSecurityPolicy.self, from: data)

    #expect(decoded.name == "test-policy")
    #expect(decoded.type == .cloudArmor)
}

@Test func testSecurityPolicyRuleCodable() throws {
    let rule = SecurityPolicyRule(
        priority: 1000,
        description: "Test rule",
        match: .ipRanges(["10.0.0.0/8"]),
        action: .deny403
    )
    let data = try JSONEncoder().encode(rule)
    let decoded = try JSONDecoder().decode(SecurityPolicyRule.self, from: data)

    #expect(decoded.priority == 1000)
    #expect(decoded.action == .deny403)
}

@Test func testRateLimitOptionsCodable() throws {
    let options = SecurityPolicyRule.RateLimitOptions(
        rateLimitThreshold: .init(count: 100, intervalSec: 60),
        enforceOnKey: .ip
    )
    let data = try JSONEncoder().encode(options)
    let decoded = try JSONDecoder().decode(SecurityPolicyRule.RateLimitOptions.self, from: data)

    #expect(decoded.rateLimitThreshold?.count == 100)
    #expect(decoded.enforceOnKey == .ip)
}

@Test func testAdaptiveProtectionConfigCodable() throws {
    let config = GoogleCloudSecurityPolicy.AdaptiveProtectionConfig(
        layer7DdosDefenseConfig: .init(enable: true, ruleVisibility: .premium)
    )
    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(GoogleCloudSecurityPolicy.AdaptiveProtectionConfig.self, from: data)

    #expect(decoded.layer7DdosDefenseConfig?.enable == true)
    #expect(decoded.layer7DdosDefenseConfig?.ruleVisibility == .premium)
}

// MARK: - Cloud CDN Tests

@Test func testCDNCachePolicyBasicInit() {
    let policy = CDNCachePolicy(
        cacheMode: .cacheAllStatic,
        defaultTTL: 3600,
        maxTTL: 86400
    )

    #expect(policy.cacheMode == .cacheAllStatic)
    #expect(policy.defaultTTL == 3600)
    #expect(policy.maxTTL == 86400)
    #expect(policy.negativeCaching == false)
}

@Test func testCDNCacheModeValues() {
    #expect(CDNCachePolicy.CacheMode.useOriginHeaders.rawValue == "USE_ORIGIN_HEADERS")
    #expect(CDNCachePolicy.CacheMode.forceCacheAll.rawValue == "FORCE_CACHE_ALL")
    #expect(CDNCachePolicy.CacheMode.cacheAllStatic.rawValue == "CACHE_ALL_STATIC")
}

@Test func testCDNCacheModeDescriptions() {
    #expect(CDNCachePolicy.CacheMode.useOriginHeaders.description.contains("Cache-Control"))
    #expect(CDNCachePolicy.CacheMode.forceCacheAll.description.contains("Cache all"))
    #expect(CDNCachePolicy.CacheMode.cacheAllStatic.description.contains("static"))
}

@Test func testCDNCachePolicyWithNegativeCaching() {
    let policy = CDNCachePolicy(
        cacheMode: .cacheAllStatic,
        negativeCaching: true,
        negativeCachingPolicy: [
            .init(code: 404, ttl: 60),
            .init(code: 500, ttl: 10)
        ]
    )

    #expect(policy.negativeCaching == true)
    #expect(policy.negativeCachingPolicy?.count == 2)
    #expect(policy.negativeCachingPolicy?[0].code == 404)
    #expect(policy.negativeCachingPolicy?[0].ttl == 60)
}

@Test func testCDNCacheKeyPolicy() {
    let keyPolicy = CDNCachePolicy.CacheKeyPolicy(
        includeHost: true,
        includeProtocol: false,
        includeQueryString: true,
        queryStringWhitelist: ["page", "limit"],
        includeHttpHeaders: ["Accept-Language"]
    )

    #expect(keyPolicy.includeHost == true)
    #expect(keyPolicy.includeProtocol == false)
    #expect(keyPolicy.includeQueryString == true)
    #expect(keyPolicy.queryStringWhitelist?.count == 2)
    #expect(keyPolicy.includeHttpHeaders?.contains("Accept-Language") == true)
}

@Test func testCDNBackendBucketCreateCommand() {
    let bucket = CDNBackendBucket(
        name: "my-assets",
        projectID: "my-project",
        bucketName: "my-storage-bucket",
        enableCDN: true
    )

    let cmd = bucket.createCommand
    #expect(cmd.contains("backend-buckets create my-assets"))
    #expect(cmd.contains("--gcs-bucket-name=my-storage-bucket"))
    #expect(cmd.contains("--enable-cdn"))
    #expect(cmd.contains("--project=my-project"))
}

@Test func testCDNBackendBucketWithCompression() {
    let bucket = CDNBackendBucket(
        name: "compressed-assets",
        projectID: "my-project",
        bucketName: "my-bucket",
        compressionMode: .automatic
    )

    let cmd = bucket.createCommand
    #expect(cmd.contains("--compression-mode=AUTOMATIC"))
}

@Test func testCDNBackendBucketDeleteCommand() {
    let bucket = CDNBackendBucket(
        name: "my-assets",
        projectID: "my-project",
        bucketName: "my-bucket"
    )

    #expect(bucket.deleteCommand.contains("backend-buckets delete my-assets"))
    #expect(bucket.deleteCommand.contains("--quiet"))
}

@Test func testCDNBackendBucketDescribeCommand() {
    let bucket = CDNBackendBucket(
        name: "my-assets",
        projectID: "my-project",
        bucketName: "my-bucket"
    )

    #expect(bucket.describeCommand.contains("backend-buckets describe my-assets"))
}

@Test func testCDNBackendBucketListCommand() {
    let cmd = CDNBackendBucket.listCommand(projectID: "my-project")
    #expect(cmd.contains("backend-buckets list"))
    #expect(cmd.contains("--project=my-project"))
}

@Test func testCDNSignedURLKeyAddToBackendBucket() {
    let key = CDNSignedURLKey(keyName: "my-key", keyValue: "secret-value")

    let cmd = key.addToBackendBucketCommand(backendBucket: "my-bucket", projectID: "my-project")
    #expect(cmd.contains("backend-buckets add-signed-url-key my-bucket"))
    #expect(cmd.contains("--key-name=my-key"))
}

@Test func testCDNSignedURLKeyAddToBackendService() {
    let key = CDNSignedURLKey(keyName: "my-key", keyValue: "secret-value")

    let cmd = key.addToBackendServiceCommand(backendService: "my-service", projectID: "my-project")
    #expect(cmd.contains("backend-services add-signed-url-key my-service"))
    #expect(cmd.contains("--key-name=my-key"))
}

@Test func testCDNSignedURLKeyDelete() {
    let bucketCmd = CDNSignedURLKey.deleteFromBackendBucketCommand(
        keyName: "my-key",
        backendBucket: "my-bucket",
        projectID: "my-project"
    )
    #expect(bucketCmd.contains("delete-signed-url-key my-bucket"))

    let serviceCmd = CDNSignedURLKey.deleteFromBackendServiceCommand(
        keyName: "my-key",
        backendService: "my-service",
        projectID: "my-project"
    )
    #expect(serviceCmd.contains("delete-signed-url-key my-service"))
}

@Test func testCDNSignedURLGeneratorCommand() {
    let cmd = CDNSignedURLGenerator.signURLCommand(
        url: "https://example.com/file.mp4",
        keyName: "my-key",
        keyFilePath: "/path/to/key",
        expiresIn: "2h"
    )

    #expect(cmd.contains("compute sign-url"))
    #expect(cmd.contains("--key-name=my-key"))
    #expect(cmd.contains("--expires-in=2h"))
}

@Test func testCDNCacheInvalidationCommand() {
    let invalidation = CDNCacheInvalidation(
        urlMap: "my-url-map",
        projectID: "my-project",
        path: "/images/*"
    )

    let cmd = invalidation.invalidateCommand
    #expect(cmd.contains("invalidate-cdn-cache my-url-map"))
    #expect(cmd.contains("--path=\"/images/*\""))
}

@Test func testCDNCacheInvalidationWithHost() {
    let invalidation = CDNCacheInvalidation(
        urlMap: "my-url-map",
        projectID: "my-project",
        path: "/api/*",
        host: "api.example.com"
    )

    let cmd = invalidation.invalidateCommand
    #expect(cmd.contains("--host=api.example.com"))
}

@Test func testCDNCacheInvalidateAllCommand() {
    let cmd = CDNCacheInvalidation.invalidateAllCommand(
        urlMap: "my-url-map",
        projectID: "my-project"
    )
    #expect(cmd.contains("--path=\"/*\""))
}

@Test func testCDNEdgeSecurityPolicyCreateCommand() {
    let policy = CDNEdgeSecurityPolicy(
        name: "my-edge-policy",
        projectID: "my-project",
        description: "Edge security"
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("security-policies create my-edge-policy"))
    #expect(cmd.contains("--type=CLOUD_ARMOR_EDGE"))
}

@Test func testCDNEdgeSecurityPolicyAttachCommands() {
    let policy = CDNEdgeSecurityPolicy(
        name: "my-edge-policy",
        projectID: "my-project"
    )

    let bucketCmd = policy.attachToBackendBucketCommand(backendBucket: "my-bucket")
    #expect(bucketCmd.contains("backend-buckets update my-bucket"))
    #expect(bucketCmd.contains("--edge-security-policy=my-edge-policy"))

    let serviceCmd = policy.attachToBackendServiceCommand(backendService: "my-service")
    #expect(serviceCmd.contains("backend-services update my-service"))
    #expect(serviceCmd.contains("--edge-security-policy=my-edge-policy"))
}

@Test func testCDNOperationsEnableCDN() {
    let cmd = CDNOperations.enableCDNOnBackendService(
        backendService: "my-service",
        projectID: "my-project",
        cacheMode: .forceCacheAll
    )

    #expect(cmd.contains("--enable-cdn"))
    #expect(cmd.contains("--cache-mode=FORCE_CACHE_ALL"))
}

@Test func testCDNOperationsDisableCDN() {
    let cmd = CDNOperations.disableCDNOnBackendService(
        backendService: "my-service",
        projectID: "my-project"
    )

    #expect(cmd.contains("--no-enable-cdn"))
}

@Test func testCDNOperationsSetCacheTTL() {
    let cmd = CDNOperations.setCacheTTL(
        backendService: "my-service",
        projectID: "my-project",
        defaultTTL: 3600,
        maxTTL: 86400,
        clientTTL: 1800
    )

    #expect(cmd.contains("--default-ttl=3600"))
    #expect(cmd.contains("--max-ttl=86400"))
    #expect(cmd.contains("--client-ttl=1800"))
}

@Test func testCDNOperationsNegativeCaching() {
    let cmd = CDNOperations.enableNegativeCaching(
        backendService: "my-service",
        projectID: "my-project"
    )

    #expect(cmd.contains("--negative-caching"))
}

@Test func testCDNOperationsServeWhileStale() {
    let cmd = CDNOperations.setServeWhileStale(
        backendService: "my-service",
        projectID: "my-project",
        seconds: 86400
    )

    #expect(cmd.contains("--serve-while-stale=86400"))
}

@Test func testCDNOperationsCacheKeyPolicy() {
    let cmd = CDNOperations.setCacheKeyPolicy(
        backendService: "my-service",
        projectID: "my-project",
        includeHost: true,
        includeProtocol: false,
        includeQueryString: true,
        queryStringWhitelist: ["page", "sort"]
    )

    #expect(cmd.contains("--cache-key-include-host"))
    #expect(cmd.contains("--no-cache-key-include-protocol"))
    #expect(cmd.contains("--cache-key-include-query-string"))
    #expect(cmd.contains("--cache-key-query-string-whitelist=page,sort"))
}

@Test func testDAISCDNTemplateStaticAssetsBucket() {
    let bucket = DAISCDNTemplate.staticAssetsBucket(
        projectID: "my-project",
        deploymentName: "dais-prod",
        storageBucket: "dais-static-bucket"
    )

    #expect(bucket.name == "dais-prod-static-assets")
    #expect(bucket.enableCDN == true)
    #expect(bucket.cdnPolicy?.cacheMode == .cacheAllStatic)
    #expect(bucket.compressionMode == .automatic)
}

@Test func testDAISCDNTemplateApiCachePolicy() {
    let policy = DAISCDNTemplate.apiCachePolicy()

    #expect(policy.cacheMode == .useOriginHeaders)
    #expect(policy.defaultTTL == 60)
    #expect(policy.serveWhileStale == 86400)
    #expect(policy.bypassCacheOnRequestHeaders?.count == 2)
}

@Test func testDAISCDNTemplateMediaCachePolicy() {
    let policy = DAISCDNTemplate.mediaCachePolicy()

    #expect(policy.cacheMode == .forceCacheAll)
    #expect(policy.defaultTTL == 2592000) // 30 days
    #expect(policy.maxTTL == 31536000) // 1 year
}

@Test func testDAISCDNTemplateEdgeSecurityPolicy() {
    let policy = DAISCDNTemplate.edgeSecurityPolicy(
        projectID: "my-project",
        deploymentName: "dais-prod"
    )

    #expect(policy.name == "dais-prod-cdn-edge-policy")
}

@Test func testDAISCDNTemplateSetupScript() {
    let script = DAISCDNTemplate.setupScript(
        projectID: "my-project",
        deploymentName: "dais-prod",
        storageBucket: "my-bucket",
        urlMap: "my-url-map"
    )

    #expect(script.contains("backend-buckets create"))
    #expect(script.contains("--enable-cdn"))
    #expect(script.contains("url-maps add-path-matcher"))
}

@Test func testDAISCDNTemplateTeardownScript() {
    let script = DAISCDNTemplate.teardownScript(
        projectID: "my-project",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("backend-buckets delete"))
}

@Test func testDAISCDNTemplateStandardHeaders() {
    let headers = DAISCDNTemplate.standardResponseHeaders
    #expect(headers.contains("X-Cache-Status: {cdn_cache_status}"))
    #expect(headers.contains { $0.contains("Strict-Transport-Security") })
}

@Test func testCDNCachePolicyCodable() throws {
    let policy = CDNCachePolicy(
        cacheMode: .cacheAllStatic,
        defaultTTL: 3600,
        maxTTL: 86400,
        negativeCaching: true
    )

    let data = try JSONEncoder().encode(policy)
    let decoded = try JSONDecoder().decode(CDNCachePolicy.self, from: data)

    #expect(decoded.cacheMode == .cacheAllStatic)
    #expect(decoded.defaultTTL == 3600)
    #expect(decoded.negativeCaching == true)
}

@Test func testCDNBackendBucketCodable() throws {
    let bucket = CDNBackendBucket(
        name: "my-bucket",
        projectID: "my-project",
        bucketName: "storage-bucket",
        enableCDN: true
    )

    let data = try JSONEncoder().encode(bucket)
    let decoded = try JSONDecoder().decode(CDNBackendBucket.self, from: data)

    #expect(decoded.name == "my-bucket")
    #expect(decoded.enableCDN == true)
}

@Test func testCDNCacheInvalidationCodable() throws {
    let invalidation = CDNCacheInvalidation(
        urlMap: "my-map",
        projectID: "my-project",
        path: "/images/*",
        host: "cdn.example.com"
    )

    let data = try JSONEncoder().encode(invalidation)
    let decoded = try JSONDecoder().decode(CDNCacheInvalidation.self, from: data)

    #expect(decoded.urlMap == "my-map")
    #expect(decoded.path == "/images/*")
    #expect(decoded.host == "cdn.example.com")
}

// MARK: - Cloud Tasks Tests

@Test func testTaskQueueBasicInit() {
    let queue = GoogleCloudTaskQueue(
        name: "my-queue",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(queue.name == "my-queue")
    #expect(queue.projectID == "my-project")
    #expect(queue.location == "us-central1")
}

@Test func testTaskQueueResourceName() {
    let queue = GoogleCloudTaskQueue(
        name: "my-queue",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(queue.resourceName == "projects/my-project/locations/us-central1/queues/my-queue")
}

@Test func testTaskQueueCreateCommand() {
    let queue = GoogleCloudTaskQueue(
        name: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        rateLimits: GoogleCloudTaskQueue.RateLimits(
            maxDispatchesPerSecond: 100,
            maxConcurrentDispatches: 10
        ),
        retryConfig: GoogleCloudTaskQueue.RetryConfig(
            maxAttempts: 5,
            minBackoff: "1s",
            maxBackoff: "60s"
        )
    )

    let cmd = queue.createCommand
    #expect(cmd.contains("tasks queues create my-queue"))
    #expect(cmd.contains("--location=us-central1"))
    #expect(cmd.contains("--max-dispatches-per-second=100"))
    #expect(cmd.contains("--max-concurrent-dispatches=10"))
    #expect(cmd.contains("--max-attempts=5"))
    #expect(cmd.contains("--min-backoff=1s"))
    #expect(cmd.contains("--max-backoff=60s"))
}

@Test func testTaskQueueDeleteCommand() {
    let queue = GoogleCloudTaskQueue(
        name: "my-queue",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(queue.deleteCommand.contains("tasks queues delete my-queue"))
    #expect(queue.deleteCommand.contains("--quiet"))
}

@Test func testTaskQueuePauseResumeCommands() {
    let queue = GoogleCloudTaskQueue(
        name: "my-queue",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(queue.pauseCommand.contains("tasks queues pause my-queue"))
    #expect(queue.resumeCommand.contains("tasks queues resume my-queue"))
}

@Test func testTaskQueuePurgeCommand() {
    let queue = GoogleCloudTaskQueue(
        name: "my-queue",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(queue.purgeCommand.contains("tasks queues purge my-queue"))
    #expect(queue.purgeCommand.contains("--quiet"))
}

@Test func testTaskQueueListCommand() {
    let cmd = GoogleCloudTaskQueue.listCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("tasks queues list"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testHTTPTaskCreateCommand() {
    let task = GoogleCloudHTTPTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        url: "https://example.com/endpoint",
        httpMethod: .post,
        headers: ["Content-Type": "application/json"],
        body: "{\"key\": \"value\"}"
    )

    let cmd = task.createCommand
    #expect(cmd.contains("tasks create-http-task"))
    #expect(cmd.contains("--queue=my-queue"))
    #expect(cmd.contains("--url=\"https://example.com/endpoint\""))
    #expect(cmd.contains("--method=POST"))
}

@Test func testHTTPTaskWithOIDCToken() {
    let task = GoogleCloudHTTPTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        url: "https://my-service.run.app/endpoint",
        oidcToken: GoogleCloudHTTPTask.OIDCToken(
            serviceAccountEmail: "sa@project.iam.gserviceaccount.com",
            audience: "https://my-service.run.app"
        )
    )

    let cmd = task.createCommand
    #expect(cmd.contains("--oidc-service-account-email=sa@project.iam.gserviceaccount.com"))
    #expect(cmd.contains("--oidc-token-audience=https://my-service.run.app"))
}

@Test func testHTTPTaskWithOAuthToken() {
    let task = GoogleCloudHTTPTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        url: "https://api.example.com/endpoint",
        oauthToken: GoogleCloudHTTPTask.OAuthToken(
            serviceAccountEmail: "sa@project.iam.gserviceaccount.com",
            scope: "https://www.googleapis.com/auth/cloud-platform"
        )
    )

    let cmd = task.createCommand
    #expect(cmd.contains("--oauth-service-account-email=sa@project.iam.gserviceaccount.com"))
    #expect(cmd.contains("--oauth-token-scope="))
}

@Test func testHTTPTaskWithTaskID() {
    let task = GoogleCloudHTTPTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        url: "https://example.com/endpoint",
        taskID: "my-task-123"
    )

    let cmd = task.createCommand
    #expect(cmd.contains("create-http-task my-task-123"))
}

@Test func testHTTPMethodValues() {
    #expect(GoogleCloudHTTPTask.HTTPMethod.get.rawValue == "GET")
    #expect(GoogleCloudHTTPTask.HTTPMethod.post.rawValue == "POST")
    #expect(GoogleCloudHTTPTask.HTTPMethod.put.rawValue == "PUT")
    #expect(GoogleCloudHTTPTask.HTTPMethod.delete.rawValue == "DELETE")
    #expect(GoogleCloudHTTPTask.HTTPMethod.patch.rawValue == "PATCH")
}

@Test func testAppEngineTaskCreateCommand() {
    let task = GoogleCloudAppEngineTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        relativeUri: "/process",
        httpMethod: .post,
        body: "{\"data\": \"test\"}"
    )

    let cmd = task.createCommand
    #expect(cmd.contains("tasks create-app-engine-task"))
    #expect(cmd.contains("--relative-uri=\"/process\""))
    #expect(cmd.contains("--method=POST"))
}

@Test func testAppEngineTaskWithRouting() {
    let task = GoogleCloudAppEngineTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        relativeUri: "/process",
        appEngineRouting: GoogleCloudAppEngineTask.AppEngineRouting(
            service: "worker",
            version: "v1"
        )
    )

    let cmd = task.createCommand
    #expect(cmd.contains("--routing=\"service:worker\""))
}

@Test func testTaskOperationsDescribeTask() {
    let cmd = TaskOperations.describeTask(
        taskID: "task-123",
        queueName: "my-queue",
        location: "us-central1",
        projectID: "my-project"
    )

    #expect(cmd.contains("tasks describe task-123"))
    #expect(cmd.contains("--queue=my-queue"))
}

@Test func testTaskOperationsDeleteTask() {
    let cmd = TaskOperations.deleteTask(
        taskID: "task-123",
        queueName: "my-queue",
        location: "us-central1",
        projectID: "my-project"
    )

    #expect(cmd.contains("tasks delete task-123"))
    #expect(cmd.contains("--quiet"))
}

@Test func testTaskOperationsRunTask() {
    let cmd = TaskOperations.runTask(
        taskID: "task-123",
        queueName: "my-queue",
        location: "us-central1",
        projectID: "my-project"
    )

    #expect(cmd.contains("tasks run task-123"))
}

@Test func testTaskOperationsListTasks() {
    let cmd = TaskOperations.listTasks(
        queueName: "my-queue",
        location: "us-central1",
        projectID: "my-project"
    )

    #expect(cmd.contains("tasks list"))
    #expect(cmd.contains("--queue=my-queue"))
}

@Test func testTaskOperationsAddIAMBinding() {
    let cmd = TaskOperations.addIAMBinding(
        queueName: "my-queue",
        location: "us-central1",
        projectID: "my-project",
        member: "serviceAccount:sa@project.iam.gserviceaccount.com",
        role: "roles/cloudtasks.enqueuer"
    )

    #expect(cmd.contains("add-iam-policy-binding"))
    #expect(cmd.contains("--role=\"roles/cloudtasks.enqueuer\""))
}

@Test func testTaskQueueRoleValues() {
    #expect(TaskQueueRole.admin.rawValue == "roles/cloudtasks.admin")
    #expect(TaskQueueRole.enqueuer.rawValue == "roles/cloudtasks.enqueuer")
    #expect(TaskQueueRole.taskDeleter.rawValue == "roles/cloudtasks.taskDeleter")
    #expect(TaskQueueRole.viewer.rawValue == "roles/cloudtasks.viewer")
}

@Test func testTaskQueueRoleDescriptions() {
    #expect(TaskQueueRole.admin.description.contains("Full control"))
    #expect(TaskQueueRole.enqueuer.description.contains("create tasks"))
}

@Test func testDAISTasksTemplateAPIProcessingQueue() {
    let queue = DAISTasksTemplate.apiProcessingQueue(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(queue.name == "dais-prod-api-processing")
    #expect(queue.rateLimits?.maxDispatchesPerSecond == 500)
    #expect(queue.retryConfig?.maxAttempts == 5)
}

@Test func testDAISTasksTemplateBackgroundJobsQueue() {
    let queue = DAISTasksTemplate.backgroundJobsQueue(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(queue.name == "dais-prod-background-jobs")
    #expect(queue.rateLimits?.maxDispatchesPerSecond == 100)
    #expect(queue.retryConfig?.maxAttempts == 10)
}

@Test func testDAISTasksTemplateHighPriorityQueue() {
    let queue = DAISTasksTemplate.highPriorityQueue(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(queue.name == "dais-prod-high-priority")
    #expect(queue.rateLimits?.maxDispatchesPerSecond == 1000)
}

@Test func testDAISTasksTemplateCloudRunTask() {
    let task = DAISTasksTemplate.cloudRunTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        cloudRunURL: "https://my-service.run.app",
        endpoint: "/process",
        payload: "{\"data\": \"test\"}",
        serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
    )

    #expect(task.url == "https://my-service.run.app/process")
    #expect(task.oidcToken?.serviceAccountEmail == "sa@project.iam.gserviceaccount.com")
}

@Test func testDAISTasksTemplateSetupScript() {
    let script = DAISTasksTemplate.setupScript(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("cloudtasks.googleapis.com"))
    #expect(script.contains("tasks queues create"))
    #expect(script.contains("api-processing"))
}

@Test func testDAISTasksTemplateTeardownScript() {
    let script = DAISTasksTemplate.teardownScript(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("tasks queues delete"))
}

@Test func testTaskQueueCodable() throws {
    let queue = GoogleCloudTaskQueue(
        name: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        rateLimits: GoogleCloudTaskQueue.RateLimits(maxDispatchesPerSecond: 100)
    )

    let data = try JSONEncoder().encode(queue)
    let decoded = try JSONDecoder().decode(GoogleCloudTaskQueue.self, from: data)

    #expect(decoded.name == "my-queue")
    #expect(decoded.rateLimits?.maxDispatchesPerSecond == 100)
}

@Test func testHTTPTaskCodable() throws {
    let task = GoogleCloudHTTPTask(
        queueName: "my-queue",
        projectID: "my-project",
        location: "us-central1",
        url: "https://example.com/endpoint",
        httpMethod: .post
    )

    let data = try JSONEncoder().encode(task)
    let decoded = try JSONDecoder().decode(GoogleCloudHTTPTask.self, from: data)

    #expect(decoded.url == "https://example.com/endpoint")
    #expect(decoded.httpMethod == .post)
}

// MARK: - Cloud KMS Tests

@Test func testKeyRingBasicInit() {
    let keyRing = GoogleCloudKeyRing(
        name: "my-keyring",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(keyRing.name == "my-keyring")
    #expect(keyRing.location == "us-central1")
}

@Test func testKeyRingResourceName() {
    let keyRing = GoogleCloudKeyRing(
        name: "my-keyring",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(keyRing.resourceName == "projects/my-project/locations/us-central1/keyRings/my-keyring")
}

@Test func testKeyRingCreateCommand() {
    let keyRing = GoogleCloudKeyRing(
        name: "my-keyring",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = keyRing.createCommand
    #expect(cmd.contains("kms keyrings create my-keyring"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testKeyRingListCommand() {
    let cmd = GoogleCloudKeyRing.listCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("kms keyrings list"))
}

@Test func testKeyRingAddIAMBinding() {
    let keyRing = GoogleCloudKeyRing(
        name: "my-keyring",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = keyRing.addIAMBindingCommand(member: "user:test@example.com", role: "roles/cloudkms.admin")
    #expect(cmd.contains("add-iam-policy-binding"))
    #expect(cmd.contains("--member=\"user:test@example.com\""))
}

@Test func testCryptoKeyBasicInit() {
    let key = GoogleCloudCryptoKey(
        name: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1",
        purpose: .encryptDecrypt,
        protectionLevel: .software
    )

    #expect(key.name == "my-key")
    #expect(key.purpose == .encryptDecrypt)
    #expect(key.protectionLevel == .software)
}

@Test func testCryptoKeyResourceName() {
    let key = GoogleCloudCryptoKey(
        name: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(key.resourceName == "projects/my-project/locations/us-central1/keyRings/my-keyring/cryptoKeys/my-key")
}

@Test func testCryptoKeyCreateCommand() {
    let key = GoogleCloudCryptoKey(
        name: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1",
        purpose: .asymmetricSign,
        protectionLevel: .hsm,
        rotationPeriod: "7776000s"
    )

    let cmd = key.createCommand
    #expect(cmd.contains("kms keys create my-key"))
    #expect(cmd.contains("--keyring=my-keyring"))
    #expect(cmd.contains("--purpose=asymmetric-signing"))
    #expect(cmd.contains("--protection-level=hsm"))
    #expect(cmd.contains("--rotation-period=7776000s"))
}

@Test func testCryptoKeyWithLabels() {
    let key = GoogleCloudCryptoKey(
        name: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1",
        labels: ["env": "prod", "team": "security"]
    )

    let cmd = key.createCommand
    #expect(cmd.contains("--labels="))
}

@Test func testKeyPurposeValues() {
    #expect(GoogleCloudCryptoKey.KeyPurpose.encryptDecrypt.rawValue == "encryption")
    #expect(GoogleCloudCryptoKey.KeyPurpose.asymmetricSign.rawValue == "asymmetric-signing")
    #expect(GoogleCloudCryptoKey.KeyPurpose.asymmetricDecrypt.rawValue == "asymmetric-encryption")
    #expect(GoogleCloudCryptoKey.KeyPurpose.mac.rawValue == "mac")
}

@Test func testProtectionLevelValues() {
    #expect(GoogleCloudCryptoKey.ProtectionLevel.software.rawValue == "software")
    #expect(GoogleCloudCryptoKey.ProtectionLevel.hsm.rawValue == "hsm")
    #expect(GoogleCloudCryptoKey.ProtectionLevel.external.rawValue == "external")
}

@Test func testCryptoKeyVersionResourceName() {
    let version = GoogleCloudCryptoKeyVersion(
        keyName: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1",
        version: "1"
    )

    #expect(version.resourceName.contains("cryptoKeyVersions/1"))
}

@Test func testCryptoKeyVersionCommands() {
    let version = GoogleCloudCryptoKeyVersion(
        keyName: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1",
        version: "1"
    )

    #expect(version.disableCommand.contains("versions disable 1"))
    #expect(version.enableCommand.contains("versions enable 1"))
    #expect(version.destroyCommand.contains("versions destroy 1"))
}

@Test func testCryptoKeyVersionGetPublicKey() {
    let version = GoogleCloudCryptoKeyVersion(
        keyName: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1",
        version: "1"
    )

    #expect(version.getPublicKeyCommand.contains("get-public-key 1"))
}

@Test func testKMSOperationsEncrypt() {
    let cmd = KMSOperations.encryptCommand(
        keyName: "my-key",
        keyRing: "my-keyring",
        location: "us-central1",
        projectID: "my-project",
        plaintextFile: "input.txt",
        ciphertextFile: "output.enc"
    )

    #expect(cmd.contains("kms encrypt"))
    #expect(cmd.contains("--plaintext-file=input.txt"))
    #expect(cmd.contains("--ciphertext-file=output.enc"))
}

@Test func testKMSOperationsDecrypt() {
    let cmd = KMSOperations.decryptCommand(
        keyName: "my-key",
        keyRing: "my-keyring",
        location: "us-central1",
        projectID: "my-project",
        ciphertextFile: "input.enc",
        plaintextFile: "output.txt"
    )

    #expect(cmd.contains("kms decrypt"))
    #expect(cmd.contains("--ciphertext-file=input.enc"))
}

@Test func testKMSOperationsAsymmetricSign() {
    let cmd = KMSOperations.asymmetricSignCommand(
        keyName: "my-key",
        keyRing: "my-keyring",
        location: "us-central1",
        projectID: "my-project",
        version: "1",
        inputFile: "data.txt",
        signatureFile: "sig.bin"
    )

    #expect(cmd.contains("asymmetric-sign"))
    #expect(cmd.contains("--version=1"))
}

@Test func testKMSOperationsMacSign() {
    let cmd = KMSOperations.macSignCommand(
        keyName: "my-key",
        keyRing: "my-keyring",
        location: "us-central1",
        projectID: "my-project",
        version: "1",
        inputFile: "data.txt",
        signatureFile: "mac.bin"
    )

    #expect(cmd.contains("mac-sign"))
}

@Test func testKMSRoleValues() {
    #expect(KMSRole.admin.rawValue == "roles/cloudkms.admin")
    #expect(KMSRole.cryptoKeyEncrypter.rawValue == "roles/cloudkms.cryptoKeyEncrypter")
    #expect(KMSRole.cryptoKeyDecrypter.rawValue == "roles/cloudkms.cryptoKeyDecrypter")
    #expect(KMSRole.signer.rawValue == "roles/cloudkms.signer")
}

@Test func testKMSRoleDescriptions() {
    #expect(KMSRole.admin.description.contains("Full control"))
    #expect(KMSRole.cryptoKeyEncrypter.description.contains("Encrypt"))
}

@Test func testDAISKMSTemplateKeyRing() {
    let keyRing = DAISKMSTemplate.keyRing(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(keyRing.name == "dais-prod-keyring")
}

@Test func testDAISKMSTemplateDataEncryptionKey() {
    let key = DAISKMSTemplate.dataEncryptionKey(
        projectID: "my-project",
        location: "us-central1",
        keyRing: "dais-prod-keyring",
        deploymentName: "dais-prod"
    )

    #expect(key.name == "dais-prod-data-key")
    #expect(key.purpose == .encryptDecrypt)
    #expect(key.rotationPeriod == "7776000s")
}

@Test func testDAISKMSTemplateHSMKey() {
    let key = DAISKMSTemplate.hsmEncryptionKey(
        projectID: "my-project",
        location: "us-central1",
        keyRing: "dais-prod-keyring",
        deploymentName: "dais-prod"
    )

    #expect(key.name == "dais-prod-hsm-key")
    #expect(key.protectionLevel == .hsm)
}

@Test func testDAISKMSTemplateSigningKey() {
    let key = DAISKMSTemplate.signingKey(
        projectID: "my-project",
        location: "us-central1",
        keyRing: "dais-prod-keyring",
        deploymentName: "dais-prod"
    )

    #expect(key.name == "dais-prod-signing-key")
    #expect(key.purpose == .asymmetricSign)
}

@Test func testDAISKMSTemplateSetupScript() {
    let script = DAISKMSTemplate.setupScript(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("cloudkms.googleapis.com"))
    #expect(script.contains("kms keyrings create"))
    #expect(script.contains("kms keys create"))
}

@Test func testDAISKMSTemplateGrantEncrypter() {
    let cmd = DAISKMSTemplate.grantEncrypterCommand(
        keyName: "my-key",
        keyRing: "my-keyring",
        location: "us-central1",
        projectID: "my-project",
        serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
    )

    #expect(cmd.contains("add-iam-policy-binding"))
    #expect(cmd.contains("cryptoKeyEncrypter"))
}

@Test func testKeyRingCodable() throws {
    let keyRing = GoogleCloudKeyRing(
        name: "my-keyring",
        projectID: "my-project",
        location: "us-central1"
    )

    let data = try JSONEncoder().encode(keyRing)
    let decoded = try JSONDecoder().decode(GoogleCloudKeyRing.self, from: data)

    #expect(decoded.name == "my-keyring")
}

@Test func testCryptoKeyCodable() throws {
    let key = GoogleCloudCryptoKey(
        name: "my-key",
        keyRing: "my-keyring",
        projectID: "my-project",
        location: "us-central1",
        purpose: .encryptDecrypt,
        protectionLevel: .software
    )

    let data = try JSONEncoder().encode(key)
    let decoded = try JSONDecoder().decode(GoogleCloudCryptoKey.self, from: data)

    #expect(decoded.name == "my-key")
    #expect(decoded.purpose == .encryptDecrypt)
}

// MARK: - Eventarc Tests

@Test func testEventarcTriggerBasicInit() {
    let trigger = GoogleCloudEventarcTrigger(
        name: "my-trigger",
        projectID: "my-project",
        location: "us-central1",
        destination: .cloudRun(service: "my-service", path: nil, region: nil),
        eventFilters: [
            EventFilter(attribute: "type", value: "google.cloud.storage.object.v1.finalized")
        ]
    )

    #expect(trigger.name == "my-trigger")
    #expect(trigger.location == "us-central1")
}

@Test func testEventarcTriggerResourceName() {
    let trigger = GoogleCloudEventarcTrigger(
        name: "my-trigger",
        projectID: "my-project",
        location: "us-central1",
        destination: .cloudRun(service: "my-service", path: nil, region: nil),
        eventFilters: []
    )

    #expect(trigger.resourceName == "projects/my-project/locations/us-central1/triggers/my-trigger")
}

@Test func testEventarcTriggerCreateCommand() {
    let trigger = GoogleCloudEventarcTrigger(
        name: "my-trigger",
        projectID: "my-project",
        location: "us-central1",
        destination: .cloudRun(service: "my-service", path: "/events", region: "us-central1"),
        eventFilters: [
            EventFilter(attribute: "type", value: "google.cloud.storage.object.v1.finalized"),
            EventFilter(attribute: "bucket", value: "my-bucket")
        ],
        serviceAccount: "sa@project.iam.gserviceaccount.com"
    )

    let cmd = trigger.createCommand
    #expect(cmd.contains("eventarc triggers create my-trigger"))
    #expect(cmd.contains("--destination-run-service=my-service"))
    #expect(cmd.contains("--service-account=sa@project.iam.gserviceaccount.com"))
}

@Test func testEventarcTriggerDeleteCommand() {
    let trigger = GoogleCloudEventarcTrigger(
        name: "my-trigger",
        projectID: "my-project",
        location: "us-central1",
        destination: .cloudRun(service: "my-service", path: nil, region: nil),
        eventFilters: []
    )

    #expect(trigger.deleteCommand.contains("eventarc triggers delete my-trigger"))
    #expect(trigger.deleteCommand.contains("--quiet"))
}

@Test func testEventarcDestinationCloudRun() {
    let dest = GoogleCloudEventarcTrigger.Destination.cloudRun(
        service: "my-service",
        path: "/webhook",
        region: "us-central1"
    )

    let flag = dest.gcloudFlag
    #expect(flag.contains("--destination-run-service=my-service"))
    #expect(flag.contains("--destination-run-path=/webhook"))
}

@Test func testEventarcDestinationCloudFunction() {
    let dest = GoogleCloudEventarcTrigger.Destination.cloudFunction(
        name: "my-function",
        region: "us-central1"
    )

    let flag = dest.gcloudFlag
    #expect(flag.contains("--destination-function=my-function"))
}

@Test func testEventarcDestinationWorkflow() {
    let dest = GoogleCloudEventarcTrigger.Destination.workflow(
        name: "my-workflow",
        region: "us-central1"
    )

    let flag = dest.gcloudFlag
    #expect(flag.contains("--destination-workflow=my-workflow"))
}

@Test func testEventFilterBasic() {
    let filter = EventFilter(attribute: "type", value: "google.cloud.storage.object.v1.finalized")

    #expect(filter.gcloudFlag.contains("--event-filters="))
    #expect(filter.gcloudFlag.contains("type=google.cloud.storage.object.v1.finalized"))
}

@Test func testEventFilterPathPattern() {
    let filter = EventFilter(
        attribute: "document",
        value: "users/{userId}",
        operator: .pathPattern
    )

    #expect(filter.gcloudFlag.contains("--event-filters-path-pattern="))
}

@Test func testEventarcChannelCreateCommand() {
    let channel = GoogleCloudEventarcChannel(
        name: "my-channel",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = channel.createCommand
    #expect(cmd.contains("eventarc channels create my-channel"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testEventarcChannelWithCryptoKey() {
    let channel = GoogleCloudEventarcChannel(
        name: "my-channel",
        projectID: "my-project",
        location: "us-central1",
        cryptoKeyName: "projects/my-project/locations/us-central1/keyRings/my-ring/cryptoKeys/my-key"
    )

    let cmd = channel.createCommand
    #expect(cmd.contains("--crypto-key="))
}

@Test func testGoogleCloudEventTypeValues() {
    #expect(GoogleCloudEventType.storageObjectFinalize.rawValue == "google.cloud.storage.object.v1.finalized")
    #expect(GoogleCloudEventType.pubsubMessagePublish.rawValue == "google.cloud.pubsub.topic.v1.messagePublished")
    #expect(GoogleCloudEventType.cloudBuildComplete.rawValue == "google.cloud.cloudbuild.build.v1.statusChanged")
}

@Test func testGoogleCloudEventTypeDescriptions() {
    #expect(GoogleCloudEventType.storageObjectFinalize.description.contains("Cloud Storage"))
    #expect(GoogleCloudEventType.pubsubMessagePublish.description.contains("Pub/Sub"))
}

@Test func testEventarcOperationsListProviders() {
    let cmd = EventarcOperations.listProvidersCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("eventarc providers list"))
}

@Test func testEventarcOperationsCreateStorageTrigger() {
    let cmd = EventarcOperations.createStorageTrigger(
        name: "storage-trigger",
        projectID: "my-project",
        location: "us-central1",
        bucket: "my-bucket",
        eventType: .storageObjectFinalize,
        destinationService: "my-service",
        serviceAccount: "sa@project.iam.gserviceaccount.com"
    )

    #expect(cmd.contains("eventarc triggers create storage-trigger"))
    #expect(cmd.contains("bucket=my-bucket"))
}

@Test func testDAISEventarcTemplateStorageUploadTrigger() {
    let trigger = DAISEventarcTemplate.storageUploadTrigger(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        bucket: "dais-uploads",
        destinationService: "dais-api",
        serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
    )

    #expect(trigger.name == "dais-prod-storage-upload")
    #expect(trigger.eventFilters.count == 2)
}

@Test func testDAISEventarcTemplatePubsubTrigger() {
    let trigger = DAISEventarcTemplate.pubsubMessageTrigger(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        destinationService: "dais-api",
        serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
    )

    #expect(trigger.name == "dais-prod-pubsub-events")
}

@Test func testDAISEventarcTemplateSetupScript() {
    let script = DAISEventarcTemplate.setupScript(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        serviceAccountEmail: "sa@project.iam.gserviceaccount.com"
    )

    #expect(script.contains("eventarc.googleapis.com"))
    #expect(script.contains("eventarc.eventReceiver"))
}

@Test func testEventarcTriggerCodable() throws {
    let trigger = GoogleCloudEventarcTrigger(
        name: "my-trigger",
        projectID: "my-project",
        location: "us-central1",
        destination: .cloudRun(service: "my-service", path: nil, region: nil),
        eventFilters: [
            EventFilter(attribute: "type", value: "test-event")
        ]
    )

    let data = try JSONEncoder().encode(trigger)
    let decoded = try JSONDecoder().decode(GoogleCloudEventarcTrigger.self, from: data)

    #expect(decoded.name == "my-trigger")
}

@Test func testEventarcChannelCodable() throws {
    let channel = GoogleCloudEventarcChannel(
        name: "my-channel",
        projectID: "my-project",
        location: "us-central1"
    )

    let data = try JSONEncoder().encode(channel)
    let decoded = try JSONDecoder().decode(GoogleCloudEventarcChannel.self, from: data)

    #expect(decoded.name == "my-channel")
}

// MARK: - Cloud Memorystore Tests

@Test func testRedisInstanceBasicInit() {
    let instance = GoogleCloudRedisInstance(
        name: "my-redis",
        projectID: "my-project",
        region: "us-central1",
        tier: .basic,
        memorySizeGB: 2
    )

    #expect(instance.name == "my-redis")
    #expect(instance.tier == .basic)
    #expect(instance.memorySizeGB == 2)
}

@Test func testRedisInstanceResourceName() {
    let instance = GoogleCloudRedisInstance(
        name: "my-redis",
        projectID: "my-project",
        region: "us-central1"
    )

    #expect(instance.resourceName == "projects/my-project/locations/us-central1/instances/my-redis")
}

@Test func testRedisInstanceCreateCommand() {
    let instance = GoogleCloudRedisInstance(
        name: "my-redis",
        projectID: "my-project",
        region: "us-central1",
        tier: .standardHa,
        memorySizeGB: 5,
        redisVersion: .redis7_0,
        authEnabled: true
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("redis instances create my-redis"))
    #expect(cmd.contains("--tier=standard"))
    #expect(cmd.contains("--size=5"))
    #expect(cmd.contains("--enable-auth"))
}

@Test func testRedisInstanceDeleteCommand() {
    let instance = GoogleCloudRedisInstance(
        name: "my-redis",
        projectID: "my-project",
        region: "us-central1"
    )

    #expect(instance.deleteCommand.contains("redis instances delete my-redis"))
    #expect(instance.deleteCommand.contains("--quiet"))
}

@Test func testRedisInstanceFailoverCommand() {
    let instance = GoogleCloudRedisInstance(
        name: "my-redis",
        projectID: "my-project",
        region: "us-central1",
        tier: .standardHa
    )

    #expect(instance.failoverCommand.contains("redis instances failover my-redis"))
}

@Test func testRedisTierValues() {
    #expect(GoogleCloudRedisInstance.Tier.basic.rawValue == "basic")
    #expect(GoogleCloudRedisInstance.Tier.standardHa.rawValue == "standard")
}

@Test func testRedisVersionValues() {
    #expect(GoogleCloudRedisInstance.RedisVersion.redis7_0.rawValue == "REDIS_7_0")
    #expect(GoogleCloudRedisInstance.RedisVersion.redis6_x.rawValue == "REDIS_6_X")
    #expect(GoogleCloudRedisInstance.RedisVersion.redis7_0.versionString == "7.0")
}

@Test func testMemcachedInstanceBasicInit() {
    let instance = GoogleCloudMemcachedInstance(
        name: "my-memcached",
        projectID: "my-project",
        region: "us-central1",
        nodeCount: 3
    )

    #expect(instance.name == "my-memcached")
    #expect(instance.nodeCount == 3)
}

@Test func testMemcachedInstanceCreateCommand() {
    let instance = GoogleCloudMemcachedInstance(
        name: "my-memcached",
        projectID: "my-project",
        region: "us-central1",
        nodeCount: 3,
        nodeCPUs: 2,
        nodeMemoryMB: 2048
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("memcache instances create my-memcached"))
    #expect(cmd.contains("--node-count=3"))
    #expect(cmd.contains("--node-cpu=2"))
    #expect(cmd.contains("--node-memory=2048MB"))
}

@Test func testMemorystoreOperationsGetConnection() {
    let cmd = MemorystoreOperations.getRedisConnectionCommand(
        instanceName: "my-redis",
        region: "us-central1",
        projectID: "my-project"
    )

    #expect(cmd.contains("redis instances describe my-redis"))
    #expect(cmd.contains("value(host,port)"))
}

@Test func testMemorystoreOperationsScaleRedis() {
    let cmd = MemorystoreOperations.scaleRedisCommand(
        instanceName: "my-redis",
        region: "us-central1",
        projectID: "my-project",
        newSizeGB: 10
    )

    #expect(cmd.contains("redis instances update"))
    #expect(cmd.contains("--size=10"))
}

@Test func testDAISMemorystoreTemplateCacheInstance() {
    let instance = DAISMemorystoreTemplate.cacheInstance(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(instance.name == "dais-prod-cache")
    #expect(instance.tier == .basic)
    #expect(instance.redisConfigs?["maxmemory-policy"] == "allkeys-lru")
}

@Test func testDAISMemorystoreTemplateSessionStore() {
    let instance = DAISMemorystoreTemplate.sessionStoreInstance(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(instance.name == "dais-prod-sessions")
    #expect(instance.tier == .standardHa)
    #expect(instance.authEnabled == true)
}

@Test func testDAISMemorystoreTemplateHACluster() {
    let instance = DAISMemorystoreTemplate.haClusterInstance(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        replicaCount: 2
    )

    #expect(instance.name == "dais-prod-ha-redis")
    #expect(instance.replicaCount == 2)
    #expect(instance.readReplicasMode == .readReplicasEnabled)
}

@Test func testDAISMemorystoreTemplateConnectionStrings() {
    let basic = DAISMemorystoreTemplate.redisConnectionString(host: "10.0.0.1")
    #expect(basic == "redis://10.0.0.1:6379")

    let withAuth = DAISMemorystoreTemplate.redisConnectionStringWithAuth(
        host: "10.0.0.1",
        authString: "secret123"
    )
    #expect(withAuth.contains("secret123"))
}

@Test func testRedisInstanceCodable() throws {
    let instance = GoogleCloudRedisInstance(
        name: "my-redis",
        projectID: "my-project",
        region: "us-central1",
        tier: .standardHa,
        memorySizeGB: 5
    )

    let data = try JSONEncoder().encode(instance)
    let decoded = try JSONDecoder().decode(GoogleCloudRedisInstance.self, from: data)

    #expect(decoded.name == "my-redis")
    #expect(decoded.tier == .standardHa)
}

@Test func testMemcachedInstanceCodable() throws {
    let instance = GoogleCloudMemcachedInstance(
        name: "my-memcached",
        projectID: "my-project",
        region: "us-central1",
        nodeCount: 3
    )

    let data = try JSONEncoder().encode(instance)
    let decoded = try JSONDecoder().decode(GoogleCloudMemcachedInstance.self, from: data)

    #expect(decoded.name == "my-memcached")
    #expect(decoded.nodeCount == 3)
}

// MARK: - VPC Service Controls Tests

@Test func testAccessPolicyBasicInit() {
    let policy = GoogleCloudAccessPolicy(
        name: "12345678",
        organizationID: "org-123",
        title: "My Policy"
    )

    #expect(policy.name == "12345678")
    #expect(policy.organizationID == "org-123")
    #expect(policy.resourceName == "accessPolicies/12345678")
}

@Test func testAccessPolicyCreateCommand() {
    let policy = GoogleCloudAccessPolicy(
        name: "my-policy",
        organizationID: "org-123",
        title: "Production Policy"
    )

    let cmd = policy.createCommand
    #expect(cmd.contains("access-context-manager policies create"))
    #expect(cmd.contains("--organization=org-123"))
    #expect(cmd.contains("--title=\"Production Policy\""))
}

@Test func testAccessPolicyListCommand() {
    let cmd = GoogleCloudAccessPolicy.listCommand(organizationID: "org-456")
    #expect(cmd.contains("policies list"))
    #expect(cmd.contains("--organization=org-456"))
}

@Test func testServicePerimeterBasicInit() {
    let perimeter = GoogleCloudServicePerimeter(
        name: "my-perimeter",
        policyID: "12345678",
        title: "Data Protection",
        resources: ["projects/123456"],
        restrictedServices: ["storage.googleapis.com"]
    )

    #expect(perimeter.name == "my-perimeter")
    #expect(perimeter.perimeterType == .regular)
    #expect(perimeter.resourceName == "accessPolicies/12345678/servicePerimeters/my-perimeter")
}

@Test func testServicePerimeterCreateCommand() {
    let perimeter = GoogleCloudServicePerimeter(
        name: "data-perimeter",
        policyID: "policy-123",
        title: "Data Protection Perimeter",
        description: "Protects data services",
        resources: ["projects/123", "projects/456"],
        restrictedServices: ["storage.googleapis.com", "bigquery.googleapis.com"],
        accessLevels: ["corp-network"]
    )

    let cmd = perimeter.createCommand
    #expect(cmd.contains("perimeters create data-perimeter"))
    #expect(cmd.contains("--policy=policy-123"))
    #expect(cmd.contains("--title=\"Data Protection Perimeter\""))
    #expect(cmd.contains("--description=\"Protects data services\""))
    #expect(cmd.contains("--resources=projects/123,projects/456"))
    #expect(cmd.contains("--restricted-services=storage.googleapis.com,bigquery.googleapis.com"))
    #expect(cmd.contains("--access-levels=corp-network"))
}

@Test func testServicePerimeterBridgeType() {
    let perimeter = GoogleCloudServicePerimeter(
        name: "bridge-perimeter",
        policyID: "policy-123",
        title: "Bridge",
        perimeterType: .bridge,
        resources: ["projects/123", "projects/456"]
    )

    let cmd = perimeter.createCommand
    #expect(cmd.contains("--perimeter-type=bridge"))
}

@Test func testServicePerimeterUpdateResources() {
    let perimeter = GoogleCloudServicePerimeter(
        name: "test-perimeter",
        policyID: "policy-123",
        title: "Test"
    )

    let addCmd = perimeter.addResourcesCommand(resources: ["projects/789"])
    #expect(addCmd.contains("perimeters update test-perimeter"))
    #expect(addCmd.contains("--add-resources=projects/789"))

    let removeCmd = perimeter.removeResourcesCommand(resources: ["projects/123"])
    #expect(removeCmd.contains("--remove-resources=projects/123"))
}

@Test func testServicePerimeterVPCAccessibleServices() {
    let perimeter = GoogleCloudServicePerimeter(
        name: "vpc-perimeter",
        policyID: "policy-123",
        title: "VPC Services",
        vpcAccessibleServices: GoogleCloudServicePerimeter.VPCAccessibleServices(
            enableRestriction: true,
            allowedServices: ["storage.googleapis.com"]
        )
    )

    let cmd = perimeter.createCommand
    #expect(cmd.contains("--enable-vpc-accessible-services"))
    #expect(cmd.contains("--vpc-allowed-services=storage.googleapis.com"))
}

@Test func testAccessLevelBasicInit() {
    let level = GoogleCloudAccessLevel(
        name: "corp-network",
        policyID: "policy-123",
        title: "Corporate Network"
    )

    #expect(level.name == "corp-network")
    #expect(level.resourceName == "accessPolicies/policy-123/accessLevels/corp-network")
}

@Test func testAccessLevelWithIPCondition() {
    let level = GoogleCloudAccessLevel(
        name: "office-access",
        policyID: "policy-123",
        title: "Office Access",
        basic: GoogleCloudAccessLevel.BasicLevel(
            conditions: [
                GoogleCloudAccessLevel.BasicLevel.Condition(
                    ipSubnetworks: ["10.0.0.0/8", "192.168.0.0/16"]
                )
            ]
        )
    )

    let cmd = level.createCommand
    #expect(cmd.contains("levels create office-access"))
    #expect(cmd.contains("--policy=policy-123"))
    #expect(cmd.contains("ipSubnetworks"))
}

@Test func testAccessLevelCustomExpression() {
    let level = GoogleCloudAccessLevel(
        name: "custom-level",
        policyID: "policy-123",
        title: "Custom Access",
        custom: GoogleCloudAccessLevel.CustomLevel(
            expression: "request.auth.claims.email.endsWith('@company.com')"
        )
    )

    let cmd = level.createCommand
    #expect(cmd.contains("--custom-level-spec"))
}

@Test func testRestrictedServicesCommon() {
    #expect(RestrictedServices.storage == "storage.googleapis.com")
    #expect(RestrictedServices.bigquery == "bigquery.googleapis.com")
    #expect(RestrictedServices.kms == "cloudkms.googleapis.com")
    #expect(RestrictedServices.allCommon.contains("storage.googleapis.com"))
    #expect(RestrictedServices.dataStorage.contains("bigquery.googleapis.com"))
    #expect(RestrictedServices.aiML.contains("aiplatform.googleapis.com"))
}

@Test func testVPCServiceControlsOperationsEnableAPI() {
    let cmd = VPCServiceControlsOperations.enableAPICommand(projectID: "my-project")
    #expect(cmd.contains("services enable accesscontextmanager.googleapis.com"))
    #expect(cmd.contains("--project=my-project"))
}

@Test func testVPCServiceControlsOperationsDryRun() {
    let commitCmd = VPCServiceControlsOperations.commitDryRunCommand(
        perimeterName: "test-perimeter",
        policyID: "policy-123"
    )
    #expect(commitCmd.contains("dry-run enforce test-perimeter"))

    let clearCmd = VPCServiceControlsOperations.clearDryRunCommand(
        perimeterName: "test-perimeter",
        policyID: "policy-123"
    )
    #expect(clearCmd.contains("dry-run drop test-perimeter"))
}

@Test func testDAISVPCServiceControlsTemplateAccessPolicy() {
    let policy = DAISVPCServiceControlsTemplate.accessPolicy(
        organizationID: "org-123",
        deploymentName: "dais-prod"
    )

    #expect(policy.name == "dais-prod-policy")
    #expect(policy.title.contains("dais-prod"))
}

@Test func testDAISVPCServiceControlsTemplateCorporateNetworkLevel() {
    let level = DAISVPCServiceControlsTemplate.corporateNetworkLevel(
        policyID: "policy-123",
        deploymentName: "dais-prod",
        corporateCIDRs: ["10.0.0.0/8", "172.16.0.0/12"]
    )

    #expect(level.name == "dais-prod-corporate-network")
    #expect(level.basic?.conditions.first?.ipSubnetworks?.contains("10.0.0.0/8") == true)
}

@Test func testDAISVPCServiceControlsTemplateDataProtectionPerimeter() {
    let perimeter = DAISVPCServiceControlsTemplate.dataProtectionPerimeter(
        policyID: "policy-123",
        deploymentName: "dais-prod",
        projectNumbers: ["123456789", "987654321"]
    )

    #expect(perimeter.name == "dais-prod-data-protection")
    #expect(perimeter.resources.contains("projects/123456789"))
    #expect(perimeter.restrictedServices.contains("storage.googleapis.com"))
}

@Test func testDAISVPCServiceControlsTemplateBridgePerimeter() {
    let perimeter = DAISVPCServiceControlsTemplate.bridgePerimeter(
        policyID: "policy-123",
        deploymentName: "dais-prod",
        projectNumbers: ["123", "456"]
    )

    #expect(perimeter.perimeterType == .bridge)
    #expect(perimeter.name == "dais-prod-bridge")
}

@Test func testDAISVPCServiceControlsTemplateComprehensivePerimeter() {
    let perimeter = DAISVPCServiceControlsTemplate.comprehensivePerimeter(
        policyID: "policy-123",
        deploymentName: "dais-prod",
        projectNumbers: ["123456"],
        allowBigQueryExport: true
    )

    #expect(perimeter.name == "dais-prod-comprehensive")
    #expect(perimeter.restrictedServices.count > 10)
    #expect(perimeter.egressPolicies != nil)
}

@Test func testDAISVPCServiceControlsTemplatePerimeterYAML() {
    let yaml = DAISVPCServiceControlsTemplate.perimeterYAML(
        name: "test-perimeter",
        title: "Test Perimeter",
        resources: ["projects/123"],
        restrictedServices: ["storage.googleapis.com"]
    )

    #expect(yaml.contains("name: test-perimeter"))
    #expect(yaml.contains("title: Test Perimeter"))
    #expect(yaml.contains("projects/123"))
    #expect(yaml.contains("storage.googleapis.com"))
}

@Test func testDAISVPCServiceControlsTemplateSetupScript() {
    let script = DAISVPCServiceControlsTemplate.setupScript(
        organizationID: "org-123",
        projectID: "my-project",
        projectNumber: "123456789",
        deploymentName: "dais-prod",
        corporateCIDRs: ["10.0.0.0/8"]
    )

    #expect(script.contains("accesscontextmanager.googleapis.com"))
    #expect(script.contains("policies create"))
    #expect(script.contains("levels create"))
    #expect(script.contains("perimeters create"))
    #expect(script.contains("dais-prod"))
}

@Test func testAccessPolicyCodable() throws {
    let policy = GoogleCloudAccessPolicy(
        name: "12345678",
        organizationID: "org-123",
        title: "Test Policy",
        scopes: ["projects/123"]
    )

    let data = try JSONEncoder().encode(policy)
    let decoded = try JSONDecoder().decode(GoogleCloudAccessPolicy.self, from: data)

    #expect(decoded.name == "12345678")
    #expect(decoded.scopes?.contains("projects/123") == true)
}

@Test func testServicePerimeterCodable() throws {
    let perimeter = GoogleCloudServicePerimeter(
        name: "test-perimeter",
        policyID: "policy-123",
        title: "Test",
        perimeterType: .regular,
        resources: ["projects/123"],
        restrictedServices: ["storage.googleapis.com"]
    )

    let data = try JSONEncoder().encode(perimeter)
    let decoded = try JSONDecoder().decode(GoogleCloudServicePerimeter.self, from: data)

    #expect(decoded.name == "test-perimeter")
    #expect(decoded.perimeterType == .regular)
}

@Test func testAccessLevelCodable() throws {
    let level = GoogleCloudAccessLevel(
        name: "test-level",
        policyID: "policy-123",
        title: "Test Level",
        basic: GoogleCloudAccessLevel.BasicLevel(
            conditions: [
                GoogleCloudAccessLevel.BasicLevel.Condition(
                    ipSubnetworks: ["10.0.0.0/8"]
                )
            ]
        )
    )

    let data = try JSONEncoder().encode(level)
    let decoded = try JSONDecoder().decode(GoogleCloudAccessLevel.self, from: data)

    #expect(decoded.name == "test-level")
    #expect(decoded.basic?.conditions.first?.ipSubnetworks?.contains("10.0.0.0/8") == true)
}

@Test func testIngressPolicyStructure() {
    let ingress = GoogleCloudServicePerimeter.IngressPolicy(
        ingressFrom: GoogleCloudServicePerimeter.IngressPolicy.IngressFrom(
            identityType: .anyServiceAccount,
            sources: [
                GoogleCloudServicePerimeter.IngressPolicy.IngressFrom.IngressSource(
                    accessLevel: "accessPolicies/123/accessLevels/corp"
                )
            ]
        ),
        ingressTo: GoogleCloudServicePerimeter.IngressPolicy.IngressTo(
            operations: [
                GoogleCloudServicePerimeter.ServiceOperation(
                    serviceName: "storage.googleapis.com"
                )
            ],
            resources: ["*"]
        )
    )

    #expect(ingress.ingressFrom.identityType == .anyServiceAccount)
    #expect(ingress.ingressTo.operations.first?.serviceName == "storage.googleapis.com")
}

@Test func testEgressPolicyStructure() {
    let egress = GoogleCloudServicePerimeter.EgressPolicy(
        egressFrom: GoogleCloudServicePerimeter.EgressPolicy.EgressFrom(
            identities: ["serviceAccount:sa@project.iam.gserviceaccount.com"]
        ),
        egressTo: GoogleCloudServicePerimeter.EgressPolicy.EgressTo(
            operations: [
                GoogleCloudServicePerimeter.ServiceOperation(
                    serviceName: "bigquery.googleapis.com",
                    methodSelectors: [
                        GoogleCloudServicePerimeter.ServiceOperation.MethodSelector(
                            method: "google.cloud.bigquery.v2.TableService.InsertAll"
                        )
                    ]
                )
            ],
            externalResources: ["projects/external-project"]
        )
    )

    #expect(egress.egressFrom.identities?.first?.contains("serviceAccount") == true)
    #expect(egress.egressTo.externalResources?.contains("projects/external-project") == true)
}

@Test func testDevicePolicyConstraints() {
    let devicePolicy = GoogleCloudAccessLevel.BasicLevel.Condition.DevicePolicy(
        requireScreenlock: true,
        allowedEncryptionStatuses: [.encrypted],
        osConstraints: [
            GoogleCloudAccessLevel.BasicLevel.Condition.DevicePolicy.OSConstraint(
                osType: .desktopMac,
                minimumVersion: "12.0"
            )
        ],
        allowedDeviceManagementLevels: [.complete],
        requireCorpOwned: true
    )

    #expect(devicePolicy.requireScreenlock == true)
    #expect(devicePolicy.osConstraints?.first?.osType == .desktopMac)
    #expect(devicePolicy.allowedDeviceManagementLevels?.contains(.complete) == true)
}

// MARK: - Cloud Filestore Tests

@Test func testFilestoreInstanceBasicInit() {
    let instance = GoogleCloudFilestoreInstance(
        name: "my-filestore",
        projectID: "my-project",
        zone: "us-central1-a",
        tier: .basicSSD,
        fileShares: [
            GoogleCloudFilestoreInstance.FileShare(name: "share", capacityGB: 1024)
        ],
        networks: [
            GoogleCloudFilestoreInstance.NetworkConfig(network: "default")
        ]
    )

    #expect(instance.name == "my-filestore")
    #expect(instance.tier == .basicSSD)
    #expect(instance.region == "us-central1")
}

@Test func testFilestoreInstanceResourceName() {
    let instance = GoogleCloudFilestoreInstance(
        name: "test-fs",
        projectID: "my-project",
        zone: "us-west1-b",
        tier: .basic,
        fileShares: [GoogleCloudFilestoreInstance.FileShare(name: "data", capacityGB: 2048)],
        networks: [GoogleCloudFilestoreInstance.NetworkConfig(network: "default")]
    )

    #expect(instance.resourceName == "projects/my-project/locations/us-west1-b/instances/test-fs")
}

@Test func testFilestoreInstanceCreateCommand() {
    let instance = GoogleCloudFilestoreInstance(
        name: "prod-storage",
        projectID: "my-project",
        zone: "us-central1-a",
        tier: .basicSSD,
        fileShares: [
            GoogleCloudFilestoreInstance.FileShare(name: "shared", capacityGB: 2560)
        ],
        networks: [
            GoogleCloudFilestoreInstance.NetworkConfig(
                network: "my-vpc",
                reservedIPRange: "10.0.0.0/29"
            )
        ],
        description: "Production storage"
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("filestore instances create prod-storage"))
    #expect(cmd.contains("--tier=basic-ssd"))
    #expect(cmd.contains("--file-share=name=shared,capacity=2560GB"))
    #expect(cmd.contains("--network=name=my-vpc,reserved-ip-range=10.0.0.0/29"))
}

@Test func testFilestoreInstanceDeleteCommand() {
    let instance = GoogleCloudFilestoreInstance(
        name: "test-fs",
        projectID: "my-project",
        zone: "us-central1-a",
        tier: .basic,
        fileShares: [GoogleCloudFilestoreInstance.FileShare(name: "share", capacityGB: 1024)],
        networks: [GoogleCloudFilestoreInstance.NetworkConfig(network: "default")]
    )

    let cmd = instance.deleteCommand
    #expect(cmd.contains("filestore instances delete test-fs"))
    #expect(cmd.contains("--zone=us-central1-a"))
}

@Test func testFilestoreTierDescriptions() {
    #expect(GoogleCloudFilestoreInstance.Tier.basic.description.contains("HDD"))
    #expect(GoogleCloudFilestoreInstance.Tier.enterprise.description.contains("HA"))
    #expect(GoogleCloudFilestoreInstance.Tier.highScaleSSD.minCapacityTB == 10.0)
}

@Test func testFilestoreNFSExportOptions() {
    let option = GoogleCloudFilestoreInstance.FileShare.NFSExportOption(
        ipRanges: ["10.0.0.0/8"],
        accessMode: .readWrite,
        squashMode: .rootSquash
    )

    #expect(option.accessMode == .readWrite)
    #expect(option.squashMode == .rootSquash)
    #expect(option.ipRanges?.contains("10.0.0.0/8") == true)
}

@Test func testFilestoreBackupBasicInit() {
    let backup = GoogleCloudFilestoreBackup(
        name: "my-backup",
        projectID: "my-project",
        region: "us-central1",
        sourceInstance: "projects/my-project/locations/us-central1-a/instances/my-fs",
        sourceFileShare: "shared"
    )

    #expect(backup.name == "my-backup")
    #expect(backup.resourceName == "projects/my-project/locations/us-central1/backups/my-backup")
}

@Test func testFilestoreBackupCreateCommand() {
    let backup = GoogleCloudFilestoreBackup(
        name: "weekly-backup",
        projectID: "my-project",
        region: "us-central1",
        sourceInstance: "projects/my-project/locations/us-central1-a/instances/prod-fs",
        sourceFileShare: "data",
        description: "Weekly backup"
    )

    let cmd = backup.createCommand
    #expect(cmd.contains("filestore backups create weekly-backup"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--source-file-share=data"))
}

@Test func testFilestoreBackupRestoreCommand() {
    let backup = GoogleCloudFilestoreBackup(
        name: "my-backup",
        projectID: "my-project",
        region: "us-central1",
        sourceInstance: "source-instance",
        sourceFileShare: "shared"
    )

    let cmd = backup.restoreCommand(
        targetInstance: "restored-fs",
        targetZone: "us-central1-a",
        targetFileShare: "restored",
        tier: .basicSSD,
        network: "default"
    )

    #expect(cmd.contains("filestore instances restore restored-fs"))
    #expect(cmd.contains("--source-backup="))
    #expect(cmd.contains("--tier=basic-ssd"))
}

@Test func testFilestoreSnapshotBasicInit() {
    let snapshot = GoogleCloudFilestoreSnapshot(
        name: "my-snapshot",
        projectID: "my-project",
        zone: "us-central1-a",
        instanceName: "my-fs"
    )

    #expect(snapshot.name == "my-snapshot")
    #expect(snapshot.resourceName.contains("snapshots/my-snapshot"))
}

@Test func testFilestoreSnapshotCreateCommand() {
    let snapshot = GoogleCloudFilestoreSnapshot(
        name: "pre-upgrade",
        projectID: "my-project",
        zone: "us-central1-a",
        instanceName: "prod-fs",
        description: "Snapshot before upgrade"
    )

    let cmd = snapshot.createCommand
    #expect(cmd.contains("filestore snapshots create pre-upgrade"))
    #expect(cmd.contains("--instance=prod-fs"))
}

@Test func testFilestoreOperationsEnableAPI() {
    let cmd = FilestoreOperations.enableAPICommand(projectID: "my-project")
    #expect(cmd.contains("services enable file.googleapis.com"))
    #expect(cmd.contains("--project=my-project"))
}

@Test func testFilestoreOperationsGetIP() {
    let cmd = FilestoreOperations.getIPAddressCommand(
        instanceName: "my-fs",
        projectID: "my-project",
        zone: "us-central1-a"
    )
    #expect(cmd.contains("filestore instances describe my-fs"))
    #expect(cmd.contains("ipAddresses"))
}

@Test func testDAISFilestoreTemplateSharedStorage() {
    let instance = DAISFilestoreTemplate.sharedStorage(
        projectID: "my-project",
        zone: "us-central1-a",
        deploymentName: "dais-prod"
    )

    #expect(instance.name == "dais-prod-shared-storage")
    #expect(instance.tier == .basicSSD)
    #expect(instance.labels?["deployment"] == "dais-prod")
}

@Test func testDAISFilestoreTemplateEnterpriseStorage() {
    let instance = DAISFilestoreTemplate.enterpriseStorage(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        capacityGB: 4096,
        network: "prod-vpc"
    )

    #expect(instance.name == "dais-prod-enterprise-storage")
    #expect(instance.tier == .enterprise)
    #expect(instance.fileShares.first?.nfsExportOptions?.first?.squashMode == .rootSquash)
}

@Test func testDAISFilestoreTemplateDataProcessing() {
    let instance = DAISFilestoreTemplate.dataProcessingStorage(
        projectID: "my-project",
        zone: "us-central1-a",
        deploymentName: "dais-prod",
        capacityGB: 20480,
        network: "data-vpc"
    )

    #expect(instance.name == "dais-prod-data-storage")
    #expect(instance.tier == .highScaleSSD)
    #expect(instance.fileShares.first?.capacityGB == 20480)
}

@Test func testDAISFilestoreTemplateFstabEntry() {
    let entry = DAISFilestoreTemplate.fstabEntry(
        filestoreIP: "10.0.0.2",
        fileShareName: "shared",
        mountPoint: "/mnt/filestore"
    )

    #expect(entry.contains("10.0.0.2:/shared"))
    #expect(entry.contains("/mnt/filestore"))
    #expect(entry.contains("nfs"))
}

@Test func testDAISFilestoreTemplateSetupScript() {
    let script = DAISFilestoreTemplate.setupScript(
        projectID: "my-project",
        zone: "us-central1-a",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("file.googleapis.com"))
    #expect(script.contains("filestore instances create"))
    #expect(script.contains("dais-prod-shared-storage"))
}

@Test func testFilestoreInstanceCodable() throws {
    let instance = GoogleCloudFilestoreInstance(
        name: "test-fs",
        projectID: "my-project",
        zone: "us-central1-a",
        tier: .enterprise,
        fileShares: [GoogleCloudFilestoreInstance.FileShare(name: "share", capacityGB: 2048)],
        networks: [GoogleCloudFilestoreInstance.NetworkConfig(network: "default")]
    )

    let data = try JSONEncoder().encode(instance)
    let decoded = try JSONDecoder().decode(GoogleCloudFilestoreInstance.self, from: data)

    #expect(decoded.name == "test-fs")
    #expect(decoded.tier == .enterprise)
}

@Test func testFilestoreBackupCodable() throws {
    let backup = GoogleCloudFilestoreBackup(
        name: "backup-1",
        projectID: "my-project",
        region: "us-central1",
        sourceInstance: "source-fs",
        sourceFileShare: "share"
    )

    let data = try JSONEncoder().encode(backup)
    let decoded = try JSONDecoder().decode(GoogleCloudFilestoreBackup.self, from: data)

    #expect(decoded.name == "backup-1")
    #expect(decoded.sourceFileShare == "share")
}

@Test func testFilestoreInstanceWithKMS() {
    let instance = GoogleCloudFilestoreInstance(
        name: "secure-fs",
        projectID: "my-project",
        zone: "us-central1-a",
        tier: .enterprise,
        fileShares: [GoogleCloudFilestoreInstance.FileShare(name: "encrypted", capacityGB: 2048)],
        networks: [GoogleCloudFilestoreInstance.NetworkConfig(network: "secure-vpc")],
        kmsKeyName: "projects/my-project/locations/us-central1/keyRings/my-ring/cryptoKeys/fs-key"
    )

    let cmd = instance.createCommand
    #expect(cmd.contains("--kms-key="))
}

@Test func testFilestoreNetworkConfigConnectMode() {
    let config = GoogleCloudFilestoreInstance.NetworkConfig(
        network: "my-vpc",
        connectMode: .privateServiceAccess
    )

    #expect(config.connectMode == .privateServiceAccess)
}

@Test func testFilestoreInstanceListCommand() {
    let cmd = GoogleCloudFilestoreInstance.listCommand(projectID: "my-project", zone: "us-central1-a")
    #expect(cmd.contains("filestore instances list"))
    #expect(cmd.contains("--zone=us-central1-a"))
}

@Test func testFilestoreBackupListCommand() {
    let cmd = GoogleCloudFilestoreBackup.listCommand(projectID: "my-project", region: "us-central1")
    #expect(cmd.contains("filestore backups list"))
    #expect(cmd.contains("--region=us-central1"))
}

// MARK: - Cloud VPN Tests

@Test func testVPNGatewayBasicInit() {
    let gateway = GoogleCloudVPNGateway(
        name: "my-vpn-gw",
        projectID: "my-project",
        region: "us-central1",
        network: "my-vpc"
    )

    #expect(gateway.name == "my-vpn-gw")
    #expect(gateway.region == "us-central1")
    #expect(gateway.resourceName == "projects/my-project/regions/us-central1/vpnGateways/my-vpn-gw")
}

@Test func testVPNGatewayCreateCommand() {
    let gateway = GoogleCloudVPNGateway(
        name: "prod-vpn",
        projectID: "my-project",
        region: "us-west1",
        network: "prod-vpc",
        stackType: .ipv4Only,
        description: "Production VPN"
    )

    let cmd = gateway.createCommand
    #expect(cmd.contains("vpn-gateways create prod-vpn"))
    #expect(cmd.contains("--network=prod-vpc"))
    #expect(cmd.contains("--stack-type=IPV4_ONLY"))
}

@Test func testVPNGatewayDeleteCommand() {
    let gateway = GoogleCloudVPNGateway(
        name: "test-vpn",
        projectID: "my-project",
        region: "us-central1",
        network: "default"
    )

    let cmd = gateway.deleteCommand
    #expect(cmd.contains("vpn-gateways delete test-vpn"))
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testExternalVPNGatewayBasicInit() {
    let external = GoogleCloudExternalVPNGateway(
        name: "peer-gw",
        projectID: "my-project",
        interfaces: [
            GoogleCloudExternalVPNGateway.Interface(id: 0, ipAddress: "203.0.113.1")
        ],
        redundancyType: .singleIPInternally
    )

    #expect(external.name == "peer-gw")
    #expect(external.interfaces.count == 1)
}

@Test func testExternalVPNGatewayCreateCommand() {
    let external = GoogleCloudExternalVPNGateway(
        name: "on-prem-gw",
        projectID: "my-project",
        interfaces: [
            GoogleCloudExternalVPNGateway.Interface(id: 0, ipAddress: "198.51.100.1"),
            GoogleCloudExternalVPNGateway.Interface(id: 1, ipAddress: "198.51.100.2")
        ],
        redundancyType: .twoIPs,
        description: "On-premises gateway"
    )

    let cmd = external.createCommand
    #expect(cmd.contains("external-vpn-gateways create on-prem-gw"))
    #expect(cmd.contains("--redundancy-type=TWO_IPS_REDUNDANCY"))
    #expect(cmd.contains("0=198.51.100.1"))
    #expect(cmd.contains("1=198.51.100.2"))
}

@Test func testVPNTunnelBasicInit() {
    let tunnel = GoogleCloudVPNTunnel(
        name: "tunnel-0",
        projectID: "my-project",
        region: "us-central1",
        vpnGateway: "my-vpn-gw",
        vpnGatewayInterface: 0,
        peerExternalGateway: "peer-gw",
        peerExternalGatewayInterface: 0,
        sharedSecret: "secret123",
        router: "my-router"
    )

    #expect(tunnel.name == "tunnel-0")
    #expect(tunnel.vpnGatewayInterface == 0)
}

@Test func testVPNTunnelCreateCommand() {
    let tunnel = GoogleCloudVPNTunnel(
        name: "prod-tunnel-0",
        projectID: "my-project",
        region: "us-west1",
        vpnGateway: "prod-vpn-gw",
        vpnGatewayInterface: 0,
        peerExternalGateway: "on-prem-gw",
        peerExternalGatewayInterface: 0,
        sharedSecret: "mysecretkey",
        router: "prod-router",
        ikeVersion: .v2
    )

    let cmd = tunnel.createCommand
    #expect(cmd.contains("vpn-tunnels create prod-tunnel-0"))
    #expect(cmd.contains("--vpn-gateway=prod-vpn-gw"))
    #expect(cmd.contains("--interface=0"))
    #expect(cmd.contains("--peer-external-gateway=on-prem-gw"))
    #expect(cmd.contains("--ike-version=2"))
    #expect(cmd.contains("--router=prod-router"))
}

@Test func testVPNTunnelResourceName() {
    let tunnel = GoogleCloudVPNTunnel(
        name: "test-tunnel",
        projectID: "my-project",
        region: "us-central1",
        vpnGateway: "vpn-gw",
        vpnGatewayInterface: 0,
        sharedSecret: "secret",
        router: "router"
    )

    #expect(tunnel.resourceName == "projects/my-project/regions/us-central1/vpnTunnels/test-tunnel")
}

@Test func testVPNTunnelListCommand() {
    let cmd = GoogleCloudVPNTunnel.listCommand(projectID: "my-project", region: "us-west1")
    #expect(cmd.contains("vpn-tunnels list"))
    #expect(cmd.contains("us-west1"))
}

@Test func testClassicVPNGatewayBasicInit() {
    let classic = GoogleCloudClassicVPNGateway(
        name: "classic-vpn",
        projectID: "my-project",
        region: "us-central1",
        network: "legacy-vpc"
    )

    #expect(classic.name == "classic-vpn")
    #expect(classic.resourceName.contains("targetVpnGateways"))
}

@Test func testClassicVPNGatewayCreateCommand() {
    let classic = GoogleCloudClassicVPNGateway(
        name: "legacy-vpn",
        projectID: "my-project",
        region: "us-east1",
        network: "old-vpc",
        description: "Legacy VPN"
    )

    let cmd = classic.createCommand
    #expect(cmd.contains("target-vpn-gateways create legacy-vpn"))
    #expect(cmd.contains("--network=old-vpc"))
}

@Test func testVPNOperationsGenerateSecret() {
    let cmd = VPNOperations.generateSharedSecretCommand(length: 32)
    #expect(cmd.contains("openssl rand -base64 32"))
}

@Test func testVPNOperationsCheckStatus() {
    let cmd = VPNOperations.checkTunnelStatusCommand(
        tunnelName: "my-tunnel",
        projectID: "my-project",
        region: "us-central1"
    )
    #expect(cmd.contains("vpn-tunnels describe my-tunnel"))
    #expect(cmd.contains("status"))
}

@Test func testVPNOperationsClassicForwardingRules() {
    let cmds = VPNOperations.createClassicForwardingRulesCommands(
        gatewayName: "classic-gw",
        projectID: "my-project",
        region: "us-central1",
        staticIP: "35.192.0.1"
    )

    #expect(cmds.count == 3)
    #expect(cmds[0].contains("ESP"))
    #expect(cmds[1].contains("500"))
    #expect(cmds[2].contains("4500"))
}

@Test func testDAISVPNTemplateHAGateway() {
    let gateway = DAISVPNTemplate.haVPNGateway(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        network: "prod-vpc"
    )

    #expect(gateway.name == "dais-prod-vpn-gw")
    #expect(gateway.stackType == .ipv4Only)
    #expect(gateway.labels?["deployment"] == "dais-prod")
}

@Test func testDAISVPNTemplateExternalGateway() {
    let external = DAISVPNTemplate.externalGateway(
        projectID: "my-project",
        deploymentName: "dais-prod",
        peerIPs: ["203.0.113.1", "203.0.113.2"]
    )

    #expect(external.name == "dais-prod-peer-gw")
    #expect(external.redundancyType == .twoIPs)
    #expect(external.interfaces.count == 2)
}

@Test func testDAISVPNTemplateExternalGatewaySingleIP() {
    let external = DAISVPNTemplate.externalGateway(
        projectID: "my-project",
        deploymentName: "dais-prod",
        peerIPs: ["198.51.100.1"]
    )

    #expect(external.redundancyType == .singleIPInternally)
    #expect(external.interfaces.count == 1)
}

@Test func testDAISVPNTemplateTunnel() {
    let tunnel = DAISVPNTemplate.vpnTunnel(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        interfaceNum: 0,
        peerInterfaceNum: 0,
        sharedSecret: "supersecret",
        routerName: "dais-router"
    )

    #expect(tunnel.name == "dais-prod-tunnel-0")
    #expect(tunnel.ikeVersion == .v2)
}

@Test func testDAISVPNTemplateBGPPeerCommand() {
    let cmd = DAISVPNTemplate.bgpPeerCommand(
        routerName: "dais-router",
        peerName: "bgp-peer-0",
        peerASN: 65001,
        peerIPAddress: "169.254.0.2",
        interfaceName: "if-tunnel-0",
        projectID: "my-project",
        region: "us-central1"
    )

    #expect(cmd.contains("add-bgp-peer dais-router"))
    #expect(cmd.contains("--peer-asn=65001"))
    #expect(cmd.contains("--peer-ip-address=169.254.0.2"))
}

@Test func testDAISVPNTemplateSetupScript() {
    let script = DAISVPNTemplate.setupScript(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        network: "prod-vpc",
        peerASN: 65001,
        peerIPs: ["203.0.113.1"]
    )

    #expect(script.contains("vpn-gateways create"))
    #expect(script.contains("vpn-tunnels create"))
    #expect(script.contains("add-bgp-peer"))
    #expect(script.contains("65001"))
}

@Test func testDAISVPNTemplateTeardownScript() {
    let script = DAISVPNTemplate.teardownScript(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("remove-bgp-peer"))
    #expect(script.contains("vpn-tunnels delete"))
    #expect(script.contains("vpn-gateways delete"))
}

@Test func testVPNGatewayCodable() throws {
    let gateway = GoogleCloudVPNGateway(
        name: "test-gw",
        projectID: "my-project",
        region: "us-central1",
        network: "default",
        stackType: .ipv4Ipv6
    )

    let data = try JSONEncoder().encode(gateway)
    let decoded = try JSONDecoder().decode(GoogleCloudVPNGateway.self, from: data)

    #expect(decoded.name == "test-gw")
    #expect(decoded.stackType == .ipv4Ipv6)
}

@Test func testVPNTunnelCodable() throws {
    let tunnel = GoogleCloudVPNTunnel(
        name: "test-tunnel",
        projectID: "my-project",
        region: "us-central1",
        vpnGateway: "vpn-gw",
        vpnGatewayInterface: 0,
        sharedSecret: "secret",
        router: "router",
        ikeVersion: .v2
    )

    let data = try JSONEncoder().encode(tunnel)
    let decoded = try JSONDecoder().decode(GoogleCloudVPNTunnel.self, from: data)

    #expect(decoded.name == "test-tunnel")
    #expect(decoded.ikeVersion == .v2)
}

@Test func testExternalVPNGatewayCodable() throws {
    let external = GoogleCloudExternalVPNGateway(
        name: "peer-gw",
        projectID: "my-project",
        interfaces: [
            GoogleCloudExternalVPNGateway.Interface(id: 0, ipAddress: "1.2.3.4")
        ],
        redundancyType: .singleIPInternally
    )

    let data = try JSONEncoder().encode(external)
    let decoded = try JSONDecoder().decode(GoogleCloudExternalVPNGateway.self, from: data)

    #expect(decoded.name == "peer-gw")
    #expect(decoded.interfaces.first?.ipAddress == "1.2.3.4")
}

@Test func testIKEVersionValues() {
    #expect(GoogleCloudVPNTunnel.IKEVersion.v1.rawValue == 1)
    #expect(GoogleCloudVPNTunnel.IKEVersion.v2.rawValue == 2)
}

@Test func testRedundancyTypeValues() {
    #expect(GoogleCloudExternalVPNGateway.RedundancyType.singleIPInternally.rawValue == "SINGLE_IP_INTERNALLY_REDUNDANT")
    #expect(GoogleCloudExternalVPNGateway.RedundancyType.twoIPs.rawValue == "TWO_IPS_REDUNDANCY")
    #expect(GoogleCloudExternalVPNGateway.RedundancyType.fourIPs.rawValue == "FOUR_IPS_REDUNDANCY")
}

// MARK: - BigQuery Tests

@Test func testBigQueryDatasetBasicInit() {
    let dataset = GoogleCloudBigQueryDataset(
        datasetID: "analytics",
        projectID: "my-project",
        location: "US",
        description: "Analytics dataset"
    )

    #expect(dataset.datasetID == "analytics")
    #expect(dataset.projectID == "my-project")
    #expect(dataset.location == "US")
    #expect(dataset.resourceName == "projects/my-project/datasets/analytics")
}

@Test func testBigQueryDatasetCreateCommand() {
    let dataset = GoogleCloudBigQueryDataset(
        datasetID: "logs",
        projectID: "my-project",
        location: "EU",
        description: "Logs dataset",
        defaultTableExpirationMs: 7776000000, // 90 days
        labels: ["env": "prod", "team": "data"]
    )

    let cmd = dataset.createCommand
    #expect(cmd.contains("bq mk --dataset"))
    #expect(cmd.contains("--location=EU"))
    #expect(cmd.contains("--description=\"Logs dataset\""))
    #expect(cmd.contains("--default_table_expiration=7776000"))
    #expect(cmd.contains("--label="))
    #expect(cmd.contains("my-project:logs"))
}

@Test func testBigQueryDatasetDescribeCommand() {
    let dataset = GoogleCloudBigQueryDataset(
        datasetID: "analytics",
        projectID: "my-project"
    )

    #expect(dataset.describeCommand == "bq show --format=prettyjson my-project:analytics")
}

@Test func testBigQueryDatasetDeleteCommand() {
    let dataset = GoogleCloudBigQueryDataset(
        datasetID: "temp_data",
        projectID: "my-project"
    )

    #expect(dataset.deleteCommand == "bq rm -r -f -d my-project:temp_data")
}

@Test func testBigQueryDatasetUpdateCommand() {
    let dataset = GoogleCloudBigQueryDataset(
        datasetID: "analytics",
        projectID: "my-project"
    )

    let cmd = dataset.updateCommand(description: "Updated description", expirationMs: 86400000)
    #expect(cmd.contains("bq update"))
    #expect(cmd.contains("--description=\"Updated description\""))
    #expect(cmd.contains("--default_table_expiration=86400"))
}

@Test func testBigQueryDatasetListCommand() {
    let cmd = GoogleCloudBigQueryDataset.listCommand(projectID: "my-project")
    #expect(cmd == "bq ls --format=prettyjson --project_id=my-project")
}

@Test func testBigQueryTableBasicInit() {
    let table = GoogleCloudBigQueryTable(
        tableID: "events",
        datasetID: "analytics",
        projectID: "my-project",
        description: "Events table"
    )

    #expect(table.tableID == "events")
    #expect(table.datasetID == "analytics")
    #expect(table.tableReference == "my-project:analytics.events")
    #expect(table.resourceName == "projects/my-project/datasets/analytics/tables/events")
}

@Test func testBigQueryTableWithPartitioningAndClustering() {
    let table = GoogleCloudBigQueryTable(
        tableID: "events",
        datasetID: "analytics",
        projectID: "my-project",
        partitioning: GoogleCloudBigQueryTable.Partitioning(
            type: .day,
            field: "event_timestamp",
            expirationMs: 31536000000 // 365 days
        ),
        clustering: GoogleCloudBigQueryTable.Clustering(
            fields: ["event_type", "user_id"]
        )
    )

    let cmd = table.createCommand(schemaFile: "schema.json")
    #expect(cmd.contains("bq mk --table"))
    #expect(cmd.contains("--time_partitioning_field=event_timestamp"))
    #expect(cmd.contains("--time_partitioning_type=DAY"))
    #expect(cmd.contains("--time_partitioning_expiration=31536000"))
    #expect(cmd.contains("--clustering_fields=event_type,user_id"))
    #expect(cmd.contains("my-project:analytics.events"))
    #expect(cmd.contains("schema.json"))
}

@Test func testBigQueryTableDescribeCommand() {
    let table = GoogleCloudBigQueryTable(
        tableID: "users",
        datasetID: "app",
        projectID: "my-project"
    )

    #expect(table.describeCommand == "bq show --format=prettyjson my-project:app.users")
}

@Test func testBigQueryTableDeleteCommand() {
    let table = GoogleCloudBigQueryTable(
        tableID: "temp",
        datasetID: "staging",
        projectID: "my-project"
    )

    #expect(table.deleteCommand == "bq rm -f -t my-project:staging.temp")
}

@Test func testBigQueryTableGetSchemaCommand() {
    let table = GoogleCloudBigQueryTable(
        tableID: "events",
        datasetID: "analytics",
        projectID: "my-project"
    )

    #expect(table.getSchemaCommand == "bq show --schema --format=prettyjson my-project:analytics.events")
}

@Test func testBigQueryTableListCommand() {
    let cmd = GoogleCloudBigQueryTable.listCommand(projectID: "my-project", datasetID: "analytics")
    #expect(cmd == "bq ls --format=prettyjson my-project:analytics")
}

@Test func testBigQuerySchemaFieldTypes() {
    #expect(GoogleCloudBigQueryTable.Schema.Field.FieldType.string.rawValue == "STRING")
    #expect(GoogleCloudBigQueryTable.Schema.Field.FieldType.integer.rawValue == "INTEGER")
    #expect(GoogleCloudBigQueryTable.Schema.Field.FieldType.timestamp.rawValue == "TIMESTAMP")
    #expect(GoogleCloudBigQueryTable.Schema.Field.FieldType.json.rawValue == "JSON")
    #expect(GoogleCloudBigQueryTable.Schema.Field.FieldType.record.rawValue == "RECORD")
}

@Test func testBigQuerySchemaFieldModes() {
    #expect(GoogleCloudBigQueryTable.Schema.Field.Mode.nullable.rawValue == "NULLABLE")
    #expect(GoogleCloudBigQueryTable.Schema.Field.Mode.required.rawValue == "REQUIRED")
    #expect(GoogleCloudBigQueryTable.Schema.Field.Mode.repeated.rawValue == "REPEATED")
}

@Test func testBigQueryPartitionTypes() {
    #expect(GoogleCloudBigQueryTable.Partitioning.PartitionType.day.rawValue == "DAY")
    #expect(GoogleCloudBigQueryTable.Partitioning.PartitionType.hour.rawValue == "HOUR")
    #expect(GoogleCloudBigQueryTable.Partitioning.PartitionType.month.rawValue == "MONTH")
    #expect(GoogleCloudBigQueryTable.Partitioning.PartitionType.year.rawValue == "YEAR")
}

@Test func testBigQueryJobBasicInit() {
    let job = GoogleCloudBigQueryJob(
        projectID: "my-project",
        query: "SELECT * FROM `my-project.analytics.events` LIMIT 100"
    )

    #expect(job.projectID == "my-project")
    #expect(job.query.contains("SELECT"))
}

@Test func testBigQueryJobQueryCommand() {
    let job = GoogleCloudBigQueryJob(
        projectID: "my-project",
        location: "US",
        query: "SELECT COUNT(*) FROM `my-project.analytics.events`",
        maximumBytesBilled: 10737418240 // 10GB
    )

    let cmd = job.queryCommand
    #expect(cmd.contains("bq query"))
    #expect(cmd.contains("--location=US"))
    #expect(cmd.contains("--use_legacy_sql=false"))
    #expect(cmd.contains("--maximum_bytes_billed=10737418240"))
    #expect(cmd.contains("--format=prettyjson"))
}

@Test func testBigQueryJobWithDestinationTable() {
    let job = GoogleCloudBigQueryJob(
        projectID: "my-project",
        query: "SELECT * FROM source",
        destinationTable: "my-project:analytics.results",
        writeDisposition: .writeTruncate
    )

    let cmd = job.queryCommand
    #expect(cmd.contains("--destination_table=my-project:analytics.results"))
    #expect(cmd.contains("--replace"))
}

@Test func testBigQueryJobInfoCommand() {
    let job = GoogleCloudBigQueryJob(
        jobID: "job_abc123",
        projectID: "my-project",
        location: "US",
        query: "SELECT 1"
    )

    let cmd = job.infoCommand
    #expect(cmd.contains("bq show"))
    #expect(cmd.contains("--job=true"))
    #expect(cmd.contains("--location=US"))
    #expect(cmd.contains("my-project:job_abc123"))
}

@Test func testBigQueryJobCancelCommand() {
    let job = GoogleCloudBigQueryJob(
        jobID: "job_xyz789",
        projectID: "my-project",
        location: "EU",
        query: "SELECT 1"
    )

    let cmd = job.cancelCommand
    #expect(cmd.contains("bq cancel"))
    #expect(cmd.contains("--location=EU"))
    #expect(cmd.contains("my-project:job_xyz789"))
}

@Test func testBigQueryJobListCommand() {
    let cmd = GoogleCloudBigQueryJob.listCommand(projectID: "my-project", allUsers: true)
    #expect(cmd.contains("bq ls --jobs=true"))
    #expect(cmd.contains("--project_id=my-project"))
    #expect(cmd.contains("--all"))
}

@Test func testBigQueryWriteDispositions() {
    #expect(GoogleCloudBigQueryJob.WriteDisposition.writeEmpty.rawValue == "WRITE_EMPTY")
    #expect(GoogleCloudBigQueryJob.WriteDisposition.writeAppend.rawValue == "WRITE_APPEND")
    #expect(GoogleCloudBigQueryJob.WriteDisposition.writeTruncate.rawValue == "WRITE_TRUNCATE")
}

@Test func testBigQueryCreateDispositions() {
    #expect(GoogleCloudBigQueryJob.CreateDisposition.createIfNeeded.rawValue == "CREATE_IF_NEEDED")
    #expect(GoogleCloudBigQueryJob.CreateDisposition.createNever.rawValue == "CREATE_NEVER")
}

@Test func testBigQueryViewBasicInit() {
    let view = GoogleCloudBigQueryView(
        viewID: "daily_summary",
        datasetID: "analytics",
        projectID: "my-project",
        query: "SELECT date, COUNT(*) as count FROM events GROUP BY date",
        description: "Daily event summary"
    )

    #expect(view.viewID == "daily_summary")
    #expect(view.viewReference == "my-project:analytics.daily_summary")
}

@Test func testBigQueryViewCreateCommand() {
    let view = GoogleCloudBigQueryView(
        viewID: "active_users",
        datasetID: "analytics",
        projectID: "my-project",
        query: "SELECT DISTINCT user_id FROM events WHERE timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)",
        description: "Active users in last 30 days"
    )

    let cmd = view.createCommand
    #expect(cmd.contains("bq mk --view"))
    #expect(cmd.contains("--description=\"Active users in last 30 days\""))
    #expect(cmd.contains("--use_legacy_sql=false"))
    #expect(cmd.contains("my-project:analytics.active_users"))
}

@Test func testBigQueryViewUpdateCommand() {
    let view = GoogleCloudBigQueryView(
        viewID: "summary",
        datasetID: "data",
        projectID: "my-project",
        query: "SELECT * FROM source"
    )

    let cmd = view.updateCommand
    #expect(cmd.contains("bq update --view"))
    #expect(cmd.contains("--use_legacy_sql=false"))
}

@Test func testBigQueryViewDeleteCommand() {
    let view = GoogleCloudBigQueryView(
        viewID: "old_view",
        datasetID: "archive",
        projectID: "my-project",
        query: "SELECT 1"
    )

    #expect(view.deleteCommand == "bq rm -f -t my-project:archive.old_view")
}

@Test func testBigQueryOperationsEnableAPI() {
    let cmd = BigQueryOperations.enableAPICommand(projectID: "my-project")
    #expect(cmd == "gcloud services enable bigquery.googleapis.com --project=my-project")
}

@Test func testBigQueryOperationsLoadFromGCS() {
    let cmd = BigQueryOperations.loadFromGCSCommand(
        sourceURI: "gs://my-bucket/data/*.csv",
        destinationTable: "my-project:dataset.table",
        sourceFormat: .csv,
        writeDisposition: .writeTruncate,
        autodetect: true
    )

    #expect(cmd.contains("bq load"))
    #expect(cmd.contains("--source_format=CSV"))
    #expect(cmd.contains("--replace"))
    #expect(cmd.contains("--autodetect"))
    #expect(cmd.contains("gs://my-bucket/data/*.csv"))
}

@Test func testBigQueryOperationsLoadFromGCSJSON() {
    let cmd = BigQueryOperations.loadFromGCSCommand(
        sourceURI: "gs://bucket/data.json",
        destinationTable: "project:dataset.table",
        sourceFormat: .json,
        writeDisposition: .writeAppend
    )

    #expect(cmd.contains("--source_format=NEWLINE_DELIMITED_JSON"))
    #expect(cmd.contains("--append_table"))
}

@Test func testBigQueryOperationsExportToGCS() {
    let cmd = BigQueryOperations.exportToGCSCommand(
        sourceTable: "my-project:dataset.table",
        destinationURI: "gs://my-bucket/export/*.csv",
        format: .csv
    )

    #expect(cmd.contains("bq extract"))
    #expect(cmd.contains("--destination_format=CSV"))
    #expect(cmd.contains("my-project:dataset.table"))
    #expect(cmd.contains("gs://my-bucket/export/*.csv"))
}

@Test func testBigQueryOperationsCopyTable() {
    let cmd = BigQueryOperations.copyTableCommand(
        source: "project:dataset.source",
        destination: "project:dataset.dest",
        writeDisposition: .writeAppend
    )

    #expect(cmd.contains("bq cp"))
    #expect(cmd.contains("--append_table"))
    #expect(cmd.contains("project:dataset.source"))
    #expect(cmd.contains("project:dataset.dest"))
}

@Test func testBigQueryOperationsPreview() {
    let cmd = BigQueryOperations.previewCommand(table: "project:dataset.table", maxRows: 25)
    #expect(cmd == "bq head -n 25 project:dataset.table")
}

@Test func testBigQueryOperationsDryRun() {
    let cmd = BigQueryOperations.dryRunCommand(query: "SELECT * FROM table")
    #expect(cmd.contains("bq query --dry_run"))
    #expect(cmd.contains("--use_legacy_sql=false"))
}

@Test func testDAISBigQueryTemplateAnalyticsDataset() {
    let dataset = DAISBigQueryTemplate.analyticsDataset(
        projectID: "my-project",
        deploymentName: "dais-prod",
        location: "US"
    )

    #expect(dataset.datasetID == "dais_prod_analytics")
    #expect(dataset.location == "US")
    #expect(dataset.labels?["deployment"] == "dais-prod")
    #expect(dataset.labels?["purpose"] == "analytics")
}

@Test func testDAISBigQueryTemplateLogsDataset() {
    let dataset = DAISBigQueryTemplate.logsDataset(
        projectID: "my-project",
        deploymentName: "dais-prod",
        location: "EU",
        expirationDays: 30
    )

    #expect(dataset.datasetID == "dais_prod_logs")
    #expect(dataset.defaultTableExpirationMs == Int64(30) * 24 * 60 * 60 * 1000)
    #expect(dataset.labels?["purpose"] == "logs")
}

@Test func testDAISBigQueryTemplateEventsTableSchema() {
    let schema = DAISBigQueryTemplate.eventsTableSchema()

    #expect(schema.fields.count == 7)
    #expect(schema.fields[0].name == "event_id")
    #expect(schema.fields[0].type == .string)
    #expect(schema.fields[0].mode == .required)
    #expect(schema.fields[2].name == "event_timestamp")
    #expect(schema.fields[2].type == .timestamp)
}

@Test func testDAISBigQueryTemplateEventsTable() {
    let table = DAISBigQueryTemplate.eventsTable(
        projectID: "my-project",
        datasetID: "dais_prod_analytics",
        deploymentName: "dais-prod"
    )

    #expect(table.tableID == "events")
    #expect(table.partitioning?.type == .day)
    #expect(table.partitioning?.field == "event_timestamp")
    #expect(table.clustering?.fields == ["event_type", "user_id"])
    #expect(table.labels?["table_type"] == "events")
}

@Test func testDAISBigQueryTemplateDailyAggregationView() {
    let view = DAISBigQueryTemplate.dailyAggregationView(
        projectID: "my-project",
        datasetID: "dais_prod_analytics",
        deploymentName: "dais-prod"
    )

    #expect(view.viewID == "daily_event_counts")
    #expect(view.query.contains("DATE(event_timestamp)"))
    #expect(view.query.contains("COUNT(*)"))
    #expect(view.query.contains("COUNT(DISTINCT user_id)"))
}

@Test func testDAISBigQueryTemplateSetupScript() {
    let script = DAISBigQueryTemplate.setupScript(
        projectID: "my-project",
        deploymentName: "dais-prod",
        location: "US"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("bigquery.googleapis.com"))
    #expect(script.contains("bq mk --dataset"))
    #expect(script.contains("dais_prod_analytics"))
    #expect(script.contains("bq mk --table"))
    #expect(script.contains("--time_partitioning_field=event_timestamp"))
    #expect(script.contains("bq mk --view"))
    #expect(script.contains("daily_event_counts"))
}

@Test func testDAISBigQueryTemplateTeardownScript() {
    let script = DAISBigQueryTemplate.teardownScript(
        projectID: "my-project",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("bq rm -r -f -d"))
    #expect(script.contains("dais_prod_analytics"))
    #expect(script.contains("dais_prod_logs"))
}

@Test func testBigQueryDatasetCodable() throws {
    let dataset = GoogleCloudBigQueryDataset(
        datasetID: "analytics",
        projectID: "my-project",
        location: "US",
        labels: ["env": "prod"]
    )

    let data = try JSONEncoder().encode(dataset)
    let decoded = try JSONDecoder().decode(GoogleCloudBigQueryDataset.self, from: data)

    #expect(decoded.datasetID == "analytics")
    #expect(decoded.location == "US")
    #expect(decoded.labels?["env"] == "prod")
}

@Test func testBigQueryTableCodable() throws {
    let table = GoogleCloudBigQueryTable(
        tableID: "events",
        datasetID: "analytics",
        projectID: "my-project",
        partitioning: GoogleCloudBigQueryTable.Partitioning(type: .day, field: "ts")
    )

    let data = try JSONEncoder().encode(table)
    let decoded = try JSONDecoder().decode(GoogleCloudBigQueryTable.self, from: data)

    #expect(decoded.tableID == "events")
    #expect(decoded.partitioning?.type == .day)
    #expect(decoded.partitioning?.field == "ts")
}

@Test func testBigQueryJobCodable() throws {
    let job = GoogleCloudBigQueryJob(
        jobID: "job123",
        projectID: "my-project",
        location: "US",
        query: "SELECT 1",
        writeDisposition: .writeTruncate
    )

    let data = try JSONEncoder().encode(job)
    let decoded = try JSONDecoder().decode(GoogleCloudBigQueryJob.self, from: data)

    #expect(decoded.jobID == "job123")
    #expect(decoded.writeDisposition == .writeTruncate)
}

@Test func testBigQueryViewCodable() throws {
    let view = GoogleCloudBigQueryView(
        viewID: "summary",
        datasetID: "data",
        projectID: "my-project",
        query: "SELECT * FROM source",
        description: "Summary view"
    )

    let data = try JSONEncoder().encode(view)
    let decoded = try JSONDecoder().decode(GoogleCloudBigQueryView.self, from: data)

    #expect(decoded.viewID == "summary")
    #expect(decoded.description == "Summary view")
}

@Test func testBigQueryAccessEntryRoles() {
    #expect(GoogleCloudBigQueryDataset.AccessEntry.Role.reader.rawValue == "READER")
    #expect(GoogleCloudBigQueryDataset.AccessEntry.Role.writer.rawValue == "WRITER")
    #expect(GoogleCloudBigQueryDataset.AccessEntry.Role.owner.rawValue == "OWNER")
}

@Test func testBigQueryAccessEntrySpecialGroups() {
    #expect(GoogleCloudBigQueryDataset.AccessEntry.SpecialGroup.projectOwners.rawValue == "projectOwners")
    #expect(GoogleCloudBigQueryDataset.AccessEntry.SpecialGroup.projectReaders.rawValue == "projectReaders")
    #expect(GoogleCloudBigQueryDataset.AccessEntry.SpecialGroup.allAuthenticatedUsers.rawValue == "allAuthenticatedUsers")
}

@Test func testBigQuerySourceFormats() {
    #expect(BigQueryOperations.SourceFormat.csv.rawValue == "CSV")
    #expect(BigQueryOperations.SourceFormat.json.rawValue == "NEWLINE_DELIMITED_JSON")
    #expect(BigQueryOperations.SourceFormat.avro.rawValue == "AVRO")
    #expect(BigQueryOperations.SourceFormat.parquet.rawValue == "PARQUET")
    #expect(BigQueryOperations.SourceFormat.orc.rawValue == "ORC")
}

@Test func testBigQueryExportFormats() {
    #expect(BigQueryOperations.ExportFormat.csv.rawValue == "CSV")
    #expect(BigQueryOperations.ExportFormat.json.rawValue == "NEWLINE_DELIMITED_JSON")
    #expect(BigQueryOperations.ExportFormat.avro.rawValue == "AVRO")
}

// MARK: - Dataflow Tests

@Test func testDataflowJobBasicInit() {
    let job = GoogleCloudDataflowJob(
        name: "my-job",
        projectID: "my-project",
        region: "us-central1",
        type: .batch
    )

    #expect(job.name == "my-job")
    #expect(job.projectID == "my-project")
    #expect(job.region == "us-central1")
    #expect(job.type == .batch)
    #expect(job.resourceName == "projects/my-project/locations/us-central1/jobs/my-job")
}

@Test func testDataflowJobWithJobID() {
    let job = GoogleCloudDataflowJob(
        jobID: "2024-01-15_12_34_56-1234567890",
        name: "my-job",
        projectID: "my-project",
        region: "us-central1"
    )

    #expect(job.resourceName == "projects/my-project/locations/us-central1/jobs/2024-01-15_12_34_56-1234567890")
}

@Test func testDataflowJobRunClassicTemplateCommand() {
    let job = GoogleCloudDataflowJob(
        name: "word-count-job",
        projectID: "my-project",
        region: "us-central1",
        type: .batch,
        templatePath: "gs://dataflow-templates/latest/Word_Count",
        parameters: [
            "inputFile": "gs://my-bucket/input.txt",
            "output": "gs://my-bucket/output"
        ],
        environment: GoogleCloudDataflowJob.EnvironmentConfig(
            tempLocation: "gs://my-bucket/temp",
            machineType: "n1-standard-2",
            numWorkers: 2,
            maxWorkers: 10
        )
    )

    let cmd = job.runClassicTemplateCommand
    #expect(cmd.contains("gcloud dataflow jobs run word-count-job"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--gcs-location=gs://dataflow-templates/latest/Word_Count"))
    #expect(cmd.contains("--parameters="))
    #expect(cmd.contains("--staging-location=gs://my-bucket/temp"))
    #expect(cmd.contains("--worker-machine-type=n1-standard-2"))
    #expect(cmd.contains("--num-workers=2"))
    #expect(cmd.contains("--max-workers=10"))
}

@Test func testDataflowJobRunFlexTemplateCommand() {
    let job = GoogleCloudDataflowJob(
        name: "flex-job",
        projectID: "my-project",
        region: "us-central1",
        type: .streaming,
        containerSpecGcsPath: "gs://my-bucket/templates/my-template.json",
        parameters: ["param1": "value1"],
        environment: GoogleCloudDataflowJob.EnvironmentConfig(
            tempLocation: "gs://my-bucket/temp",
            enableStreamingEngine: true
        )
    )

    let cmd = job.runFlexTemplateCommand
    #expect(cmd.contains("gcloud dataflow flex-template run flex-job"))
    #expect(cmd.contains("--template-file-gcs-location=gs://my-bucket/templates/my-template.json"))
    #expect(cmd.contains("--enable-streaming-engine"))
}

@Test func testDataflowJobDescribeCommand() {
    let job = GoogleCloudDataflowJob(
        jobID: "job-123",
        name: "my-job",
        projectID: "my-project",
        region: "us-central1"
    )

    #expect(job.describeCommand == "gcloud dataflow jobs describe job-123 --project=my-project --region=us-central1")
}

@Test func testDataflowJobCancelCommand() {
    let job = GoogleCloudDataflowJob(
        jobID: "job-456",
        name: "my-job",
        projectID: "my-project",
        region: "us-west1"
    )

    #expect(job.cancelCommand == "gcloud dataflow jobs cancel job-456 --project=my-project --region=us-west1")
}

@Test func testDataflowJobDrainCommand() {
    let job = GoogleCloudDataflowJob(
        jobID: "streaming-job-789",
        name: "streaming-job",
        projectID: "my-project",
        region: "europe-west1",
        type: .streaming
    )

    #expect(job.drainCommand == "gcloud dataflow jobs drain streaming-job-789 --project=my-project --region=europe-west1")
}

@Test func testDataflowJobListCommand() {
    let cmd = GoogleCloudDataflowJob.listCommand(projectID: "my-project", region: "us-central1")
    #expect(cmd == "gcloud dataflow jobs list --project=my-project --region=us-central1")

    let cmdWithStatus = GoogleCloudDataflowJob.listCommand(
        projectID: "my-project",
        region: "us-central1",
        status: .running
    )
    #expect(cmdWithStatus.contains("--status=running"))
}

@Test func testDataflowJobTypes() {
    #expect(GoogleCloudDataflowJob.JobType.batch.rawValue == "JOB_TYPE_BATCH")
    #expect(GoogleCloudDataflowJob.JobType.streaming.rawValue == "JOB_TYPE_STREAMING")
}

@Test func testDataflowJobStates() {
    #expect(GoogleCloudDataflowJob.JobState.running.rawValue == "JOB_STATE_RUNNING")
    #expect(GoogleCloudDataflowJob.JobState.done.rawValue == "JOB_STATE_DONE")
    #expect(GoogleCloudDataflowJob.JobState.failed.rawValue == "JOB_STATE_FAILED")
    #expect(GoogleCloudDataflowJob.JobState.cancelled.rawValue == "JOB_STATE_CANCELLED")
    #expect(GoogleCloudDataflowJob.JobState.draining.rawValue == "JOB_STATE_DRAINING")
    #expect(GoogleCloudDataflowJob.JobState.drained.rawValue == "JOB_STATE_DRAINED")
}

@Test func testDataflowJobWithNetworkConfig() {
    let job = GoogleCloudDataflowJob(
        name: "vpc-job",
        projectID: "my-project",
        region: "us-central1",
        environment: GoogleCloudDataflowJob.EnvironmentConfig(
            network: "my-vpc",
            subnetwork: "regions/us-central1/subnetworks/my-subnet",
            serviceAccountEmail: "dataflow@my-project.iam.gserviceaccount.com"
        )
    )

    let cmd = job.runClassicTemplateCommand
    #expect(cmd.contains("--network=my-vpc"))
    #expect(cmd.contains("--subnetwork=regions/us-central1/subnetworks/my-subnet"))
    #expect(cmd.contains("--service-account-email=dataflow@my-project.iam.gserviceaccount.com"))
}

@Test func testDataflowFlexTemplateBasicInit() {
    let template = GoogleCloudDataflowFlexTemplate(
        name: "my-template",
        projectID: "my-project",
        templatePath: "gs://my-bucket/templates/my-template.json",
        containerImage: "gcr.io/my-project/my-pipeline:latest"
    )

    #expect(template.name == "my-template")
    #expect(template.containerImage.contains("my-pipeline"))
}

@Test func testDataflowFlexTemplateBuildCommand() {
    let template = GoogleCloudDataflowFlexTemplate(
        name: "my-template",
        projectID: "my-project",
        templatePath: "gs://my-bucket/templates/my-template.json",
        containerImage: "gcr.io/my-project/my-pipeline:latest"
    )

    let cmd = template.buildTemplateCommand(
        jarPath: "target/my-pipeline.jar",
        tempLocation: "gs://my-bucket/temp"
    )

    #expect(cmd.contains("gcloud dataflow flex-template build"))
    #expect(cmd.contains("--image=gcr.io/my-project/my-pipeline:latest"))
    #expect(cmd.contains("--jar=target/my-pipeline.jar"))
    #expect(cmd.contains("--temp-location=gs://my-bucket/temp"))
}

@Test func testDataflowFlexTemplateSDKLanguages() {
    #expect(GoogleCloudDataflowFlexTemplate.SDKInfo.Language.java.rawValue == "JAVA")
    #expect(GoogleCloudDataflowFlexTemplate.SDKInfo.Language.python.rawValue == "PYTHON")
    #expect(GoogleCloudDataflowFlexTemplate.SDKInfo.Language.go.rawValue == "GO")
}

@Test func testDataflowSQLBasicInit() {
    let sql = GoogleCloudDataflowSQL(
        name: "sql-job",
        projectID: "my-project",
        region: "us-central1",
        query: "SELECT * FROM pubsub.topic.`my-project`.`my-topic`",
        bigqueryDataset: "my_dataset",
        bigqueryTable: "my_table"
    )

    #expect(sql.name == "sql-job")
    #expect(sql.query.contains("SELECT"))
}

@Test func testDataflowSQLRunCommand() {
    let sql = GoogleCloudDataflowSQL(
        name: "streaming-sql",
        projectID: "my-project",
        region: "us-central1",
        query: "SELECT * FROM pubsub.topic.`my-project`.`my-topic`",
        bigqueryDataset: "analytics",
        bigqueryTable: "events"
    )

    let cmd = sql.runCommand
    #expect(cmd.contains("gcloud dataflow sql query"))
    #expect(cmd.contains("--job-name=streaming-sql"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--bigquery-dataset=analytics"))
    #expect(cmd.contains("--bigquery-table=events"))
}

@Test func testDataflowSQLDryRun() {
    let sql = GoogleCloudDataflowSQL(
        name: "test-sql",
        projectID: "my-project",
        region: "us-central1",
        query: "SELECT 1",
        dryRun: true
    )

    let cmd = sql.runCommand
    #expect(cmd.contains("--dry-run"))
}

@Test func testDataflowSnapshotBasicInit() {
    let snapshot = GoogleCloudDataflowSnapshot(
        projectID: "my-project",
        region: "us-central1",
        sourceJobID: "streaming-job-123",
        description: "Daily snapshot"
    )

    #expect(snapshot.sourceJobID == "streaming-job-123")
}

@Test func testDataflowSnapshotCreateCommand() {
    let snapshot = GoogleCloudDataflowSnapshot(
        projectID: "my-project",
        region: "us-central1",
        sourceJobID: "job-456",
        description: "Backup before update",
        ttl: "7d"
    )

    let cmd = snapshot.createCommand
    #expect(cmd.contains("gcloud dataflow snapshots create"))
    #expect(cmd.contains("--job-id=job-456"))
    #expect(cmd.contains("--snapshot-description=\"Backup before update\""))
    #expect(cmd.contains("--snapshot-ttl=7d"))
}

@Test func testDataflowSnapshotDeleteCommand() {
    let snapshot = GoogleCloudDataflowSnapshot(
        snapshotID: "snap-789",
        projectID: "my-project",
        region: "us-central1",
        sourceJobID: "job-123"
    )

    #expect(snapshot.deleteCommand == "gcloud dataflow snapshots delete snap-789 --project=my-project --region=us-central1")
}

@Test func testDataflowSnapshotDescribeCommand() {
    let snapshot = GoogleCloudDataflowSnapshot(
        snapshotID: "snap-abc",
        projectID: "my-project",
        region: "europe-west1",
        sourceJobID: "job-xyz"
    )

    #expect(snapshot.describeCommand == "gcloud dataflow snapshots describe snap-abc --project=my-project --region=europe-west1")
}

@Test func testDataflowSnapshotListCommand() {
    let cmd = GoogleCloudDataflowSnapshot.listCommand(projectID: "my-project", region: "us-central1")
    #expect(cmd == "gcloud dataflow snapshots list --project=my-project --region=us-central1")

    let cmdWithJob = GoogleCloudDataflowSnapshot.listCommand(
        projectID: "my-project",
        region: "us-central1",
        jobID: "job-123"
    )
    #expect(cmdWithJob.contains("--job-id=job-123"))
}

@Test func testDataflowOperationsEnableAPI() {
    let cmd = DataflowOperations.enableAPICommand(projectID: "my-project")
    #expect(cmd == "gcloud services enable dataflow.googleapis.com --project=my-project")
}

@Test func testDataflowOperationsMetrics() {
    let cmd = DataflowOperations.metricsCommand(
        jobID: "job-123",
        projectID: "my-project",
        region: "us-central1"
    )
    #expect(cmd == "gcloud dataflow metrics list job-123 --project=my-project --region=us-central1")
}

@Test func testDataflowOperationsLogs() {
    let cmd = DataflowOperations.logsCommand(
        jobID: "job-456",
        projectID: "my-project",
        region: "us-west1"
    )
    #expect(cmd == "gcloud dataflow logs list job-456 --project=my-project --region=us-west1")
}

@Test func testDataflowOperationsUpdateJob() {
    let cmd = DataflowOperations.updateJobCommand(
        jobID: "streaming-job",
        projectID: "my-project",
        region: "us-central1",
        templatePath: "gs://bucket/template.json"
    )
    #expect(cmd.contains("gcloud dataflow jobs update-options"))
    #expect(cmd.contains("--job-id=streaming-job"))
    #expect(cmd.contains("--template-gcs-path=gs://bucket/template.json"))
}

@Test func testGoogleDataflowTemplatesConstants() {
    #expect(GoogleDataflowTemplates.wordCount == "gs://dataflow-templates/latest/Word_Count")
    #expect(GoogleDataflowTemplates.pubSubToBigQuery == "gs://dataflow-templates/latest/PubSub_to_BigQuery")
    #expect(GoogleDataflowTemplates.bigQueryToGCS == "gs://dataflow-templates/latest/BigQuery_to_GCS_Export")
    #expect(GoogleDataflowTemplates.textToBigQuery == "gs://dataflow-templates/latest/GCS_Text_to_BigQuery")
}

@Test func testGoogleDataflowTemplatesWordCountJob() {
    let job = GoogleDataflowTemplates.wordCountJob(
        name: "word-count",
        projectID: "my-project",
        region: "us-central1",
        inputFile: "gs://bucket/input.txt",
        outputLocation: "gs://bucket/output",
        tempLocation: "gs://bucket/temp"
    )

    #expect(job.name == "word-count")
    #expect(job.type == .batch)
    #expect(job.templatePath == GoogleDataflowTemplates.wordCount)
    #expect(job.parameters?["inputFile"] == "gs://bucket/input.txt")
}

@Test func testGoogleDataflowTemplatesPubSubToBigQueryJob() {
    let job = GoogleDataflowTemplates.pubSubToBigQueryJob(
        name: "streaming-job",
        projectID: "my-project",
        region: "us-central1",
        inputTopic: "projects/my-project/topics/my-topic",
        outputTable: "my-project:dataset.table",
        tempLocation: "gs://bucket/temp",
        enableStreamingEngine: true
    )

    #expect(job.name == "streaming-job")
    #expect(job.type == .streaming)
    #expect(job.environment?.enableStreamingEngine == true)
}

@Test func testGoogleDataflowTemplatesTextToBigQueryJob() {
    let job = GoogleDataflowTemplates.textToBigQueryJob(
        name: "text-to-bq",
        projectID: "my-project",
        region: "us-central1",
        inputFilePattern: "gs://bucket/data/*.json",
        jsonSchemaPath: "gs://bucket/schema.json",
        outputTable: "my-project:dataset.table",
        bigQueryLoadingTemporaryDirectory: "gs://bucket/bq-temp",
        tempLocation: "gs://bucket/temp"
    )

    #expect(job.parameters?["inputFilePattern"] == "gs://bucket/data/*.json")
    #expect(job.parameters?["JSONPath"] == "gs://bucket/schema.json")
}

@Test func testGoogleDataflowTemplatesBigQueryToGCSJob() {
    let job = GoogleDataflowTemplates.bigQueryToGCSJob(
        name: "export-job",
        projectID: "my-project",
        region: "us-central1",
        inputTable: "my-project:dataset.source_table",
        outputDirectory: "gs://bucket/exports",
        tempLocation: "gs://bucket/temp"
    )

    #expect(job.type == .batch)
    #expect(job.parameters?["inputTableId"] == "my-project:dataset.source_table")
    #expect(job.parameters?["outputDirectory"] == "gs://bucket/exports")
}

@Test func testDAISDataflowTemplateStreamingETLJob() {
    let job = DAISDataflowTemplate.streamingETLJob(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        inputTopic: "projects/my-project/topics/events",
        outputTable: "my-project:analytics.events",
        tempBucket: "dais-prod-dataflow"
    )

    #expect(job.name == "dais-prod-streaming-etl")
    #expect(job.type == .streaming)
    #expect(job.environment?.enableStreamingEngine == true)
    #expect(job.labels?["deployment"] == "dais-prod")
    #expect(job.labels?["managed-by"] == "dais")
}

@Test func testDAISDataflowTemplateBatchExportJob() {
    let job = DAISDataflowTemplate.batchExportJob(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        sourceTable: "my-project:analytics.events",
        destinationBucket: "dais-prod-exports",
        tempBucket: "dais-prod-dataflow"
    )

    #expect(job.name == "dais-prod-batch-export")
    #expect(job.type == .batch)
    #expect(job.environment?.machineType == "n1-standard-4")
}

@Test func testDAISDataflowTemplateLogProcessingJob() {
    let job = DAISDataflowTemplate.logProcessingJob(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        logsTopic: "projects/my-project/topics/logs",
        outputDataset: "dais_prod_logs",
        tempBucket: "dais-prod-dataflow"
    )

    #expect(job.name == "dais-prod-log-processor")
    #expect(job.type == .streaming)
    #expect(job.environment?.additionalExperiments?.contains("enable_streaming_engine") == true)
}

@Test func testDAISDataflowTemplateDataArchiveJob() {
    let job = DAISDataflowTemplate.dataArchiveJob(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        sourceTable: "my-project:analytics.old_events",
        archiveBucket: "dais-prod-archive",
        tempBucket: "dais-prod-dataflow"
    )

    #expect(job.name == "dais-prod-data-archive")
    #expect(job.environment?.diskSizeGb == 100)
    #expect(job.environment?.maxWorkers == 50)
}

@Test func testDAISDataflowTemplateSetupScript() {
    let script = DAISDataflowTemplate.setupScript(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod",
        tempBucket: "dais-prod-dataflow",
        serviceAccountEmail: "dataflow@my-project.iam.gserviceaccount.com"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("dataflow.googleapis.com"))
    #expect(script.contains("gsutil mb"))
    #expect(script.contains("roles/dataflow.admin"))
    #expect(script.contains("roles/dataflow.worker"))
    #expect(script.contains("roles/storage.objectAdmin"))
    #expect(script.contains("roles/bigquery.dataEditor"))
    #expect(script.contains("roles/pubsub.subscriber"))
}

@Test func testDAISDataflowTemplateTeardownScript() {
    let script = DAISDataflowTemplate.teardownScript(
        projectID: "my-project",
        region: "us-central1",
        deploymentName: "dais-prod"
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("dataflow jobs cancel"))
    #expect(script.contains("dataflow jobs drain"))
    #expect(script.contains("dais-prod"))
}

@Test func testDataflowJobCodable() throws {
    let job = GoogleCloudDataflowJob(
        jobID: "job-123",
        name: "my-job",
        projectID: "my-project",
        region: "us-central1",
        type: .streaming,
        state: .running,
        parameters: ["key": "value"]
    )

    let data = try JSONEncoder().encode(job)
    let decoded = try JSONDecoder().decode(GoogleCloudDataflowJob.self, from: data)

    #expect(decoded.jobID == "job-123")
    #expect(decoded.type == .streaming)
    #expect(decoded.state == .running)
    #expect(decoded.parameters?["key"] == "value")
}

@Test func testDataflowFlexTemplateCodable() throws {
    let template = GoogleCloudDataflowFlexTemplate(
        name: "my-template",
        projectID: "my-project",
        templatePath: "gs://bucket/template.json",
        containerImage: "gcr.io/project/image:latest",
        sdkInfo: GoogleCloudDataflowFlexTemplate.SDKInfo(language: .java, version: "2.45.0")
    )

    let data = try JSONEncoder().encode(template)
    let decoded = try JSONDecoder().decode(GoogleCloudDataflowFlexTemplate.self, from: data)

    #expect(decoded.name == "my-template")
    #expect(decoded.sdkInfo?.language == .java)
    #expect(decoded.sdkInfo?.version == "2.45.0")
}

@Test func testDataflowSQLCodable() throws {
    let sql = GoogleCloudDataflowSQL(
        name: "sql-job",
        projectID: "my-project",
        region: "us-central1",
        query: "SELECT 1",
        bigqueryDataset: "dataset"
    )

    let data = try JSONEncoder().encode(sql)
    let decoded = try JSONDecoder().decode(GoogleCloudDataflowSQL.self, from: data)

    #expect(decoded.name == "sql-job")
    #expect(decoded.bigqueryDataset == "dataset")
}

@Test func testDataflowSnapshotCodable() throws {
    let snapshot = GoogleCloudDataflowSnapshot(
        snapshotID: "snap-123",
        projectID: "my-project",
        region: "us-central1",
        sourceJobID: "job-456",
        description: "Test snapshot",
        ttl: "7d"
    )

    let data = try JSONEncoder().encode(snapshot)
    let decoded = try JSONDecoder().decode(GoogleCloudDataflowSnapshot.self, from: data)

    #expect(decoded.snapshotID == "snap-123")
    #expect(decoded.ttl == "7d")
}

@Test func testDataflowEnvironmentConfigCodable() throws {
    let config = GoogleCloudDataflowJob.EnvironmentConfig(
        tempLocation: "gs://bucket/temp",
        machineType: "n1-standard-4",
        numWorkers: 2,
        maxWorkers: 10,
        enableStreamingEngine: true,
        diskSizeGb: 50
    )

    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(GoogleCloudDataflowJob.EnvironmentConfig.self, from: data)

    #expect(decoded.machineType == "n1-standard-4")
    #expect(decoded.enableStreamingEngine == true)
    #expect(decoded.diskSizeGb == 50)
}

@Test func testDataflowDiskTypes() {
    #expect(GoogleCloudDataflowJob.EnvironmentConfig.DiskType.pdSsd.rawValue == "pd-ssd")
    #expect(GoogleCloudDataflowJob.EnvironmentConfig.DiskType.pdStandard.rawValue == "pd-standard")
    #expect(GoogleCloudDataflowJob.EnvironmentConfig.DiskType.pdBalanced.rawValue == "pd-balanced")
}

// MARK: - Cloud Deploy Tests

@Test func testDeliveryPipelineBasicInit() {
    let pipeline = GoogleCloudDeliveryPipeline(
        name: "my-pipeline",
        projectID: "my-project",
        location: "us-central1",
        description: "Test pipeline"
    )

    #expect(pipeline.name == "my-pipeline")
    #expect(pipeline.projectID == "my-project")
    #expect(pipeline.resourceName == "projects/my-project/locations/us-central1/deliveryPipelines/my-pipeline")
}

@Test func testDeliveryPipelineWithStages() {
    let pipeline = GoogleCloudDeliveryPipeline(
        name: "prod-pipeline",
        projectID: "my-project",
        location: "us-central1",
        serialPipeline: GoogleCloudDeliveryPipeline.SerialPipeline(
            stages: [
                GoogleCloudDeliveryPipeline.SerialPipeline.Stage(targetId: "dev", profiles: ["dev"]),
                GoogleCloudDeliveryPipeline.SerialPipeline.Stage(targetId: "staging", profiles: ["staging"]),
                GoogleCloudDeliveryPipeline.SerialPipeline.Stage(targetId: "prod", profiles: ["prod"])
            ]
        )
    )

    #expect(pipeline.serialPipeline?.stages.count == 3)
    #expect(pipeline.serialPipeline?.stages[0].targetId == "dev")
    #expect(pipeline.serialPipeline?.stages[2].targetId == "prod")
}

@Test func testDeliveryPipelineCreateCommand() {
    let pipeline = GoogleCloudDeliveryPipeline(
        name: "app-pipeline",
        projectID: "my-project",
        location: "us-central1",
        description: "Application delivery pipeline",
        labels: ["team": "platform"]
    )

    let cmd = pipeline.createCommand
    #expect(cmd.contains("gcloud deploy delivery-pipelines create app-pipeline"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--description=\"Application delivery pipeline\""))
    #expect(cmd.contains("--labels=team=platform"))
}

@Test func testDeliveryPipelineDescribeCommand() {
    let pipeline = GoogleCloudDeliveryPipeline(
        name: "my-pipeline",
        projectID: "my-project",
        location: "us-west1"
    )

    #expect(pipeline.describeCommand == "gcloud deploy delivery-pipelines describe my-pipeline --project=my-project --region=us-west1")
}

@Test func testDeliveryPipelineDeleteCommand() {
    let pipeline = GoogleCloudDeliveryPipeline(
        name: "old-pipeline",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(pipeline.deleteCommand == "gcloud deploy delivery-pipelines delete old-pipeline --project=my-project --region=us-central1 --quiet")
}

@Test func testDeliveryPipelineListCommand() {
    let cmd = GoogleCloudDeliveryPipeline.listCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd == "gcloud deploy delivery-pipelines list --project=my-project --region=us-central1")
}

@Test func testDeliveryPipelineCreateFromFileCommand() {
    let pipeline = GoogleCloudDeliveryPipeline(
        name: "my-pipeline",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = pipeline.createFromFileCommand(filePath: "pipeline.yaml")
    #expect(cmd == "gcloud deploy apply --file=pipeline.yaml --project=my-project --region=us-central1")
}

@Test func testDeployTargetCloudRun() {
    let target = GoogleCloudDeployTarget(
        name: "prod-target",
        projectID: "my-project",
        location: "us-central1",
        description: "Production Cloud Run target",
        targetType: .cloudRun(location: "us-central1"),
        requireApproval: true
    )

    #expect(target.name == "prod-target")
    #expect(target.resourceName == "projects/my-project/locations/us-central1/targets/prod-target")

    let cmd = target.createCommand
    #expect(cmd.contains("gcloud deploy targets create prod-target"))
    #expect(cmd.contains("--run-location=us-central1"))
    #expect(cmd.contains("--require-approval"))
}

@Test func testDeployTargetGKE() {
    let target = GoogleCloudDeployTarget(
        name: "gke-prod",
        projectID: "my-project",
        location: "us-central1",
        targetType: .gke(
            cluster: "projects/my-project/locations/us-central1/clusters/my-cluster",
            internalIP: true
        )
    )

    let cmd = target.createCommand
    #expect(cmd.contains("--gke-cluster=projects/my-project/locations/us-central1/clusters/my-cluster"))
    #expect(cmd.contains("--internal-ip"))
}

@Test func testDeployTargetDescribeCommand() {
    let target = GoogleCloudDeployTarget(
        name: "dev-target",
        projectID: "my-project",
        location: "us-central1",
        targetType: .cloudRun(location: "us-central1")
    )

    #expect(target.describeCommand == "gcloud deploy targets describe dev-target --project=my-project --region=us-central1")
}

@Test func testDeployTargetDeleteCommand() {
    let target = GoogleCloudDeployTarget(
        name: "old-target",
        projectID: "my-project",
        location: "us-west1",
        targetType: .cloudRun(location: "us-west1")
    )

    #expect(target.deleteCommand == "gcloud deploy targets delete old-target --project=my-project --region=us-west1 --quiet")
}

@Test func testDeployTargetListCommand() {
    let cmd = GoogleCloudDeployTarget.listCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd == "gcloud deploy targets list --project=my-project --region=us-central1")
}

@Test func testDeployReleaseBasicInit() {
    let release = GoogleCloudDeployRelease(
        name: "release-001",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "my-pipeline",
        description: "Initial release"
    )

    #expect(release.name == "release-001")
    #expect(release.resourceName == "projects/my-project/locations/us-central1/deliveryPipelines/my-pipeline/releases/release-001")
}

@Test func testDeployReleaseCreateCommand() {
    let release = GoogleCloudDeployRelease(
        name: "v1.0.0",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "app-pipeline",
        description: "Version 1.0.0 release",
        buildArtifacts: [
            GoogleCloudDeployRelease.BuildArtifact(image: "app", tag: "gcr.io/my-project/app:v1.0.0")
        ],
        skaffoldConfigUri: "gs://my-bucket/skaffold.yaml"
    )

    let cmd = release.createCommand
    #expect(cmd.contains("gcloud deploy releases create v1.0.0"))
    #expect(cmd.contains("--delivery-pipeline=app-pipeline"))
    #expect(cmd.contains("--images=app=gcr.io/my-project/app:v1.0.0"))
    #expect(cmd.contains("--source=gs://my-bucket/skaffold.yaml"))
}

@Test func testDeployReleaseDescribeCommand() {
    let release = GoogleCloudDeployRelease(
        name: "rel-123",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "my-pipeline"
    )

    #expect(release.describeCommand.contains("releases describe rel-123"))
    #expect(release.describeCommand.contains("--delivery-pipeline=my-pipeline"))
}

@Test func testDeployReleaseListCommand() {
    let cmd = GoogleCloudDeployRelease.listCommand(
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "my-pipeline"
    )
    #expect(cmd.contains("releases list"))
    #expect(cmd.contains("--delivery-pipeline=my-pipeline"))
}

@Test func testDeployReleasePromoteCommand() {
    let release = GoogleCloudDeployRelease(
        name: "v1.0.0",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "app-pipeline"
    )

    let cmd = release.promoteCommand(toTarget: "prod")
    #expect(cmd.contains("releases promote"))
    #expect(cmd.contains("--release=v1.0.0"))
    #expect(cmd.contains("--to-target=prod"))
}

@Test func testDeployRolloutBasicInit() {
    let rollout = GoogleCloudDeployRollout(
        name: "rollout-001",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "my-pipeline",
        releaseName: "v1.0.0",
        targetId: "prod",
        state: .inProgress
    )

    #expect(rollout.name == "rollout-001")
    #expect(rollout.state == .inProgress)
    #expect(rollout.resourceName.contains("rollouts/rollout-001"))
}

@Test func testDeployRolloutDescribeCommand() {
    let rollout = GoogleCloudDeployRollout(
        name: "rollout-abc",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "pipeline",
        releaseName: "release",
        targetId: "prod"
    )

    #expect(rollout.describeCommand.contains("rollouts describe rollout-abc"))
    #expect(rollout.describeCommand.contains("--release=release"))
}

@Test func testDeployRolloutApproveCommand() {
    let rollout = GoogleCloudDeployRollout(
        name: "pending-rollout",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "pipeline",
        releaseName: "release",
        targetId: "prod",
        state: .pendingApproval
    )

    #expect(rollout.approveCommand.contains("rollouts approve pending-rollout"))
}

@Test func testDeployRolloutRejectCommand() {
    let rollout = GoogleCloudDeployRollout(
        name: "bad-rollout",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "pipeline",
        releaseName: "release",
        targetId: "prod"
    )

    #expect(rollout.rejectCommand.contains("rollouts reject bad-rollout"))
}

@Test func testDeployRolloutCancelCommand() {
    let rollout = GoogleCloudDeployRollout(
        name: "in-progress-rollout",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "pipeline",
        releaseName: "release",
        targetId: "prod"
    )

    #expect(rollout.cancelCommand.contains("rollouts cancel in-progress-rollout"))
}

@Test func testDeployRolloutStates() {
    #expect(GoogleCloudDeployRollout.RolloutState.succeeded.rawValue == "SUCCEEDED")
    #expect(GoogleCloudDeployRollout.RolloutState.failed.rawValue == "FAILED")
    #expect(GoogleCloudDeployRollout.RolloutState.inProgress.rawValue == "IN_PROGRESS")
    #expect(GoogleCloudDeployRollout.RolloutState.pendingApproval.rawValue == "PENDING_APPROVAL")
    #expect(GoogleCloudDeployRollout.RolloutState.cancelled.rawValue == "CANCELLED")
}

@Test func testCloudDeployOperationsEnableAPI() {
    let cmd = CloudDeployOperations.enableAPICommand(projectID: "my-project")
    #expect(cmd == "gcloud services enable clouddeploy.googleapis.com --project=my-project")
}

@Test func testCloudDeployOperationsGetServiceAccount() {
    let cmd = CloudDeployOperations.getServiceAccountCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("deploy get-config"))
}

@Test func testCloudDeployOperationsCreateAutomation() {
    let cmd = CloudDeployOperations.createAutomationCommand(
        name: "auto-promote",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "my-pipeline",
        targetId: "staging",
        serviceAccount: "deploy@my-project.iam.gserviceaccount.com",
        automationType: .promoteRelease
    )

    #expect(cmd.contains("automations create auto-promote"))
    #expect(cmd.contains("--promote-release-rule=promoteRule"))
}

@Test func testDAISCloudDeployTemplateCloudRunPipeline() {
    let pipeline = DAISCloudDeployTemplate.cloudRunPipeline(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        stages: [
            (name: "dev", runLocation: "us-central1", requireApproval: false),
            (name: "prod", runLocation: "us-central1", requireApproval: true)
        ]
    )

    #expect(pipeline.name == "dais-prod-pipeline")
    #expect(pipeline.serialPipeline?.stages.count == 2)
    #expect(pipeline.labels?["deployment"] == "dais-prod")
}

@Test func testDAISCloudDeployTemplateCloudRunTarget() {
    let target = DAISCloudDeployTemplate.cloudRunTarget(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        environment: "prod",
        runLocation: "us-central1",
        requireApproval: true
    )

    #expect(target.name == "dais-prod-prod")
    #expect(target.requireApproval == true)
    #expect(target.labels?["environment"] == "prod")
}

@Test func testDAISCloudDeployTemplateGKETarget() {
    let target = DAISCloudDeployTemplate.gkeTarget(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        environment: "staging",
        clusterName: "main-cluster",
        clusterLocation: "us-central1-a"
    )

    #expect(target.name == "dais-prod-staging")
    if case .gke(let cluster, _) = target.targetType {
        #expect(cluster.contains("main-cluster"))
    }
}

@Test func testDAISCloudDeployTemplateSetupScript() {
    let script = DAISCloudDeployTemplate.setupScript(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        environments: [
            (name: "dev", runLocation: "us-central1", requireApproval: false),
            (name: "prod", runLocation: "us-central1", requireApproval: true)
        ]
    )

    #expect(script.contains("#!/bin/bash"))
    #expect(script.contains("clouddeploy.googleapis.com"))
    #expect(script.contains("targets create dais-prod-dev"))
    #expect(script.contains("targets create dais-prod-prod"))
    #expect(script.contains("--require-approval"))
    #expect(script.contains("dais-prod-pipeline"))
}

@Test func testDAISCloudDeployTemplateTeardownScript() {
    let script = DAISCloudDeployTemplate.teardownScript(
        projectID: "my-project",
        location: "us-central1",
        deploymentName: "dais-prod",
        environments: ["dev", "staging", "prod"]
    )

    #expect(script.contains("delivery-pipelines delete dais-prod-pipeline"))
    #expect(script.contains("targets delete dais-prod-dev"))
    #expect(script.contains("targets delete dais-prod-staging"))
    #expect(script.contains("targets delete dais-prod-prod"))
}

@Test func testDAISCloudDeployTemplateSkaffoldYaml() {
    let yaml = DAISCloudDeployTemplate.skaffoldYamlCloudRun(
        projectID: "my-project",
        serviceName: "my-service",
        image: "gcr.io/my-project/my-service:latest"
    )

    #expect(yaml.contains("apiVersion: skaffold/v4beta7"))
    #expect(yaml.contains("cloudrun: {}"))
}

@Test func testDAISCloudDeployTemplateCloudRunServiceYaml() {
    let yaml = DAISCloudDeployTemplate.cloudRunServiceYaml(
        serviceName: "api-service",
        image: "gcr.io/project/api:v1",
        port: 8080,
        memory: "1Gi",
        cpu: "2"
    )

    #expect(yaml.contains("serving.knative.dev/v1"))
    #expect(yaml.contains("name: api-service"))
    #expect(yaml.contains("containerPort: 8080"))
    #expect(yaml.contains("memory: 1Gi"))
}

@Test func testDeliveryPipelineCodable() throws {
    let pipeline = GoogleCloudDeliveryPipeline(
        name: "test-pipeline",
        projectID: "my-project",
        location: "us-central1",
        description: "Test",
        labels: ["env": "test"]
    )

    let data = try JSONEncoder().encode(pipeline)
    let decoded = try JSONDecoder().decode(GoogleCloudDeliveryPipeline.self, from: data)

    #expect(decoded.name == "test-pipeline")
    #expect(decoded.labels?["env"] == "test")
}

@Test func testDeployReleaseCodable() throws {
    let release = GoogleCloudDeployRelease(
        name: "v1.0.0",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "pipeline",
        buildArtifacts: [
            GoogleCloudDeployRelease.BuildArtifact(image: "app", tag: "v1.0.0")
        ]
    )

    let data = try JSONEncoder().encode(release)
    let decoded = try JSONDecoder().decode(GoogleCloudDeployRelease.self, from: data)

    #expect(decoded.name == "v1.0.0")
    #expect(decoded.buildArtifacts?.first?.tag == "v1.0.0")
}

@Test func testDeployRolloutCodable() throws {
    let rollout = GoogleCloudDeployRollout(
        name: "rollout-1",
        projectID: "my-project",
        location: "us-central1",
        pipelineName: "pipeline",
        releaseName: "release",
        targetId: "prod",
        state: .succeeded
    )

    let data = try JSONEncoder().encode(rollout)
    let decoded = try JSONDecoder().decode(GoogleCloudDeployRollout.self, from: data)

    #expect(decoded.name == "rollout-1")
    #expect(decoded.state == .succeeded)
}

@Test func testExecutionConfigUsages() {
    #expect(GoogleCloudDeployTarget.ExecutionConfig.Usage.render.rawValue == "RENDER")
    #expect(GoogleCloudDeployTarget.ExecutionConfig.Usage.deploy.rawValue == "DEPLOY")
    #expect(GoogleCloudDeployTarget.ExecutionConfig.Usage.verify.rawValue == "VERIFY")
}

// MARK: - Cloud Workflows Tests

@Test func testWorkflowBasicInit() {
    let workflow = GoogleCloudWorkflow(
        name: "my-workflow",
        projectID: "my-project",
        location: "us-central1",
        description: "Test workflow"
    )

    #expect(workflow.name == "my-workflow")
    #expect(workflow.projectID == "my-project")
    #expect(workflow.location == "us-central1")
    #expect(workflow.description == "Test workflow")
}

@Test func testWorkflowResourceName() {
    let workflow = GoogleCloudWorkflow(
        name: "my-workflow",
        projectID: "my-project",
        location: "us-west1"
    )

    #expect(workflow.resourceName == "projects/my-project/locations/us-west1/workflows/my-workflow")
}

@Test func testWorkflowCreateCommand() {
    let workflow = GoogleCloudWorkflow(
        name: "my-workflow",
        projectID: "my-project",
        location: "us-central1",
        description: "Test workflow",
        serviceAccount: "workflow-sa@my-project.iam.gserviceaccount.com",
        callLogLevel: .logAllCalls
    )

    let cmd = workflow.createCommand
    #expect(cmd.contains("gcloud workflows deploy my-workflow"))
    #expect(cmd.contains("--location=us-central1"))
    #expect(cmd.contains("--description='Test workflow'"))
    #expect(cmd.contains("--service-account=workflow-sa@my-project.iam.gserviceaccount.com"))
    #expect(cmd.contains("--call-log-level="))
}

@Test func testWorkflowDeleteCommand() {
    let workflow = GoogleCloudWorkflow(
        name: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(workflow.deleteCommand == "gcloud workflows delete my-workflow --location=us-central1 --quiet")
}

@Test func testWorkflowDescribeCommand() {
    let workflow = GoogleCloudWorkflow(
        name: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(workflow.describeCommand == "gcloud workflows describe my-workflow --location=us-central1")
}

@Test func testWorkflowExecuteCommand() {
    let workflow = GoogleCloudWorkflow(
        name: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = workflow.executeCommand(data: "{\"key\": \"value\"}")
    #expect(cmd.contains("gcloud workflows run my-workflow"))
    #expect(cmd.contains("--location=us-central1"))
    #expect(cmd.contains("--data="))
}

@Test func testWorkflowListRevisionsCommand() {
    let workflow = GoogleCloudWorkflow(
        name: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(workflow.listRevisionsCommand == "gcloud workflows revisions list --workflow=my-workflow --location=us-central1")
}

@Test func testWorkflowStateValues() {
    #expect(GoogleCloudWorkflow.WorkflowState.active.rawValue == "ACTIVE")
    #expect(GoogleCloudWorkflow.WorkflowState.unavailable.rawValue == "UNAVAILABLE")
}

@Test func testWorkflowCallLogLevelValues() {
    #expect(GoogleCloudWorkflow.CallLogLevel.logAllCalls.rawValue == "LOG_ALL_CALLS")
    #expect(GoogleCloudWorkflow.CallLogLevel.logErrorsOnly.rawValue == "LOG_ERRORS_ONLY")
    #expect(GoogleCloudWorkflow.CallLogLevel.logNone.rawValue == "LOG_NONE")
}

@Test func testWorkflowExecutionBasicInit() {
    let execution = GoogleCloudWorkflowExecution(
        name: "exec-123",
        workflowName: "my-workflow",
        projectID: "my-project",
        location: "us-central1",
        state: .succeeded
    )

    #expect(execution.name == "exec-123")
    #expect(execution.workflowName == "my-workflow")
    #expect(execution.state == .succeeded)
}

@Test func testWorkflowExecutionResourceName() {
    let execution = GoogleCloudWorkflowExecution(
        name: "exec-123",
        workflowName: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(execution.resourceName == "projects/my-project/locations/us-central1/workflows/my-workflow/executions/exec-123")
}

@Test func testWorkflowExecutionDescribeCommand() {
    let execution = GoogleCloudWorkflowExecution(
        name: "exec-123",
        workflowName: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(execution.describeCommand == "gcloud workflows executions describe exec-123 --workflow=my-workflow --location=us-central1")
}

@Test func testWorkflowExecutionCancelCommand() {
    let execution = GoogleCloudWorkflowExecution(
        name: "exec-123",
        workflowName: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(execution.cancelCommand == "gcloud workflows executions cancel exec-123 --workflow=my-workflow --location=us-central1")
}

@Test func testWorkflowExecutionWaitCommand() {
    let execution = GoogleCloudWorkflowExecution(
        name: "exec-123",
        workflowName: "my-workflow",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(execution.waitCommand == "gcloud workflows executions wait exec-123 --workflow=my-workflow --location=us-central1")
}

@Test func testWorkflowExecutionStateValues() {
    #expect(GoogleCloudWorkflowExecution.ExecutionState.active.rawValue == "ACTIVE")
    #expect(GoogleCloudWorkflowExecution.ExecutionState.succeeded.rawValue == "SUCCEEDED")
    #expect(GoogleCloudWorkflowExecution.ExecutionState.failed.rawValue == "FAILED")
    #expect(GoogleCloudWorkflowExecution.ExecutionState.cancelled.rawValue == "CANCELLED")
    #expect(GoogleCloudWorkflowExecution.ExecutionState.queued.rawValue == "QUEUED")
}

@Test func testWorkflowYAMLBuilderBasic() {
    var builder = WorkflowYAMLBuilder()
    builder.addStep("init", .assign(variables: [("project", "my-project")]))
    builder.addStep("returnResult", .return(value: "${project}"))

    let yaml = builder.build()
    #expect(yaml.contains("main:"))
    #expect(yaml.contains("steps:"))
    #expect(yaml.contains("- init:"))
    #expect(yaml.contains("- returnResult:"))
}

@Test func testWorkflowStepAssign() {
    let step = WorkflowStep.assign(variables: [("x", "1"), ("y", "2")])
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("assign:"))
    #expect(yaml.contains("- x: 1"))
    #expect(yaml.contains("- y: 2"))
}

@Test func testWorkflowStepHTTPGet() {
    let step = WorkflowStep.httpGet(url: "https://api.example.com/data", result: "response")
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("call: http.get"))
    #expect(yaml.contains("url: https://api.example.com/data"))
    #expect(yaml.contains("result: response"))
}

@Test func testWorkflowStepHTTPPost() {
    let step = WorkflowStep.httpPost(
        url: "https://api.example.com/submit",
        body: ["key": "value"],
        result: "postResult"
    )
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("call: http.post"))
    #expect(yaml.contains("url: https://api.example.com/submit"))
    #expect(yaml.contains("body:"))
    #expect(yaml.contains("key: value"))
    #expect(yaml.contains("result: postResult"))
}

@Test func testWorkflowStepReturn() {
    let step = WorkflowStep.return(value: "${result}")
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("return: ${result}"))
}

@Test func testWorkflowStepLog() {
    let step = WorkflowStep.log(text: "Processing started", severity: "INFO")
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("call: sys.log"))
    #expect(yaml.contains("text: Processing started"))
    #expect(yaml.contains("severity: INFO"))
}

@Test func testWorkflowStepSleep() {
    let step = WorkflowStep.sleep(seconds: 30)
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("call: sys.sleep"))
    #expect(yaml.contains("seconds: 30"))
}

@Test func testWorkflowStepRaise() {
    let step = WorkflowStep.raise(error: "Error occurred")
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("raise: Error occurred"))
}

@Test func testWorkflowStepCallConnector() {
    let step = WorkflowStep.callConnector(
        connector: "googleapis.bigquery.v2.jobs",
        method: "query",
        args: ["projectId": "my-project"],
        result: "queryResult"
    )
    let yaml = step.toYAML(indent: 8)

    #expect(yaml.contains("call: googleapis.bigquery.v2.jobs.query"))
    #expect(yaml.contains("projectId: my-project"))
    #expect(yaml.contains("result: queryResult"))
}

@Test func testWorkflowOperationsListCommand() {
    let cmd = WorkflowOperations.listCommand(location: "us-east1")
    #expect(cmd == "gcloud workflows list --location=us-east1")
}

@Test func testWorkflowOperationsListAllCommand() {
    #expect(WorkflowOperations.listAllCommand == "gcloud workflows list --location=-")
}

@Test func testWorkflowOperationsListExecutionsCommand() {
    let cmd = WorkflowOperations.listExecutionsCommand(workflow: "my-workflow", location: "us-central1", limit: 10)
    #expect(cmd.contains("gcloud workflows executions list"))
    #expect(cmd.contains("--workflow=my-workflow"))
    #expect(cmd.contains("--limit=10"))
}

@Test func testWorkflowOperationsRunWithJSONCommand() {
    let cmd = WorkflowOperations.runWithJSONCommand(workflow: "my-workflow", location: "us-central1", jsonFile: "input.json")
    #expect(cmd.contains("gcloud workflows run my-workflow"))
    #expect(cmd.contains("--data-file=input.json"))
}

@Test func testWorkflowOperationsEnableAPICommand() {
    #expect(WorkflowOperations.enableAPICommand == "gcloud services enable workflows.googleapis.com")
}

@Test func testWorkflowConnectorsBigQueryQuery() {
    let step = WorkflowConnectors.BigQuery.query(query: "SELECT * FROM table", projectID: "my-project")

    if case .callConnector(let connector, let method, let args, _) = step {
        #expect(connector == "googleapis.bigquery.v2.jobs")
        #expect(method == "query")
        #expect(args["projectId"] == "my-project")
    }
}

@Test func testWorkflowConnectorsStorageListObjects() {
    let step = WorkflowConnectors.Storage.listObjects(bucket: "my-bucket")

    if case .callConnector(let connector, let method, let args, _) = step {
        #expect(connector == "googleapis.storage.v1.objects")
        #expect(method == "list")
        #expect(args["bucket"] == "my-bucket")
    }
}

@Test func testWorkflowConnectorsPubSubPublish() {
    let step = WorkflowConnectors.PubSub.publish(topic: "my-topic", message: "Hello")

    if case .callConnector(let connector, let method, _, _) = step {
        #expect(connector == "googleapis.pubsub.v1.projects.topics")
        #expect(method == "publish")
    }
}

@Test func testWorkflowConnectorsSecretManagerAccess() {
    let step = WorkflowConnectors.SecretManager.accessSecret(secret: "my-secret", version: "1")

    if case .callConnector(let connector, let method, let args, _) = step {
        #expect(connector == "googleapis.secretmanager.v1.projects.secrets.versions")
        #expect(method == "access")
        #expect(args["name"] == "my-secret/versions/1")
    }
}

@Test func testDAISWorkflowsTemplateDataProcessing() {
    let template = DAISWorkflowsTemplate(
        projectID: "my-project",
        location: "us-central1",
        serviceAccountEmail: "workflow-sa@my-project.iam.gserviceaccount.com"
    )

    let workflow = template.dataProcessingWorkflow
    #expect(workflow.name == "dais-data-processing")
    #expect(workflow.labels?["app"] == "dais")
    #expect(workflow.labels?["component"] == "data-processing")
    #expect(workflow.serviceAccount == "workflow-sa@my-project.iam.gserviceaccount.com")
    #expect(workflow.sourceContents?.contains("processData") == true)
}

@Test func testDAISWorkflowsTemplateStorageEvent() {
    let template = DAISWorkflowsTemplate(projectID: "my-project")

    let workflow = template.storageEventWorkflow
    #expect(workflow.name == "dais-storage-event-handler")
    #expect(workflow.sourceContents?.contains("event.data.bucket") == true)
    #expect(workflow.sourceContents?.contains("contentType") == true)
}

@Test func testDAISWorkflowsTemplateBatchProcessing() {
    let template = DAISWorkflowsTemplate(projectID: "my-project")

    let workflow = template.batchProcessingWorkflow
    #expect(workflow.name == "dais-batch-processing")
    #expect(workflow.sourceContents?.contains("parallel:") == true)
    #expect(workflow.sourceContents?.contains("processedCount") == true)
}

@Test func testDAISWorkflowsTemplateRetry() {
    let template = DAISWorkflowsTemplate(projectID: "my-project")

    let workflow = template.retryWorkflow
    #expect(workflow.name == "dais-retry-workflow")
    #expect(workflow.sourceContents?.contains("maxRetries") == true)
    #expect(workflow.sourceContents?.contains("exponential") != true || workflow.sourceContents?.contains("math.pow") == true)
}

@Test func testDAISWorkflowsTemplateApproval() {
    let template = DAISWorkflowsTemplate(projectID: "my-project")

    let workflow = template.approvalWorkflow
    #expect(workflow.name == "dais-approval-workflow")
    #expect(workflow.sourceContents?.contains("callbacks.await") == true)
    #expect(workflow.sourceContents?.contains("approvalTimeout") == true)
}

@Test func testDAISWorkflowsTemplateSetupScript() {
    let template = DAISWorkflowsTemplate(
        projectID: "my-project",
        location: "us-central1",
        serviceAccountEmail: "sa@my-project.iam.gserviceaccount.com"
    )

    let script = template.setupScript
    #expect(script.contains("gcloud services enable workflows.googleapis.com"))
    #expect(script.contains("gcloud workflows deploy dais-data-processing"))
    #expect(script.contains("gcloud workflows deploy dais-batch-processing"))
    #expect(script.contains("gcloud workflows list"))
}

@Test func testWorkflowCodable() throws {
    let workflow = GoogleCloudWorkflow(
        name: "test-workflow",
        projectID: "my-project",
        location: "us-central1",
        description: "Test",
        labels: ["env": "test"],
        callLogLevel: .logAllCalls
    )

    let data = try JSONEncoder().encode(workflow)
    let decoded = try JSONDecoder().decode(GoogleCloudWorkflow.self, from: data)

    #expect(decoded.name == "test-workflow")
    #expect(decoded.callLogLevel == .logAllCalls)
}

@Test func testWorkflowExecutionCodable() throws {
    let execution = GoogleCloudWorkflowExecution(
        name: "exec-1",
        workflowName: "my-workflow",
        projectID: "my-project",
        location: "us-central1",
        argument: "{\"key\": \"value\"}",
        state: .succeeded
    )

    let data = try JSONEncoder().encode(execution)
    let decoded = try JSONDecoder().decode(GoogleCloudWorkflowExecution.self, from: data)

    #expect(decoded.name == "exec-1")
    #expect(decoded.argument == "{\"key\": \"value\"}")
    #expect(decoded.state == .succeeded)
}

// MARK: - API Gateway Tests

@Test func testAPIGatewayAPIBasicInit() {
    let api = GoogleCloudAPIGatewayAPI(
        name: "my-api",
        projectID: "my-project",
        displayName: "My API"
    )

    #expect(api.name == "my-api")
    #expect(api.projectID == "my-project")
    #expect(api.displayName == "My API")
}

@Test func testAPIGatewayAPIResourceName() {
    let api = GoogleCloudAPIGatewayAPI(
        name: "my-api",
        projectID: "my-project"
    )

    #expect(api.resourceName == "projects/my-project/locations/global/apis/my-api")
}

@Test func testAPIGatewayAPICreateCommand() {
    let api = GoogleCloudAPIGatewayAPI(
        name: "my-api",
        projectID: "my-project",
        displayName: "My API",
        labels: ["env": "prod"]
    )

    let cmd = api.createCommand
    #expect(cmd.contains("gcloud api-gateway apis create my-api"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--display-name='My API'"))
    #expect(cmd.contains("--labels=env=prod"))
}

@Test func testAPIGatewayAPIDeleteCommand() {
    let api = GoogleCloudAPIGatewayAPI(
        name: "my-api",
        projectID: "my-project"
    )

    #expect(api.deleteCommand == "gcloud api-gateway apis delete my-api --project=my-project --quiet")
}

@Test func testAPIGatewayAPIDescribeCommand() {
    let api = GoogleCloudAPIGatewayAPI(
        name: "my-api",
        projectID: "my-project"
    )

    #expect(api.describeCommand == "gcloud api-gateway apis describe my-api --project=my-project")
}

@Test func testAPIGatewayAPIStateValues() {
    #expect(GoogleCloudAPIGatewayAPI.APIState.active.rawValue == "ACTIVE")
    #expect(GoogleCloudAPIGatewayAPI.APIState.creating.rawValue == "CREATING")
    #expect(GoogleCloudAPIGatewayAPI.APIState.failed.rawValue == "FAILED")
}

@Test func testAPIGatewayConfigBasicInit() {
    let config = GoogleCloudAPIGatewayConfig(
        name: "my-config",
        apiName: "my-api",
        projectID: "my-project",
        gatewayServiceAccount: "sa@my-project.iam.gserviceaccount.com"
    )

    #expect(config.name == "my-config")
    #expect(config.apiName == "my-api")
    #expect(config.gatewayServiceAccount == "sa@my-project.iam.gserviceaccount.com")
}

@Test func testAPIGatewayConfigResourceName() {
    let config = GoogleCloudAPIGatewayConfig(
        name: "my-config",
        apiName: "my-api",
        projectID: "my-project"
    )

    #expect(config.resourceName == "projects/my-project/locations/global/apis/my-api/configs/my-config")
}

@Test func testAPIGatewayConfigCreateCommand() {
    let config = GoogleCloudAPIGatewayConfig(
        name: "my-config",
        apiName: "my-api",
        projectID: "my-project",
        displayName: "My Config",
        gatewayServiceAccount: "sa@my-project.iam.gserviceaccount.com"
    )

    let cmd = config.createCommand(openAPISpec: "spec.yaml")
    #expect(cmd.contains("gcloud api-gateway api-configs create my-config"))
    #expect(cmd.contains("--api=my-api"))
    #expect(cmd.contains("--openapi-spec=spec.yaml"))
    #expect(cmd.contains("--backend-auth-service-account=sa@my-project.iam.gserviceaccount.com"))
}

@Test func testAPIGatewayConfigDeleteCommand() {
    let config = GoogleCloudAPIGatewayConfig(
        name: "my-config",
        apiName: "my-api",
        projectID: "my-project"
    )

    #expect(config.deleteCommand == "gcloud api-gateway api-configs delete my-config --api=my-api --project=my-project --quiet")
}

@Test func testAPIGatewayConfigStateValues() {
    #expect(GoogleCloudAPIGatewayConfig.ConfigState.active.rawValue == "ACTIVE")
    #expect(GoogleCloudAPIGatewayConfig.ConfigState.activating.rawValue == "ACTIVATING")
}

@Test func testAPIGatewayGatewayBasicInit() {
    let gateway = GoogleCloudAPIGatewayGateway(
        name: "my-gateway",
        projectID: "my-project",
        location: "us-central1",
        apiConfig: "projects/my-project/locations/global/apis/my-api/configs/my-config"
    )

    #expect(gateway.name == "my-gateway")
    #expect(gateway.location == "us-central1")
    #expect(gateway.apiConfig.contains("my-config"))
}

@Test func testAPIGatewayGatewayResourceName() {
    let gateway = GoogleCloudAPIGatewayGateway(
        name: "my-gateway",
        projectID: "my-project",
        location: "us-west1",
        apiConfig: "config"
    )

    #expect(gateway.resourceName == "projects/my-project/locations/us-west1/gateways/my-gateway")
}

@Test func testAPIGatewayGatewayCreateCommand() {
    let gateway = GoogleCloudAPIGatewayGateway(
        name: "my-gateway",
        projectID: "my-project",
        location: "us-central1",
        apiConfig: "my-config",
        displayName: "My Gateway",
        labels: ["app": "dais"]
    )

    let cmd = gateway.createCommand
    #expect(cmd.contains("gcloud api-gateway gateways create my-gateway"))
    #expect(cmd.contains("--api-config=my-config"))
    #expect(cmd.contains("--location=us-central1"))
    #expect(cmd.contains("--display-name='My Gateway'"))
}

@Test func testAPIGatewayGatewayDeleteCommand() {
    let gateway = GoogleCloudAPIGatewayGateway(
        name: "my-gateway",
        projectID: "my-project",
        location: "us-central1",
        apiConfig: "config"
    )

    #expect(gateway.deleteCommand == "gcloud api-gateway gateways delete my-gateway --location=us-central1 --project=my-project --quiet")
}

@Test func testAPIGatewayGatewayUpdateCommand() {
    let gateway = GoogleCloudAPIGatewayGateway(
        name: "my-gateway",
        projectID: "my-project",
        location: "us-central1",
        apiConfig: "old-config"
    )

    let cmd = gateway.updateCommand(newApiConfig: "new-config")
    #expect(cmd.contains("gcloud api-gateway gateways update my-gateway"))
    #expect(cmd.contains("--api-config=new-config"))
}

@Test func testAPIGatewayGatewayStateValues() {
    #expect(GoogleCloudAPIGatewayGateway.GatewayState.active.rawValue == "ACTIVE")
    #expect(GoogleCloudAPIGatewayGateway.GatewayState.updating.rawValue == "UPDATING")
}

@Test func testOpenAPISpecBuilderBasic() {
    var builder = OpenAPISpecBuilder(
        title: "Test API",
        description: "A test API",
        version: "1.0.0"
    )

    builder.addPath("/test", method: "GET", operation: OpenAPISpecBuilder.Operation(
        operationId: "testOp",
        backendAddress: "https://backend.example.com/test"
    ))

    let spec = builder.build()
    #expect(spec.contains("swagger: \"2.0\""))
    #expect(spec.contains("title: \"Test API\""))
    #expect(spec.contains("/test:"))
    #expect(spec.contains("operationId: \"testOp\""))
}

@Test func testOpenAPISpecBuilderWithAPIKey() {
    var builder = OpenAPISpecBuilder(title: "API")
    builder.addAPIKeyAuth(name: "api_key", header: "x-api-key")

    let spec = builder.build()
    #expect(spec.contains("securityDefinitions:"))
    #expect(spec.contains("api_key:"))
    #expect(spec.contains("type: \"apiKey\""))
}

@Test func testOpenAPISpecBuilderWithJWT() {
    var builder = OpenAPISpecBuilder(title: "API")
    builder.addJWTAuth(
        name: "jwt",
        issuer: "https://issuer.example.com",
        jwksURI: "https://issuer.example.com/.well-known/jwks.json",
        audiences: ["my-app"]
    )

    let spec = builder.build()
    #expect(spec.contains("x-google-issuer:"))
    #expect(spec.contains("x-google-jwks_uri:"))
}

@Test func testOpenAPISpecBuilderWithFirebase() {
    var builder = OpenAPISpecBuilder(title: "API")
    builder.addFirebaseAuth(name: "firebase", projectID: "my-project")

    let spec = builder.build()
    #expect(spec.contains("securetoken.google.com/my-project"))
}

@Test func testOpenAPISpecBuilderWithParameters() {
    var builder = OpenAPISpecBuilder(title: "API")
    builder.addPath("/users/{id}", method: "GET", operation: OpenAPISpecBuilder.Operation(
        operationId: "getUser",
        parameters: [
            OpenAPISpecBuilder.Parameter(name: "id", in: .path, required: true, type: "string")
        ],
        backendAddress: "https://backend.example.com/users/{id}"
    ))

    let spec = builder.build()
    #expect(spec.contains("parameters:"))
    #expect(spec.contains("name: \"id\""))
    #expect(spec.contains("in: \"path\""))
}

@Test func testAPIGatewayOperationsListAPIs() {
    let cmd = APIGatewayOperations.listAPIsCommand(projectID: "my-project")
    #expect(cmd == "gcloud api-gateway apis list --project=my-project")
}

@Test func testAPIGatewayOperationsListConfigs() {
    let cmd = APIGatewayOperations.listConfigsCommand(apiName: "my-api", projectID: "my-project")
    #expect(cmd == "gcloud api-gateway api-configs list --api=my-api --project=my-project")
}

@Test func testAPIGatewayOperationsListGateways() {
    let cmd = APIGatewayOperations.listGatewaysCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("gcloud api-gateway gateways list"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testAPIGatewayOperationsEnableAPIs() {
    let cmd = APIGatewayOperations.enableAPIsCommand
    #expect(cmd.contains("apigateway.googleapis.com"))
    #expect(cmd.contains("servicemanagement.googleapis.com"))
}

@Test func testDAISAPIGatewayTemplateAPI() {
    let template = DAISAPIGatewayTemplate(
        projectID: "my-project",
        backendURL: "https://my-backend.run.app"
    )

    let api = template.api
    #expect(api.name == "dais-api")
    #expect(api.displayName == "DAIS API")
    #expect(api.labels?["app"] == "dais")
}

@Test func testDAISAPIGatewayTemplateConfig() {
    let template = DAISAPIGatewayTemplate(
        projectID: "my-project",
        serviceAccountEmail: "sa@my-project.iam.gserviceaccount.com",
        backendURL: "https://my-backend.run.app"
    )

    let config = template.config(version: "v2")
    #expect(config.name == "dais-api-config-v2")
    #expect(config.gatewayServiceAccount == "sa@my-project.iam.gserviceaccount.com")
}

@Test func testDAISAPIGatewayTemplateGateway() {
    let template = DAISAPIGatewayTemplate(
        projectID: "my-project",
        location: "us-west1",
        backendURL: "https://my-backend.run.app"
    )

    let gateway = template.gateway()
    #expect(gateway.name == "dais-api-gateway")
    #expect(gateway.location == "us-west1")
}

@Test func testDAISAPIGatewayTemplateOpenAPISpec() {
    let template = DAISAPIGatewayTemplate(
        projectID: "my-project",
        backendURL: "https://my-backend.run.app"
    )

    let spec = template.openAPISpec
    #expect(spec.contains("swagger: \"2.0\""))
    #expect(spec.contains("DAIS API"))
    #expect(spec.contains("/health"))
    #expect(spec.contains("/api/v1/nodes"))
    #expect(spec.contains("/api/v1/inference"))
}

@Test func testDAISAPIGatewayTemplateOpenAPISpecWithAPIKey() {
    let template = DAISAPIGatewayTemplate(
        projectID: "my-project",
        backendURL: "https://my-backend.run.app"
    )

    let spec = template.openAPISpecWithAPIKey
    #expect(spec.contains("x-api-key"))
    #expect(spec.contains("type: \"apiKey\""))
}

@Test func testDAISAPIGatewayTemplateSetupScript() {
    let template = DAISAPIGatewayTemplate(
        projectID: "my-project",
        location: "us-central1",
        backendURL: "https://my-backend.run.app"
    )

    let script = template.setupScript
    #expect(script.contains("gcloud services enable apigateway.googleapis.com"))
    #expect(script.contains("gcloud api-gateway apis create"))
    #expect(script.contains("gcloud api-gateway api-configs create"))
    #expect(script.contains("gcloud api-gateway gateways create"))
}

@Test func testDAISAPIGatewayTemplateTeardownScript() {
    let template = DAISAPIGatewayTemplate(
        projectID: "my-project",
        backendURL: "https://my-backend.run.app"
    )

    let script = template.teardownScript
    #expect(script.contains("gcloud api-gateway gateways delete"))
    #expect(script.contains("gcloud api-gateway api-configs delete"))
    #expect(script.contains("gcloud api-gateway apis delete"))
}

@Test func testAPIGatewayAPICodable() throws {
    let api = GoogleCloudAPIGatewayAPI(
        name: "test-api",
        projectID: "my-project",
        displayName: "Test",
        labels: ["env": "test"],
        state: .active
    )

    let data = try JSONEncoder().encode(api)
    let decoded = try JSONDecoder().decode(GoogleCloudAPIGatewayAPI.self, from: data)

    #expect(decoded.name == "test-api")
    #expect(decoded.state == .active)
}

@Test func testAPIGatewayConfigCodable() throws {
    let config = GoogleCloudAPIGatewayConfig(
        name: "test-config",
        apiName: "test-api",
        projectID: "my-project",
        state: .active
    )

    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(GoogleCloudAPIGatewayConfig.self, from: data)

    #expect(decoded.name == "test-config")
    #expect(decoded.state == .active)
}

@Test func testAPIGatewayGatewayCodable() throws {
    let gateway = GoogleCloudAPIGatewayGateway(
        name: "test-gateway",
        projectID: "my-project",
        location: "us-central1",
        apiConfig: "config",
        state: .active
    )

    let data = try JSONEncoder().encode(gateway)
    let decoded = try JSONDecoder().decode(GoogleCloudAPIGatewayGateway.self, from: data)

    #expect(decoded.name == "test-gateway")
    #expect(decoded.state == .active)
}

// MARK: - Cloud DLP Tests

@Test func testDLPInfoTypeBasicInit() {
    let infoType = GoogleCloudDLPInfoType(name: "CUSTOM_TYPE")
    #expect(infoType.name == "CUSTOM_TYPE")
}

@Test func testDLPInfoTypeBuiltIn() {
    #expect(GoogleCloudDLPInfoType.creditCardNumber.name == "CREDIT_CARD_NUMBER")
    #expect(GoogleCloudDLPInfoType.emailAddress.name == "EMAIL_ADDRESS")
    #expect(GoogleCloudDLPInfoType.phoneNumber.name == "PHONE_NUMBER")
    #expect(GoogleCloudDLPInfoType.usSSN.name == "US_SOCIAL_SECURITY_NUMBER")
    #expect(GoogleCloudDLPInfoType.ipAddress.name == "IP_ADDRESS")
}

@Test func testDLPInfoTypeAllPII() {
    let pii = GoogleCloudDLPInfoType.allPII
    #expect(pii.count > 5)
    #expect(pii.contains(where: { $0.name == "CREDIT_CARD_NUMBER" }))
    #expect(pii.contains(where: { $0.name == "EMAIL_ADDRESS" }))
}

@Test func testDLPInfoTypeFinancial() {
    let financial = GoogleCloudDLPInfoType.financial
    #expect(financial.contains(where: { $0.name == "CREDIT_CARD_NUMBER" }))
    #expect(financial.contains(where: { $0.name == "IBAN_CODE" }))
}

@Test func testDLPInfoTypeHealthcare() {
    let healthcare = GoogleCloudDLPInfoType.healthcare
    #expect(healthcare.contains(where: { $0.name == "MEDICAL_RECORD_NUMBER" }))
}

@Test func testDLPInspectConfigBasic() {
    let config = GoogleCloudDLPInspectConfig(
        infoTypes: [.emailAddress, .phoneNumber],
        minLikelihood: .likely,
        includeQuote: true
    )

    #expect(config.infoTypes?.count == 2)
    #expect(config.minLikelihood == .likely)
    #expect(config.includeQuote == true)
}

@Test func testDLPInspectConfigLikelihoodValues() {
    #expect(GoogleCloudDLPInspectConfig.Likelihood.veryUnlikely.rawValue == "VERY_UNLIKELY")
    #expect(GoogleCloudDLPInspectConfig.Likelihood.likely.rawValue == "LIKELY")
    #expect(GoogleCloudDLPInspectConfig.Likelihood.veryLikely.rawValue == "VERY_LIKELY")
}

@Test func testDLPInspectConfigFindingLimits() {
    let limits = GoogleCloudDLPInspectConfig.FindingLimits(
        maxFindingsPerItem: 50,
        maxFindingsPerRequest: 500
    )

    #expect(limits.maxFindingsPerItem == 50)
    #expect(limits.maxFindingsPerRequest == 500)
}

@Test func testDLPDeidentifyConfigRedact() {
    let config = GoogleCloudDLPDeidentifyConfig(
        infoTypeTransformations: GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations(
            transformations: [
                GoogleCloudDLPDeidentifyConfig.InfoTypeTransformations.InfoTypeTransformation(
                    primitiveTransformation: .redact
                )
            ]
        )
    )

    #expect(config.infoTypeTransformations?.transformations.count == 1)
}

@Test func testPrimitiveTransformationRedact() {
    let transform = PrimitiveTransformation.redact
    #expect(transform.redactConfig != nil)
}

@Test func testPrimitiveTransformationReplace() {
    let transform = PrimitiveTransformation.replace(with: "[REDACTED]")
    #expect(transform.replaceConfig?.newValue.stringValue == "[REDACTED]")
}

@Test func testPrimitiveTransformationMask() {
    let transform = PrimitiveTransformation.mask(character: "#", numberToMask: 4)
    #expect(transform.characterMaskConfig?.maskingCharacter == "#")
    #expect(transform.characterMaskConfig?.numberToMask == 4)
}

@Test func testPrimitiveTransformationReplaceWithInfoType() {
    let transform = PrimitiveTransformation.replaceWithInfoType
    #expect(transform.replaceWithInfoTypeConfig != nil)
}

@Test func testDLPInspectTemplateBasicInit() {
    let template = GoogleCloudDLPInspectTemplate(
        name: "my-template",
        projectID: "my-project",
        location: "us-central1",
        displayName: "My Template",
        inspectConfig: GoogleCloudDLPInspectConfig(infoTypes: [.emailAddress])
    )

    #expect(template.name == "my-template")
    #expect(template.location == "us-central1")
}

@Test func testDLPInspectTemplateResourceName() {
    let template = GoogleCloudDLPInspectTemplate(
        name: "my-template",
        projectID: "my-project",
        location: "global",
        inspectConfig: GoogleCloudDLPInspectConfig()
    )

    #expect(template.resourceName == "projects/my-project/locations/global/inspectTemplates/my-template")
}

@Test func testDLPInspectTemplateCreateCommand() {
    let template = GoogleCloudDLPInspectTemplate(
        name: "my-template",
        projectID: "my-project",
        displayName: "My Template",
        inspectConfig: GoogleCloudDLPInspectConfig()
    )

    let cmd = template.createCommand
    #expect(cmd.contains("gcloud dlp inspect-templates create my-template"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--display-name='My Template'"))
}

@Test func testDLPDeidentifyTemplateBasicInit() {
    let template = GoogleCloudDLPDeidentifyTemplate(
        name: "my-deidentify-template",
        projectID: "my-project",
        displayName: "My Deidentify Template",
        deidentifyConfig: GoogleCloudDLPDeidentifyConfig()
    )

    #expect(template.name == "my-deidentify-template")
}

@Test func testDLPDeidentifyTemplateResourceName() {
    let template = GoogleCloudDLPDeidentifyTemplate(
        name: "my-template",
        projectID: "my-project",
        location: "us-east1",
        deidentifyConfig: GoogleCloudDLPDeidentifyConfig()
    )

    #expect(template.resourceName == "projects/my-project/locations/us-east1/deidentifyTemplates/my-template")
}

@Test func testDLPJobTriggerBasicInit() {
    let trigger = GoogleCloudDLPJobTrigger(
        name: "my-trigger",
        projectID: "my-project",
        displayName: "My Trigger"
    )

    #expect(trigger.name == "my-trigger")
    #expect(trigger.displayName == "My Trigger")
}

@Test func testDLPJobTriggerResourceName() {
    let trigger = GoogleCloudDLPJobTrigger(
        name: "my-trigger",
        projectID: "my-project",
        location: "global"
    )

    #expect(trigger.resourceName == "projects/my-project/locations/global/jobTriggers/my-trigger")
}

@Test func testDLPJobTriggerSchedule() {
    let hourly = GoogleCloudDLPJobTrigger.Trigger.Schedule.hours(1)
    #expect(hourly.recurrencePeriodDuration == "3600s")

    let daily = GoogleCloudDLPJobTrigger.Trigger.Schedule.days(1)
    #expect(daily.recurrencePeriodDuration == "86400s")
}

@Test func testDLPJobTriggerStatusValues() {
    #expect(GoogleCloudDLPJobTrigger.Status.healthy.rawValue == "HEALTHY")
    #expect(GoogleCloudDLPJobTrigger.Status.paused.rawValue == "PAUSED")
}

@Test func testDLPJobTriggerCommands() {
    let trigger = GoogleCloudDLPJobTrigger(
        name: "my-trigger",
        projectID: "my-project",
        location: "global"
    )

    #expect(trigger.describeCommand.contains("gcloud dlp job-triggers describe"))
    #expect(trigger.deleteCommand.contains("gcloud dlp job-triggers delete"))
    #expect(trigger.activateCommand.contains("gcloud dlp job-triggers activate"))
    #expect(trigger.pauseCommand.contains("gcloud dlp job-triggers pause"))
}

@Test func testDLPOperationsInspectContent() {
    let cmd = DLPOperations.inspectContentCommand(
        projectID: "my-project",
        content: "test",
        infoTypes: [.emailAddress, .phoneNumber]
    )

    #expect(cmd.contains("gcloud dlp text inspect"))
    #expect(cmd.contains("--info-types=EMAIL_ADDRESS,PHONE_NUMBER"))
}

@Test func testDLPOperationsInspectFile() {
    let cmd = DLPOperations.inspectFileCommand(
        projectID: "my-project",
        file: "data.txt",
        infoTypes: [.creditCardNumber]
    )

    #expect(cmd.contains("--content-file=data.txt"))
    #expect(cmd.contains("CREDIT_CARD_NUMBER"))
}

@Test func testDLPOperationsListCommands() {
    #expect(DLPOperations.listInspectTemplatesCommand(projectID: "my-project")
        .contains("gcloud dlp inspect-templates list"))

    #expect(DLPOperations.listDeidentifyTemplatesCommand(projectID: "my-project")
        .contains("gcloud dlp deidentify-templates list"))

    #expect(DLPOperations.listJobTriggersCommand(projectID: "my-project")
        .contains("gcloud dlp job-triggers list"))
}

@Test func testDLPOperationsEnableAPI() {
    #expect(DLPOperations.enableAPICommand == "gcloud services enable dlp.googleapis.com")
}

@Test func testDAISDLPTemplatePIIInspectConfig() {
    let template = DAISDLPTemplate(projectID: "my-project")
    let config = template.piiInspectConfig

    #expect(config.infoTypes?.isEmpty == false)
    #expect(config.minLikelihood == .likely)
}

@Test func testDAISDLPTemplateFinancialInspectConfig() {
    let template = DAISDLPTemplate(projectID: "my-project")
    let config = template.financialInspectConfig

    #expect(config.infoTypes?.contains(where: { $0.name == "CREDIT_CARD_NUMBER" }) == true)
}

@Test func testDAISDLPTemplateRedactionConfig() {
    let template = DAISDLPTemplate(projectID: "my-project")
    let config = template.redactionDeidentifyConfig

    #expect(config.infoTypeTransformations != nil)
}

@Test func testDAISDLPTemplateMaskingConfig() {
    let template = DAISDLPTemplate(projectID: "my-project")
    let config = template.maskingDeidentifyConfig

    #expect(config.infoTypeTransformations?.transformations.count ?? 0 > 0)
}

@Test func testDAISDLPTemplatePIIInspectTemplate() {
    let template = DAISDLPTemplate(projectID: "my-project")
    let inspectTemplate = template.piiInspectTemplate

    #expect(inspectTemplate.name == "dais-pii-inspect")
    #expect(inspectTemplate.displayName == "DAIS PII Inspection Template")
}

@Test func testDAISDLPTemplateRedactionDeidentifyTemplate() {
    let template = DAISDLPTemplate(projectID: "my-project")
    let deidentifyTemplate = template.redactionDeidentifyTemplate

    #expect(deidentifyTemplate.name == "dais-redaction-deidentify")
}

@Test func testDAISDLPTemplateSetupScript() {
    let template = DAISDLPTemplate(projectID: "my-project")
    let script = template.setupScript

    #expect(script.contains("gcloud services enable dlp.googleapis.com"))
}

@Test func testDLPInfoTypeCodable() throws {
    let infoType = GoogleCloudDLPInfoType(
        name: "CUSTOM_TYPE",
        sensitivityScore: .sensitivityHigh
    )

    let data = try JSONEncoder().encode(infoType)
    let decoded = try JSONDecoder().decode(GoogleCloudDLPInfoType.self, from: data)

    #expect(decoded.name == "CUSTOM_TYPE")
    #expect(decoded.sensitivityScore == .sensitivityHigh)
}

@Test func testDLPInspectConfigCodable() throws {
    let config = GoogleCloudDLPInspectConfig(
        infoTypes: [.emailAddress],
        minLikelihood: .likely
    )

    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(GoogleCloudDLPInspectConfig.self, from: data)

    #expect(decoded.infoTypes?.first?.name == "EMAIL_ADDRESS")
    #expect(decoded.minLikelihood == .likely)
}

@Test func testDLPInspectTemplateCodable() throws {
    let template = GoogleCloudDLPInspectTemplate(
        name: "test-template",
        projectID: "my-project",
        displayName: "Test",
        inspectConfig: GoogleCloudDLPInspectConfig(infoTypes: [.creditCardNumber])
    )

    let data = try JSONEncoder().encode(template)
    let decoded = try JSONDecoder().decode(GoogleCloudDLPInspectTemplate.self, from: data)

    #expect(decoded.name == "test-template")
}

// MARK: - GKE Cluster Tests

@Test func testGKEClusterBasicInit() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(cluster.name == "my-cluster")
    #expect(cluster.projectID == "my-project")
    #expect(cluster.location == "us-central1")
}

@Test func testGKEClusterResourceName() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(cluster.resourceName == "projects/my-project/locations/us-central1/clusters/my-cluster")
}

@Test func testGKEClusterIsRegional() {
    let regional = GoogleCloudGKECluster(
        name: "regional-cluster",
        projectID: "my-project",
        location: "us-central1"
    )
    #expect(regional.isRegional == true)

    let zonal = GoogleCloudGKECluster(
        name: "zonal-cluster",
        projectID: "my-project",
        location: "us-central1-a"
    )
    #expect(zonal.isRegional == false)
}

@Test func testGKEClusterCreateCommandRegional() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        initialNodeCount: 3
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("gcloud container clusters create my-cluster"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--num-nodes=3"))
}

@Test func testGKEClusterCreateCommandZonal() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1-a",
        initialNodeCount: 3
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--zone=us-central1-a"))
    #expect(!cmd.contains("--region="))
}

@Test func testGKEClusterCreateCommandAutopilot() {
    let cluster = GoogleCloudGKECluster(
        name: "autopilot-cluster",
        projectID: "my-project",
        location: "us-central1",
        autopilot: GoogleCloudGKECluster.Autopilot(enabled: true)
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--enable-autopilot"))
    #expect(!cmd.contains("--num-nodes"))
}

@Test func testGKEClusterCreateCommandWithNodeConfig() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        initialNodeCount: 3,
        nodeConfig: GoogleCloudGKECluster.NodeConfig(
            machineType: "e2-standard-4",
            diskSizeGb: 100,
            diskType: .pdSsd,
            spot: true
        )
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--machine-type=e2-standard-4"))
    #expect(cmd.contains("--disk-size=100"))
    #expect(cmd.contains("--disk-type=pd-ssd"))
    #expect(cmd.contains("--spot"))
}

@Test func testGKEClusterCreateCommandWithPrivateCluster() {
    let cluster = GoogleCloudGKECluster(
        name: "private-cluster",
        projectID: "my-project",
        location: "us-central1",
        privateClusterConfig: GoogleCloudGKECluster.PrivateClusterConfig(
            enablePrivateNodes: true,
            enablePrivateEndpoint: false,
            masterIpv4CidrBlock: "172.16.0.0/28"
        )
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--enable-private-nodes"))
    #expect(!cmd.contains("--enable-private-endpoint"))
    #expect(cmd.contains("--master-ipv4-cidr=172.16.0.0/28"))
}

@Test func testGKEClusterCreateCommandWithReleaseChannel() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        releaseChannel: GoogleCloudGKECluster.ReleaseChannel(channel: .stable)
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--release-channel=stable"))
}

@Test func testGKEClusterCreateCommandWithWorkloadIdentity() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        workloadIdentityConfig: GoogleCloudGKECluster.WorkloadIdentityConfig(
            workloadPool: "my-project.svc.id.goog"
        )
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--workload-pool=my-project.svc.id.goog"))
}

@Test func testGKEClusterCreateCommandWithNetwork() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        networkConfig: GoogleCloudGKECluster.NetworkConfig(
            network: "my-vpc",
            subnetwork: "my-subnet"
        )
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--network=my-vpc"))
    #expect(cmd.contains("--subnetwork=my-subnet"))
}

@Test func testGKEClusterCreateCommandWithLabels() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        labels: ["env": "prod", "team": "ml"]
    )

    let cmd = cluster.createCommand
    #expect(cmd.contains("--labels="))
}

@Test func testGKEClusterDeleteCommand() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = cluster.deleteCommand
    #expect(cmd.contains("gcloud container clusters delete my-cluster"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--quiet"))
}

@Test func testGKEClusterDescribeCommand() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = cluster.describeCommand
    #expect(cmd.contains("gcloud container clusters describe my-cluster"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testGKEClusterGetCredentialsCommand() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = cluster.getCredentialsCommand
    #expect(cmd.contains("gcloud container clusters get-credentials my-cluster"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testGKEClusterResizeCommand() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = cluster.resizeCommand(nodeCount: 5, nodePool: "default-pool")
    #expect(cmd.contains("gcloud container clusters resize my-cluster"))
    #expect(cmd.contains("--node-pool=default-pool"))
    #expect(cmd.contains("--num-nodes=5"))
    #expect(cmd.contains("--quiet"))
}

@Test func testGKEClusterUpgradeCommandMaster() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = cluster.upgradeCommand(version: "1.28.3-gke.1200")
    #expect(cmd.contains("gcloud container clusters upgrade my-cluster"))
    #expect(cmd.contains("--cluster-version=1.28.3-gke.1200"))
    #expect(cmd.contains("--master"))
}

@Test func testGKEClusterUpgradeCommandNodePool() {
    let cluster = GoogleCloudGKECluster(
        name: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = cluster.upgradeCommand(version: "1.28.3-gke.1200", nodePool: "default-pool")
    #expect(cmd.contains("--node-pool=default-pool"))
    #expect(!cmd.contains("--master"))
}

// MARK: - GKE Node Config Tests

@Test func testGKENodeConfigDiskTypes() {
    #expect(GoogleCloudGKECluster.NodeConfig.DiskType.pdStandard.rawValue == "pd-standard")
    #expect(GoogleCloudGKECluster.NodeConfig.DiskType.pdSsd.rawValue == "pd-ssd")
    #expect(GoogleCloudGKECluster.NodeConfig.DiskType.pdBalanced.rawValue == "pd-balanced")
}

@Test func testGKENodeConfigTaint() {
    let taint = GoogleCloudGKECluster.NodeConfig.Taint(
        key: "dedicated",
        value: "gpu",
        effect: .noSchedule
    )

    #expect(taint.key == "dedicated")
    #expect(taint.value == "gpu")
    #expect(taint.effect == .noSchedule)
}

@Test func testGKENodeConfigTaintEffects() {
    #expect(GoogleCloudGKECluster.NodeConfig.Taint.TaintEffect.noSchedule.rawValue == "NO_SCHEDULE")
    #expect(GoogleCloudGKECluster.NodeConfig.Taint.TaintEffect.preferNoSchedule.rawValue == "PREFER_NO_SCHEDULE")
    #expect(GoogleCloudGKECluster.NodeConfig.Taint.TaintEffect.noExecute.rawValue == "NO_EXECUTE")
}

@Test func testGKENodeConfigAccelerator() {
    let accelerator = GoogleCloudGKECluster.NodeConfig.Accelerator(
        acceleratorCount: 2,
        acceleratorType: "nvidia-tesla-t4",
        gpuPartitionSize: "1g.5gb"
    )

    #expect(accelerator.acceleratorCount == 2)
    #expect(accelerator.acceleratorType == "nvidia-tesla-t4")
    #expect(accelerator.gpuPartitionSize == "1g.5gb")
}

// MARK: - GKE Network Config Tests

@Test func testGKENetworkConfigDatapathProvider() {
    #expect(GoogleCloudGKECluster.NetworkConfig.DatapathProvider.legacyDatapath.rawValue == "LEGACY_DATAPATH")
    #expect(GoogleCloudGKECluster.NetworkConfig.DatapathProvider.advancedDatapath.rawValue == "ADVANCED_DATAPATH")
}

// MARK: - GKE Release Channel Tests

@Test func testGKEReleaseChannels() {
    #expect(GoogleCloudGKECluster.ReleaseChannel.Channel.rapid.rawValue == "RAPID")
    #expect(GoogleCloudGKECluster.ReleaseChannel.Channel.regular.rawValue == "REGULAR")
    #expect(GoogleCloudGKECluster.ReleaseChannel.Channel.stable.rawValue == "STABLE")
}

// MARK: - GKE Cluster Status Tests

@Test func testGKEClusterStatusValues() {
    #expect(GoogleCloudGKECluster.ClusterStatus.provisioning.rawValue == "PROVISIONING")
    #expect(GoogleCloudGKECluster.ClusterStatus.running.rawValue == "RUNNING")
    #expect(GoogleCloudGKECluster.ClusterStatus.reconciling.rawValue == "RECONCILING")
    #expect(GoogleCloudGKECluster.ClusterStatus.stopping.rawValue == "STOPPING")
    #expect(GoogleCloudGKECluster.ClusterStatus.error.rawValue == "ERROR")
    #expect(GoogleCloudGKECluster.ClusterStatus.degraded.rawValue == "DEGRADED")
}

// MARK: - GKE Node Pool Tests

@Test func testGKENodePoolBasicInit() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        initialNodeCount: 3
    )

    #expect(nodePool.name == "my-pool")
    #expect(nodePool.clusterName == "my-cluster")
    #expect(nodePool.initialNodeCount == 3)
}

@Test func testGKENodePoolResourceName() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    #expect(nodePool.resourceName == "projects/my-project/locations/us-central1/clusters/my-cluster/nodePools/my-pool")
}

@Test func testGKENodePoolCreateCommand() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        initialNodeCount: 3
    )

    let cmd = nodePool.createCommand
    #expect(cmd.contains("gcloud container node-pools create my-pool"))
    #expect(cmd.contains("--cluster=my-cluster"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--region=us-central1"))
    #expect(cmd.contains("--num-nodes=3"))
}

@Test func testGKENodePoolCreateCommandWithConfig() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        config: GoogleCloudGKECluster.NodeConfig(
            machineType: "n2-standard-8",
            diskSizeGb: 200,
            diskType: .pdSsd,
            spot: true
        )
    )

    let cmd = nodePool.createCommand
    #expect(cmd.contains("--machine-type=n2-standard-8"))
    #expect(cmd.contains("--disk-size=200"))
    #expect(cmd.contains("--disk-type=pd-ssd"))
    #expect(cmd.contains("--spot"))
}

@Test func testGKENodePoolCreateCommandWithAutoscaling() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        autoscaling: GoogleCloudGKENodePool.Autoscaling(
            enabled: true,
            minNodeCount: 1,
            maxNodeCount: 10
        )
    )

    let cmd = nodePool.createCommand
    #expect(cmd.contains("--enable-autoscaling"))
    #expect(cmd.contains("--min-nodes=1"))
    #expect(cmd.contains("--max-nodes=10"))
}

@Test func testGKENodePoolCreateCommandWithManagement() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        management: GoogleCloudGKENodePool.NodeManagement(
            autoUpgrade: true,
            autoRepair: true
        )
    )

    let cmd = nodePool.createCommand
    #expect(cmd.contains("--enable-autoupgrade"))
    #expect(cmd.contains("--enable-autorepair"))
}

@Test func testGKENodePoolCreateCommandManagementDisabled() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        management: GoogleCloudGKENodePool.NodeManagement(
            autoUpgrade: false,
            autoRepair: false
        )
    )

    let cmd = nodePool.createCommand
    #expect(cmd.contains("--no-enable-autoupgrade"))
    #expect(cmd.contains("--no-enable-autorepair"))
}

@Test func testGKENodePoolDeleteCommand() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = nodePool.deleteCommand
    #expect(cmd.contains("gcloud container node-pools delete my-pool"))
    #expect(cmd.contains("--cluster=my-cluster"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--quiet"))
}

@Test func testGKENodePoolDescribeCommand() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = nodePool.describeCommand
    #expect(cmd.contains("gcloud container node-pools describe my-pool"))
    #expect(cmd.contains("--cluster=my-cluster"))
}

@Test func testGKENodePoolResizeCommand() {
    let nodePool = GoogleCloudGKENodePool(
        name: "my-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1"
    )

    let cmd = nodePool.resizeCommand(nodeCount: 5)
    #expect(cmd.contains("gcloud container clusters resize my-cluster"))
    #expect(cmd.contains("--node-pool=my-pool"))
    #expect(cmd.contains("--num-nodes=5"))
}

// MARK: - GKE Autoscaling Tests

@Test func testGKEAutoscalingLocationPolicy() {
    #expect(GoogleCloudGKENodePool.Autoscaling.LocationPolicy.balanced.rawValue == "BALANCED")
    #expect(GoogleCloudGKENodePool.Autoscaling.LocationPolicy.any.rawValue == "ANY")
}

// MARK: - GKE Upgrade Settings Tests

@Test func testGKEUpgradeSettingsStrategy() {
    #expect(GoogleCloudGKENodePool.UpgradeSettings.Strategy.blueGreen.rawValue == "BLUE_GREEN")
    #expect(GoogleCloudGKENodePool.UpgradeSettings.Strategy.surge.rawValue == "SURGE")
}

// MARK: - GKE Node Pool Status Tests

@Test func testGKENodePoolStatusValues() {
    #expect(GoogleCloudGKENodePool.NodePoolStatus.provisioning.rawValue == "PROVISIONING")
    #expect(GoogleCloudGKENodePool.NodePoolStatus.running.rawValue == "RUNNING")
    #expect(GoogleCloudGKENodePool.NodePoolStatus.runningWithError.rawValue == "RUNNING_WITH_ERROR")
    #expect(GoogleCloudGKENodePool.NodePoolStatus.reconciling.rawValue == "RECONCILING")
    #expect(GoogleCloudGKENodePool.NodePoolStatus.stopping.rawValue == "STOPPING")
    #expect(GoogleCloudGKENodePool.NodePoolStatus.error.rawValue == "ERROR")
}

// MARK: - GKE Operations Tests

@Test func testGKEOperationsListClusters() {
    let cmd = GKEOperations.listClustersCommand(projectID: "my-project")
    #expect(cmd.contains("gcloud container clusters list"))
    #expect(cmd.contains("--project=my-project"))
}

@Test func testGKEOperationsListClustersWithRegion() {
    let cmd = GKEOperations.listClustersCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("--region=us-central1"))
}

@Test func testGKEOperationsListNodePools() {
    let cmd = GKEOperations.listNodePoolsCommand(cluster: "my-cluster", projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("gcloud container node-pools list"))
    #expect(cmd.contains("--cluster=my-cluster"))
    #expect(cmd.contains("--project=my-project"))
}

@Test func testGKEOperationsGetServerConfig() {
    let cmd = GKEOperations.getServerConfigCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("gcloud container get-server-config"))
    #expect(cmd.contains("--project=my-project"))
}

@Test func testGKEOperationsEnableAPI() {
    #expect(GKEOperations.enableAPICommand == "gcloud services enable container.googleapis.com")
}

@Test func testGKEOperationsListOperations() {
    let cmd = GKEOperations.listOperationsCommand(projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("gcloud container operations list"))
    #expect(cmd.contains("--project=my-project"))
    #expect(cmd.contains("--location=us-central1"))
}

@Test func testGKEOperationsGetKubeconfig() {
    let cmd = GKEOperations.getKubeconfigCommand(cluster: "my-cluster", projectID: "my-project", location: "us-central1")
    #expect(cmd.contains("gcloud container clusters get-credentials my-cluster"))
    #expect(cmd.contains("--project=my-project"))
}

// MARK: - DAIS GKE Template Tests

@Test func testDAISGKETemplateBasicInit() {
    let template = DAISGKETemplate(
        projectID: "my-project",
        location: "us-central1",
        clusterName: "dais-cluster"
    )

    #expect(template.projectID == "my-project")
    #expect(template.location == "us-central1")
    #expect(template.clusterName == "dais-cluster")
}

@Test func testDAISGKETemplateStandardCluster() {
    let template = DAISGKETemplate(projectID: "my-project")
    let cluster = template.standardCluster

    #expect(cluster.name == "dais-cluster")
    #expect(cluster.initialNodeCount == 3)
    #expect(cluster.nodeConfig?.machineType == "e2-standard-4")
    #expect(cluster.releaseChannel?.channel == .regular)
    #expect(cluster.workloadIdentityConfig?.workloadPool == "my-project.svc.id.goog")
}

@Test func testDAISGKETemplateAutopilotCluster() {
    let template = DAISGKETemplate(projectID: "my-project")
    let cluster = template.autopilotCluster

    #expect(cluster.name == "dais-cluster-autopilot")
    #expect(cluster.autopilot?.enabled == true)
}

@Test func testDAISGKETemplatePrivateCluster() {
    let template = DAISGKETemplate(projectID: "my-project")
    let cluster = template.privateCluster

    #expect(cluster.name == "dais-cluster-private")
    #expect(cluster.privateClusterConfig?.enablePrivateNodes == true)
    #expect(cluster.privateClusterConfig?.masterIpv4CidrBlock == "172.16.0.0/28")
}

@Test func testDAISGKETemplateGPUNodePool() {
    let template = DAISGKETemplate(projectID: "my-project")
    let nodePool = template.gpuNodePool

    #expect(nodePool.name == "gpu-pool")
    #expect(nodePool.config?.accelerators?.first?.acceleratorType == "nvidia-tesla-t4")
    #expect(nodePool.autoscaling?.enabled == true)
    #expect(nodePool.autoscaling?.minNodeCount == 0)
    #expect(nodePool.autoscaling?.maxNodeCount == 5)
}

@Test func testDAISGKETemplateSpotNodePool() {
    let template = DAISGKETemplate(projectID: "my-project")
    let nodePool = template.spotNodePool

    #expect(nodePool.name == "spot-pool")
    #expect(nodePool.config?.spot == true)
    #expect(nodePool.initialNodeCount == 0)
}

@Test func testDAISGKETemplateSetupScript() {
    let template = DAISGKETemplate(projectID: "my-project")
    let script = template.setupScript

    #expect(script.contains("gcloud services enable container.googleapis.com"))
    #expect(script.contains("gcloud container clusters create"))
    #expect(script.contains("gcloud container clusters get-credentials"))
}

@Test func testDAISGKETemplateTeardownScript() {
    let template = DAISGKETemplate(projectID: "my-project")
    let script = template.teardownScript

    #expect(script.contains("gcloud container clusters delete"))
}

// MARK: - GKE Codable Tests

@Test func testGKEClusterCodable() throws {
    let cluster = GoogleCloudGKECluster(
        name: "test-cluster",
        projectID: "my-project",
        location: "us-central1",
        initialNodeCount: 3
    )

    let data = try JSONEncoder().encode(cluster)
    let decoded = try JSONDecoder().decode(GoogleCloudGKECluster.self, from: data)

    #expect(decoded.name == "test-cluster")
    #expect(decoded.initialNodeCount == 3)
}

@Test func testGKENodePoolCodable() throws {
    let nodePool = GoogleCloudGKENodePool(
        name: "test-pool",
        clusterName: "my-cluster",
        projectID: "my-project",
        location: "us-central1",
        autoscaling: GoogleCloudGKENodePool.Autoscaling(
            enabled: true,
            minNodeCount: 1,
            maxNodeCount: 5
        )
    )

    let data = try JSONEncoder().encode(nodePool)
    let decoded = try JSONDecoder().decode(GoogleCloudGKENodePool.self, from: data)

    #expect(decoded.name == "test-pool")
    #expect(decoded.autoscaling?.enabled == true)
}

@Test func testGKENodeConfigCodable() throws {
    let config = GoogleCloudGKECluster.NodeConfig(
        machineType: "e2-standard-4",
        diskSizeGb: 100,
        diskType: .pdSsd,
        spot: true
    )

    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(GoogleCloudGKECluster.NodeConfig.self, from: data)

    #expect(decoded.machineType == "e2-standard-4")
    #expect(decoded.diskType == .pdSsd)
    #expect(decoded.spot == true)
}
