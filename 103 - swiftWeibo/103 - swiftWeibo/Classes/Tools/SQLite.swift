import Foundation

class SQLite {
    
    /// 单例
    private static let instance = SQLite()
    class var sharedSQLite: SQLite {
        return instance
    }
    
    /// database_connection 对象
    var db: COpaquePointer = nil;
    
    ///  打开数据库
    func openDatabase(dbName: String) -> Bool {
        let path = dbName.documentPath()
        print(path)
        if (sqlite3_open(path.cStringUsingEncoding(NSUTF8StringEncoding)!, &db) == SQLITE_OK) {
            return createTable()
        } else {
            return false
        }
    }
    
    ///  创建数据表
    private func createTable() -> Bool {
        var result = false
        let sql = "CREATE TABLE IF NOT EXISTS T_Status ( \n" +
        "id integer NOT NULL, \n" +
        "text TEXT NOT NULL DEFAULT '', \n" +
        "source TEXT NOT NULL DEFAULT '', \n" +
        "created_at TEXT NOT NULL DEFAULT '', \n" +
        "reposts_count INTEGER NOT NULL DEFAULT 0, \n" +
        "comments_count INTEGER NOT NULL DEFAULT 0, \n" +
        "attitudes_count INTEGER NOT NULL DEFAULT 0, \n" +
        "userId INTEGER NOT NULL DEFAULT 0, \n" +
        "retweetedId INTEGER NOT NULL DEFAULT 0, \n" +
        "refresh INTEGER NOT NULL DEFAULT 0, \n" +
        "PRIMARY KEY(id) \n" +
        "); \n" +
        "CREATE TABLE IF NOT EXISTS T_StatusPic ( \n" +
        "id INTEGER NOT NULL, \n" +
        "statusId INTEGER NOT NULL DEFAULT 0, \n" +
        "thumbnail_pic text NOT NULL DEFAULT ‘’, \n" +
        "PRIMARY KEY(id) \n" +
        "); \n" +
        "CREATE TABLE IF NOT EXISTS T_User ( \n" +
        "id integer NOT NULL, \n" +
        "screen_name TEXT NOT NULL DEFAULT '', \n" +
        "name TEXT NOT NULL DEFAULT '', \n" +
        "profile_image_url TEXT NOT NULL DEFAULT '', \n" +
        "avatar_large TEXT NOT NULL DEFAULT '', \n" +
        "created_at TEXT NOT NULL DEFAULT '', \n" +
        "verified INTEGER NOT NULL DEFAULT 0, \n" +
        "mbrank INTEGER NOT NULL DEFAULT 0, \n" +
        "PRIMARY KEY(id) \n" +
        ");"
        
        return execSQL(sql)
    }
    
    ///  执行单条语句查询语句
    func execSQL(sql: String) -> Bool {
        return sqlite3_exec(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, nil, nil, nil) == SQLITE_OK
    }
    
    ///  执行返回结果数量
    func execCount(sql: String) -> Int {
        let record = execRecordSet(sql)
        
        return (record[0] as! [AnyObject])[0] as! Int
    }
    
    ///  执行返回单条记录
    func execRow(sql: String) -> [AnyObject]? {
        let record = execRecordSet(sql)
        
        if record.count > 0 {
            return (record[0] as! [AnyObject])
        } else {
            return nil
        }
    }
    
    ///  执行 SQL 返回结果集合
    func execRecordSet(sql: String) -> [AnyObject] {
        
        // 1. 准备 sql
        var stmt: COpaquePointer = nil

        var recordList = [AnyObject]()
        if sqlite3_prepare_v2(db, sql.cStringUsingEncoding(NSUTF8StringEncoding)!, -1, &stmt, nil) == SQLITE_OK {
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                recordList.append(rowData(stmt))
            }
        }
        
        // 释放语句
        sqlite3_finalize(stmt)
        
        return recordList
    }
        
    /// 返回一行数据数组
    private func rowData(stmt: COpaquePointer) -> [AnyObject] {
        
        var array = [AnyObject]()
        for i in 0..<sqlite3_column_count(stmt) {

            switch sqlite3_column_type(stmt, i) {
            case SQLITE_FLOAT:
                array.append(sqlite3_column_double(stmt, i))
            case SQLITE_INTEGER:
                array.append(Int(sqlite3_column_int64(stmt, i)))
            case SQLITE_TEXT:
                let chars: UnsafePointer<CChar> = (UnsafePointer<CChar>)(sqlite3_column_text(stmt, i))
                array.append(String.fromCString(chars)!)
            case SQLITE_NULL:
                array.append(NSNull())
            case let type:
                print("不支持的类型 \(type)")
            }
        }
        return array
    }
}