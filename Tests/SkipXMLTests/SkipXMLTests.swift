// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import XCTest
import Foundation
import SkipXML

@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 8, *)
final class SkipXMLTests: XCTestCase {
    func testSkipXML() throws {
        func roundtrip(xml: String) throws -> String {
            try XMLNode.parse(data: xml.data(using: String.Encoding.utf8)!).xmlString()
        }

        XCTAssertEqual(try roundtrip(xml: #"<a/>"#), """
        <?xml version="1.0" encoding="UTF-8"?><a></a>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<x><y a="1" b="true"><z>txt</z></y></x>"#), """
//        <?xml version="1.0" encoding="UTF-8"?><x><y a="1" b="true"><z>txt</z></y></x>
//        """)
    }

}
