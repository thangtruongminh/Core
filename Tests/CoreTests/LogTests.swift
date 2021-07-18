    import XCTest
    @testable import Core
    
    final class LogTests: XCTestCase {
        func testExample() {
            Log.info()

        }
        func testPerformanceExample() throws {
            // This is an example of a performance test case.

            self.measure {
                let expectation = XCTestExpectation(description: "Update store profile")

                (0...1000).forEach { num in
                    switch num % 3 {
                    case 0 :
                        Log.info(items: [num]) {
                            expectation.fulfill()
                        }
                    case 1:
                        Log.error(items: [num]) {
                            expectation.fulfill()
                        }
                    case 2:
                        Log.success(items: [num]) {
                            expectation.fulfill()
                        }
                    default:
                        return
                    }
                    
                }
                (0...1000).forEach{
                    print($0)
                }
                wait(for: [expectation], timeout: 20.0)
                
            }
        }
        
    }
