//
//  EmployeeDirectoryViewModelTests.m
//  EmployeeDirectoryAppTests
//
//  Created by Zeeshan Shakeel on 25/05/2025.
//

#import <XCTest/XCTest.h>
#import "EmployeeDirectoryViewModel.h"
#import "MockEmployeeService.h"
#import <EmployeeNetworking/Employee.h>
#import <EmployeeNetworking/EmployeeListResponse.h>
#import <EmployeeNetworking/EmployeeService.h>

// Define the error domain constant for access in tests
extern NSString *const EmployeeServiceErrorDomain;

// Mock ViewModel Delegate to capture calls
@interface MockEmployeeDirectoryViewModelDelegate : NSObject <EmployeeDirectoryViewModelDelegate>
@property (nonatomic, assign) BOOL didUpdateDataCalled;
@property (nonatomic, assign) BOOL didUpdateLoadingStateCalled;
@property (nonatomic, assign) BOOL isLoadingState;
@property (nonatomic, assign) BOOL didEncounterErrorCalled;
@property (nonatomic, copy, nullable) NSString *capturedErrorMessage;

@end

@implementation MockEmployeeDirectoryViewModelDelegate

- (void)employeeDirectoryViewModelDidUpdateData:(EmployeeDirectoryViewModel *)sender {
    self.didUpdateDataCalled = YES;
}

- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didUpdateLoadingState:(BOOL)isLoading {
    self.didUpdateLoadingStateCalled = YES;
    self.isLoadingState = isLoading;
}

- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didEncounterError:(nullable NSString *)errorMessage {
    self.didEncounterErrorCalled = YES;
    self.capturedErrorMessage = errorMessage;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetMockState];
    }
    return self;
}

- (void)resetMockState {
    _didUpdateDataCalled = NO;
    _didUpdateLoadingStateCalled = NO;
    _isLoadingState = NO;
    _didEncounterErrorCalled = NO;
    _capturedErrorMessage = nil;
}

@end

@interface EmployeeDirectoryViewModelTests : XCTestCase
@property (nonatomic, strong) EmployeeDirectoryViewModel *viewModel;
@property (nonatomic, strong) MockEmployeeService *mockService;
@property (nonatomic, strong) MockEmployeeDirectoryViewModelDelegate *mockDelegate;
@end

@implementation EmployeeDirectoryViewModelTests

- (void)setUp {
    [super setUp];
    self.mockService = [[MockEmployeeService alloc] initWithBaseURLString:@"https://mock.api/employees" andSession:[NSURLSession sharedSession]];
    self.viewModel = [[EmployeeDirectoryViewModel alloc] initWithEmployeeService:self.mockService];
    self.mockDelegate = [[MockEmployeeDirectoryViewModelDelegate alloc] init];
    self.viewModel.delegate = self.mockDelegate;
    // resetMockState is called in MockEmployeeDirectoryViewModelDelegate's init, so no need here.
}

- (void)tearDown {
    self.viewModel = nil;
    self.mockService = nil;
    self.mockDelegate = nil;
    [super tearDown];
}

#pragma mark - Helper Methods for Test Data

- (Employee *)createValidEmployeeWithUUID:(NSString *)uuid {
    Employee *employee = [[Employee alloc] initWithDictionary:@{
        @"uuid": uuid,
        @"full_name": [NSString stringWithFormat:@"Name %@", uuid],
        @"email_address": [NSString stringWithFormat:@"%@@example.com", uuid],
        @"team": @"Test Team",
        @"employee_type": @"FULL_TIME"
    }];
    return employee;
}

- (Employee *)createMalformedEmployeeWithUUID:(NSString *)uuid {
    // Missing required 'full_name'
    Employee *employee = [[Employee alloc] initWithDictionary:@{
        @"uuid": uuid,
        @"email_address": [NSString stringWithFormat:@"%@@example.com", uuid],
        @"team": @"Test Team",
        @"employee_type": @"FULL_TIME"
    }];
    return employee;
}

- (EmployeeListResponse *)createEmployeeListResponseWithEmployees:(NSArray<Employee *> *)employees {
    NSDictionary *responseDict = @{@"employees": [self employeeArrayToDictionaryArray:employees]};
    EmployeeListResponse *response = [[EmployeeListResponse alloc] initWithDictionary:responseDict];
    return response;
}

