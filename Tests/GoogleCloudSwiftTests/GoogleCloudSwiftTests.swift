import Testing
@testable import GoogleCloudSwift

@Test func testGoogleCloudProvider() {
    let provider = GoogleCloudProvider(
        projectID: "test-project",
        region: .usWest1
    )

    #expect(provider.projectID == "test-project")
    #expect(provider.region == .usWest1)
    #expect(provider.zone == nil)
}

@Test func testGoogleCloudRegion() {
    let region = GoogleCloudRegion.usWest1

    #expect(region.rawValue == "us-west1")
    #expect(region.displayName == "Oregon, USA")
    #expect(region.defaultZone == "us-west1-a")
}

@Test func testGoogleCloudMachineType() {
    let machineType = GoogleCloudMachineType.e2Micro

    #expect(machineType.isFreeTierEligible)
    #expect(machineType.approximateMonthlyCostUSD == 0)
}

@Test func testGoogleCloudSecret() {
    let secret = GoogleCloudSecret(
        name: "test-secret",
        projectID: "test-project"
    )

    #expect(secret.resourceName == "projects/test-project/secrets/test-secret")
    #expect(secret.version == "latest")
}
