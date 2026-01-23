
SkipXML is a Skip framework that provides an XML Document parser.

## Setup

To include this framework in your project, add the following
dependency to your `Package.swift` file:

```swift
let package = Package(
    name: "my-package",
    products: [
        .library(name: "MyProduct", targets: ["MyTarget"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.dev/skip-xml.git", "0.0.0"..<"2.0.0"),
    ],
    targets: [
        .target(name: "MyTarget", dependencies: [
            .product(name: "SkipXML", package: "skip-xml")
        ])
    ]
)
```

## Usage

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
[Skip](https://skip.dev) plugin to transpile Swift into Kotlin.

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


## License

This software is licensed under the
[GNU Lesser General Public License v3.0](https://spdx.org/licenses/LGPL-3.0-only.html),
with a [linking exception](https://spdx.org/licenses/LGPL-3.0-linking-exception.html)
to clarify that distribution to restricted environments (e.g., app stores) is permitted.
