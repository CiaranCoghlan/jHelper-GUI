//
//  HttpRequest.swift
//  JAMF Helper GUI
//
//  Created by Jordan Wisniewski on 9/29/15.
//
//  Copyright (C) 2016, JAMF Software, LLC All rights reserved.
//
//  THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
//  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
//  DAMAGE.

import Cocoa

open class HttpRequest: NSObject, URLSessionDelegate {
    
    func post(_ url: String, user: String, password: String, data: String){

        let data = (data as NSString).data(using: String.Encoding.utf8.rawValue)

        //Combine the credentials
        let credentials = user + ":" + password
        
        //UTF-8 Encode login information, and then Base64 encode login information
        let utf8_credentials = credentials.data(using: String.Encoding.utf8)
        let base64_credentials = utf8_credentials!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        //Create a request object, set method to 'POST' and the body to the script XML
        let request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = data
        
        //Create a default configuration, and add additional headers for Basic Authentication and Content Type
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(base64_credentials)", "Content-Type" : "text/xml"]
        
        //Initialize a NSURL session
        let session = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        //Create the task with the request, and prepare to log result/errors to console
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async(execute: {
                    self.httpStatus(status: httpResponse)
                })
            }
        })
        
        //Start the task (ie. Submit HTTP Request)
        task.resume()
    }
    
    func httpStatus(status: HTTPURLResponse) {
        
        let statusCode = status.statusCode
        let message = "Code: " + String(statusCode) + "\n" +
                      "Reason: " + HTTPURLResponse.localizedString(forStatusCode: statusCode)
        
        if statusCode == 201 {
            DispatchQueue.main.async(execute: {
                HelperUtils.displayAlert("HTTP Request", string: message)
            })
            
        } else {
            DispatchQueue.main.async(execute: {
                HelperUtils.displayAlert("HTTP Request", string: message)
            })
            
        }
    }
    
    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        
    }
}
