import Foundation

class Json {
    static func parse(_ string: String) -> Any? {
        do {
            return try JSONSerialization.jsonObject(
                with: string.data(using: .utf8)!,
                options: .mutableContainers)
        } catch {
            print("[Json] unable to parse json: \(error)")
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
            print("[Json] unable to dump json: \(error)")
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
}
