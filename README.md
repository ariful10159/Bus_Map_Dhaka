# Bus Map Dhaka

Bus Map Dhaka is a Flutter-based mobile application designed to provide users with an interactive map interface for navigating bus routes in Dhaka city. The app features a login interface, a home screen with OpenStreetMap integration, and the ability to display routes, bus names, and markers.

## Features

- **Login Interface**: Users must log in to access the app.
- **Home Screen**: Displays the user's present address, destination, and a map showing the route.
- **OpenStreetMap Integration**: Interactive map with markers and polylines.
- **Dynamic Route Display**: Shows the route between the selected start and destination points.
- **Bus Information**: Displays the bus name along the route.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ariful10159/Bus_Map_Dhaka.git
   ```
2. Navigate to the project directory:
   ```bash
   cd Bus_Map_Dhaka
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter_map`: For OpenStreetMap integration.
- `latlong2`: For handling geographical coordinates.

## Project Structure

```
Bus_Map_Dhaka/
├── android/          # Android-specific files
├── ios/              # iOS-specific files
├── lib/              # Main Flutter code
│   ├── main.dart     # Entry point of the app
│   ├── login_screen.dart  # Login interface
│   ├── home_screen.dart   # Home screen with map
├── pubspec.yaml      # Flutter dependencies
└── README.md         # Project documentation
```

## How to Use

1. Launch the app.
2. Log in using your credentials.
3. On the home screen, select your present address and destination.
4. View the route, bus name, and markers on the map.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

Developed by [ariful10159](https://github.com/ariful10159).
