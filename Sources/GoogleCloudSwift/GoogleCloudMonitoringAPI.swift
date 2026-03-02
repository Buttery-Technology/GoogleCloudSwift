//
//  GoogleCloudMonitoringAPI.swift
//  GoogleCloudSwift
//
//  Created by Jonathan Holland on 3/2/26.
//

import AsyncHTTPClient
import Foundation
import NIOCore

/// REST API client for Google Cloud Monitoring.
///
/// Provides methods for reading time series data and metric descriptors
/// via the Cloud Monitoring API v3.
///
/// ## Example Usage
/// ```swift
/// let monitoringAPI = await GoogleCloudMonitoringAPI.create(
///     authClient: authClient,
///     httpClient: httpClient
/// )
///
/// // Query CPU utilization for a VM
/// let response = try await monitoringAPI.listTimeSeries(
///     filter: "metric.type=\"compute.googleapis.com/instance/cpu/utilization\"",
///     intervalStartTime: "2026-03-01T00:00:00Z",
///     intervalEndTime: "2026-03-02T00:00:00Z"
/// )
/// ```
public actor GoogleCloudMonitoringAPI {
	private let client: GoogleCloudHTTPClient
	private let _projectId: String

	/// The Google Cloud project ID this client operates on.
	public var projectId: String { _projectId }

	private static let baseURL = "https://monitoring.googleapis.com"

	/// Initialize the Cloud Monitoring API client.
	/// - Parameters:
	///   - authClient: The authentication client for obtaining access tokens.
	///   - httpClient: The underlying HTTP client.
	///   - projectId: The Google Cloud project ID.
	///   - retryConfiguration: Configuration for retry behavior on transient failures.
	///   - requestTimeout: Timeout for individual HTTP requests in seconds.
	public init(
		authClient: GoogleCloudAuthClient,
		httpClient: HTTPClient,
		projectId: String,
		retryConfiguration: RetryConfiguration = .default,
		requestTimeout: TimeInterval = 60
	) {
		self._projectId = projectId
		self.client = GoogleCloudHTTPClient(
			authClient: authClient,
			httpClient: httpClient,
			baseURL: Self.baseURL,
			retryConfiguration: retryConfiguration,
			requestTimeout: requestTimeout
		)
	}

	/// Create a Cloud Monitoring API client, inferring project ID from auth credentials.
	/// - Parameters:
	///   - authClient: The authentication client for obtaining access tokens.
	///   - httpClient: The underlying HTTP client.
	///   - retryConfiguration: Configuration for retry behavior on transient failures.
	///   - requestTimeout: Timeout for individual HTTP requests in seconds.
	/// - Returns: A configured Cloud Monitoring API client.
	public static func create(
		authClient: GoogleCloudAuthClient,
		httpClient: HTTPClient,
		retryConfiguration: RetryConfiguration = .default,
		requestTimeout: TimeInterval = 60
	) async -> GoogleCloudMonitoringAPI {
		let projectId = await authClient.projectId
		return GoogleCloudMonitoringAPI(
			authClient: authClient,
			httpClient: httpClient,
			projectId: projectId,
			retryConfiguration: retryConfiguration,
			requestTimeout: requestTimeout
		)
	}

	// MARK: - Time Series

	/// List time series data matching the given filter.
	/// - Parameters:
	///   - filter: A Monitoring filter specifying which time series to return.
	///   - intervalStartTime: Start of the time interval (RFC 3339 / ISO 8601).
	///   - intervalEndTime: End of the time interval (RFC 3339 / ISO 8601).
	///   - aggregationAlignmentPeriod: The alignment period for per-series alignment (e.g. "60s", "300s").
	///   - aggregationPerSeriesAligner: The approach to be used to align individual time series (e.g. "ALIGN_MEAN").
	///   - pageSize: Maximum number of results to return per page.
	///   - pageToken: Token for fetching the next page of results.
	/// - Returns: A list of time series matching the filter.
	public func listTimeSeries(
		filter: String,
		intervalStartTime: String,
		intervalEndTime: String,
		aggregationAlignmentPeriod: String? = nil,
		aggregationPerSeriesAligner: String? = nil,
		pageSize: Int? = nil,
		pageToken: String? = nil
	) async throws -> MonitoringTimeSeriesListResponse {
		var queryParams: [(String, String)] = [
			("filter", filter),
			("interval.startTime", intervalStartTime),
			("interval.endTime", intervalEndTime),
		]

		if let period = aggregationAlignmentPeriod {
			queryParams.append(("aggregation.alignmentPeriod", period))
		}
		if let aligner = aggregationPerSeriesAligner {
			queryParams.append(("aggregation.perSeriesAligner", aligner))
		}
		if let pageSize {
			queryParams.append(("pageSize", String(pageSize)))
		}
		if let pageToken {
			queryParams.append(("pageToken", pageToken))
		}

		let response: GoogleCloudAPIResponse<MonitoringTimeSeriesListResponse> = try await client.get(
			path: "/v3/projects/\(_projectId)/timeSeries",
			queryParameters: queryParams
		)
		return response.data
	}

	/// Get a specific metric descriptor.
	/// - Parameter metricType: The metric type (e.g. "compute.googleapis.com/instance/cpu/utilization").
	/// - Returns: The metric descriptor.
	public func getMetricDescriptor(metricType: String) async throws -> MonitoringMetricDescriptor {
		let response: GoogleCloudAPIResponse<MonitoringMetricDescriptor> = try await client.get(
			path: "/v3/projects/\(_projectId)/metricDescriptors/\(metricType)"
		)
		return response.data
	}

	/// List metric descriptors matching an optional filter.
	/// - Parameters:
	///   - filter: An optional filter to narrow results (e.g. `metric.type = starts_with("compute")`).
	///   - pageSize: Maximum number of results to return per page.
	///   - pageToken: Token for fetching the next page of results.
	/// - Returns: A list of metric descriptors.
	public func listMetricDescriptors(
		filter: String? = nil,
		pageSize: Int? = nil,
		pageToken: String? = nil
	) async throws -> MonitoringMetricDescriptorListResponse {
		var queryParams: [(String, String)] = []

		if let filter {
			queryParams.append(("filter", filter))
		}
		if let pageSize {
			queryParams.append(("pageSize", String(pageSize)))
		}
		if let pageToken {
			queryParams.append(("pageToken", pageToken))
		}

		let response: GoogleCloudAPIResponse<MonitoringMetricDescriptorListResponse> = try await client.get(
			path: "/v3/projects/\(_projectId)/metricDescriptors",
			queryParameters: queryParams
		)
		return response.data
	}
}

