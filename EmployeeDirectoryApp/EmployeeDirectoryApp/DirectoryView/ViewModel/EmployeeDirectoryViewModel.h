//
//  EmployeeDirectoryViewModel.h
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import <Foundation/Foundation.h>
#import <EmployeeNetworking/Employee.h>

NS_ASSUME_NONNULL_BEGIN

// Forward declaration of the ViewModel class
@class EmployeeDirectoryViewModel;

// Delegate protocol for communication from ViewModel to ViewController
@protocol EmployeeDirectoryViewModelDelegate <NSObject>

@required
/**
 * @brief Notifies the delegate that employee data has been updated.
 * This can be called on success or when data is cleared (e.g., on error).
 */
- (void)employeeDirectoryViewModelDidUpdateData:(EmployeeDirectoryViewModel *)sender;

@optional
/**
 * @brief Notifies the delegate that the loading state has changed.
 * @param isLoading YES if data is currently being fetched, NO otherwise.
 */
- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didUpdateLoadingState:(BOOL)isLoading;

/**
 * @brief Notifies the delegate that an error occurred during data fetching.
 * @param errorMessage A user-friendly message describing the error.
 */
- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didEncounterError:(nullable NSString *)errorMessage;

@end


@interface EmployeeDirectoryViewModel : NSObject

// Delegate for the UI to observe/bind to get notified of the changes in the view model
@property (nonatomic, weak, nullable) id<EmployeeDirectoryViewModelDelegate> delegate;

// The array of Employee objects to be displayed
@property (nonatomic, strong, readonly) NSArray<Employee *> *employees;

// Loading state for UI indicators
@property (nonatomic, assign, readonly) BOOL isLoading;

// Error message for UI display
@property (nonatomic, copy, readonly, nullable) NSString *errorMessage;


/**
 * @brief Initializes the view model with the necessary dependencies.
 * @param baseURLString The base URL string for the EmployeeService.
 * @param session The NSURLSession instance to use for networking.
 * @return An initialized EmployeeDirectoryViewModel instance.
 */
- (instancetype)initWithBaseURLString:(NSString *)baseURLString session:(NSURLSession *)session NS_DESIGNATED_INITIALIZER;

// Prevent direct calls to init
- (instancetype)init NS_UNAVAILABLE;


/**
 * @brief Initiates the fetching of employee data.
 * This method will update the isLoading state and notify the delegate upon completion.
 */
- (void)fetchEmployees;

@end

NS_ASSUME_NONNULL_END
