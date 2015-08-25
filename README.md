BlueCats SDK Extensions for the OtherLevels SDK
================

This repository contains extensions which combine the functionality of the BlueCats and OtherLevels platforms.  Using [CocoaPods](http://www.cocoapods.org) you can easily integrate these extensions into your application along with both SDKs.

##Required Pods
````
pod 'BlueCatsSDK', :git => 'https://github.com/bluecats/bluecats-ios-sdk.git'
pod 'OtherLevels', :git => 'https://github.com/bluecats/otherlevels-ios-sdk.git'
````

##Extensions

###OLLocationEventPoster

The OLLocationEventPoster posts location events from the BlueCats Zone Monitor to the OtherLevels platform.  For information on setting up the BlueCats platform in coordination with this extension, please see [**this guide**](https://github.com/bluecats/bluecats-otherlevels-ios-sdkext/wiki/OLLocationEventPoster).

####Installation

Add the following line to your pod file for each target you would like the extension to be included in:
````
pod 'OLLocationEventPoster', :git => 'https://github.com/bluecats/bluecats-otherlevels-ios-sdkext.git'
````


