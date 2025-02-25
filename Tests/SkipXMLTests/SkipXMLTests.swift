// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import XCTest
import Foundation
import SkipXML

@available(macOS 13, macCatalyst 16, iOS 16, tvOS 16, watchOS 8, *)
final class SkipXMLTests: XCTestCase {
    func testSkipXML() throws {
        // parse then re-serialize the given XML String
        func roundtrip(xml: String, options: SkipXML.XMLNode.Options = [], verify: Bool = true) throws -> String {
            let xmlData = xml.data(using: String.Encoding.utf8) ?? Data()
            let node = try XMLNode.parse(data: xmlData, options: options)
            let str = node.xmlString(declaration: nil) // omit <?xml version="1.0" standalone="yes"?>
            #if os(macOS)
            // when running on macOS, use the built-in XMLDocument's serialization and compare the  output
            let str2 = try XMLDocument(data: xmlData).xmlData(options: [.nodePreserveCDATA])
            var xmlStr2 = String(data: str2, encoding: .utf8) ?? ""
            xmlStr2 = xmlStr2.replacingOccurrences(of: #"<?xml version="1.0"?>"#, with: "")
            xmlStr2 = xmlStr2.replacingOccurrences(of: #"<?xml version="1.0" standalone="yes"?>"#, with: "")
            //print(xmlStr2 ?? "")
            if verify { // only verify if we are instructed to do so
                XCTAssertEqual(str, xmlStr2, "XMLNode serialization should match XMLDocument")
            }
            #endif
            return str
        }

        func resource(named name: String) throws -> String {
            let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: nil))
            return try String(contentsOf: url)
        }

        XCTAssertEqual(try roundtrip(xml: #"<a/>"#), """
        <a></a>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<x><y a="1" b="true"><z>txt</z></y></x>"#), """
        <x><y a="1" b="true"><z>txt</z></y></x>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<tag><![CDATA[ABC]]></tag>"#), """
//        <tag><![CDATA[ABC]]></tag>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<root></root>"#), """
        <root></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root>This is some text.</root>"#), """
        <root>This is some text.</root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><child1>Value 1</child1><child2>Value 2</child2></root>"#), """
        <root><child1>Value 1</child1><child2>Value 2</child2></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root attribute1="value1" attribute2="value2"></root>"#), """
        <root attribute1="value1" attribute2="value2"></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root />"#), """
        <root></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><!-- This is a comment --></root>"#), """
        <root><!-- This is a comment --></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<tag><!-- comment --></tag>"#), """
        <tag><!-- comment --></tag>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root><![CDATA[This is CDATA text.]]></root>"#), """
//        <root>This is CDATA text.</root>
//        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root xmlns="http://example.com"><child>Value</child></root>"#), """
//        <root xmlns="http://example.com"><child>Value</child></root>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<?xml version="1.0"?><root></root>"#), """
        <root></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root>5 &gt; 2</root>"#), """
        <root>5 &gt; 2</root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root>This is <em>emphasized</em> text.</root>"#), """
        <root>This is <em>emphasized</em> text.</root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root></root>"#), """
        <root></root>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<!DOCTYPE root><root></root>"#), """
//        <!DOCTYPE root>\n<root></root>
//        """)

        #if !SKIP
        XCTAssertEqual(try roundtrip(xml: "<root>Line 1\nLine 2</root>"), """
        <root>Line 1\nLine 2</root>
        """)
        #endif

        XCTAssertEqual(try roundtrip(xml: #"<root>&lt; &gt; &amp; &apos; &quot;</root>"#), """
        <root>&lt; &gt; &amp; ' "</root>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root xmlns="http://example.com"><child>Value</child></root>"#), """
//        <root xmlns="http://example.com"><child>Value</child></root>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><integer>42</integer><boolean>true</boolean><string>Hello, world!</string></root>"#), """
        <root><integer>42</integer><boolean>true</boolean><string>Hello, world!</string></root>
        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><item id="1">First Item</item><item id="2">Second Item</item></root>"#), """
        <root><item id="1">First Item</item><item id="2">Second Item</item></root>
        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root><item xmlns="http://example.com">Item 1</item><item xmlns="http://example.com">Item 2</item></root>"#), """
//        <root><item xmlns="http://example.com">Item 1</item><item xmlns="http://example.com">Item 2</item></root>
//        """)

//        XCTAssertEqual(try roundtrip(xml: #"<root xmlns:ns1="http://www.example.com/ns1" xmlns:ns2="http://www.example.com/ns2"><element1><ns1:subelement1>value1</ns1:subelement1><ns2:subelement2>value2</ns2:subelement2></element1></root>"#), """
//        <root xmlns:ns1="http://www.example.com/ns1" xmlns:ns2="http://www.example.com/ns2"><element1><ns1:subelement1>value1</ns1:subelement1><ns2:subelement2>value2</ns2:subelement2></element1></root>
//        """)

        XCTAssertEqual(try roundtrip(xml: #"<root><element1><subelement1><subsubelement1>value1</subsubelement1></subelement1><subelement2><subsubelement2>value2</subsubelement2></subelement2></element1></root>"#), """
        <root><element1><subelement1><subsubelement1>value1</subsubelement1></subelement1><subelement2><subsubelement2>value2</subsubelement2></subelement2></element1></root>
        """)

        // we do not verify these documents because macOS XMLDocument has different spacing and element ordering

        XCTAssertEqual(try roundtrip(xml: resource(named: "vmap.xml"), verify: false), """
<vmap:VMAP version="1.0" xmlns:uo="uo" xmlns:vmap="http://www.iab.net/vmap-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <vmap:Extensions>
    <uo:unicornOnce></uo:unicornOnce>
    <uo:contentImpressions></uo:contentImpressions>
    <uo:requestParameters></uo:requestParameters>
  </vmap:Extensions>
</vmap:VMAP>
""")

        // check again with namespace processing enabled (which is not currently represented in the output)
        XCTAssertEqual(try roundtrip(xml: resource(named: "vmap.xml"), options: [.processNamespaces], verify: false), """
<VMAP version="1.0">
  <Extensions>
    <unicornOnce></unicornOnce>
    <contentImpressions></contentImpressions>
    <requestParameters></requestParameters>
  </Extensions>
</VMAP>
""")

        XCTAssertEqual(try roundtrip(xml: resource(named: "ocf.xml"), verify: false), """
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"></rootfile>
  </rootfiles>
  
  <metadata xmlns="http://purl.org/dc/elements/1.1/">
    <identifier id="pub-id">urn:uuid:pubid</identifier>
  </metadata>
</container>
""")

        XCTAssertEqual(try roundtrip(xml: resource(named: "atom.xml"), verify: false), """
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <title>Example Feed</title>
  <subtitle>A subtitle.</subtitle>
  <link href="http://example.org/feed/" rel="self"></link>
  <link href="http://example.org/"></link>
  <id>urn:uuid:60a76c80-d399-11d9-b91C-0003939e0af6</id>
  <updated>2003-12-13T18:30:02Z</updated>
  <entry>
    <title>Atom-Powered Robots Run Amok</title>
    <dc:language>en-us</dc:language>
    <link href="http://example.org/2003/12/13/atom03"></link>
    <link href="http://example.org/2003/12/13/atom03.html" rel="alternate" type="text/html"></link>
    <link href="http://example.org/2003/12/13/atom03/edit" rel="edit"></link>
    <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
    <updated>2003-12-13T18:30:02Z</updated>
    <summary>Some text.</summary>
    <author>
      <name>John Doe</name>
      <email>johndoe@example.com</email>
    </author>
  </entry>
</feed>
""")

        // this is a big file (207K), so we don't verify the actual contents
        let xmlContents = try roundtrip(xml: resource(named: "xml.xml"), verify: false)
        XCTAssertTrue(xmlContents.contains("The XML design should be prepared quickly"))

    }
}
