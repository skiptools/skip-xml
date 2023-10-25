import XCTest
import OSLog
import Foundation
import SkipFFI

#if !SKIP
import libxml2
#else
let libxml2: LibXMLLibrary = com.sun.jna.Native.load("xml2", (LibXMLLibrary.self as kotlin.reflect.KClass).java)
#endif

let logger: Logger = Logger(subsystem: "SkipXML", category: "Tests")

@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 8, *)
final class SkipXMLTests: XCTestCase {
    func testSkipXML() throws {
        XCTAssertEqual(1 + 2, 3, "basic test")
    }
    
    func testLibXMLJNA() throws {
        libxml2.xmlInitParser()
        libxml2.xmlCleanupParser()
    }

    func testSimpleDarwinJNA() throws {
        #if SKIP
        /// A fake "Darwin" namespace atop Android's Bionic libc via JNA FFI
        let Darwin: BionicDarwin = com.sun.jna.Native.load("c", (BionicDarwin.self as kotlin.reflect.KClass).java)
        #endif

        XCTAssertEqual(12, Darwin.abs(-12))
        Darwin.free(Darwin.malloc(8))

        XCTAssertNotNil(Darwin.getenv("PATH"), "PATH environment should be set for getenv")
        XCTAssertNil(Darwin.getenv("PATH_DOES_NOT_EXIST"), "non-existent key should not return a value for getenv")
    }
}

#if SKIP


// MARK: LibXMLLibrary

protocol LibXMLLibrary : com.sun.jna.Library {
    func xmlInitParser()
    func xmlCleanupParser()
}

// MARK: BionicDarwin

protocol BionicDarwin : com.sun.jna.Library {
    func abs(_ value: Int32) -> Int32

    func malloc(_ size: Int32) -> OpaquePointer
    func free(_ ptr: OpaquePointer) -> Int32

    func getenv(_ key: String) -> String?
}
#endif

