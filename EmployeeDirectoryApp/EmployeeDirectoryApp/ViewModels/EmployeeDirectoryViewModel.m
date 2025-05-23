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
    if (self.isLoading) { // Use the public getter here
        return;
    }

    // Update the ivars
    _errorMessage = nil;
    _isLoading = YES;

    // Notify delegate about loading state change immediately
    if ([self.delegate respondsToSelector:@selector(employeeDirectoryViewModel:didUpdateLoadingState:)]) {
        [self.delegate employeeDirectoryViewModel:self didUpdateLoadingState:self.isLoading];
    }
    
    __weak typeof(self) weakSelf = self;

    [self.employeeService fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!strongSelf) {
                    return;
                }
        
        // Always set loading to NO when the request completes
        strongSelf.isLoading = NO;

        if (employeeList) {
            strongSelf.employees = employeeList.employees;
            strongSelf.errorMessage = nil;
        } else {
            strongSelf.employees = @[];
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

        // Notify delegate about data update
        if ([self.delegate respondsToSelector:@selector(employeeDirectoryViewModelDidUpdateData:)]) {
            [self.delegate employeeDirectoryViewModelDidUpdateData:self];
        }
        // Notify delegate about error message (if any)
        if ([self.delegate respondsToSelector:@selector(employeeDirectoryViewModel:didEncounterError:)] && self.errorMessage) {
            [self.delegate employeeDirectoryViewModel:self didEncounterError:self.errorMessage];
        }
    }];
}

@end
