BlueCats SDK Extensions for the OtherLevels SDK
================

This repo contains extensions which combine functionality of the BlueCats and OtherLevels platforms.  Using [CocoaPods](http://www.cocoapods.org) you can easily integrate these extensions into your application along with both SDKs.  

##Extensions

###OLLocationEventPoster

The OLLocationEventPoster relays events from the BlueCats SDK to the OtherLevels platform.  For information on setting up the BlueCats platform in cooridnation with this extension, plese see [**this guide**](https://github.com/bluecats/bluecats-otherlevels-ios-sdkext/wiki/OLLocationEventPoster).

####Installation

Add the following line to your pod file for each target you would like the extension to be included within:
````
pod 'OLLocationEventPoster', :git => 'https://github.com/bluecats/bluecats-otherlevels-ios-sdkext.git'
````

##Required Pods
````
pod 'BlueCatsSDK', :git => 'https://github.com/bluecats/bluecats-ios-sdk.git', :tag => '0.6.0.rc.5'
pod 'OtherLevels', :git => 'https://github.com/bluecats/otherlevels-ios-sdk.git'
````
