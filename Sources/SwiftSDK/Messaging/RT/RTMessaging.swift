//
//  RTMessaging.swift
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

class RTMessaging: RTListener {
    
    private var channel: Channel

    init(channel: Channel) {
        self.channel = channel
    }
    
    func connect(responseHandler: (() -> Void)!, errorHandler: ((Fault) -> Void)!) {
        if let channelName = self.channel.channelName {
            let options = ["channel": channelName] as [String : Any]
            let subscription = createSubscription(type: PUB_SUB_CONNECT, options: options, connectionHandler: responseHandler, responseHandler: nil, errorHandler: errorHandler)
            subscription.subscribe()
        }
    }
    
    func addStringMessageListener(selector: String?, responseHandler: ((String) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        var options = [String : Any]()
        if let channelName = self.channel.channelName {
            options["channel"] = channelName
        }
        if let selector = selector {
            options["selector"] = selector
        }
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any],
                let message = response["message"] as? String {
                responseHandler(message)
            }
        }
        let subscription = createSubscription(type: PUB_SUB_MESSAGES, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
        subscription.subscribe()
        return subscription
    }
    
    func addDictionaryMessageListener(selector: String?, responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        var options = [String : Any]()
        if let channelName = self.channel.channelName {
            options["channel"] = channelName
        }
        if let selector = selector {
            options["selector"] = selector
        }
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any],
                let message = response["message"] as? [String : Any],
                message["___class"] == nil {
                responseHandler(message)
            }
        }
        let subscription = createSubscription(type: PUB_SUB_MESSAGES, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
        subscription.subscribe()
        return subscription
    }
    
    func addCustomObjectMessageListener(selector: String?, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        var options = [String : Any]()
        if let channelName = self.channel.channelName {
            options["channel"] = channelName
        }
        if let selector = selector {
            options["selector"] = selector
        }
        let wrappedBlock: (Any) -> () = { response in
            if let response = response as? [String : Any],
                let message = response["message"] as? [String : Any],
                let className = message["___class"] as? String {
                responseHandler(PersistenceServiceUtils().dictionaryToEntity(dictionary: message, className: className) as Any)
            }
        }
        let subscription = createSubscription(type: PUB_SUB_MESSAGES, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
        subscription.subscribe()
        return subscription
    }
    
    func addMessageListener(selector: String?, responseHandler: ((PublishMessageInfo) -> Void)!, errorHandler: ((Fault) -> Void)!) -> RTSubscription? {
        var options = [String : Any]()
        if let channelName = self.channel.channelName {
            options["channel"] = channelName
        }
        if let selector = selector {
            options["selector"] = selector
        }
        let wrappedBlock: (Any) -> () = { response in           
            if let response = response as? [String : Any],
                let publishMessageInfo = ProcessResponse.shared.adaptToPublishMessageInfo(messageInfoDictionary: response) {
                responseHandler(publishMessageInfo)
            }
        }
        let subscription = createSubscription(type: PUB_SUB_MESSAGES, options: options, connectionHandler: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
        subscription.subscribe()
        return subscription
    }
    
    func removeMessageListeners(selector: String?) {
        stopSubscriptionForChannel(channel: self.channel, event: PUB_SUB_MESSAGES, selector: selector)
    }
}
