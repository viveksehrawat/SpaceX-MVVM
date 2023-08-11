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

protocol Service {
    var headers: [String: Any]? { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: Any]? { get }
    var method: ServiceMethod { get }
    var body: Data? { get }
}

extension Service {
    
    private var url: URL? {
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
    
    public var urlRequest: URLRequest {
        guard let url = self.url else {
            fatalError("URL could not be built")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if !headers.isEmpty {
            headers.forEach { (key, value) in
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        if (method == .post) {
            if let body = body {
                //print("make body: \(String(data: body, encoding: .utf8) ?? "")")
                request.httpBody = body
            }
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
    case failure(Error)
    case empty
}


class ServiceProvider<T: Service> {
    var urlSession : URLSessionProtocol
    
    init() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        self.urlSession = session
    }
    
    func load<U>(service: T, decodeType: U.Type, completion: @escaping (Result<U>) -> Void) where U: Decodable {
        call(service.urlRequest) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let resp = try decoder.decode(decodeType, from: data)
                    completion(.success(resp))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            case .empty:
                completion(.empty)
            }
        }
    }
}

extension ServiceProvider {
    private func call(_ request: URLRequest, deliverQueue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<Data>) -> Void) {
        urlSession.dataTask(with: request) { (data, _, error) in
            if let error = error {
                deliverQueue.async {
                    completion(.failure(error))
                }
            } else if let data = data {
                deliverQueue.async {
                    completion(.success(data))
                }
            } else {
                deliverQueue.async {
                    completion(.empty)
                }
            }
        }.resume()
    }
}

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume()
}


extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping URLSessionProtocol.DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

