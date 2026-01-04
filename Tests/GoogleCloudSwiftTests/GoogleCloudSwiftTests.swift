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