// MARK: - Response Models

/// Response for listing time series data.
public struct MonitoringTimeSeriesListResponse: Codable, Sendable {
	public let timeSeries: [MonitoringTimeSeries]?
	public let nextPageToken: String?
}

/// A single time series with metric data points.
public struct MonitoringTimeSeries: Codable, Sendable {
	public let metric: MonitoringMetric?
	public let resource: MonitoringMonitoredResource?
	public let metricKind: String?
	public let valueType: String?
	public let points: [MonitoringPoint]?
}

/// A single data point in a time series.
public struct MonitoringPoint: Codable, Sendable {
	public let interval: MonitoringTimeInterval?
	public let value: MonitoringTypedValue?
}

/// A typed value from the Monitoring API (only one field is set).
public struct MonitoringTypedValue: Codable, Sendable {
	public let doubleValue: Double?
	public let int64Value: String?
	public let stringValue: String?
	public let boolValue: Bool?
}

/// A time interval with start and end times.
public struct MonitoringTimeInterval: Codable, Sendable {
	public let startTime: String?
	public let endTime: String?
}

/// Metric identifier with type and labels.
public struct MonitoringMetric: Codable, Sendable {
	public let type: String?
	public let labels: [String: String]?
}

/// Monitored resource with type and labels.
public struct MonitoringMonitoredResource: Codable, Sendable {
	public let type: String?
	public let labels: [String: String]?
}

/// A metric descriptor describing a metric type.
public struct MonitoringMetricDescriptor: Codable, Sendable {
	public let name: String?
	public let type: String?
	public let labels: [MonitoringLabelDescriptor]?
	public let metricKind: String?
	public let valueType: String?
	public let unit: String?
	public let description: String?
	public let displayName: String?
}

/// A label descriptor for a metric.
public struct MonitoringLabelDescriptor: Codable, Sendable {
	public let key: String?
	public let valueType: String?
	public let description: String?
}

/// Response for listing metric descriptors.
public struct MonitoringMetricDescriptorListResponse: Codable, Sendable {
	public let metricDescriptors: [MonitoringMetricDescriptor]?
	public let nextPageToken: String?
}
