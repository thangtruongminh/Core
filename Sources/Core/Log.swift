
import Foundation
public typealias JSON = [String: Any]
public class Log: AsyncFunctions {
    static let shared                           = Log()
    private let dateString                      : String
    private let documentsURL                    : URL
    private let dateFormatter                   : DateFormatter
    private var oldtime                         : Date = Date()
    private var duration                        : TimeInterval = 300
    private var logDataTemp                     : Dictionary<LogLevel,[LogEntity]> = [:]
    private var logFilePathDict                 : Dictionary<LogLevel, String>     = [:]
    private var timerDict                       : Dictionary<LogLevel, Timer>      = [:]
    private var semaphore1                      = DispatchSemaphore(value: 1)
    private var previousMemory                  : UInt64!

    private enum LogLevel: String {
        case info
        case error
        case success
        case usedMemory
        func getPath(documentsURL: URL, dateString: String) -> String {
            let logLevelName = self.rawValue
            let filename = "Log_" + logLevelName + dateString + ".txt"
            return documentsURL.appendingPathComponent(filename).path
        }
        var indicator: String {
            switch self {
            case .info:
                return ""
            case .success:
                return "✅"
            case .error:
                return "🔴"
            case .usedMemory:
                return "💿"
            }
        }
    }
    private init () {
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateString = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZ"
        dateFormatter.locale = NSLocale.system
        documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("DocumentPath: " , documentsURL.path)
        previousMemory = getUsedMemorySize()
    }
    


    private func log(logLevel: LogLevel, file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, items: [Any], completion: (()-> Void)? = nil) {
        let newtime = Date()
        async(attributes: .concurrent) {[weak self] _ in
            guard let self = self else {return}
            func createPrintOutString() -> String {
                let dateTime = self.dateFormatter.string(from: newtime)
                let itemString = items.map { String(describing: $0) }.joined(separator: " ")
                let filename = file.split(separator: "/").dropFirst(3).joined(separator: "/")
                let content = itemString.count == 0 ? "" : "\t\(itemString)"
                let delta = String(describing: self.oldtime.timeIntervalSince(newtime)).prefix(6)
                return "\n\(dateTime)(\(delta))\t\(filename) \(function)(line:\(line - 1)) \(logLevel.indicator) \(thread.isMainThread ? "MainThread": "") \(content)"
            }
            let printOutString = createPrintOutString()
            print(printOutString)
            let newLogEntity = LogEntity(date: newtime, content: printOutString)
            self.semaphore1.wait()
            if self.logDataTemp[logLevel] == nil {
                self.logDataTemp[logLevel] = []
            }
            self.logDataTemp[logLevel]?.append(newLogEntity)
            self.oldtime = Date()
            self.writeToFile(logLevel: logLevel, completion: completion)
            self.semaphore1.signal()
        }
    }
    
    private func writeToFile(logLevel: LogLevel, completion: (()-> Void)? = nil) {
        DispatchQueue.main.async {
            if let timer = self.timerDict[logLevel], timer.isValid {
                timer.invalidate()
            }
            self.timerDict[logLevel] = Timer.scheduledTimer(
                withTimeInterval: self.duration / 1000, repeats: false, block: { [weak self] _ in
                    guard let self = self else {return}
                    let logdata = self.logDataTemp[logLevel]
                    self.logDataTemp[logLevel]?.removeAll()
                    let content = logdata?.sorted{ $0.date < $1.date}.reduce("") { result, logEntity in
                        result + logEntity.content + "\n"
                    }
                    if self.logFilePathDict[logLevel] == nil {
                        self.logFilePathDict[logLevel] = logLevel.getPath(documentsURL: self.documentsURL, dateString: self.dateString)
                    }
                    content?.writeToFile(path: self.logFilePathDict[logLevel]!)
                    completion?()
                })
        }
        
    }
    public static func infoUsedMemory(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, srcId: String, completion: (()-> Void)? = nil) {
        let usedMemory: UInt64 = Log.shared.getUsedMemorySize()
        Log.shared.log(logLevel: .usedMemory, file: file, function: function, line: line, thread: thread, items: ["srcId:", srcId, "usedMemory:", usedMemory, "KB","(\(usedMemory - Log.shared.previousMemory))"], completion: completion)

    }
    
    public static func info(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, completion: (()-> Void)? = nil) {
        Log.shared.log(logLevel: .info, file: file, function: function, line: line, thread: thread, items: [""], completion: completion)
    }
    public static func info(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, _ content: String, completion: (()-> Void)? = nil) {
        Log.shared.log(logLevel: .info, file: file, function: function, line: line, thread: thread, items: [content], completion: completion)
    }
    
