//
//  CidsSessionFactory.swift
//  BelsiTests
//
//  Created by Thorsten Hell on 14/08/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation

class CidsSessionFactory : NSObject, URLSessionDelegate{
    var localServerCertData:Data?
    var identityAndTrustForCSC:IdentityAndTrust?
    override init() {
        super.init()
        localServerCertData = try? Data(contentsOf: URL(fileURLWithPath: CidsConnector.sharedInstance().serverCertPath))
        let clientCertData = try? Data(contentsOf: URL(fileURLWithPath: CidsConnector.sharedInstance().clientCertPath));
        if let ccert=clientCertData {
            identityAndTrustForCSC = self.extractIdentity(ccert, certPassword: CidsConnector.sharedInstance().clientCertContainerPass)
        }

    }
    
    func getNewCidsSession() -> Foundation.URLSession{
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        return Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: CidsConnector.sharedInstance().cidsURLSessionQueue)
    }
    
    func getPickyNewCidsSession() -> Foundation.URLSession{
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        sessionConfig.timeoutIntervalForResource=10
        return Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: CidsConnector.sharedInstance().cidsPickyURLSessionQueue)
    }
    
    func getNewWebDavSession() -> Foundation.URLSession{
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        return Foundation.URLSession(configuration: sessionConfig, delegate: WebDavUrlSessionDelegate(), delegateQueue: CidsConnector.sharedInstance().webdavURLSessionQueue)
    }
    

    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let authMethod=challenge.protectionSpace.authenticationMethod
        
        if authMethod==NSURLAuthenticationMethodServerTrust {
            let serverTrust=challenge.protectionSpace.serverTrust
            let serverCert=SecTrustGetCertificateAtIndex(serverTrust!, 0)!
            let remoteCertificateData = NSData(data:SecCertificateCopyData(serverCert) as Data) as Data

            
            
            if  remoteCertificateData == localServerCertData! {
                
                completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
            }
            else {
                print("Problem with Server CERT Check")
            }
        } else if authMethod==NSURLAuthenticationMethodClientCertificate {
            if let clientCert=identityAndTrustForCSC {
                let urlCredential:URLCredential = URLCredential(
                    identity: clientCert.identityRef,
                    certificates: identityAndTrustForCSC!.certArray as [AnyObject],
                    persistence: URLCredential.Persistence.forSession);
                
                completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, urlCredential);
            }
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    }
    
    fileprivate func extractIdentity(_ certData:Data, certPassword:String) -> IdentityAndTrust? {
        
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        let items: UnsafeMutablePointer<CFArray?> = UnsafeMutablePointer.allocate(capacity: 1)
        let certOptions = [ kSecImportExportPassphrase as String: certPassword ] as CFDictionary
        
        // import certificate to read its entries
        securityError = SecPKCS12Import(certData as CFData, certOptions, items);
        
        if securityError == errSecSuccess {
            
            let certItems:CFArray = items.pointee as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!;
                
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"];
                let trustRef:SecTrust = trustPointer as! SecTrust;
                
                // grab the certificate chain
                let certRef:UnsafeMutablePointer<SecCertificate?>=UnsafeMutablePointer.allocate(capacity: 1)
                SecIdentityCopyCertificate(secIdentityRef, certRef);
                //let clientCert=certRef?.takeRetainedValue()
                let certArray:NSMutableArray = NSMutableArray();
                certArray.add(certRef.pointee as SecCertificate!);
                
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray: certArray);
            }
        }
        
        return identityAndTrust;
    }
}


struct IdentityAndTrust {
    
    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:NSArray
}


class WebDavUrlSessionDelegate:NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let authMethod=challenge.protectionSpace.authenticationMethod
        
        if authMethod == NSURLAuthenticationMethodHTTPDigest {
            let urlCredential:URLCredential = URLCredential(user: Secrets.getWebDavUser(), password: Secrets.getWebDavPass(), persistence: URLCredential.Persistence.forSession)
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, urlCredential)
        }
        
    }
}
