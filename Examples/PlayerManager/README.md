# Player Manager

<img width="1062" alt="Screenshot 2024-02-07 at 20 30 53" src="https://github.com/antongorb/composable-avplayer/assets/39763987/bd69d18e-eab4-4e1e-a036-3880f1795018">

This application demonstrates how to build a simple application for both iOS and macOS using AVPlayer.

The core logic of the application is written a single time, and powers both views. All of the code shared between the iOS and macOS apps is in the `Common` Swift package.

Interaction with `AVPlayer` API is done via the [`ComposableAVPlayer`](../../Sources/ComposableAVPlayer) library that comes with the Composable Architecture. It gives you an `Effect`-friendly interface to all of `AVPlayer` APIs, making it easy to use its features from a reducer _and_ making it easy to test logic that depends on its `AVPlayer` functionality.
