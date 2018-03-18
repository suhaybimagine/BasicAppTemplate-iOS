//
//  DataExtensions.swift
//  OffersMatch
//
//  Created by Ali Hajjaj on 3/14/18.
//  Copyright © 2018 Ali Hajjaj. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

extension Request {
    
    public static func serializeResponseSwiftyJSON(
        options: JSONSerialization.ReadingOptions,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?)
        -> Result<JSON>
    {
        let emptyDataStatusCodes: Set<Int> = [204, 205]
        
        guard error == nil else { return .failure(error!) }
        
        if let response = response, emptyDataStatusCodes.contains(response.statusCode) { return .success(JSON.null) }
        
        guard let validData = data, validData.count > 0 else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
        }
        
        do {
            let json = try JSON(data: validData, options: options)
            return .success(json)
        } catch {
            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
        }
    }
}


extension DataRequest {
    
    public static func swiftyJsonResponseSerializer(
        options: JSONSerialization.ReadingOptions = .allowFragments)
        -> DataResponseSerializer<JSON>
    {
        return DataResponseSerializer { _, response, data, error in
            return Request.serializeResponseSwiftyJSON(options: options, response: response, data: data, error: error)
        }
    }
    
    @discardableResult
    public func responseSwiftyJSON(
        queue: DispatchQueue? = nil,
        options: JSONSerialization.ReadingOptions = .allowFragments,
        completionHandler: @escaping (DataResponse<JSON>) -> Void)
        -> Self
    {
        return response(
            queue: queue,
            responseSerializer: DataRequest.swiftyJsonResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
}


let JSONDateFomatter = DateFormatter()
extension JSON {
    
    var defaultDate:Date? {
        return self.date(ofFormat: "dd/MM/yyyy hh:mm:ssa")
    }
    
    func date(ofFormat format:String) -> Date? {
        
        if let str = self.string {
            JSONDateFomatter.dateFormat = format
            return JSONDateFomatter.date(from: str)
        }
        
        return nil
    }
}
