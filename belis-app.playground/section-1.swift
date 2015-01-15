// Playground - noun: a place where people can play

import UIKit
import Alamofire

var result=Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"]);




Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
    .response { (request, response, data, error) in
        println(response!.description);
}




