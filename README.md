
SkipXML is a Skip framework that provides an XML Document parser.

On Swift/iOS it is implemented using `Foundation.XMLParser` and `Foundation.XMLParserDelegate`,
and on the Kotlin/Android side it uses `org.xml.sax.XMLReader` and `org.xml.sax.helpers.DefaultHandler`.

Documents are parsed into in-memory `XMLNode` structures as follows:

```swift
import SkipXML

func parseXML(data: Data) throws -> String {
    let node = try XMLNode.parse(data: data, options: [.processNamespaces])    
    return node.xmlString() // returns the XML document as a string
}

```
 

## Building

This project is a Swift Package Manager module that uses the
[Skip](https://skip.tools) plugin to transpile Swift into Kotlin.

Building the module requires that Skip be installed using 
[Homebrew](https://brew.sh) with `brew install skiptools/skip/skip`.
This will also install the necessary build prerequisites:
Kotlin, Gradle, and the Android build tools.

## Testing

The module can be tested using the standard `swift test` command
or by running the test target for the macOS destination in Xcode,
which will run the Swift tests as well as the transpiled
Kotlin JUnit tests in the Robolectric Android simulation environment.

Parity testing can be performed with `skip test`,
which will output a table of the test results for both platforms.

