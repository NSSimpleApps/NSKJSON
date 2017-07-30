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

Test cases were taken from here:

https://github.com/nst/JSONTestSuite

https://github.com/json5/json5-tests

TODO:

1. Improve error reports.