- (NSArray *)employeeArrayToDictionaryArray:(NSArray<Employee *> *)employees {
    NSMutableArray *dictArray = [NSMutableArray array];
    for (Employee *emp in employees) {
        [dictArray addObject:@{
            @"uuid": emp.uuid ?: [NSNull null],
            @"full_name": emp.fullName ?: [NSNull null],
            @"email_address": emp.emailAddress ?: [NSNull null],
            @"team": emp.team ?: [NSNull null],
            @"employee_type": @"FULL_TIME"
        }];
    }
    return dictArray;
}

#pragma mark - Test Cases

- (void)testViewModel_InitialState {
    XCTAssertNotNil(self.viewModel, @"ViewModel should be initialized.");
    XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading initially.");
    XCTAssertNil(self.viewModel.errorMessage, @"Error message should be nil initially.");
    XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty initially.");
}

- (void)testViewModel_FetchSuccess_ValidEmployees {
    // Arrange: Mock successful response with valid employees
    Employee *emp1 = [self createValidEmployeeWithUUID:@"1"];
    Employee *emp2 = [self createValidEmployeeWithUUID:@"2"];
    EmployeeListResponse *mockResponse = [self createEmployeeListResponseWithEmployees:@[emp1, emp2]];
    self.mockService.mockEmployeeListResponse = mockResponse;
    self.mockService.mockError = nil; // Ensure no error is mocked

    // Act: Fetch employees
    // Because MockEmployeeService is now synchronous, all delegate calls
    // and ViewModel state changes happen immediately upon this line.
    [self.viewModel fetchEmployees];

    // Assert: Directly check the ViewModel and delegate's final state
    XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading after completion.");
    XCTAssertNil(self.viewModel.errorMessage, @"Error message should be nil on success.");
    XCTAssertEqual(self.viewModel.employees.count, 2, @"ViewModel should have 2 employees.");
    XCTAssertEqualObjects(self.viewModel.employees[0].fullName, emp1.fullName, @"First employee name should match.");
    XCTAssertTrue(self.mockDelegate.didUpdateDataCalled, @"Delegate's didUpdateData should be called.");
    XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
    XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO after completion.");
}

- (void)testViewModel_FetchSuccess_EmptyEmployees {
    // Arrange
    EmployeeListResponse *mockResponse = [self createEmployeeListResponseWithEmployees:@[]];
    self.mockService.mockEmployeeListResponse = mockResponse;
    self.mockService.mockError = nil;

    // Act
    [self.viewModel fetchEmployees];

    // Assert
    XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading.");
    XCTAssertNil(self.viewModel.errorMessage, @"Error message should be nil.");
    XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty.");
    XCTAssertTrue(self.mockDelegate.didUpdateDataCalled, @"Delegate's didUpdateData should be called.");
    XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
    XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO.");
}

- (void)testViewModel_FetchSuccess_MalformedEmployeeInvalidatesList {
    // Arrange
    Employee *validEmp = [self createValidEmployeeWithUUID:@"1"];
    Employee *malformedEmp = [self createMalformedEmployeeWithUUID:@"malformed"];
    EmployeeListResponse *mockResponse = [self createEmployeeListResponseWithEmployees:@[validEmp, malformedEmp]];
    self.mockService.mockEmployeeListResponse = mockResponse;
    self.mockService.mockError = nil; // No network error, but data is malformed

    // Act
    [self.viewModel fetchEmployees];

    // Assert
    XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading.");
    XCTAssertNotNil(self.viewModel.errorMessage, @"Error message should not be nil.");
    XCTAssertEqualObjects(self.viewModel.errorMessage, @"Employee List is Malformed.", @"Error message should indicate malformed list.");
    XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty due to malformed data.");
    XCTAssertTrue(self.mockDelegate.didEncounterErrorCalled, @"Delegate's didEncounterError should be called.");
    XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
    XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO.");
}

- (void)testViewModel_FetchFailure_NetworkError {
    // Arrange
    NSError *mockError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                             code:EmployeeServiceErrorCodeNetworkError
                                         userInfo:@{NSLocalizedDescriptionKey: @"Network connection failed."}];
    self.mockService.mockEmployeeListResponse = nil; // No response
    self.mockService.mockError = mockError; // Mock an error

    // Act
    [self.viewModel fetchEmployees];

    // Assert
    XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading.");
    XCTAssertNotNil(self.viewModel.errorMessage, @"Error message should not be nil.");
    XCTAssertTrue([self.viewModel.errorMessage containsString:@"Network connection failed."], @"Error message should reflect network error.");
    XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty on error.");
    XCTAssertTrue(self.mockDelegate.didEncounterErrorCalled, @"Delegate's didEncounterError should be called.");
    XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
    XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO.");
}


@end
