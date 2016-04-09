import Foundation

extension String {
    ///  在字符串前拼接文档目录
    func documentPath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last as! String
        
        return (path as NSString).stringByAppendingPathComponent(self)
    }
    
    ///  在字符串前拼接缓存目录
    func cachePath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).last as! String
        
        return (path as NSString).stringByAppendingPathComponent(self)
    }
    
    ///  在字符串前拼接临时目录
    func tempPath() -> String {
        return (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(self)
    }
}