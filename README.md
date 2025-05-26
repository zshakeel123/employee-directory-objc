**Employee Directory iOS App**

This project showcases a clean, maintainable, and robust iOS application developed in Objective-C and UIKit, demonstrating best practices in architecture, UI/UX, and testing. It serves as a classic example of applying the Model-View-ViewModel (MVVM) design pattern in a real-world scenario.

**Project Overview**

The Employee Directory app is a lightweight iOS application designed to display a list of employees and their detailed profiles. It's composed of two main parts:

**EmployeeNetworking Project:** A dedicated framework responsible for handling all network requests, parsing employee data, and encapsulating the API service logic. This separation ensures that the networking layer is independent and reusable.
**EmployeeDirectoryApp Host:** The main application that consumes the EmployeeNetworking framework. It features two primary screens:
Employee Directory View: Displays a paginated list of employees using a UICollectionView.
Employee Detail View: Presents comprehensive details of a selected employee.
This project is a testament to how complex features can be built with simplicity and strong architectural principles, even in Objective-C, making it easy to understand and extend.

**Key Achievements & Quality Highlights**

**Architecture & Design Patterns**

**MVVM (Model-View-ViewModel):** 

This project rigorously applies the MVVM pattern, especially within the EmployeeDirectoryApp host.

ViewModel: Acts as a clean, testable layer between the Model (Employee data, EmployeeNetworking) and the View (UIViewController, UICollectionViewCell). ViewModels prepare data for display, handle UI logic, and manage state, abstracting away the underlying business logic.

Controller (View): UIViewControllers and UICollectionViewCells are kept lean, primarily responsible for rendering the UI and forwarding user interactions to the ViewModel. This reduces "Massive View Controller" syndrome.

Model: Defined within EmployeeNetworking, representing the core data structures (e.g., Employee, EmployeeListResponse) and service interactions.
Separation of Concerns: Achieved through:

Dedicated EmployeeNetworking Framework: Completely decouples network operations from the main application's UI logic. This makes the networking layer independently reusable and testable.

Clear Boundaries: Each component (ViewModel, Controller, Cell, Networking Service) has a well-defined responsibility, preventing tight coupling and promoting modularity.
UI/UX & User Experience

Responsive UI: The application provides a smooth and responsive user interface, even during network operations.

Activity Indicators: Thoughtful implementation of UIActivityIndicatorView to provide visual feedback during data fetching, enhancing the perceived performance and user experience.

Pull-to-Refresh: The Employee Directory view includes a UIRefreshControl, allowing users to easily refresh the employee list, improving data freshness and user control.

Robust Image Caching: Implemented via Kingfisher (a highly optimized Swift library), ensuring fast and efficient loading of employee profile images.

Placeholders are displayed while images load, preventing blank UI.

API Edge Case Handling: The application gracefully handles various API responses, including:
Loading states.
No data found.
Network errors (e.g., connection issues, server errors) with user-friendly messages.

**Maintainability & Code Quality**

Objective-C Best Practices: Adheres to modern Objective-C conventions and memory management practices.

Lightweight Project: Consciously avoids unnecessary third-party dependencies, opting for a single, robust library (Kingfisher) for image caching where a custom solution would add significant complexity.

Modular Design: The project's compartmentalized structure makes it easy for new developers to understand individual components without grasping the entire system.

Clear Naming Conventions: Consistent and descriptive naming for classes, methods, and properties enhances code readability.

Readability: Code is well-commented where necessary, focusing on clarity over excessive inline comments.


**Testability**

Dependency Injection (DI): ViewModels are initialized with their dependencies (e.g., EmployeeService is injected into EmployeeDirectoryViewModel). This makes it trivial to inject mock services during unit tests.

Unit Tests for Networking Layer: The EmployeeNetworkingTests project contains unit tests for the EmployeeService, ensuring the reliability of API calls and data parsing.

Unit Tests for ViewModels: The EmployeeDirectoryAppTests project contains unit tests for EmployeeDirectoryViewModel and EmployeeDetailViewModel, verifying their logic, state changes, and delegate interactions independently of the UI or network. This demonstrates the MVVM pattern's core benefit: testable presentation logic.

Mocking: Utilizes mock objects (e.g., MockEmployeeService) to isolate units under test, allowing for precise control over test scenarios and independent verification of component behavior.

I take great pride in the quality, structure, maintainability, and testability of this codebase. It stands as a strong demonstration of my strengths in mobile app development and my commitment to building robust, production-ready applications.

**Project Structure**

```
├── EmployeeDirectoryApp.xcworkspace/  # The main workspace
├── Podfile                        # CocoaPods configuration (if used)
├── EmployeeDirectoryApp/
│   ├── Common/                    # Common utilities, constants, etc.
│   │   ├── AppConstants.h/m
│   │   └── KingfisherWrapper.h/m  # (Optional: If you created a thin wrapper around Kingfisher)
│   ├── DirectoryView/
│   │   ├── Controller/
│   │   │   └── EmployeeDirectoryViewController.h/m
│   │   ├── ViewModel/
│   │   │   └── EmployeeDirectoryViewModel.h/m
│   │   └── Cell/
│   │       └── EmployeeCollectionViewCell.h/m
│   └── DetailView/
│       ├── Controller/
│       │   └── EmployeeDetailViewController.h/m
│       └── ViewModel/
│           └── EmployeeDetailViewModel.h/m
├── EmployeeDirectoryAppTests/     # Unit tests for the main application's logic (ViewModels)
│   └── MockEmployeeService.h/m    # Mock service for testing
├── EmployeeNetworking/            # Standalone framework for network services
│   ├── EmployeeNetworking.xcodeproj/
│   ├── EmployeeService.h/m
│   └── Employee.h/m               # Employee Model definition
├── EmployeeNetworkingTests/       # Unit tests for the networking framework
└── README.md
```

**Running the Project**

Follow these instructions to set up and run the Employee Directory iOS App on your local machine.

**Prerequisites**

Xcode 13.0 or higher
iOS 14.0 SDK or higher
A stable internet connection (to fetch employee data from the API and download Kingfisher)


**Installation**

1- Clone the repository:

2- Install Swift Packages:

This project uses Swift Package Manager (SPM) for its dependencies. Xcode will automatically resolve and download Kingfisher when you open the workspace.

**Dependencies**

Kingfisher: For robust and efficient image loading and caching.

Integrated via Swift Package Manager.
(Note: The project intentionally limits third-party dependencies to focus on demonstrating core iOS development skills and architecture.)

**Contact**

For any questions or further discussion about this project, please feel free to reach out.

**Zeeshan Shakeel**<br>
[https://www.linkedin.com/in/zeeshakeel/] 











