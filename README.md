# NSKJSON
NSKJSON is a swift library to parse plain-json format and json5 format.

Installation: place this into `Podfile`
```
use_frameworks!
target 'Target' do
    pod 'NSKJSON'
end
```

Usage:
```objc
import NSKJSON

let data = // some data...

do {
    let plainJson = try NSKJSON.jsonObject(with: data, version: .plain)
    let json5 = try NSKJSON.jsonObject(with: data, version: .json5)
} catch {
    
    print(error)
}

```

TODO:

1. Supporting `UTF16-BE`, `UTF16-LE`, `UTF32-BE`, `UTF32-LE` encodings.

2. Improve error reports.
