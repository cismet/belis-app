//
//  CidsOperations.swift
//  BelsiTests
//
//  Created by Thorsten Hell on 14/08/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class CidsRequestOperation: NSOperation {
    var sessionFactory=CidsSessionFactory()
    var qu: NSOperationQueue
    var task: NSURLSessionDataTask?
    var baseUrl:String=""
    var domain:String="BELIS2"
    var authHeader=""
    var url=""
    
    init(user: String, pass:String){
        self.qu=NSOperationQueue.mainQueue()
        let loginString = NSString(format: "%@:%@", user, pass)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions([])
        authHeader="Basic \(base64LoginString)"
    }
    override var executing : Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    private var _executing : Bool=false
    
    override var finished : Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    private var _finished : Bool=false
    
    
    override func cancel(){
        if let t=self.task {
            t.cancel()
        }
    }
    
    /**
    This creates a new query parameters string from the given NSDictionary. For
    example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
    string will be @"day=Tuesday&month=January".
    @param queryParameters The input dictionary.
    @return The created parameters string.
    */
    func stringFromQueryParameters(queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            //let part = NSString(format: "%@=%@",name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            let part = NSString(format: "%@=%@",
                    name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!,
                    value.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)
            parts.append(part as String)
        }
        return parts.joinWithSeparator("&")
    }
    
    /**
    Creates a new URL by adding the given query parameters.
    @param URL The input URL.
    @param queryParameters The query parameter dictionary to add.
    @return A new NSURL.
    */
    func NSURLByAppendingQueryParameters(URL : NSURL!, queryParameters : Dictionary<String, String>) -> NSURL {
        let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString, self.stringFromQueryParameters(queryParameters))
        return NSURL(string: URLString as String)!
    }
    
    func enqueue(){
        self.qu.addOperation(self)
    }
    
}

class PingOperation: CidsRequestOperation {
//    init(baseUrl: String, domain: String,entityName:String, id: Int, user: String, pass:String, queue: NSOperationQueue, completionHandler: (operation:GetEntityOperation, data : NSData!, response : NSURLResponse!, error : NSError!, queue: NSOperationQueue) -> ()) {
//        super.init(user:user,pass:pass)
//        self.id=id
//        self.qu=queue
//        self.completionHandler=completionHandler
//        url="\(baseUrl)/\(domain).\(entityName)/\(id)"
//    }
}



class GetEntityOperation: CidsRequestOperation {
    var id = -1
    
    var entityName=""
    
    var completionHandler: ((operation:GetEntityOperation, data : NSData!, response : NSURLResponse!, error : NSError!, queue: NSOperationQueue) -> ())?
    
    init(baseUrl: String, domain: String,entityName:String, id: Int, user: String, pass:String, queue: NSOperationQueue, completionHandler: (operation:GetEntityOperation, data : NSData!, response : NSURLResponse!, error : NSError!, queue: NSOperationQueue) -> ()) {
        super.init(user:user,pass:pass)
        self.id=id
        self.qu=queue
        self.completionHandler=completionHandler
        url="\(baseUrl)/\(domain).\(entityName)/\(id)"
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        else  {
            let nsurl = NSURL(string: url)
            
            let request = NSMutableURLRequest(URL: nsurl!)
            request.HTTPMethod = "GET"
            
            request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let session=sessionFactory.getNewCidsSession()
            /* Start a new Task */
            task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                if let handler=self.completionHandler {
                    handler(operation: self, data: data, response: response, error: error, queue: self.qu)
                }
                else {
                    if (error == nil) {
                        // Success
                        let statusCode = (response as! NSHTTPURLResponse).statusCode
                        print("URL Session Task Succeeded: HTTP \(statusCode)")
                    }
                    else {
                        // Failure
                        print("URL Session Task Failed: %@", error!.localizedDescription);
                    }
                }
                
                
                self.executing=false
                self.finished = true
                self.task=nil
            })
            if let t=self.task {
                t.resume()
            }
        }
    }
}

class GetAllEntitiesOperation: CidsRequestOperation {
    var entityName=""
    var completionHandler: ((operation:GetAllEntitiesOperation, data : NSData!, response : NSURLResponse!, error : NSError!, queue: NSOperationQueue) -> ())?
    
    init(baseUrl: String, domain: String,entityName:String, user: String, pass:String, queue: NSOperationQueue, completionHandler: (operation:GetAllEntitiesOperation, data : NSData!, response : NSURLResponse!, error : NSError!, queue: NSOperationQueue) -> ()) {
        super.init(user:user,pass:pass)
        self.qu=queue
        self.completionHandler=completionHandler
        url="\(baseUrl)/\(domain).\(entityName)?limit=10000000"
    }
    
    override func main() {
        if self.cancelled {
            return
        }
        else  {
            let nsurl = NSURL(string: url)
            
            let request = NSMutableURLRequest(URL: nsurl!)
            request.HTTPMethod = "GET"
            
            request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let session=sessionFactory.getNewCidsSession()
            /* Start a new Task */
            task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                if let handler=self.completionHandler {
                    handler(operation: self, data: data, response: response, error: error, queue: self.qu)
                }
                else {
                    if (error == nil) {
                        // Success
                        let statusCode = (response as! NSHTTPURLResponse).statusCode
                        print("URL Session Task Succeeded: HTTP \(statusCode)")
                    }
                    else {
                        // Failure
                        print("URL Session Task Failed: %@", error!.localizedDescription);
                    }
                }
                
                
                self.executing=false
                self.finished = true
                self.task=nil
            })
            if let t=self.task {
                t.resume()
            }
        }
    }
}

