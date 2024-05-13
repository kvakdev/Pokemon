# Pokemon

## Test app 
### I used The Composable Architecture to excercise and show its capabilities.
### Fetching pokemnos from the API is done with pagination in packs of 10
### I also implemented search withing the already fetched results
### When tapping a Pokemon user is navigated to Details screen with some basic info about the Pokemon
### When tapping 'Hear latest cry' button the '.ogg' file is downloaded to the device, converted to '.wav' format as iOS can't natively play the '.ogg' format, wav file is stored in the documents directory, next time it's not loaded but played from cache.
### To handle '.ogg' format I used 'OggDecoder' framework
