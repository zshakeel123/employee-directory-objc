//
//  EmployeeService.h
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 21/05/2025.
//

#import <Foundation/Foundation.h>
#import <EmployeeNetworking/EmployeeListResponse.h>

NS_ASSUME_NONNULL_BEGIN

// Define the error domain for EmployeeService specific errors (declared public)
extern NSString *const EmployeeServiceErrorDomain;

// Define specific error codes (publicly exposed for consumer convenience)
typedef NS_ENUM(NSInteger, EmployeeServiceErrorCode) {
    EmployeeServiceErrorCodeInvalidURL = 1,
    EmployeeServiceErrorCodeNoData = 2,
    EmployeeServiceErrorCodeJSONParsingFailed = 3,
    EmployeeServiceErrorCodeInvalidResponseFormat = 4,
    EmployeeServiceErrorCodeNetworkError = 5,
    EmployeeServiceErrorCodeInitializationFailed = 6
};

// Define a type for the completion block
typedef void (^EmployeeFetchCompletionBlock)(EmployeeListResponse *_Nullable employeeList, NSError *_Nullable error);

@interface EmployeeService : NSObject

/**
 * @brief Initializes the EmployeeService with a specific API base URL.
 * @param baseURLString The base URL string for the employees API endpoint.
 * @return An initialized EmployeeService instance.
 */
- (instancetype)initWithBaseURLString:(NSString *)baseURLString andSession:(NSURLSession *)session NS_DESIGNATED_INITIALIZER;

// Prevent direct calls to init
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Fetches a list of employees from the configured API endpoint.
 * @param completion A block to be executed upon completion of the fetch operation.
 * - employeeList: The parsed EmployeeListResponse object if successful, otherwise nil.
 * - error: An NSError object if an error occurred, otherwise nil.
 */
- (void)fetchEmployeesWithCompletion:(EmployeeFetchCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
