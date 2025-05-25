//
//  MockEmployeeService.h
//  EmployeeDirectoryAppTests
//
//  Created by Zeeshan Shakeel on 25/05/2025.
//

#import <EmployeeNetworking/EmployeeNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockEmployeeService : EmployeeService

// Properties to control the mock's behavior (simplified)
@property (nonatomic, strong, nullable) EmployeeListResponse *mockEmployeeListResponse;
@property (nonatomic, strong, nullable) NSError *mockError;

@end

NS_ASSUME_NONNULL_END
