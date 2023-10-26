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
        // parse then re-serialize the given XML String
        func roundtrip(xml: String) throws -> String {
            let xmlData = xml.data(using: String.Encoding.utf8) ?? Data()
            let str = try XMLNode.parse(data: xmlData, options: [.processNamespaces]).xmlString()
            #if os(macOS)
            // when running on macOS, use the built-in XMLDocument's serialization and compare the  output
            let str2 = try XMLDocument(data: xmlData).xmlData(options: [.nodePreserveCDATA])
            let xmlStr2 = String(data: str2, encoding: .utf8)
            //return xmlStr2 ?? ""
            XCTAssertEqual(str, xmlStr2, "XMLNode serialization should match XMLDocument")
            #endif
            return str
        }

        XCTAssertEqual(try roundtrip(xml: #"<a/>"#), """
        <?xml version="1.0"?><a></a>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<x><y a="1" b="true"><z>txt</z></y></x>"#), """
        <?xml version="1.0"?><x><y a="1" b="true"><z>txt</z></y></x>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<tag><![CDATA[ABC]]></tag>"#), """
//        <?xml version="1.0"?><tag><![CDATA[ABC]]></tag>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<root></root>"#), """
        <?xml version="1.0"?><root></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root>This is some text.</root>"#), """
        <?xml version="1.0"?><root>This is some text.</root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><child1>Value 1</child1><child2>Value 2</child2></root>"#), """
        <?xml version="1.0"?><root><child1>Value 1</child1><child2>Value 2</child2></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root attribute1="value1" attribute2="value2"></root>"#), """
        <?xml version="1.0"?><root attribute1="value1" attribute2="value2"></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root />"#), """
        <?xml version="1.0"?><root></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><!-- This is a comment --></root>"#), """
        <?xml version="1.0"?><root><!-- This is a comment --></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<tag><!-- comment --></tag>"#), """
        <?xml version="1.0"?><tag><!-- comment --></tag>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root><![CDATA[This is CDATA text.]]></root>"#), """
//        <?xml version="1.0"?><root>This is CDATA text.</root>
//        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root xmlns="http://example.com"><child>Value</child></root>"#), """
//        <?xml version="1.0"?><root xmlns="http://example.com"><child>Value</child></root>
//        """)

//        XCTAssertEqual(try roundtrip(xml: #"<?xml version="1.0"?><root></root>"#), """
//        <?xml version="1.0" standalone="yes"?><root></root>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<root>5 &gt; 2</root>"#), """
        <?xml version="1.0"?><root>5 &gt; 2</root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root>This is <em>emphasized</em> text.</root>"#), """
        <?xml version="1.0"?><root>This is <em>emphasized</em> text.</root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root></root>"#), """
        <?xml version="1.0"?><root></root>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<!DOCTYPE root><root></root>"#), """
//        <?xml version="1.0"?>\n<!DOCTYPE root>\n<root></root>
//        """)

        #if !SKIP
        XCTAssertEqual(try roundtrip(xml: "<root>Line 1\nLine 2</root>"), """
        <?xml version="1.0"?><root>Line 1\nLine 2</root>
        """)
        #endif

        XCTAssertEqual(try roundtrip(xml: #"<root>&lt; &gt; &amp; &apos; &quot;</root>"#), """
        <?xml version="1.0"?><root>&lt; &gt; &amp; ' "</root>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root xmlns="http://example.com"><child>Value</child></root>"#), """
//        <?xml version="1.0"?><root xmlns="http://example.com"><child>Value</child></root>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><integer>42</integer><boolean>true</boolean><string>Hello, world!</string></root>"#), """
        <?xml version="1.0"?><root><integer>42</integer><boolean>true</boolean><string>Hello, world!</string></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><item id="1">First Item</item><item id="2">Second Item</item></root>"#), """
        <?xml version="1.0"?><root><item id="1">First Item</item><item id="2">Second Item</item></root>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root><item xmlns="http://example.com">Item 1</item><item xmlns="http://example.com">Item 2</item></root>"#), """
//        <?xml version="1.0"?><root><item xmlns="http://example.com">Item 1</item><item xmlns="http://example.com">Item 2</item></root>
//        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root xmlns:ns1="http://www.example.com/ns1" xmlns:ns2="http://www.example.com/ns2"><element1><ns1:subelement1>value1</ns1:subelement1><ns2:subelement2>value2</ns2:subelement2></element1></root>"#), """
//        <?xml version="1.0"?><root xmlns:ns1="http://www.example.com/ns1" xmlns:ns2="http://www.example.com/ns2"><element1><ns1:subelement1>value1</ns1:subelement1><ns2:subelement2>value2</ns2:subelement2></element1></root>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><element1><subelement1><subsubelement1>value1</subsubelement1></subelement1><subelement2><subsubelement2>value2</subsubelement2></subelement2></element1></root>"#), """
        <?xml version="1.0"?><root><element1><subelement1><subsubelement1>value1</subsubelement1></subelement1><subelement2><subsubelement2>value2</subsubelement2></subelement2></element1></root>
        """)
    }

}
