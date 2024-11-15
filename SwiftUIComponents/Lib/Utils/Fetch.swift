import Foundation
import SwiftUI

func fetch(_ url: URL, method: HttpMethod = .get, body: Data?, headers: [String: String]?)
  async throws
  -> (Data, HTTPURLResponse)
{
  var urlRequest: URLRequest = URLRequest(url: url)
  urlRequest.httpMethod = method.rawValue
  urlRequest.httpBody = body
  urlRequest.allHTTPHeaderFields = headers

  let (data, response) = try await URLSession.shared.data(for: urlRequest)

  guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
    (200...299).contains(httpResponse.statusCode)
  else {
    let statusCode = (response as! HTTPURLResponse).statusCode
    throw HttpError(httpErrorCode: statusCode, kind: .serverError)
  }

  return (data, httpResponse)
}

struct HttpError: Error {
  enum ErrorKind {
    case serverError
  }

  let httpErrorCode: Int
  let kind: ErrorKind
}

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}
