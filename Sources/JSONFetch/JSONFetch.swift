import Foundation


public enum FetchHttpMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

public enum FetchError {
    case invalidURL(url: String)
    case invalidResponse
    case customError(error: Error)
}

public enum FetchResult {
    case error(error: FetchError, response: URLResponse?)
    case ok(data: Data, response: URLResponse?)
}


public final class Fetch {

    private let session: URLSession
    private var path = ""
    private var host = ""
    private var body: Data?
    private var ssl = true
    private var params = [String: String]()
    private var headers = [
        "accept-encoding": "gzip, deflate, br",
        "accept": "application/json"
    ]


    private init(session: URLSession = .shared) {
        self.session = session
    }

    public static func new(session: URLSession = .shared, host: String, ssl: Bool = true) -> Fetch {
        let f = Fetch(session: session)
        f.host = host
        f.ssl = ssl

        return f
    }

    public func set(path: String) -> Fetch {
        self.path = path
        return self
    }

    public func makeFormURLEncoded() -> Fetch {
        self.headers["Content-Type"] = "application/x-www-form-urlencoded"
        return self
    }

    public func set(body: Data) -> Fetch {
        self.body = body
        return self
    }

    public func add(param: String, withValue value: String) -> Fetch {
        self.params[param] = value
        return self
    }

    public func add(header: String, withValue value: String) -> Fetch {
        self.headers[header] = value
        return self
    }


    public func fetch(with method: FetchHttpMethod, completionHandler: @escaping (FetchResult) -> ()) {
        doRequest(method: method, completionHandler: completionHandler)
    }


    private func doRequest(method: FetchHttpMethod, completionHandler: @escaping (FetchResult) -> ()) {

        var url = URLComponents()
        url.host = self.host
        url.path = self.path
        url.scheme = self.ssl ? "https" : "http"

        // append the parameters, if any
        url.queryItems = self.params.map(URLQueryItem.init)


        guard let endpoint = url.url else {
            completionHandler(.error(error: .invalidURL(url: "\(url)"), response: nil))
            return
        }


        var clientReq = URLRequest(url: endpoint)

        if let b = self.body {
            clientReq.httpBody = b
        }


        headers.forEach {
            clientReq.addValue($1, forHTTPHeaderField: $0)
        }


        clientReq.httpMethod = method == .GET ? "GET" : "POST"


        let task = session.dataTask(with: clientReq) { (data, response, error) in

            if let d = data {
                completionHandler(.ok(data: d, response: response))
                return
            }

            if let e = error {
                completionHandler(.error(error: .customError(error: e), response: response))
                return
            }


            completionHandler(.error(error: .invalidResponse, response: response))
        }
        task.resume()
    }


}




