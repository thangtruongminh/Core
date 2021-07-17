    import XCTest
    @testable import Log
    
    final class LogTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
        }
        func testPerformanceExample() throws {
            // This is an example of a performance test case.
            
            self.measure {
                (0...1000).forEach { num in
                        Log.info(items: [num])
                }
                print(Thread.current)
                (0...1000).forEach{
                    print($0)
                }
                
                
            }
        }
        
    }
