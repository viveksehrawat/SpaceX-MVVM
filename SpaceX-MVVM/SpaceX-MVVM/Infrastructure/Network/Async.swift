//
//  SpaceXAsyncService.swift
//  SpaceX-Async-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import Foundation

enum AsyncServiceMethod: String {
    case get = "GET"
    case post = "POST"
}

enum AsyncNetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

enum AsyncEnvironment {
    case production
    case uat
    
    var baseURL: String {
        switch self {
        case .production:
            return "https://api.example.com"
        case .uat:
            return "https://uat-api.example.com"
        }
    }
}

protocol AsyncService {
    var environment: AsyncEnvironment { get }
    var headers: [String: String] { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    var method: AsyncServiceMethod { get }
    var body: Data? { get }
    var baseURL: String { get }
}

extension AsyncService {
    var url: URL? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        urlComponents.path = urlComponents.path + path
        guard let parameters = parameters as? [String: String] else {
            fatalError("parameters for GET http method must conform to [String: String]")
        }
        if parameters.count > 0 {
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return urlComponents.url
    }
}

extension AsyncService {
    var urlRequest: URLRequest {
        guard let url = url else {
            fatalError("URL could not be built")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if !headers.isEmpty {
            request.allHTTPHeaderFields = headers
        }
        
        if method == .post {
            request.httpBody = body
        }
        
        return request
    }
}

extension AsyncService {
    
    var parameters: [String: Any] {
        return [:]
    }
    var headers: [String: Any] {
        return [:]
    }
}

enum AsyncResult<T> {
    case success(T)
    case failure(AsyncNetworkError)
    case empty
}

class AsyncServiceProvider<T: AsyncService> {
    var urlSession: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        self.urlSession = session
    }
    
    func load<U>(service: T, decodeType: U.Type) async throws -> U where U: Decodable {
        let request = service.urlRequest
        do {
            let (data, _) = try await urlSession.data(for: request)
            let decoder = JSONDecoder()
            return try decoder.decode(decodeType, from: data)
        } catch {
            throw AsyncNetworkError.requestFailed(error)
        }
    }
}

//
//  SpaceXAsyncService.swift
//  SpaceX-Async-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import Foundation

enum HomeAsyncService {
    case allLaunches
    case uploadData(Data)
}

extension HomeAsyncService: AsyncService {
    
    var environment: AsyncEnvironment {
        return .production
    }
    
    var headers: [String : String] {
        [:]
    }
    
    var baseURL: String {
        return environment.baseURL
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

    var method: AsyncServiceMethod {
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


import Foundation
import Combine

class HomeAsyncViewModel: ObservableObject {
    
    @Published private var launchesList = [Launch]()
    @Published var searchText = ""
    
    var filteredLaunches: [Launch] {
        return searchText == "" ? launchesList : launchesList.filter { $0.mission_name.contains(searchText.lowercased()) }
    }

    let provider = AsyncServiceProvider<HomeAsyncService>()
    
    func getAllLaunches() async {
        do {
            let launches = try await provider.load(service: .allLaunches, decodeType: [Launch].self)
            launchesList = launches
            print("Mission --> \(launches[0].mission_name)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
