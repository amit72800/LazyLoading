# LazyLoading
This is a sample application showing download and handling images using URLSession.


Simple and efficient image lazy loading functionality for the iOS written in Swift.

LazyLoading is demo project for showing such functionality.

### Features

Asynchronous image downloader on a background thread. Main thread is never blocked.

Uses URLSession background configuration to do so.

Caching of the downloaded images at document directory.

uses collection view to show images.

Complete control over your image data
Guarantees that the same image url will not be downloaded again but will be fetched from the cache.

Calls the delegate when the download in complete and then in the main thread reload the particular cell of the collection view using the index path.

Facebook ads are also integrated at every 6th position of the cell in collection view.

Display the images super fast 🚀.
