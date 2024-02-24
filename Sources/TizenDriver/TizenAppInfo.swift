//
//  TizenAppInfo.swift
//
//
//  Created by Jan Verrept on 28/02/2020.
//

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
