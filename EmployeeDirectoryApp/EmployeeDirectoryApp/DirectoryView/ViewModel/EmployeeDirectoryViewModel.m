//
//  EmployeeDirectoryViewModel.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import "EmployeeDirectoryViewModel.h"
#import <EmployeeNetworking/EmployeeService.h>

@interface EmployeeDirectoryViewModel ()

// Redeclare public properties as readwrite in the private class extension
// The compiler will now automatically synthesize _employees, _isLoading, _errorMessage
@property (nonatomic, strong, readwrite) NSArray<Employee *> *employees;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, copy, readwrite, nullable) NSString *errorMessage;

@property (nonatomic, strong) EmployeeService *employeeService;

@end

@implementation EmployeeDirectoryViewModel

- (instancetype)initWithBaseURLString:(NSString *)baseURLString session:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _employeeService = [[EmployeeService alloc] initWithBaseURLString:baseURLString andSession:session];
        if (!_employeeService) {
            NSLog(@"Error: Failed to initialize EmployeeService in ViewModel.");
            return nil;
        }
        _employees = @[];
        _isLoading = NO;
        _errorMessage = nil;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not the designated initializer for EmployeeDirectoryViewModel. Use -initWithBaseURLString:session: instead."
                                 userInfo:nil];
}

- (void)fetchEmployees {
    if (self.isLoading) {
        return;
    }

    _errorMessage = nil;
    _isLoading = YES;

    if ([self.delegate respondsToSelector:@selector(employeeDirectoryViewModel:didUpdateLoadingState:)]) {
        [self.delegate employeeDirectoryViewModel:self didUpdateLoadingState:self.isLoading];
    }
    
    __weak typeof(self) weakSelf = self;

    [self.employeeService fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        
        strongSelf.isLoading = NO; // Always set loading to NO when the request completes

        if (employeeList) {
            BOOL isMalformed = NO;
            NSMutableArray<Employee *> *validEmployees = [NSMutableArray array];

            // Iterate through the fetched employees and validate each one
            for (Employee *employee in employeeList.employees) {
                if ([employee isValidEmployee]) { // Use the new validation method
                    [validEmployees addObject:employee];
                } else {
                    NSLog(@"Malformed employee found: %@", employee.uuid);
                    isMalformed = YES; // Mark the entire list as malformed
                    break; // As per requirement, invalidate the entire list on first malformed employee
                }
            }

            if (isMalformed) {
                // If any employee was malformed, invalidate the entire list and set error
                strongSelf.employees = @[]; // Clear the list
                strongSelf.errorMessage = @"Employee List is Malformed."; // Specific error message
                
                // You might also want to create a specific NSError object here if the ViewController needs it
                // NSError *malformedError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                //                                                 code:EmployeeServiceErrorCodeMalformedEmployeeData
                //                                             userInfo:@{NSLocalizedDescriptionKey: strongSelf.errorMessage}];
                // If you pass an NSError, adjust the delegate to include it.
            } else {
                // All employees are valid
                strongSelf.employees = [validEmployees copy];
                strongSelf.errorMessage = nil; // Clear any previous error
            }

        } else {
            // Original network/parsing error from EmployeeService
            strongSelf.employees = @[]; // Clear data on error
            NSString *userFriendlyErrorMessage = @"An unknown error occurred.";

            if (error) {
                if ([error.domain isEqualToString:EmployeeServiceErrorDomain]) {
                    switch (error.code) {
                        case EmployeeServiceErrorCodeNetworkError:
                            userFriendlyErrorMessage = @"Network connection failed. Please check your internet.";
                            break;
                        case EmployeeServiceErrorCodeJSONParsingFailed:
                        case EmployeeServiceErrorCodeInvalidResponseFormat:
                            userFriendlyErrorMessage = @"Failed to read employee data. Please try again later.";
                            break;
                        case EmployeeServiceErrorCodeNoData:
                            userFriendlyErrorMessage = @"No employee data available.";
                            break;
                        case EmployeeServiceErrorCodeInvalidURL:
                        case EmployeeServiceErrorCodeInitializationFailed:
                            userFriendlyErrorMessage = @"Application configuration error. Please contact support.";
                            break;
                        default:
                            userFriendlyErrorMessage = [NSString stringWithFormat:@"Error fetching employees: %@", error.localizedDescription];
                            break;
                    }
                } else {
                    userFriendlyErrorMessage = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
                }
            }
            strongSelf.errorMessage = userFriendlyErrorMessage;
            NSLog(@"Error fetching employees: %@", error);
        }

        // Notify delegate about the update
        if ([strongSelf.delegate respondsToSelector:@selector(employeeDirectoryViewModel:didEncounterError:)] && strongSelf.errorMessage) {
            [strongSelf.delegate employeeDirectoryViewModel:strongSelf didEncounterError:strongSelf.errorMessage];
        } else if ([strongSelf.delegate respondsToSelector:@selector(employeeDirectoryViewModelDidUpdateData:)]) {
            [strongSelf.delegate employeeDirectoryViewModelDidUpdateData:strongSelf];
        }
    }];
}


@end
