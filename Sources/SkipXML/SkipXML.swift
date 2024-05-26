// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if canImport(FoundationXML)
import class FoundationXML.XMLParser
import protocol FoundationXML.XMLParserDelegate
#elseif canImport(Foundation)
import class Foundation.XMLParser
import protocol Foundation.XMLParserDelegate
#endif

import Foundation

#if !SKIP
import class ObjectiveC.NSObject
typealias ParserDelegateType = XMLParserDelegate
typealias LexicalDelegateType = NSObject
typealias XMLParserType = XMLParser
#else
typealias ParserDelegateType = org.xml.sax.helpers.DefaultHandler
typealias LexicalDelegateType = org.xml.sax.ext.LexicalHandler
typealias XMLParserType = Void
#endif

/// An XML Element Document, which is an in-memory tree representation
/// of the contents of an XML source.
public struct XMLNode : Hashable {
    public enum Errors : Error {
        case unknownParseError
        case badElementCount(Int)
    }

    public struct Entity : OptionSet {
        /// The format's default value.
        public let rawValue: UInt

        /// Creates an Entity value with the given raw value.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static var lt: Entity { return Entity(rawValue: UInt(1) << 0) }
        public static var amp: Entity { return Entity(rawValue: UInt(1) << 1) }
        public static var gt: Entity { return Entity(rawValue: UInt(1) << 2) }
        public static var quot: Entity { return Entity(rawValue: UInt(1) << 3) }
        public static var apos: Entity { return Entity(rawValue: UInt(1) << 4) }
    }

    public var elementName: String
    public var attributes: [String : String]
    public var children: [Child]
    public var namespaceURI: String?
    public var qualifiedName: String?
    public var namespaces: [String: String]?

    /// This is the document root, which is the only one that permits an empty element name
    public var isDocument: Bool { return elementName == "" }

    /// Returns all the children of this tree that are element nodes
    public var elementChildren: [XMLNode] {
        return children.compactMap { child in
            if case .element(let element) = child {
                return element
            } else {
                return nil
            }
        }
    }

    /// The attributes for this element
    public subscript(attribute name: String) -> String? {
        get { return attributes[name] }
        set { attributes[name] = newValue }
    }

    /// A `Child` consists of all the data strucutres that may be contained within an XML element.
    public enum Child : Hashable {
        case element(XMLNode)
        case content(String)
        case comment(String)
        case cdata(Data)
        case whitespace(String)
        case processingInstruction(target: String, data: String?)

        /// Returns the name of the node if it an element node, otherwise nil
        public var element: XMLNode? {
            if case let .element(element) = self {
                return element
            } else {
                return nil
            }
        }

        /// Returns the name of the node if it an element node, otherwise nil
        public var elementName: String? {
            element?.elementName
        }

        /// Returns the content of the node if it a content node, otherwise nil
        public var stringContent: String? {
            if case let .content(content) = self {
                return content
            } else {
                return nil
            }
        }

        /// Returns the content of the node if it a comment node, otherwise nil
        public var comment: String? {
            if case let .comment(comment) = self {
                return comment
            } else {
                return nil
            }
        }

        /// Returns the content of the node if it a cdata node, otherwise nil
        public var cdata: Data? {
            if case let .cdata(cdata) = self {
                return cdata
            } else {
                return nil
            }
        }
    }

    public init(elementName: String, attributes: [String : String] = [:], children: [Child] = [], namespaceURI: String? = nil, qualifiedName: String? = nil, namespaces: [String: String]? = nil) {
        self.elementName = elementName
        self.attributes = attributes
        self.children = children
        self.namespaceURI = namespaceURI
        self.qualifiedName = qualifiedName
        self.namespaces = namespaces
    }

    /// Appends the given tree as an element child
    public mutating func append(_ element: XMLNode) {
        self.children.append(.element(element))
    }

    /// Adds the given element to the node.
    /// - Parameters:
    ///   - elementName: the name of the element
    ///   - attributes: any attributes for the element
    ///   - content: the textual content of the element
    ///   - CDATA: whether the text content should be in a CDATA tag (default: false)
    /// - Returns: the appended XMLNode
    @discardableResult public mutating func addElement(_ elementName: String, attributes: [String: String] = [:] , content: String? = nil, CDATA: Bool = false) -> XMLNode {
        var node = XMLNode(elementName: elementName, attributes: attributes)
        if let content = content {
            if CDATA {
                node.children.append(.cdata(content.data(using: String.Encoding.utf8) ?? Data()))
            } else {
                node.children.append(.content(content))
            }
        }
        self.children.append(.element(node))
        return self
    }

