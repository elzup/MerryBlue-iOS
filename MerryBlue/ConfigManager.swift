import Foundation

class ConfigManager {
    static private let configNameKey = "name"
    static private let configListIdKey = "listid"
    
    static func setName(text: String) {
        updateData(configNameKey, value: text)
    }
    static func getName() -> String? {
        return selectData(configNameKey) as? String
    }
   
    static func setListId(id: String) {
        updateData(configListIdKey, value: id)
    }
    
    static func getListId() -> String? {
        return selectData(configListIdKey) as? String
    }
    
    static func selectData(key: String) -> AnyObject? {
        let defaults = self.getDefaults()
        return defaults.objectForKey(key)
    }
    
    static func updateData(key: String, value: AnyObject) {
        let defaults = self.getDefaults()
        defaults.setObject(value, forKey: key)
        defaults.synchronize()
    }
    
    static func getDefaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
}