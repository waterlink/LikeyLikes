import Foundation

class StockHttpClient: HttpClient {
    let endpoint: String
    let urlSession: URLSession
    
    init(endpoint: String) {
        self.endpoint = endpoint
        
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlSession = URLSession(configuration: urlSessionConfig)
    }
    
    func get(url: String, handler: @escaping (String, Error?) -> Void) {
        print("[StockHttpClient] get: \(url)")
        
        let task = urlSession.dataTask(
            with: URL(string: "\(endpoint)\(url)")!
        ) {(data, response, error) in
            
            if let error = error {
                handler("", error)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode < 200 || response.statusCode >= 400 {
                    handler("", HttpError(url: url, statusCode: response.statusCode))
                    return
                }
            } else {
                handler("", UnableToDecodeResponse())
                return
            }
            
            guard let data = data,
                let dataString = String(data: data, encoding: .utf8) else {
                    print("[StockHttpClient] unable to decode response")
                    handler("", UnableToDecodeResponse())
                    return
            }
            
            handler(dataString, nil)
            
        }
        
        task.resume()
    }
}

class UnableToDecodeResponse: Error {
    
}

struct HttpError: Error {
    let url: String
    let statusCode: Int
}
