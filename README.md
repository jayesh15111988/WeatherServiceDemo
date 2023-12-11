## Weather SDK Demo app



### App Demo





https://github.com/jayesh15111988/WeatherServiceDemo/assets/6687735/9c02fa47-d885-4b0e-8fd9-6f72b06e241a







### Overview

This project aims to develop a demo iOS application to demonstrate the usage of `WeatherService` SDK and how it utilizes it to build features on top of it



### Features



## Screens



1. Locations list screen

The screen shows the list of predefined locations. Currently, they come from local JSON file and are subsequently cached. In the future change, they can also be fetched from the remote URL



![Simulator Screenshot - iPhone 15 Pro - 2023-12-11 at 15 09 20](https://github.com/jayesh15111988/WeatherServiceDemo/assets/6687735/4c12dc17-c12f-4398-8bba-b9a90113ceda)





2. Favorites list screen

The screen that shows the favorited locations



![Simulator Screenshot - iPhone 15 Pro - 2023-12-11 at 15 09 23](https://github.com/jayesh15111988/WeatherServiceDemo/assets/6687735/df443e6e-2bb2-495d-be9b-cac260a5d4b8)





4. Temperature Forecast Details screen

A screen that shows the current temperature and the temperatures for the next 7 days. This includes minimum, maximum, and average temperature



![Simulator Screenshot - iPhone 15 Pro - 2023-12-11 at 15 09 33](https://github.com/jayesh15111988/WeatherServiceDemo/assets/6687735/92875b25-6e52-4d9c-9709-d1d6b74cb803)





## Caching

The app uses Core data for caching user content and models. For example, when the user favorites individual locations, this is persisted across app restarts. 

Also, whenever the user favorites a location, the current and forecasted temperature details will be cached.



The bookmarked location is automatically cached and is removed when the user unbookmarks the item. While getting a forecast, the app first tries to download data from the network.

If that call fails due to an unavailable network, the app retrieves the forecast data from the previously stored cache.



### Architecture

The app uses MVVM-Router architecture. The reason is, that I wanted to separate out all the business and data transformation logic away from the view layer. 

The view model is responsible for getting models from the `WeatherService` API and converting them into local view models to be consumed by the view layer.



I ruled out MVC due to it polluting the view layer and making it difficult to just test the business logic due to intermixing with a view. 

I also thought about VIPER architecture, but it seemed an overkill for a feature this small given the boilerplate code it tends to add. 

Finally, I decided to use MVVM as a middle ground between these two possible alternatives.



The MVVM-Router architecture applies to all the app screens. Namely, there are 4 components in this architecture with a brief description



1. View - Responsible for laying out `UIKit` elements on the screen

2. ViewModel - The layer responsible for applying business logic to the network models

3. Model - The models received from the network or the SDK

4. Router - Also called as a coordinator. Responsible for routing and navigation within the app



### How to run the app?

The app can be run simply by opening "WeatherServiceDemo.xcodeproj" file and pressing CMD + R to run it



### Unit Tests

Due to time constraints, I haven't written any tests for the demo app. However, the code is structured so that it can be easily unit-tested. 



### Manual testing

I performed the manual testing on the app before submission handling all features and edge cases. Namely following functionalities are tested



1. Showing locations list

2. Favoriting location

3. Caching support

4. Offline viewing of bookmarked locations

5. Favorites list



### UI/Automated tests

I haven't added any UI/Automated tests due to time limitations, but given the extra time, I will write extra tests to verify the E2E app flow



### Device support

This app is currently supported only on iPhone (Any model) in portrait and landscape mode.



### Third-party images used

I am not using third-party images in the app



### Usage of 3rd party library

I am not using any 3rd party library in this app.



### Deployment Target

The app needs a minimum version of iOS 15 for the deployment



### Xcode version

The app was compiled and run on Xcode version 15.0



### API/SDK used for getting forecast data

I am using [Weather Service SDK](https://github.com/jayesh15111988/WeatherService) to get the weather forecast information for the selected location.

The detailed guide on using this API can be found in [README file](https://github.com/jayesh15111988/WeatherService/blob/main/README.md)



### Future enhancements

The project can be extended in several ways in the future



- Comprehensive unit and UI tests

- Support for cache flush in case of a large number of locations

- Accessibility

- Support for showing forecast at the current location



### Swift version used

Swift 5.0