    public static func info(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, items: [Any], completion: (()-> Void)? = nil) {
        Log.shared.log(logLevel: .info, file: file, function: function, line: line, thread: thread, items: items, completion: completion)
    }

    
    public static func error(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, items: [Any], completion: (()-> Void)? = nil) {
        Log.shared.log(logLevel: .error, file: file, function: function, line: line, thread: thread, items: items, completion: completion)
    }
    
    public static func error(file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, _ content: String, completion: (()-> Void)? = nil) {
        Log.shared.log(logLevel: .error , file: file, function: function, line: line, thread: thread, items: [content], completion: completion)
    }
    public static func success(file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, items: [Any], completion: (()-> Void)? = nil) {
        Log.shared.log(logLevel: .success , file: file, function: function, line: line, thread: thread, items: items, completion: completion)
    }
    public static func success(file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, _ content: String, completion: (()-> Void)? = nil) {
        Log.shared.log(logLevel: .success , file: file, function: function, line: line, thread: thread, items: [content], completion: completion)
    }
    
    public static func requestSuccess<R: Codable>(file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, thread: Thread = Thread.current, request: URLRequest, parameters: JSON? = nil, response: R, completion: (()-> Void)? = nil) {
        let method = String(describing:request.httpMethod)
        var headers = ""
        do {
            headers = try request.allHTTPHeaderFields?.toJsonString() ?? ""
        } catch {
            Log.error(items: ["parse headers:", error.localizedDescription])
        }
        
        var parametersString = ""
        do {
            parametersString = try parameters?.toJsonString() ?? ""
        } catch {
            Log.error(items: ["parse parametersString:", error.localizedDescription])
        }
        let url = request.url?.absoluteString ?? ""
        var responseString: String = ""
        
        do {
            let dict = try response.toDictionary()
            responseString = try dict.toJsonString()
        } catch {
            Log.error(items: ["parse responseString:", error.localizedDescription])
        }
        let logInfo = """
        Success Method ⇢ \(method)) ⚡️ URL ⇢ \(url)
        ✨Header ⇢ \(headers)
        ✨Parameters ⇢ \(parametersString)
        ✨Response ⇢ \(responseString)
        """
        Log.success(file: file, function: function, line: line, thread: thread, logInfo, completion: completion)
        
    }
    
    public static func requestError(file: String = #file, function: String = #function, line: Int = #line, column: Int = #column, thread: Thread = Thread.current, request: URLRequest, parameters: JSON? = nil, error: Error, completion: (()-> Void)? = nil) {
        let method = String(describing:request.httpMethod)
        var headers = ""
        do {
            headers = try request.allHTTPHeaderFields?.toJsonString() ?? ""
        } catch {
            Log.error(items: ["parse headers:", error.localizedDescription])
        }
        
        var parametersString = ""
        do {
            parametersString = try parameters?.toJsonString() ?? ""
        } catch {
            Log.error(items: ["parse parametersString:", error.localizedDescription])
        }
        let url = request.url?.absoluteString ?? ""
       
        let logInfo = """
        Failure Method ⇢ \(method)) ⚡️ URL ⇢ \(url)
        ✨Header ⇢ \(headers)
        ✨Parameters ⇢ \(parametersString)
        ✨Error ⇢ \(error.localizedDescription)
        """
        Log.error(file: file, function: function, line: line, thread: thread, logInfo, completion: completion)
    }
    
    private func getUsedMemorySize() -> UInt64 {
        // タスク情報からメモリ情報を取得
        var taskInfo = mach_task_basic_info()
        var count = UInt32(MemoryLayout.size(ofValue: taskInfo) / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            task_info(
                mach_task_self_,
                task_flavor_t(MACH_TASK_BASIC_INFO),
                $0.withMemoryRebound(
                    to: Int32.self,
                    capacity: 1, {pointer in UnsafeMutablePointer<Int32>(pointer)}
                ),
                &count
            )
        }
        // KBにして返す
        return result == KERN_SUCCESS ? taskInfo.resident_size / 1024: 0
    }
}

struct LogEntity {
    var date : Date = Date()
    var content: String = ""
}

extension LogEntity {
    static func > (left: LogEntity, right: LogEntity) -> Bool {
        return left.date > right.date
    }
    static func < (left: LogEntity, right: LogEntity) -> Bool {
        return left.date < right.date
    }
}
