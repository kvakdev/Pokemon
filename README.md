# Pokemon

## Test app 
### 1.I used The Composable Architecture to excercise and show its capabilities.
### 2.Fetching pokemnos from the API is done with pagination in packs of 10
### 3.I also implemented search withing the already fetched results
### 4.When tapping a Pokemon user is navigated to Details screen with some basic info about the Pokemon
### 5.When tapping 'Hear latest cry' button the '.ogg' file is downloaded to the device, converted to '.wav' format as iOS can't natively play the '.ogg' format, wav file is stored in the documents directory, next time it's not loaded but played from cache. The sound is weird but the browswer makes the same sound so I assume it works correctly.
### 6.To handle '.ogg' format I used 'OggDecoder' framework
### 7.The project also features several unit tests covering basic logic of navigation and loading
### 8.Dependency Injection is provided by the TCA framework for live, preview and test use cases.

## Description of the challenge is below
TECHNICAL TEST IOS
To evaluate your skills and coding style, we would like you to develop a small application that
uses https://pokeapi.co/ REST API.
Application
The app must accomplish the following:
1. The main screen must load a list of Pokémon from the API
2. Each Pokémon entry on the list must contain their respective name and image
3. Once the user taps on a Pokémon, the app must navigate to a detailed screen, as
explained on the next item
4. On the detail screen, the app must:
a. show the Pokémon's name and image
b. show a list of at least six fields of your choosing (ID, ability, base experience,
moves, height, and weight are examples)
Feel free to use any UI toolkit, libraries, and frameworks you deem necessary, as long as
you can explain the reasoning behind your choices.
Must-haves:
1. Get an API key, as explained in the documentation of https://pokeapi.co/
2. Use XCode (Swift) and share the project via Github.
3. Include a README explaining your approach to the problem
4. You can use third-party libraries with their preference to handle dependencies.
5. Take the opportunity to showcase your coding style and use whatever design pattern
(MVVM, VIPER, MVC, MVP, etc.) you would frequently have used for this task.
Nice-to-haves:
1. Pagination
2. Search Field
3. Functional programming
4. Dependency Injection
5. Unit Testing
6. UI Testing
7. Mark any of them as favorites and send a POST request with the Pokémon data to a
WebHook like http://webhook.site. (include the WebHook URL you used in the app)
8. Adapt UI to mobile orientation changes
9. Feel free to add more items as you wish (amaze us)
