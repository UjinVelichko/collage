/*
 * Created by Ujin Velichko.
 * Copyright (c) UranCompany. All rights reserved.
 */

import ObjectMapper

final class JSONParser {
    static func loadJSON<T: Mappable>(name: String,
                                      result type: T.Type,
                                      onSuccess: (( _ parsedResponce: T) -> ())?,
                                      onError: (( _ error: Error) -> ())?) {
        DispatchQueue.global().async {
            do {
                let JSON = try getJSONFromFile(name)
                
                if let parsedResult = mapJSON(json: JSON, parsedObjectType: T.self) {
                    onSuccess?(parsedResult)
                } else { onError?(JSONParserError.mapObject(String(describing: T.self), name)) }
            } catch { onError?(error) }
        }
    }

    private static func getJSONFromFile(_ name: String) throws -> Any {
        guard let path = Bundle.main.path(forResource: name, ofType: "json") else {
            throw JSONParserError.invalidFileName(name)
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            let data = try Data(contentsOf: url)
            
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch { throw error }
    }
    
    
    private static func mapJSON<T: Mappable>(json: Any, parsedObjectType: T.Type) -> T? {
        return Mapper<T>().map(JSONObject: json)
    }
}
