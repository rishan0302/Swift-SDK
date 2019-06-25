//
//  EmailEnvelope.swift
//
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2019 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

@objcMembers open class EmailEnvelope: NSObject {
    
    open var to: [String]?
    open var cc: [String]?
    open var bcc: [String]?
    open var query: String?
    
    open func addTo(to: [String]) {
        if self.to == nil {
            self.to = [String]()
        }
        self.to!.append(contentsOf: to)
    }
    
    open func addCc(cc: [String]) {
        if self.cc == nil {
            self.cc = [String]()
        }
        self.cc!.append(contentsOf: cc)
    }
    
    open func addBcc(bcc: [String]) {
        if self.bcc == nil {
            self.bcc = [String]()
        }
        self.bcc!.append(contentsOf: bcc)
    }
}