// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
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

    func testParseString() throws {
        let node = try XMLNode.parse(string: "<root><child>Hello</child></root>")
        XCTAssertEqual(node.elementChildren.count, 1)
        let root = node.elementChildren[0]
        XCTAssertEqual(root.elementName, "root")
        XCTAssertEqual(root.elementChildren[0].stringContent, "Hello")
    }

    func testChildElementsNamed() throws {
        let node = try XMLNode.parse(string: "<root><item>A</item><other>B</other><item>C</item></root>")
        let root = node.elementChildren[0]
        let items = root.childElements(named: "item")
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].stringContent, "A")
        XCTAssertEqual(items[1].stringContent, "C")

        let others = root.childElements(named: "other")
        XCTAssertEqual(others.count, 1)
        XCTAssertEqual(others[0].stringContent, "B")

        let missing = root.childElements(named: "nonexistent")
        XCTAssertEqual(missing.count, 0)
    }

    func testFirstChildElementNamed() throws {
        let node = try XMLNode.parse(string: "<root><a>1</a><b>2</b><a>3</a></root>")
        let root = node.elementChildren[0]

        let first = root.firstChildElement(named: "a")
        XCTAssertNotNil(first)
        XCTAssertEqual(first?.stringContent, "1")

        let b = root.firstChildElement(named: "b")
        XCTAssertNotNil(b)
        XCTAssertEqual(b?.stringContent, "2")

        XCTAssertNil(root.firstChildElement(named: "missing"))
    }

    func testDescendantsNamed() throws {
        let xml = """
        <root>
            <a>1</a>
            <b><a>2</a><c><a>3</a></c></b>
            <a>4</a>
        </root>
        """
        let node = try XMLNode.parse(string: xml)
        let root = node.elementChildren[0]

        let allAs = root.descendants(named: "a")
        XCTAssertEqual(allAs.count, 4)
        XCTAssertEqual(allAs[0].trimmedStringContent, "1")
        XCTAssertEqual(allAs[1].trimmedStringContent, "2")
        XCTAssertEqual(allAs[2].trimmedStringContent, "3")
        XCTAssertEqual(allAs[3].trimmedStringContent, "4")

        let allCs = root.descendants(named: "c")
        XCTAssertEqual(allCs.count, 1)

        XCTAssertEqual(root.descendants(named: "nonexistent").count, 0)
    }

    func testRemoveChildrenNamed() throws {
        let node = try XMLNode.parse(string: "<root><keep>A</keep><remove>B</remove><keep>C</keep><remove>D</remove></root>")
        var root = node.elementChildren[0]

        let removed = root.removeChildren(named: "remove")
        XCTAssertEqual(removed, 2)
        XCTAssertEqual(root.elementChildren.count, 2)
        XCTAssertEqual(root.elementChildren[0].elementName, "keep")
        XCTAssertEqual(root.elementChildren[1].elementName, "keep")

        let removedNone = root.removeChildren(named: "nonexistent")
        XCTAssertEqual(removedNone, 0)
        XCTAssertEqual(root.elementChildren.count, 2)
    }

    func testTrimmedStringContent() throws {
        let node = try XMLNode.parse(string: "<root>  hello world  </root>")
        let root = node.elementChildren[0]
        XCTAssertEqual(root.stringContent, "  hello world  ")
        XCTAssertEqual(root.trimmedStringContent, "hello world")
    }

    func testChildContentTrimmed() throws {
        let xml = "<person><name> Alice </name><age>30</age><city>NYC</city></person>"
        let node = try XMLNode.parse(string: xml)
        let person = node.elementChildren[0]

        XCTAssertEqual(person.childContentTrimmed(forElementName: "name"), "Alice")
        XCTAssertEqual(person.childContentTrimmed(forElementName: "age"), "30")
        XCTAssertEqual(person.childContentTrimmed(forElementName: "city"), "NYC")
        XCTAssertNil(person.childContentTrimmed(forElementName: "missing"))
    }
}
