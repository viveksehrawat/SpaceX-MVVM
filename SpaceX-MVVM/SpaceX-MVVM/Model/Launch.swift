//
//  Launch.swift
//  SpaceX-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import Foundation

struct Launch: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case mission_name,launch_year,rocket,links
        case launchSite = "launch_site"
    }
    let id = UUID()
    let mission_name: String
    let launch_year: String
    let rocket: Rocket
    let links: Links?
    var launchSite: LaunchSite?
}

struct Links: Codable {
    enum CodingKeys: String, CodingKey {
        case mission_patch
    }
    let mission_patch: String?
}


struct Rocket: Codable, Identifiable {
    enum CodingKeys: String, CodingKey {
        case id = "rocket_id"
        case name = "rocket_name"
        case type = "rocket_type"
    }
    let id: String
    let name: String
    let type: String
}

struct LaunchSite: Codable {
    let siteID, siteName : String?

    enum CodingKeys: String, CodingKey {
        case siteID = "site_id"
        case siteName = "site_name_long"
    }
}