    /// Returns an array of child elements with the given name and optional namespace.
    /// - Parameters:
    ///   - elementName: the element name of the child
    ///   - namespace: the list of namespaces
    /// - Returns: the filtered list of child elements matching the name and namespace URI.
//    public func childElements(named elementName: String, namespaceURI: String? = nil) -> [XMLNode] {
//        if let namespaceURI = namespaceURI {
//            // there may be more than a single alias to a given namespace
//            guard let prefixes = self.namespaces?.filter({ $0.value == namespaceURI }).keys,
//                    !prefixes.isEmpty else {
//                return []
//            }
//            let elementNames = Set(prefixes.map({ $0 + ":" + elementName }))
//            return self.elementChildren.filter { element in
//                elementNames.contains(element.elementName)
//            }
//        } else {
//            return self.elementChildren
//        }
//    }

    /// Returns the value of the given attribute, optionally mapped with the given URL
    /// - Parameters:
    ///   - key: the attribute key
    ///   - namespace: the namespace of the key
    /// - Returns: the value of the attribute
//    public func attributeValue(key: String, namespaceURI: String? = nil) -> String? {
//        if let namespaceURI = namespaceURI {
//            // there may be more than a single alias to a given namespace
//            guard let prefixes = self.namespaces?.filter({ $0.value == namespaceURI }).keys,
//                    !prefixes.isEmpty else {
//                return nil
//            }
//            for pfx in prefixes {
//                if let value = self.attributes[pfx + ":" + key] {
//                    return value
//                }
//            }
//            return nil
//        } else {
//            return self.attributes[key]
//        }
//    }


    /// Returns the string with the given XML entites escaped; the default does not include single apostrophes
    func escapedXMLEntities(content: String, entities: Entity) -> String {
        var str = ""
        #if !SKIP
        str.reserveCapacity(content.count)
        #endif
        let lt = entities.contains(.lt)
        let amp = entities.contains(.amp)
        let gt = entities.contains(.gt)
        //let quot = entities.contains(.quot)
        let apos = entities.contains(.apos)
        for char in content {
            if char == "<" && lt == true { str += "&lt;" }
            else if char == "&" && amp == true { str += "&amp;" }
            else if char == ">" && gt == true { str += "&gt;" }
            //else if char == "\"" && quot == true { str += "&quot;" }
            else if char == "'" && apos == true { str += "&apos;" }
            else { str += String(char) }
        }
        return str
    }

    public func xmlString(declaration: String = "<?xml version=\"1.0\"?>", quote: String = "\"", compactCloseTags: Bool = false, escape escapeEntities: Entity = [.lt, .amp, .gt], commentScriptCDATA: Bool = false, attributeSorter: ([String: String]) -> [(String, String)] = { Array($0).sorted(by: { $0.0 < $1.0 }) }) -> String {
        var str = ""

        // when we use single quotes for entites, we escape them; same for double-quotes
        var entities = escapeEntities
        entities.insert(quote == "\"" ? .quot : .apos)

        if isDocument {
            str += declaration // the document header is the XML declaration
        } else {
            str += "<" + elementName
            for (key, value) in attributeSorter(attributes) {
                str += " " + key + "=" + quote + escapedXMLEntities(content: value, entities: entities) + quote
            }
            if children.isEmpty && compactCloseTags {
                str += "/"
            }
            str += ">"
        }

        for child in children {
            switch child {
            case .element(let element):
                str += element.xmlString(quote: quote, compactCloseTags: compactCloseTags, escape: entities, commentScriptCDATA: commentScriptCDATA, attributeSorter: attributeSorter)
            case .content(let content):
                str += escapedXMLEntities(content: content, entities: entities)
            case .comment(let comment):
                str += "<!--" + comment + "-->"
            case .cdata(let data):
                // note that we manually replace "]]>" with "]] >" in order to prevent it from breaking the CDATA
                // this is potentially dangerous, because the code might contains "]]>" that runs in a meaningful way.
                let code = (String(data: data, encoding: String.Encoding.utf8)?.replacingOccurrences(of: "]]>", with: "]] >") ?? "")
                //dbg("CDATA", data.localizedByteCount, elementName)
                if commentScriptCDATA && elementName == "script" {
                    // https://www.w3.org/TR/html-polyglot/#dfn-safe-text-content
                    str += "//<![CDATA[\n" + code + "\n//]]>"
                } else {
                    str += "<![CDATA[" + code + "]]>"
                }
            case .whitespace(let whitespace):
                str += whitespace
            case .processingInstruction(let target, let data):
                str += "<?" + target
                if let data = data {
                    str += " " + data
                }
                str += "?>"
            }
        }

        if !isDocument && !(children.isEmpty && compactCloseTags) {
            str += "</" + elementName + ">"
        }

        return str
    }

