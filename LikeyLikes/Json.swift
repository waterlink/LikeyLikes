import Foundation

class Json {
    static func parse(_ string: String) -> Any? {
        do {
            return try JSONSerialization.jsonObject(
                with: string.data(using: .utf8)!,
                options: .mutableContainers)
        } catch {
            print("[Json] unable to parse json: \(error); string='\(string)'")
            return nil
        }
    }
    
    static func dump(_ data: Any) -> String? {
        if let dataString = data as? String {
            return dataString
        }
        
        do {
            let result = try JSONSerialization.data(
                withJSONObject: data,
                options: JSONSerialization.WritingOptions())
            
            return encode(data: result)
        } catch {
            print("[Json] unable to dump json: \(error); data='\(data)'")
            return nil
        }
    }
    
    private static func encode(data: Data) -> String? {
        guard let string = String(
            data: data,
            encoding: .utf8) else {
                print("[Json] unable to encode json data to string")
                return nil
        }
        
        return string
    }
    
    static func query(_ data: Any, at expression: String) -> Any? {
        var json: Any? = data
        
        let parts = expression.components(separatedBy: ".")
        
        parts.forEach { part in
            if part != "" {
                json = (json as? [String: Any])?[part] as Any?
            }
        }
        
        return json
    }
}
