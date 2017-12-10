import Foundation

class ErrorBuilder {
    
    class func errorMessage(for error: APIError) -> String? {
        switch error {
        case .invalidDataReceived:
            return "Received invalid data. Probably server does not repond."
        case .invalidURL:
            return "Invalid URL address used."
        case .invalidResponseType:
            return "You have probably reached the limit of free GitHub api requests."
        case .JSONSerializationError:
            return "Received data couldn't have been serialized to valid JSON object."
        default:
            return nil
        }
    }
}