class LoginOperation: CidsRequestOperation {
    var completionHandler: ((loggedIn: Bool, error: NSError?) -> ())?
    init(baseUrl: String, domain: String, user: String, pass:String, completionHandler: (loggedIn: Bool, error: NSError?) -> ()){
        super.init(user:user,pass:pass)
        url="\(baseUrl)/classes?domain=local&limit=1&offset=0&role=all"
        self.completionHandler=completionHandler
    }
    override func main() {
        if self.cancelled {
            return
        }
        else  {
            let nsurl = NSURL(string: url)
            let request = NSMutableURLRequest(URL: nsurl!)
            request.HTTPMethod = "GET"
            
            request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let session=sessionFactory.getPickyNewCidsSession()
            /* Start a new Task */
            task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                if let err=error {
                    self.completionHandler!(loggedIn: false,error: err)
                }
                else {
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode) for \(self.url)")
                    
                    if statusCode==200 {
                        self.completionHandler!(loggedIn: true,error: nil)
                    }
                    else {
                        self.completionHandler!(loggedIn: false,error: nil)
                    }
                }
                self.executing=false
                self.finished = true
                self.task=nil
            })
            if let t=self.task {
                t.resume()
            }
        }
    }
}


class SearchOperation: CidsRequestOperation {
    var parameters:QueryParameters?
    var completionHandler: ((data : NSData!, response : NSURLResponse!, error : NSError!) -> Void)?
    
    init(baseUrl: String, searchKey:String, user: String, pass:String, parameters:QueryParameters,completionHandler: ((data : NSData!, response : NSURLResponse!, error : NSError!) -> Void)!) {
        super.init(user: user, pass: pass)
        self.parameters=parameters
        url="\(baseUrl)/searches/\(searchKey)/results"
        self.completionHandler=completionHandler
    }
    
    override func main() {
        let session=sessionFactory.getNewCidsSession()
        print(url)
        var URL = NSURL(string: url)
        let URLParams = [
            "role": "all",
            "limit": "100",
            "offset\"": "null",
        ]
        URL = NSURLByAppendingQueryParameters(URL, queryParameters: URLParams)
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "POST"
        request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let y = Mapper().toJSON(parameters!)
        print(Mapper().toJSONString(parameters!, prettyPrint: true)!)
        request.HTTPBody=try? NSJSONSerialization.dataWithJSONObject(y, options: NSJSONWritingOptions())
        
        /* Start a new Task */
        let task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            if let handler=self.completionHandler {
                handler(data: data, response: response, error: error)
            }
            else {
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                }
            }
            self.executing=false
            self.finished = true
            self.task=nil
        })
        task.resume()
        
    }
}



class ServerActionOperation: CidsRequestOperation {
    var params: ActionParameterContainer?
    var completionHandler: ((data : NSData!, response : NSURLResponse!, error : NSError!) -> Void)?
    init(baseUrl: String, user: String, pass:String, actionName: String, params: ActionParameterContainer, completionHandler: (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void) {
        super.init(user:user, pass:pass)
        url="\(baseUrl)/actions/\(domain).\(actionName)/tasks"
        self.params=params
        self.completionHandler=completionHandler
    }
    override func main() {
        let session=sessionFactory.getNewCidsSession()
        var URL = NSURL(string: url)
        let URLParams = [
            "role": "all",
            "resultingInstanceType": "result",
        ]
        URL = self.NSURLByAppendingQueryParameters(URL, queryParameters: URLParams)
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "POST"
        //request.addValue("Basic V2VuZGxpbmdNQEJFTElTMjp3bWJlbGlz", forHTTPHeaderField: "Authorization")
        request.addValue(authHeader, forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=nFcUS6GTpcRsBnbvYHhdwyggifFtKeLm", forHTTPHeaderField: "Content-Type")
        
        let paramsAsJSON:String=Mapper().toJSONString(params!, prettyPrint: false)!
        let bodyString = "--nFcUS6GTpcRsBnbvYHhdwyggifFtKeLm\r\n" +
            "Content-Disposition: form-data; name=\"taskparams\"; filename=\"addDoc.json\"\r\n" +
            "Content-Type: application/json\r\n" +
            "\r\n" +
            "\(paramsAsJSON) \r\n" +
            "\r\n" +
        "--nFcUS6GTpcRsBnbvYHhdwyggifFtKeLm--\r\n"
        
        
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let task = session.dataTaskWithRequest(request, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
            if let handler=self.completionHandler {
                handler(data: data, response: response, error: error)
            }
            else {
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                }
            }
            
            self.executing=false
            self.finished = true
            self.task=nil
        })
        task.resume()
    }
}

class WebDavUploadImageOperation: CidsRequestOperation {
    var image:UIImage?
    var completionHandler: ((data : NSData!, response : NSURLResponse!, error : NSError!) -> Void)?
    init(baseUrl: String, user: String, pass:String, fileName: String, image:UIImage, completionHandler: (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void) {
        super.init(user:user, pass:pass)
        url="\(baseUrl)/\(fileName)"
        self.image=image
        self.completionHandler=completionHandler
        
    }
    override func main() {
        let session=sessionFactory.getNewWebDavSession()
        let URL = NSURL(string: url)
        
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "PUT"
        
        
        let jpg=UIImageJPEGRepresentation(image!, CGFloat(0.9))
        
        let task = session.uploadTaskWithRequest(request, fromData: jpg) {
            (data, response, error) -> Void in
            if let handler=self.completionHandler {
                handler(data: data, response: response, error: error)
            }
            else {
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                }
            }
            self.executing=false
            self.finished = true
            self.task=nil
        }
        
        task.resume()
    }
}

