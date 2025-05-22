//
//  EmployeeService.h
//  EmployeeNetworking
//
//  Created by Zeeshan Shakeel on 21/05/2025.
//

#import <Foundation/Foundation.h>
#import <EmployeeNetworking/EmployeeListResponse.h>

NS_ASSUME_NONNULL_BEGIN

// Define a type for the completion block
typedef void (^EmployeeFetchCompletionBlock)(EmployeeListResponse *_Nullable employeeList, NSError *_Nullable error);

@interface EmployeeService : NSObject

/**
 * @brief Initializes the EmployeeService with a specific API base URL.
 * @param baseURLString The base URL string for the employees API endpoint.
 * @return An initialized EmployeeService instance.
 */
- (instancetype)initWithBaseURLString:(NSString *)baseURLString NS_DESIGNATED_INITIALIZER;

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