    /// Options for configuring the `XMLParser`
    public struct Options: OptionSet, Hashable {
        public let rawValue: Int

        public static let resolveExternalEntities = Options(rawValue: 1 << 0)
        public static let reportNamespacePrefixes = Options(rawValue: 1 << 1)
        public static let processNamespaces = Options(rawValue: 1 << 2)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    /// Parses the given `Data` and returns an `XMLNode`
    public static func parse(data: Data, options: Options = [], entityResolver: ((_ name: String, _ systemID: String?) -> (Data?))? = nil) throws -> XMLNode {
        let delegate = ParserDelegate()
        if let entityResolver = entityResolver {
            delegate.entityResolver = entityResolver
        }

        #if !SKIP
        let parser = XMLParser(data: data)
        parser.shouldProcessNamespaces = options.contains(.processNamespaces)
        parser.shouldReportNamespacePrefixes = options.contains(.reportNamespacePrefixes)
        parser.shouldResolveExternalEntities = options.contains(.resolveExternalEntities)

        parser.delegate = delegate
        if parser.parse() == false {
            if let error = parser.parserError {
                throw error
            } else if let parseError = delegate.parseErrors.first {
                throw parseError
            } else if let validationError = delegate.validationErrors.first {
                throw validationError
            } else {
                throw Errors.unknownParseError
            }
        }
        #else
        // Robolectric throws: java.lang.UnsatisfiedLinkError: 'void org.apache.harmony.xml.ExpatParser.staticInitialize(java.lang.String)'
        //let xmlString = String(data: data, encoding: String.Encoding.utf8) ?? ""
        //try android.util.Xml.parse(xmlString, delegate)

        // if we don't set the system property, then we can get the error:
        // Android error: org.xml.sax.SAXException: Can't create default XMLReader; is system property org.xml.sax.driver set
        //System.setProperty("org.xml.sax.driver", "org.apache.harmony.xml.ExpatReader")
        // let reader = org.xml.sax.helpers.XMLReaderFactory.createXMLReader()
        // reader.setContentHandler(delegate)
        // reader.parse(org.xml.sax.InputSource(java.io.ByteArrayInputStream(data.platformData)))

        let parserFactory = javax.xml.parsers.SAXParserFactory.newInstance()
        parserFactory.setValidating(false) // we don't want to load external DTDs
        parserFactory.setNamespaceAware(options.contains(.processNamespaces))
        try? parserFactory.setFeature("http://xml.org/sax/features/validation", false)
        try? parserFactory.setFeature("http://apache.org/xml/features/nonvalidating/load-dtd-grammar", false)
        try? parserFactory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)
        try? parserFactory.setFeature("http://xml.org/sax/features/external-general-entities", false)
        try? parserFactory.setFeature("http://xml.org/sax/features/external-parameter-entities", false)

        let parser = parserFactory.newSAXParser()
        parser.setProperty("http://xml.org/sax/properties/lexical-handler", delegate)
        parser.parse(java.io.ByteArrayInputStream(data.platformData), delegate)

        #endif

        if delegate.elements.count != 1 {
            throw Errors.badElementCount(delegate.elements.count)
        }

        return delegate.currentElement!
    }

    /// A parser delegate that can be used with either `Foundation.XMLParserDelegate` or as a `org.xml.sax.ContentHandler`.
    class ParserDelegate : LexicalDelegateType, ParserDelegateType {
        var elements = Array<XMLNode>()
        var namespaces: [String: [String]] = [:]
        var parseErrors: [Error] = []
        var validationErrors: [Error] = []
        var entityResolver: (_ name: String, _ systemID: String?) -> (Data?) = { _, _ in nil}

        override init() {
            super.init()
        }

        /// Convenience getter/setter for the bottom of the elements stack
        var currentElement: XMLNode? {
            get {
                return elements.last
            }

            set {
                if let newValue = newValue {
                    if elements.isEmpty {
                        elements.append(newValue)
                    } else {
                        elements[elements.count-1] = newValue
                    }
                }
            }
        }

        func parserDidStartDocument(_ parser: XMLParserType) {
            // the root document is simply an empty element name
            elements.append(XMLNode(elementName: ""))
        }

        func parserDidEndDocument(_ parser: XMLParserType) {
            // we do nothing here because we hold on to the root document
        }

        func parser(_ parser: XMLParserType, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
            self.namespaces[prefix, default: []].append(namespaceURI)
        }

        func parser(_ parser: XMLParserType, didEndMappingPrefix prefix: String) {
            let _ = self.namespaces[prefix]?.popLast()
        }

        func parser(_ parser: XMLParserType, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            elements.append(XMLNode(elementName: qName ?? elementName, attributes: attributeDict, children: [], namespaceURI: namespaceURI, qualifiedName: qName, namespaces: self.namespaces.compactMapValues(\.last)))
        }

