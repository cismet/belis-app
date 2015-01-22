//
//  NetworkStuff.swift
//  belis-app
//
//  Created by Thorsten Hell on 21/01/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import Alamofire

class NetworkOperation : ConcurrentOperation {
    
    
    
    let URLString: String
    let networkOperationCompletionHandler: (urlRequest: NSURLRequest?, response: AnyObject?, responseObject: AnyObject?, error: NSError?) -> ()
    let parameters: [String : AnyObject]?
    let user: String
    let password: String
    let method: Alamofire.Method
    
    
    weak var request: Alamofire.Request?
    
    init(method: Alamofire.Method, URLString: String, user: String, password: String, parameters: [String : AnyObject], networkOperationCompletionHandler: (urlRequest: NSURLRequest?, response: AnyObject?, responseObject: AnyObject?, error: NSError?) -> ()) {
        self.URLString = URLString
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
        self.parameters=parameters
        self.user=user
        self.password=password
        self.method=method
        super.init()
    }
    
    // when the operation actually starts, this is the method that will be called
    
    override func main() {
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let manager = Alamofire.Manager(configuration: configuration)
        request = manager.request(method, URLString, parameters: parameters)
            .authenticate(user: user, password: password)
            .responseJSON { (request, response, responseObject, error) in
                // do whatever you want here; personally, I'll just all the completion handler that was passed to me in `init`
                
                self.networkOperationCompletionHandler(urlRequest: request, response: response, responseObject: responseObject, error: error)
                
                // now that I'm done, complete this operation
                
                self.completeOperation()
        }
    }
    
    // we'll also support canceling the request, in case we need it
    
    override func cancel() {
        request?.cancel()
        super.cancel()
    }
}

class ConcurrentOperation : NSOperation {
    
    override var concurrent: Bool {
        return true
    }
    
    override var asynchronous: Bool {
        return true
    }
    
    private var _executing: Bool = false
    override var executing: Bool {
        get {
            return _executing
        }
        set {
            if (_executing != newValue) {
                self.willChangeValueForKey("isExecuting")
                _executing = newValue
                self.didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override var finished: Bool {
        get {
            return _finished
        }
        set {
            if (_finished != newValue) {
                self.willChangeValueForKey("isFinished")
                _finished = newValue
                self.didChangeValueForKey("isFinished")
            }
        }
    }
    
    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting
    
    func completeOperation() {
        executing = false
        finished  = true
    }
    
    override func start() {
        if (cancelled) {
            finished = true
            return
        }
        
        executing = true
        
        main()
    }
}
