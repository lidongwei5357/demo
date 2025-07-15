//
//  DefaultDecoder.swift
//  Diablo
//
//  Created by wangkun on 2018/3/29.
//  Copyright © 2018年 wangkun. All rights reserved.
//



extension RequestContainer {
    @discardableResult
    public func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil,
                                                      decoder: JSONDecoder = JSONDecoder(),
                                                      config: ACDMResponeConfig = ACDMResponeConfig(),
                                                      completionHandler: @escaping (DataResponse<T>) -> Void) -> RequestContainer {

        _ = self.dataRequest.response(queue: queue,
                                      responseSerializer: RequestContainer.DecodableObjectSerializer(decoder: decoder, target: self.target, plugins: self.plugins, config: config),
                                      completionHandler: completionHandler)
        return self
    }

    internal static func DecodableObjectSerializer<T: Decodable>(decoder: JSONDecoder, target: FGTarget, plugins: [FGPlugin], config: ACDMResponeConfig) -> DataResponseSerializer<T> {
        return DataResponseSerializer { request, response, data, error in
            if let error = error {
                return .failure(error)
            }
            return self.decodeToObject(decoder: decoder,
                                       target: target,
                                       config: config,
                                       plugins: plugins,
                                       request: request,
                                       response: response,
                                       data: data)
        }
    }

    private static func decodeToObject<T: Decodable>(decoder: JSONDecoder,
                                                     target: FGTarget,
                                                     config: ACDMResponeConfig,
                                                     plugins: [FGPlugin],
                                                     request: URLRequest?,
                                                     response: HTTPURLResponse?,
                                                     data: Data?) -> Result<T> {
        let resultData = transformData(decoder: decoder, target: target, config: config, plugins: plugins, request: request, response: response, data: data)
        switch resultData {
        case .success(let value):
            return acdmDecode(decoder: decoder, data: value, target: target)
        case .failure(let error):
            return .failure(error)
        }
    }

    private static func acdmDecode<T: Decodable>(decoder: JSONDecoder, data: Data, target: FGTarget) -> Result<T> {
        do {
            let object = try decoder.decode(ACDMBody<T>.self, from: data)

//            // 非 0都返回failure
            if object.code == 0 {
                return .success(object.data)
            } else {
                let error = customLogicErrorHandler(code: object.code, msg: object.msg ?? "")
                target.commonErrorHandler?(error.code)
                return .failure(error)
            }
        } catch {
            do {
                let acdmException = try decoder.decode(ACDMBody<ACDMNull>.self, from: data)
                let error = customLogicErrorHandler(code: acdmException.code, msg: acdmException.msg ?? "")
                target.commonErrorHandler?(error.code)
                return .failure(error)
            } catch {
                return .failure(error)
            }
        }
    }

}


extension RequestContainer {
    @discardableResult
    public func responseACDMJSON(queue: DispatchQueue? = nil,
                             options: JSONSerialization.ReadingOptions = .allowFragments,
                             config: ACDMResponeConfig = ACDMResponeConfig(),
                             completionHandler: @escaping (DataResponse<Any>) -> Void) -> RequestContainer {

        _ = self.dataRequest.response(queue: queue, responseSerializer: RequestContainer.jsonACDMResponseSerializer(target: target, plugins: plugins, config: config, options: options), completionHandler: completionHandler)
        return self
    }

    internal static func jsonACDMResponseSerializer(target: FGTarget, plugins: [FGPlugin], config: ACDMResponeConfig, options: JSONSerialization.ReadingOptions = .allowFragments) -> DataResponseSerializer<Any> {

        return DataResponseSerializer { request, response, data, error in
            if let error = error {
                return .failure(error)
            }
            return self.decodeToACDMJSON(target: target, plugins: plugins, config: config, options: options, request: request, response: response, data: data)
        }
    }

    private static func decodeToACDMJSON(target: FGTarget, plugins: [FGPlugin], config: ACDMResponeConfig, options: JSONSerialization.ReadingOptions, request: URLRequest?, response: HTTPURLResponse?, data: Data?) -> Result<Any> {
        let resultData = transformData(decoder: JSONDecoder(), target: target, config: config, plugins: plugins, request: request, response: response, data: data)
        switch resultData {
        case .success(let value):
            return acdmJOSN(options: options, data: value)
        case .failure(let error):
            return .failure(error)
        }
    }

    private static func acdmJOSN(options: JSONSerialization.ReadingOptions, data: Data) -> Result<Any> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: options)
            if let dic = json as? [String : Any] {
                let code = (dic["code"] as? Int) ?? -9999
                let msg =  (dic["msg"] as? String) ?? ""
                let dataInDic = dic["data"]
                if code == 0 {
                    return .success(dataInDic ?? [:])
                } else {
                    let error = customLogicErrorHandler(code: code, msg: msg)
                    return .failure(error)
                }
            }
            return .success(json)
        }
        catch {
            return .failure(error)
        }
    }
}

extension RequestContainer {
    private static func transformData(decoder: JSONDecoder,
                                      target: FGTarget,
                                      config: ACDMResponeConfig,
                                      plugins: [FGPlugin],
                                      request: URLRequest?,
                                      response: HTTPURLResponse?,
                                      data: Data?) -> Result<Data> {
        guard let resultData = data else { return Result.failure(FGError.decodeError(reason: .noData)) }

        if let acdmtarget = target as? ACDMTarget, config.isNeedDecrypt {
            do {
                //获取要解密的数据
                let encryptResult = try decoder.decode(ACDMResult.self, from: resultData)
                let decryptedResult = acdmtarget.decrypt(data: encryptResult)
                plugins.forEach{ $0.didReceive(request: request, response: response, data: decryptedResult) }
                switch decryptedResult {
                case .success(let data):    return .success(data)
                case .failure(let error):   return .failure(error)
                }
            }
            catch {
                plugins.forEach{ $0.didReceive(request: request, response: response, data: Result.failure(error)) }
                return .failure(error)
            }

        } else {
            let result = Request.serializeResponseData(response: response, data: data, error: nil)
            plugins.forEach{ $0.didReceive(request: request, response: response, data: result) }
            switch result {
            case .success(let data):    return .success(data)
            case .failure(let error):   return .failure(error)
            }
        }
    }

    private static func customLogicErrorHandler(code: Int, msg: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : msg.isEmpty ? "error need review" : msg]
        let error = NSError(domain: "com.acdm", code: code, userInfo: userInfo)
        return error
    }
}

