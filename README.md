# campus_navigation_app

---

AR Navigation App Using On-Device Machine Learning with A* Algorithm

 Overview
The AR Navigation App is a mobile application that provides real-time navigation using Augmented Reality (AR) and on-device machine learning. The app leverages ARCore to overlay navigation instructions on the real-world view through the camera, while the A* algorithm is used for pathfinding. The project includes two main components:

1. User App: Provides AR-based navigation to end-users.
2. Admin App: Allows administrators to manage locations and AR markers.

## Features
- AR Navigation: Real-time directions overlaid on the camera view using ARCore.
- On-Device Pathfinding: Uses the A* algorithm for efficient, on-device pathfinding.
- Location Management: Admin app to manage AR markers and locations.
- Offline Capability: Minimal reliance on internet connectivity for smooth operation in areas with poor network coverage.

Technologies Used
- Flutter: Cross-platform app development framework used for both User and Admin apps.
- ARCore: Google's platform for building augmented reality experiences.
- Firebase: Backend services used for authentication and database management (Admin App).
- A* Algorithm: Used for pathfinding and navigation.
- Provider: State management solution in Flutter.

Getting Started

Prerequisites
- Flutter SDK: Ensure that you have Flutter installed on your machine. Installation instructions can be found [here](https://flutter.dev/docs/get-started/install).
- Android Studio: Recommended IDE for Flutter development.
- ARCore Supported Device: A device that supports ARCore is required to run the User app.

 Installation
1. Clone the Repository:
   
   git clone https://github.com/samfredd/ar-navigation-app.git
   cd ar-navigation-app
   ```

2. Install Dependencies:
   Navigate to the `admin_app` and `user_app` directories and install dependencies for each:
  
   cd admin_app
   flutter pub get
   cd ../user_app
   flutter pub get
   ```

3. Firebase Configuration*(For Admin App):
   - Set up a Firebase project and add your app to the project.
   - Download the `google-services.json` file from Firebase and place it in the `android/app` directory of the `admin_app` project.
   - Configure Firebase authentication and Firestore for your project.

4. Run the App:
   - For the Admin App:
     
     cd admin_app
     flutter run
     ```
   - For the User App:
  
     cd user_app
     flutter run
     ```

Project Structure
Admin App
```
admin_app/
│
├── lib/
│   ├── auth_service.dart  // Authentication logic
│   ├── home_screen.dart   // Main screen for admin app
│   ├── main.dart          // Entry point of the admin app
│   └── ...
├── android/
│   ├── app/
│   │   ├── google-services.json  // Firebase configuration file
│   └── ...
├── pubspec.yaml           // Flutter dependencies and assets
└── ...
```

 User App
```
user_app/
│
├── lib/
│   ├── ar_view.dart       // AR view logic using ARCore
│   ├── home_screen.dart   // Main screen for user app
│   ├── main.dart          // Entry point of the user app
│   └── ...
├── android/
│   └── ...
├── pubspec.yaml           // Flutter dependencies and assets
└── ...
```

Usage

Admin App
- Login: Administrators log in using their Firebase credentials.
- Manage Locations: Add, update, or delete AR markers and locations via the map interface.
- View Data: Access and manage the database of locations and markers.

User App
- AR Navigation: Launch the app to view real-time navigation instructions overlaid on the camera view.
- Pathfinding: The app calculates the optimal path using the A* algorithm and guides the user using AR markers.

Testing
- Unit Testing: Run unit tests to verify the functionality of individual components.
- Integration Testing: Ensure that different parts of the app work together as expected.
- User Acceptance Testing: Gather feedback from users to improve the app's usability and performance.

Contributing
Contributions are welcome! Please fork the repository and submit a pull request.

1. Fork the repo.
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -m 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. Submit a pull request.


 Contact
For any questions or inquiries, feel free to contact me at solugbenga393@gmail.com.

---
