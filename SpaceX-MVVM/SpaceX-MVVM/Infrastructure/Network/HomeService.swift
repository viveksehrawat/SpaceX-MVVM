//
//  SpaceXService.swift
//  SpaceX-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import Foundation

enum HomeService {
    case allLaunches
    case uploadData(Data)
}

extension HomeService: Service {
    var headers: [String : Any]? {
        [:]
    }
    
    var baseURL: String {
        return "https://api.spacexdata.com"
    }

    var path: String {
        switch self {
        case .allLaunches:
            return "/v2/launches"
        case .uploadData:
            return "/v2/launches"
        }
    }

    var parameters: [String: Any]? {

        let params: [String: Any] = [:]

        switch self {
        case .allLaunches:
            break
        case .uploadData:
            break
        }
        return params
    }

    var method: ServiceMethod {
        switch(self) {
        case .allLaunches:
            return .get
        case .uploadData:
            return .post
        }
    }
    var body: Data? {
        switch(self) {
        case .allLaunches:
            return nil
        case .uploadData(let data):
            return data
        }
    }
}
