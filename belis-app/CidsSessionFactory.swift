//
//  CidsSessionFactory.swift
//  BelsiTests
//
//  Created by Thorsten Hell on 14/08/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation

class CidsSessionFactory : NSObject, NSURLSessionDelegate{
    let queue = NSOperationQueue()
    var localServerCertData:NSData?
    var identityAndTrustForCSC:IdentityAndTrust?
    override init() {
        super.init()
        queue.maxConcurrentOperationCount=1
        localServerCertData = NSData(contentsOfFile: CidsConnector.sharedInstance().serverCertPath)!
        let clientCertData = NSData(contentsOfFile: CidsConnector.sharedInstance().clientCertPath);
        if let ccert=clientCertData {
            identityAndTrustForCSC = self.extractIdentity(ccert, certPassword: CidsConnector.sharedInstance().clientCertContainerPass)
        }

    }
    
    func getNewCidsSession() -> NSURLSession{
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        return NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: queue)
    }
    
    func getPickyNewCidsSession() -> NSURLSession{
        return getNewCidsSession()
//        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
//        sessionConfig.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
//        sessionConfig.timeoutIntervalForResource=10
//        return NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: queue)
    }
    
    func getNewWebDavSession() -> NSURLSession{
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        return NSURLSession(configuration: sessionConfig, delegate: WebDavUrlSessionDelegate(), delegateQueue: queue)
    }
    

    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        let authMethod=challenge.protectionSpace.authenticationMethod
        
        //SecTrustEvaluate(challenge.protectionSpace.serverTrust!, nil);
        
        if authMethod==NSURLAuthenticationMethodServerTrust {
            print("check server cert")
            let serverTrust=challenge.protectionSpace.serverTrust
            let serverCert=SecTrustGetCertificateAtIndex(serverTrust!, 0)! //.takeUnretainedValue()
            let remoteCertificateData = NSData(data:SecCertificateCopyData(serverCert)) //.takeRetainedValue())

            
            
            if  remoteCertificateData.isEqualToData(localServerCertData!) {
                print("YAY")
                
              //  completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))                
                completionHandler(.UseCredential, NSURLCredential(trust: challenge.protectionSpace.serverTrust!))
            }
            else {
                print("NAY")
            }
        } else if authMethod==NSURLAuthenticationMethodClientCertificate {
            print("provide client cert")
            if let clientCert=identityAndTrustForCSC {
                
                let urlCredential:NSURLCredential = NSURLCredential(
                    identity: clientCert.identityRef,
                    certificates: identityAndTrustForCSC!.certArray as [AnyObject],
                    persistence: NSURLCredentialPersistence.ForSession);
                
                completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, urlCredential);
            }
        }
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
    }
    
    private func extractIdentity(certData:NSData, certPassword:String) -> IdentityAndTrust? {
        
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        //var items:Unmanaged<CFArray>?
        let items: UnsafeMutablePointer<CFArray?> = UnsafeMutablePointer<CFArray?>.alloc(1)
        
//        let certOptions:CFDictionary = [ kSecImportExportPassphrase.takeRetainedValue() as String: certPassword ];
        let certOptions:CFDictionary = [ kSecImportExportPassphrase as String: certPassword ];
        
        // import certificate to read its entries
        securityError = SecPKCS12Import(certData, certOptions, items);
        
        if securityError == errSecSuccess {
            
            let certItems:CFArray = items.memory as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentityRef = identityPointer as! SecIdentityRef!;
                
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrustRef = trustPointer as! SecTrustRef;
                
                // grab the certificate chain
                let certRef:UnsafeMutablePointer<SecCertificate?>=UnsafeMutablePointer<SecCertificate?>.alloc(1)
                SecIdentityCopyCertificate(secIdentityRef, certRef);
                //let clientCert=certRef?.takeRetainedValue()
                let certArray:NSMutableArray = NSMutableArray();
                certArray.addObject(certRef.memory as SecCertificateRef!);
                
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray: certArray);
            }
        }
        
        return identityAndTrust;
    }
}


struct IdentityAndTrust {
    
    var identityRef:SecIdentityRef
    var trust:SecTrustRef
    var certArray:NSArray
}


class WebDavUrlSessionDelegate:NSObject, NSURLSessionTaskDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        let authMethod=challenge.protectionSpace.authenticationMethod
        
        if authMethod == NSURLAuthenticationMethodHTTPDigest {
            let urlCredential:NSURLCredential = NSURLCredential(user: Secrets.getWebDavUser(), password: Secrets.getWebDavPass(), persistence: NSURLCredentialPersistence.ForSession)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, urlCredential)
        }
        
    }
}
