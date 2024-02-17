// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let AppsRootData = try? JSONDecoder().decode(AppsRootData.self, from: jsonData)

import Foundation

// MARK: - AppsRootData
struct AppsRootData: Decodable {
	let data: DataContainer
	let event: String
	let from: String

	enum CodingKeys: String, CodingKey {
		case data
		case event
		case from
	}
}

// MARK: - DataContainer
struct DataContainer: Decodable{
	let data: [AppInfo]

	enum CodingKeys: String, CodingKey {
		case data = "data"
	}
}

extension TizenDriver.App:Decodable{}

enum AppType:Int, Decodable{
	case DEEP_LINK = 2
	case NATIVE_LAUNCH = 4
}

// MARK: - AppInfo
struct AppInfo: Decodable {
	
	let name: String
	let id: TizenDriver.App
	let type: AppType
	let icon: String
	let isLock: Int

	enum CodingKeys: String, CodingKey {
		case name
		case id = "appId"
		case type = "app_type"
		case icon
		case isLock = "is_lock"
	}
}
