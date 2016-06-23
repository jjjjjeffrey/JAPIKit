import Alamofire
import SwiftyJSON

public typealias APIHttpMethod = Alamofire.Method
public typealias APIParameterEncoding = Alamofire.ParameterEncoding

public typealias APIResponse = Alamofire.Response<AnyObject, NSError>

public enum APIResponseErrorType {
    case HTTP403, JSONError, NoneBody
    case OtherError(String)
    case Message(String)
    
    public func description() -> String {
        switch self {
        case .HTTP403:
            return "HTTP 403 error"
        case .JSONError:
            return "JSON data error"
        case .NoneBody:
            return "HTTP body is NULL"
        case let .OtherError(message):
            return message
        case let .Message(message):
            return message
        }
    }
}

public enum APIResponseVerifyResult<DataType, ErrorType> {
    case Success(DataType?)
    case Failure(DataType?, ErrorType)
}

public enum APINotification: String, Notification {
    case Success
    case NetworkError
    case HTTP403
}

public protocol APIRequestable {
    
    associatedtype DataType
    associatedtype ErrorType
    
    var method: APIHttpMethod { get set }
    var URLString: String { get set }
    var parameters: [String: AnyObject]? { get set }
    var encoding: APIParameterEncoding? { get set }
    var headers: [String: String]? { get set }
    
    func request(callback: (result: APIResponseVerifyResult<DataType, ErrorType>) -> Void) -> Void
    
    func verify(response: APIResponse) -> APIResponseVerifyResult<DataType, ErrorType>
}

public protocol Notification {
    
    var name: String { get }
    func post(object anObject: AnyObject?, userInfo aUserInfo: [NSObject : AnyObject]?)
    func addObserver(observer: AnyObject, selector aSelector: Selector, object anObject: AnyObject?)
    static func removeAll(observer: AnyObject)
}

public extension Notification where Self: RawRepresentable, Self.RawValue == String {
    
    var name: String {
        return "\(Self.self).\(self.rawValue)"
    }
    
    public func post(object anObject: AnyObject? = nil, userInfo aUserInfo: [NSObject : AnyObject]? = nil) {
        NSNotificationCenter.defaultCenter().postNotificationName(self.name, object: anObject, userInfo: aUserInfo)
    }
    
    public func addObserver(observer: AnyObject, selector aSelector: Selector, object anObject: AnyObject? = nil) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: self.name, object: anObject)
    }
    
    static public func removeAll(observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
}

public class APIRequest: APIRequestable {
    
    public typealias DataType = JSON
    public typealias ErrorType = APIResponseErrorType
    
    public var method: APIHttpMethod = .GET
    public var URLString: String = "http://www.apple.com"
    public var parameters: [String: AnyObject]?
    public var encoding: APIParameterEncoding? = .JSON
    public var headers: [String: String]?
    
    public init() {}
}

extension APIRequest {
    public func request(callback: (result: APIResponseVerifyResult<DataType, ErrorType>) -> Void) -> Void {
        Alamofire.request(self.method,
            self.URLString,
            parameters: self.parameters,
            encoding: self.encoding ?? .URL,
            headers: self.headers).responseJSON { response in
                callback(result: self.verify(response))
        }
    }
    
    public func verify(response: APIResponse) -> APIResponseVerifyResult<DataType, ErrorType> {
        
        guard response.result.isSuccess else {
            APINotification.NetworkError.post()
            return APIResponseVerifyResult.Failure(nil, APIResponseErrorType.OtherError(response.result.debugDescription))
        }
        
        if let statusCode = response.response?.statusCode {
            if statusCode == 403 {
                APINotification.HTTP403.post()
                return APIResponseVerifyResult.Failure(nil, APIResponseErrorType.HTTP403)
            }
        }
        
        if let data = response.data {
            return verify(data)
        } else {
            return APIResponseVerifyResult.Failure(nil, APIResponseErrorType.NoneBody)
        }
        
    }
    
    private func verify(businessData: NSData) -> APIResponseVerifyResult<DataType, ErrorType> {
        
        let json = JSON(data: businessData)
        guard let ret = json["ret"].int else {
            return APIResponseVerifyResult.Failure(json, APIResponseErrorType.JSONError)
        }
        
        guard ret == 0 else {
            if let message = json["message"].string {
                return APIResponseVerifyResult.Failure(json, APIResponseErrorType.Message(message))
            } else {
                return APIResponseVerifyResult.Failure(json, APIResponseErrorType.JSONError)
            }
        }
        
        APINotification.Success.post()
        return APIResponseVerifyResult.Success(json["data"])
    }
}
