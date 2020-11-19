# DebugNetworkLib
![DebugNetworkLib]()

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

### NodeJS

### Download Server:
```
https://github.com/padgithub/ServerDebugNetwork
```

```shell
brew install node
cd Server
npm install
```

### Run Server

```shell
./run-server-debug.sh
```

final go to [Server](http://localhost:3000/)

## Installation

DebugNetworkLib is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DebugNetworkLib'
```

and your AppDelegate add

```Swift

#if DEBUG
import DebugNetworkLib
#endif

#if DEBUG
DNL.sharedInstance().start()
#endif
```

## Author

padgithub, dungqb00@gmail.com

## License

DebugNetworkLib is available under the MIT license. See the LICENSE file for more info.
