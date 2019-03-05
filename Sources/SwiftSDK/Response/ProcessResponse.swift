//
//  ProcessResponse.swift
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

class ProcessResponse: NSObject {
    
    static let shared = ProcessResponse()
    
    func adapt<T>(response: ReturnedResponse, to: T.Type) -> Any? where T: Decodable {
        if response.data?.count == 0 {
            if let responseResult = getResponseResult(response: response), responseResult is Fault {
                return responseResult as! Fault
            }
            return nil
        }
        else {
            if let responseResult = getResponseResult(response: response) {
                if responseResult is Fault {
                    return responseResult as! Fault
                }
                else {
                    do {
                        if to == BackendlessUser.self {
                            return adaptToBackendlessUser(responseResult: responseResult)
                        }
                            //                        else if to == [BackendlessUser].self {
                            //                            if let responseResult = responseResult as? [[String: Any]] {
                            //                            }
                            //                        }
                        else if let responseData = response.data {
                            let responseObject = try JSONDecoder().decode(to, from: responseData)
                            return responseObject
                        }
                    }
                        //                    catch let DecodingError.dataCorrupted(context) {
                        //                        print(context)
                        //                    } catch let DecodingError.keyNotFound(key, context) {
                        //                        print("Key '\(key)' not found:", context.debugDescription)
                        //                        print("codingPath:", context.codingPath)
                        //                    } catch let DecodingError.valueNotFound(value, context) {
                        //                        print("Value '\(value)' not found:", context.debugDescription)
                        //                        print("codingPath:", context.codingPath)
                        //                    } catch let DecodingError.typeMismatch(type, context)  {
                        //                        print("Type '\(type)' mismatch:", context.debugDescription)
                        //                        print("codingPath:", context.codingPath)
                        //                    } catch {
                        //                        print("error: ", error)
                        //                    }
                    catch {
                        return Fault(domain: (error as NSError).domain, code: (error as NSError).code, userInfo: (error as NSError).userInfo)
                    }
                }
            }
            return nil
        }
    }
    
    func adaptToBackendlessUser(responseResult: Any?) -> Any? {
        if let responseResult = responseResult as? [String: Any] {
            let properties = ["email": responseResult["email"], "name": responseResult["name"], "objectId": responseResult["objectId"], "userToken": responseResult["user-token"]]
            do {
                let responseData = try JSONSerialization.data(withJSONObject: properties)
                do {
                    let responseObject = try JSONDecoder().decode(BackendlessUser.self, from: responseData)
                    responseObject.setProperties(properties: responseResult)
                    return responseObject
                }
                catch {
                    return Fault(domain: (error as NSError).domain, code: (error as NSError).code, userInfo: (error as NSError).userInfo)
                }
            }
            catch {
                return Fault(domain: (error as NSError).domain, code: (error as NSError).code, userInfo: (error as NSError).userInfo)
            }
            
        }
        return nil
    }
    
    func adaptToGeoPoint(geoDictionary: [String : Any]) -> GeoPoint? {
        if let objectId = geoDictionary["objectId"] as? String,
            let latitude = geoDictionary["latitude"] as? Double,
            let longitude = geoDictionary["longitude"] as? Double,
            let categories = geoDictionary["categories"] as? [String],
            let metadata = geoDictionary["metadata"] as? [String: String] {            
            return GeoPoint(objectId: objectId, latitude: latitude, longitude: longitude, categories: categories, metadata: JSON(metadata))
        }
        return nil
    }
    
    func adaptToPublishMessageInfo(messageInfoDictionary: [String : Any]) -> PublishMessageInfo? {        
        let publishMessageInfo = PublishMessageInfo()
        if let messageId = messageInfoDictionary["messageId"] as? String {
            publishMessageInfo.messageId = messageId
        }
        if let timestamp = messageInfoDictionary["timestamp"] as? NSNumber? {
            publishMessageInfo.timestamp = timestamp
        }
        if let message = messageInfoDictionary["message"] {
            if let messageDictionary = message as? [String : Any],
                let className = messageDictionary["___class"] as? String {
                publishMessageInfo.message = PersistenceServiceUtils().dictionaryToEntity(dictionary: messageDictionary, className: className)
            }
            else {
                publishMessageInfo.message = message
            }
        }
        if let publisherId = messageInfoDictionary["publisherId"] as? String {
            publishMessageInfo.publisherId = publisherId
        }
        if let subtopic = messageInfoDictionary["subtopic"] as? String {
            publishMessageInfo.subtopic = subtopic
        }
        if let pushSinglecast = messageInfoDictionary["pushSinglecast"] as? [Any] {
            publishMessageInfo.pushSinglecast = pushSinglecast
        }
        if let pushBroadcast = messageInfoDictionary["pushBroadcast"] as? NSNumber {
            publishMessageInfo.pushBroadcast = pushBroadcast
        }
        if let publishPolicy = messageInfoDictionary["publishPolicy"] as? String {
            publishMessageInfo.publishPolicy = publishPolicy
        }
        if let query = messageInfoDictionary["query"] as? String {
            publishMessageInfo.query = query
        }
        if let publishAt = messageInfoDictionary["publishAt"] as? NSNumber {
            publishMessageInfo.publishAt = publishAt
        }
        if let repeatEvery = messageInfoDictionary["repeatEvery"] as? NSNumber {
            publishMessageInfo.repeatEvery = repeatEvery
        }
        if let headers = messageInfoDictionary["headers"] as? [String : Any] {
            publishMessageInfo.headers = headers
        }
        return publishMessageInfo
    }
    
    func getResponseResult(response: ReturnedResponse) -> Any? {
        if let error = response.error {
            let faultCode = response.response?.statusCode
            let faultMessage = error.localizedDescription
            return faultConstructor(faultMessage, faultCode: faultCode!)
        }
        else if let _response = response.response {
            if let data = response.data {
                let responseResultDictionary =  try? JSONSerialization.jsonObject(with: data, options: [])
                if let faultDictionary = responseResultDictionary as? [String: Any],
                    let faultCode = faultDictionary["code"] as? Int,
                    let faultMessage = faultDictionary["message"] as? String {
                    return faultConstructor(faultMessage, faultCode: faultCode)
                }
                if responseResultDictionary != nil {
                    return responseResultDictionary
                }
                else if _response.statusCode < 200 || _response.statusCode > 400 {
                    let faultCode = _response.statusCode
                    let faultMessage = "Backendless server error"
                    return faultConstructor(faultMessage, faultCode: faultCode)
                }
                return responseResultDictionary
            }
        }
        return nil
    }
    
    func faultConstructor(_ faultMessage: String, faultCode: Int) -> Fault {
        var message = faultMessage
        if faultCode < 200 || faultCode > 400 {
            if faultCode == 404 {
                message = "Not Found"
            }
        }
        return Fault(message: message, faultCode: faultCode)
    }
}
