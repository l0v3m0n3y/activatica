import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.unknown))
                }
            }
            task.resume()
        }
    }
}

@MainActor
public class Activatica {
    private let api = "https://activatica.org/api"
    private var headers: [String: String]
    
    public init() {
        self.headers = [
            "Connection": "keep-alive",
            "Accept-Encoding": "deflate, zstd",
            "Accept-Language": "en-US,en;q=0.9",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36"
        ]
    }
    
    private func fetchJSON(from urlString: String) async throws -> Any {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data)
    }
    
    public func getTypesList() async throws -> Any {
        try await fetchJSON(from: "\(api)/types")
    }
    
    public func getHeader() async throws -> Any {
        try await fetchJSON(from: "\(api)/header")
    }
    
    public func getSearchSuggest(q: String) async throws -> Any {
        guard var components = URLComponents(string: "\(api)/search/suggest") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "q", value: q))
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw NSError(domain: "Invalid URL components", code: -1)
        }
        
        return try await fetchJSON(from: url.absoluteString)
    }
    
    public func getMaterials(type: String,cursor: String? = nil, limit: Int? = nil) async throws -> Any {
        guard var components = URLComponents(string: "\(api)/posts") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "type", value: type))
        
        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw NSError(domain: "Invalid URL components", code: -1)
        }
        
        return try await fetchJSON(from: url.absoluteString)
    }
    
    public func getFeedPosts(limit: Int = 16,feedKind: String = "home",types: String? = nil,cursor: String = nil,hideHidden: Int? = nil) async throws -> Any {
        guard var components = URLComponents(string: "\(api)/feed") else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        queryItems.append(URLQueryItem(name: "feedKind", value: feedKind))
        
        if let types = types {
            queryItems.append(URLQueryItem(name: "types", value: types))
        }


        if let cursor = cursor {
            queryItems.append(URLQueryItem(name: "cursor", value: cursor))
        }

        if let hideHidden = hideHidden {
            queryItems.append(URLQueryItem(name: "hideHidden", value: String(hideHidden)))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw NSError(domain: "Invalid URL components", code: -1)
        }
        
        return try await fetchJSON(from: url.absoluteString)
    }
}
