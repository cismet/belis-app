//
//  CidsOperations.swift
//  BelsiTests
//
//  Created by Thorsten Hell on 14/08/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class CidsRequestOperation: Operation {
    var sessionFactory=CidsSessionFactory()
    var qu: OperationQueue
    var task: URLSessionDataTask?
    var baseUrl:String=""
    var domain:String="BELIS2"
    var authHeader=""
    var url=""
    
    init(user: String, pass:String){
        self.qu=OperationQueue.main
        let loginString = NSString(format: "%@:%@", user, pass)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        authHeader="Basic \(base64LoginString)"
    }
    override var isExecuting : Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    fileprivate var _executing : Bool=false
    
    override var isFinished : Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    fileprivate var _finished : Bool=false
    
    override func cancel(){
        super.cancel()
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
    func stringFromQueryParameters(_ queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        for (name, value) in queryParameters {
            //let part = NSString(format: "%@=%@",name.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            let part = NSString(format: "%@=%@",
                    name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
                    value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
    /**
    Creates a new URL by adding the given query parameters.
    @param URL The input URL.
    @param queryParameters The query parameter dictionary to add.
    @return A new NSURL.
    */
    func NSURLByAppendingQueryParameters(_ URL : Foundation.URL!, queryParameters : Dictionary<String, String>) -> Foundation.URL {
        let URLString : NSString = NSString(format: "%@?%@", URL.absoluteString, self.stringFromQueryParameters(queryParameters))
        return Foundation.URL(string: URLString as String)!
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
    var session:Foundation.URLSession?
    var entityName=""
    var completionHandler: ((_ operation:GetEntityOperation, _ data : Data?, _ response : URLResponse?, _ error : Error?, _ queue: OperationQueue) -> ())?
    
    init(baseUrl: String, domain: String,entityName:String, id: Int, user: String, pass:String, queue: OperationQueue, completionHandler: @escaping (_ operation:GetEntityOperation, _ data : Data?, _ response : URLResponse?, _ error : Error?, _ queue: OperationQueue) -> ()) {
        super.init(user:user,pass:pass)
        self.id=id
        self.qu=queue
        self.entityName=entityName
        self.completionHandler=completionHandler
        url="\(baseUrl)/\(domain).\(entityName)/\(id)"
    }
    
    override func main() {
        print("do get \(entityName).\(id)")
        if (self.isCancelled || CidsConnector.sharedInstance().isCancelRequested) {
            return
        }
        else  {
            let nsurl = URL(string: url)
            
            var request = URLRequest(url: nsurl!)
            request.httpMethod = "GET"
            
            request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            session=sessionFactory.getNewCidsSession()
            
            task = session?.dataTask(with: request, completionHandler: { (data, response, error) in
                if let handler=self.completionHandler {
                    handler(self, data, response, error, self.qu)
                }
                else {
                    if (error == nil) {
                        // Success
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        print("getEntity::URL Session Task Succeeded: HTTP \(statusCode)")
                    }
                    else {
                        // Failure
                        print("getEntity::URL Session Task Failed: %@", error!.localizedDescription);
                    }
                }
                
                self.isExecuting=false
                self.isFinished = true
                self.task=nil
            })
            task?.resume()
        }
    }
    override func cancel() {
        super.cancel()
        self._finished = true

        print("cancel get \(entityName).\(id) \(self.isCancelled),\(self.isFinished),\(self.isExecuting) ")
    }
}
class GetAllEntitiesOperation: CidsRequestOperation {
    var entityName=""
    var completionHandler: ((_ operation:GetAllEntitiesOperation, _ data : Data?, _ response : URLResponse?, _ error : Error?, _ queue: OperationQueue) -> ())?
    
    init(baseUrl: String, domain: String,entityName:String, user: String, pass:String, queue: OperationQueue, completionHandler: @escaping (_ operation:GetAllEntitiesOperation, _ data : Data?, _ response : URLResponse?, _ error : Error?, _ queue: OperationQueue) -> ()) {
        super.init(user:user,pass:pass)
        self.qu=queue
        self.completionHandler=completionHandler
        url="\(baseUrl)/\(domain).\(entityName)?limit=10000000"
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        else  {
            let nsurl = URL(string: url)
            
            var request = URLRequest(url: nsurl!)
            request.httpMethod = "GET"
            
            request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let session=sessionFactory.getNewCidsSession()
            /* Start a new Task */
            task = session.dataTask(with: request, completionHandler: { (data , response , error ) in
                if let handler=self.completionHandler {
                    handler(self, data, response, error, self.qu)
                }
                else {
                    if (error == nil) {
                        // Success
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        print("getAllEntities::URL Session Task Succeeded: HTTP \(statusCode)")
                    }
                    else {
                        // Failure
                        print("getAllEntities::URL Session Task Failed: %@", error!.localizedDescription);
                    }
                }
                
                
                self.isExecuting=false
                self.isFinished = true
                self.task=nil
            })
            if let t=self.task {
                t.resume()
            }
        }
    }
}
class LoginOperation: CidsRequestOperation {
    var completionHandler: ((_ loggedIn: Bool, _ error: Error?) -> ())?
    init(baseUrl: String, domain: String, user: String, pass:String, completionHandler: @escaping (_ loggedIn: Bool, _ error: Error?) -> ()){
        super.init(user:user,pass:pass)
        url="\(baseUrl)/classes?domain=local&limit=1&offset=0&role=all"
        self.completionHandler=completionHandler
    }
    override func main() {
        if self.isCancelled {
            return
        }
        else  {
            let nsurl = URL(string: url)
            var request = URLRequest(url: nsurl!)
            request.httpMethod = "GET"
            
            request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let session=sessionFactory.getPickyNewCidsSession()
            /* Start a new Task */
            task = session.dataTask(with: request, completionHandler: { (data , response , error ) in
                if let err=error {
                    self.completionHandler!(false,err)
                }
                else {
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode) for \(self.url)")
                    
                    if statusCode==200 {
                        self.completionHandler!(true,nil)
                    }
                    else {
                        self.completionHandler!(false,nil)
                    }
                }
                self.isExecuting=false
                self.isFinished = true
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
    var completionHandler: ((_ data : Data?, _ response : URLResponse?, _ error : Error?) -> Void)?
    
    init(baseUrl: String, searchKey:String, user: String, pass:String, queue: OperationQueue, parameters:QueryParameters,completionHandler: ((_ data : Data?, _ response : URLResponse?, _ error : Error?) -> Void)!) {
        super.init(user: user, pass: pass)
        self.qu=queue
        self.parameters=parameters
        url="\(baseUrl)/searches/\(searchKey)/results"
        self.completionHandler=completionHandler
    }
    
    override func main() {
        let session=sessionFactory.getNewCidsSession()
        print(url)
        var URL = Foundation.URL(string: url)
        let URLParams = [
            "role": "all",
            "limit": "100",
            "offset\"": "null",
        ]
        URL = NSURLByAppendingQueryParameters(URL, queryParameters: URLParams)
        var request = URLRequest(url: URL!)
        request.httpMethod = "POST"
        request.addValue(authHeader, forHTTPHeaderField: "Authorization") //correct passwd
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let y = Mapper().toJSON(parameters!)
        print(Mapper().toJSONString(parameters!, prettyPrint: true)!)
        request.httpBody=try? JSONSerialization.data(withJSONObject: y, options: JSONSerialization.WritingOptions())
        
        /* Start a new Task */
        task = session.dataTask(with: request, completionHandler: { (data , response , error ) in
            if let handler=self.completionHandler {
                handler(data, response, error)
            }
            else {
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("search::URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("search::URL Session Task Failed: %@", error!.localizedDescription);
                }
            }
            self.isExecuting=false
            self.isFinished = true
            self.task=nil
        })
        task?.resume()
        
    }
}
class ServerActionOperation: CidsRequestOperation {
    var params: ActionParameterContainer?
    var completionHandler: ((_ data : Data?, _ response : URLResponse?, _ error : Error?) -> Void)?
    init(baseUrl: String, user: String, pass:String, actionName: String, params: ActionParameterContainer, completionHandler: @escaping (_ data : Data?, _ response : URLResponse?, _ error : Error?) -> Void) {
        super.init(user:user, pass:pass)
        url="\(baseUrl)/actions/\(domain).\(actionName)/tasks"
        self.params=params
        self.completionHandler=completionHandler
    }
    override func main() {
        let session=sessionFactory.getNewCidsSession()
        var URL = Foundation.URL(string: url)
        let URLParams = [
            "role": "all",
            "resultingInstanceType": "result",
        ]
        URL = self.NSURLByAppendingQueryParameters(URL, queryParameters: URLParams)
        var request = URLRequest(url: URL!)
        request.httpMethod = "POST"
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
        
        
        request.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        task = session.dataTask(with: request, completionHandler: { (data , response , error ) -> Void in
            if let handler=self.completionHandler {
                handler(data, response, error)
            }
            else {
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("serverAction::URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("serverAction::URL Session Task Failed: %@", error!.localizedDescription);
                }
            }
            
            self.isExecuting=false
            self.isFinished = true
            self.task=nil
        })
        task?.resume()
    }
}
class WebDavUploadImageOperation: CidsRequestOperation {
    var image:UIImage?
    var completionHandler: ((_ data : Data?, _ response : URLResponse?, _ error : Error?) -> Void)?
    init(baseUrl: String, user: String, pass:String, fileName: String, image:UIImage, completionHandler: @escaping (_ data : Data?, _ response : URLResponse?, _ error : Error?) -> Void) {
        super.init(user:user, pass:pass)
        url="\(baseUrl)/\(fileName)"
        self.image=image
        self.completionHandler=completionHandler
        
    }
    override func main() {
        let session=sessionFactory.getNewWebDavSession()
        let URL = Foundation.URL(string: url)
        
        var request = URLRequest(url: URL!)
        request.httpMethod = "PUT"
        
        
        let jpg=UIImageJPEGRepresentation(image!, CGFloat(0.9))
        
        task = session.uploadTask(with: request, from: jpg, completionHandler: {
            (data, response, error) -> Void in
            if let handler=self.completionHandler {
                handler(data, response, error)
            }
            else {
                
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("webdavUpload::URL Session Task Succeeded: HTTP \(statusCode)")
                }
                else {
                    // Failure
                    print("webdavUpload::URL Session Task Failed: %@", error!.localizedDescription);
                }
            }
            self.isExecuting=false
            self.isFinished = true
            self.task=nil
        }) 
        
        task?.resume()
    }
}

