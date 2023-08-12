//
//  Service.swift
//  SpaceX-MVVM
//
//  Created by Vivek Sehrawat on 11/08/23.
//

import Foundation

enum ServiceMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

enum Environment {
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

protocol Service {
    var environment: Environment { get }
    var headers: [String: String] { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    var method: ServiceMethod { get }
    var body: Data? { get }
    var baseURL: String { get }

}

extension Service {
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

extension Service {
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

extension Service {
    
    var parameters: [String: Any] {
        return [:]
    }
    var headers: [String: Any] {
        return [:]
    }
}


enum Result<T> {
    case success(T)
    case failure(NetworkError)
    case empty
}


class ServiceProvider<T: Service> {
    var urlSession : URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        self.urlSession = session
    }
    
    func load<U>(service: T, decodeType: U.Type, completion: @escaping (Result<U>) -> Void) where U: Decodable {
        let request = service.urlRequest
        urlSession.dataTask(with: request) { (data, _, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
            } else if let data = data {
                let decoder = JSONDecoder()
                do {
                    let resp = try decoder.decode(decodeType, from: data)
                    DispatchQueue.main.async {
                        completion(.success(resp))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingFailed(error)))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.empty)
                }
            }
        }.resume()
    }
}
