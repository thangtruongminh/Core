
import Foundation

public class Log: AsyncFunctions {
    private static let shared = Log()

    enum LogLevel: String {
        case info
        case error
        case success
        var logFilePath: URL {
            let documentsPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let logLevelName = self.rawValue.capitalizingFirstLetter()
            let dateString = Date().toString(format: "yyyyMMdd")
            let filename = logLevelName + dateString + ".txt"
            return documentsPathURL.appendingPathComponent(filename)
        }
        var indicator: String {
            switch self {
            case .info:
                return ""
            case .success:
                return "✅"
            case .error:
                return "🔴"
            }
        }
    }
    
    var oldtime : Date = Date()
    
    init() {
        
    }
    
    private func log(logLevel: LogLevel, file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, items: [Any]) {
        let newtime = Date()
        asyncInSerialQueue {[weak self] _ in
            let dateTime = newtime.toString()
            let itemString = items.map { String(describing: $0) }.joined(separator: " ")
            let filename = file.split(separator: "/").dropFirst(3).joined(separator: "/")
            let content = itemString.count == 0 ? "" : "\t\(itemString)"
            let delta = String(describing: newtime.timeIntervalSince(self!.oldtime)).prefix(6)
            let printOutString = "\n\(dateTime)(\(delta))\t\(filename) \(function)(line:\(line - 1)) \(logLevel.indicator)thread: \(thread.name ?? "")\(content)"
            print(printOutString)
            self?.writeToFile(logLevel: .info, content: printOutString)
            self?.oldtime = Date()
            
        }
    }
    
    private func writeToFile(logLevel: LogLevel, content: String) {
            let file = logLevel.logFilePath.path
            guard let data = content.data(using: String.Encoding.utf8) else {return}

            if FileManager.default.fileExists(atPath: file) == false {
                print(file, "is creating....")
                if FileManager.default.createFile(atPath: file, contents: nil, attributes: nil) {
                    print(file, "is created")
                }
            }
            let fileHandle = FileHandle(forWritingAtPath: file)
            fileHandle?.seekToEndOfFile()
            fileHandle?.write(data)
            fileHandle?.closeFile()
    }
    
    
    
    public static func info(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, content: String = "") {
        Log.shared.log(logLevel: .info, file: file, function: function, line: line , items: [content])
    }
    
    public static func info(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, items: [Any]) {
        Log.shared.log(logLevel: .info, file: file, function: function, line: line , items: items)
    }

    
    public static func error(file: String = #file, function: String = #function, line: Int = #line,thread: Thread = Thread.current, items: [Any]) {
        Log.shared.log(logLevel: .error, file: file, function: function, line: line , items: items)
    }
    
    public static func error(file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, content: String = "") {
        Log.shared.log(logLevel: .error , file: file, function: function, line: line , items: [content])
    }
    public static func success(file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, items: [Any]) {
        Log.shared.log(logLevel: .success , file: file, function: function, line: line , items: items)
    }
    public static func success(file: String = #file, function: String = #function, line: Int = #line, thread: Thread = Thread.current, content: String = "") {
        Log.shared.log(logLevel: .success , file: file, function: function, line: line , items: [content])
    }
}