        func parser(_ parser: XMLParserType, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            if let element = elements.popLast() { // remove the last element…
                currentElement?.children.append(.element(element)) // … and add it as a child to the parent
            }
        }

        func parser(_ parser: XMLParserType, foundCharacters string: String) {
            currentElement?.children.append(.content(string))
        }

        func parser(_ parser: XMLParserType, foundIgnorableWhitespace whitespaceString: String) {
            currentElement?.children.append(.whitespace(whitespaceString))
        }

        func parser(_ parser: XMLParserType, foundProcessingInstructionWithTarget target: String, data: String?) {
            currentElement?.children.append(.processingInstruction(target: target, data: data))
        }

        func parser(_ parser: XMLParserType, foundComment comment: String) {
            currentElement?.children.append(.comment(comment))
        }

        func parser(_ parser: XMLParserType, foundCDATA CDATABlock: Data) {
            currentElement?.children.append(.cdata(CDATABlock))
        }

        func parser(_ parser: XMLParserType, resolveExternalEntityName name: String, systemID: String?) -> Data? {
            entityResolver(name, systemID)
        }

        func parser(_ parser: XMLParserType, parseErrorOccurred parseError: Error) {
            parseErrors.append(parseError)
        }

        func parser(_ parser: XMLParserType, validationErrorOccurred validationError: Error) {
            validationErrors.append(validationError)
        }


        #if SKIP

        // MARK: org.xml.sax.ContentHandler implementation

        override func startDocument() {
            parserDidStartDocument(())
        }

        override func endDocument() {
            parserDidEndDocument(())
        }

        override func characters(ch: CharArray, start: Int, length: Int) {
            parser((), foundCharacters: String(ch, start, length))
        }

        override func comment(ch: CharArray, start: Int, length: Int) {
            parser((), foundComment: String(ch, start, length))
        }

        override func startCDATA() {
            parser((), foundCDATA: Data())
        }

        override func endCDATA() {
        }

        override func startEntity(name: String) {
        }

        override func endEntity(name: String) {
        }

        override func startDTD(name: String?, publicId: String?, systemId: String?) {
        }

        override func endDTD() {
        }
        
        override func ignorableWhitespace(ch: CharArray, start: Int, length: Int) {
            parser((), foundIgnorableWhitespace: String(ch, start, length))
        }

        override func processingInstruction(target: String, data: String?) {
            parser((), foundProcessingInstructionWithTarget: target, data: data)
        }

        override func startElement(uri: String?, localName: String, qName: String?, attributes: org.xml.sax.Attributes) {
            var attrs: [String: String] = [:]
            for i in 0..<attributes.length {
                attrs[attributes.getLocalName(i)] = attributes.getValue(i)
            }
            parser((), didStartElement: localName.isEmpty ? qName ?? localName : localName , namespaceURI: uri, qualifiedName: qName, attributes: attrs)
        }

        override func endElement(uri: String?, localName: String, qName: String?) {
            parser((), didEndElement: localName, namespaceURI: uri, qualifiedName: qName)
        }
        #endif
    }

//    public struct ParseError : Error, Hashable {
//        /// The line number in the original document at which the error occured
//        public var lineNumber: Int
//        /// The column number in the original document at which the error occured
//        public var columnNumber: Int
//        /// The underlying error code for the error
//        public var code: XMLParser.ErrorCode
//        /// Whether this is a validation error or a parser error
//        public var validation: Bool
//    }
}


/// Utilities for XMLNode
public extension XMLNode {
    /// All the raw string content of all children (which may contain blank whitespace elements)
    var childContent: [String] {
        self.children.map {
            if case .content(let str) = $0 { return str }
            if case .cdata(let data) = $0 { return String(data: data, encoding: String.Encoding.utf8) }
            return nil
        }.compactMap({ $0 })
    }

    /// Join together all the child contents that are strings or CDATA blocks
    var stringContent: String {
        childContent.joined()
    }

    /// Converts the current node into a dictionary of element children names and the trimmed content of their joined string children.
    /// Note that any non-content children are ignored, so this is not a complete view of the element node.
    ///
    /// E.g. the XML:
    ///
    /// ```<ob><str>X</string><num>1.2</num></ob>```
    ///
    /// will return the dictionary:
    ///
    /// ```["str": "X", "num": "1.2"]```
    func elementDictionary(attributes: Bool, childNodes: Bool) -> [String: String] {
        var dict: [String: String] = [:]
        if attributes {
            for (key, value) in self.attributes {
                dict[key] = value
            }
        }
        if childNodes {
            for child in elementChildren {
                dict[child.elementName] = child.stringContent
            }
        }
        return dict
    }
}
