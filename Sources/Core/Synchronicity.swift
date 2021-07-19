import Foundation

public protocol AsyncFunctions: AnyObject { }

public extension AsyncFunctions {
    
    func async(label: String = #function, attributes: DispatchQueue.Attributes = [], _ code: @escaping (Self) -> ()) {
        DispatchQueue(label:"com.bigzero.\(label)",attributes: attributes).async { [weak self] in
            guard let self = self else { return }
            code(self)
        }
    }
    
    
    // Perform two blocking calls on separate threads and get their results
    func execute<A, B>(_ f: @escaping (() throws -> (A)), _ g: @escaping (() throws -> (B))) -> (Result<A, Error>, Result<B, Error>) {

        var result1: Result<A, Error>!
        var result2: Result<B, Error>!
        let semaphore1 = DispatchSemaphore(value: 0)
        let semaphore2 = DispatchSemaphore(value: 0)

        DispatchQueue(label: #function+"execute-1").async {
            do { result1 = .success(try f()) }
            catch { result1 = .failure(error) }
            semaphore1.signal()
        }

        DispatchQueue(label: #function+"execute-2").async {
            do { result2 = .success(try g()) }
            catch { result2 = .failure(error) }
            semaphore2.signal()
        }

        semaphore1.wait()
        semaphore2.wait()

        if result1 == nil { assertionFailure("Impossible condition") }
        if result2 == nil { assertionFailure("Impossible condition") }

        return (result1!, result2!)
    }
}
