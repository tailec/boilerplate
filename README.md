
![The Tin Woodman of Oz](https://openclipart.org/image/200px/svg_to_png/184586/the-tin-woodsman.png)

#boilerplate [![codebeat](https://codebeat.co/badges/256b8082-7bd9-41c4-a93e-1ea9e297bc79)](https://codebeat.co/projects/github-com-tailec-boilerplate)
This repository demonstrates different architectures and usage of popular reactive programming frameworks.

I decided to open-source couple of small apps (3-6 screens) with very basic UI. I hope, these projects will save someone else's time.

Currently, only [GitHub API Client](#github-api-client) is available. Rest of the apps will be published very soon!


1. [GitHub API Client](#github-api-client) - MVVM and RxSwift
2. *500px photo viewer app - VIPER and RxSwift - March 2016*
3. *TBA - mix of MVVM and VIPER by Florent Pillet ([@fpillet](https://twitter.com/fpillet)) and RxSwift - April 2016*
4. *TODO List - MVVM and SwiftBond - April 2016*
5. *Commits app - MVVM and ReactiveCocoa - Coming soon*


Also, there are plans to create sample app using [ReSwift](https://github.com/ReSwift/ReSwift).

Pull requests are welcome.

##GitHub API client
Watch demo on [vimeo](https://vimeo.com/158834222).

The GitHub API client requires you to sign in with your GitHub account.
Sample app uses your username and password to generate auth token (app doesn't store your login credentials).
More information can be found [here](https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization).

###Features

* MVVM architecture
* Uses [RxSwift](https://github.com/ReactiveX/RxSwift)
* Autocompletion search
* GitHub sign in process
* Shows how to zip many network requests
* RxCocoa UIKit bindings (RxCocoa `UITableView` bindings are really cool)
* Uses [Moya](https://github.com/Moya/Moya) as networking layer
* Implements RxSwift custom operators
* Implements RxSwift helper operators for [Moya](https://github.com/Moya/Moya)
* Uses [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)


[Upcoming features and code checklist](Docs/Github-upcoming-features-and-code-checklist.md)

###Setup
```
cd github
pod install
open github.xcworkspace
```

##Thanks
* [@ashfurrow](https://twitter.com/ashfurrow) and [@orta](https://twitter.com/orta) for [Moya](https://github.com/Moya/Moya), [C-41](https://github.com/ashfurrow/C-41), [Kiosk](https://github.com/artsy/eidolon)
* [@icanzilb](https://twitter.com/icanzilb) for ideas
* [@fpillet](https://twitter.com/fpillet) for [MVVM / VIPER mix](https://slack-files.com/T051G5Y6D-F0HABHKDK-8e9141e191)

##Author
Pawel Krawiec

* [www.tailec.com](http://www.tailec.com)
* [@tailectailec](https://twitter.com/tailectailec)

##Licence
MIT
