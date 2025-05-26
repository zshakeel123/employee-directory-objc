//
//  EmployeeDirectoryViewModelTests.m
//  EmployeeDirectoryAppTests
//
//  Created by Zeeshan Shakeel on 25/05/2025.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
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

@property (nonatomic, strong, nullable) XCTestExpectation *testExpectation;
@property (nonatomic, assign) BOOL expectationFulfilled;

@end

@implementation MockEmployeeDirectoryViewModelDelegate

- (void)employeeDirectoryViewModelDidUpdateData:(EmployeeDirectoryViewModel *)sender {
    self.didUpdateDataCalled = YES;
    
    if(!self.expectationFulfilled && self.testExpectation){
        [self.testExpectation fulfill];
        self.expectationFulfilled = YES;
    }
}

- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didUpdateLoadingState:(BOOL)isLoading {
    self.didUpdateLoadingStateCalled = YES;
    self.isLoadingState = isLoading;
    
    if(!self.expectationFulfilled && self.testExpectation){
        [self.testExpectation fulfill];
        self.expectationFulfilled = YES;
    }
}

- (void)employeeDirectoryViewModel:(EmployeeDirectoryViewModel *)sender didEncounterError:(nullable NSString *)errorMessage {
    self.didEncounterErrorCalled = YES;
    
    if(!self.expectationFulfilled && self.testExpectation){
        [self.testExpectation fulfill];
        self.expectationFulfilled = YES;
    }
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
    _expectationFulfilled = NO;
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
    self.mockService.mockError = nil;
    self.mockDelegate.testExpectation = [self expectationWithDescription:@"Test Expectation"];

    // Act: Fetch employees
    [self.viewModel fetchEmployees];
    
    // Wait a bit so as that assertion is checked after fetch Employees finishes async & viewmodel state is updated.
    [NSThread sleepForTimeInterval:0.5];
    
    // Assert: Check the ViewModel and delegate's final state
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading after completion.");
        XCTAssertNil(self.viewModel.errorMessage, @"Error message should be nil on success.");
        XCTAssertEqual(self.viewModel.employees.count, 2, @"ViewModel should have 2 employees.");
        XCTAssertEqualObjects(self.viewModel.employees[0].fullName, emp1.fullName, @"First employee name should match.");
        XCTAssertTrue(self.mockDelegate.didUpdateDataCalled, @"Delegate's didUpdateData should be called.");
        XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
        XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO after completion.");
    }];
}

- (void)testViewModel_FetchSuccess_EmptyEmployees {
    // Arrange
    EmployeeListResponse *mockResponse = [self createEmployeeListResponseWithEmployees:@[]];
    self.mockService.mockEmployeeListResponse = mockResponse;
    self.mockService.mockError = nil;
    self.mockDelegate.testExpectation = [self expectationWithDescription:@"Test Expectation"];

    // Act
    [self.viewModel fetchEmployees];
    
    // Wait a bit so as that assertion is checked after fetch Employees finishes async & viewmodel state is updated.
    [NSThread sleepForTimeInterval:0.5];
    
    // Assert: Check the ViewModel and delegate's final state
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading.");
        XCTAssertNil(self.viewModel.errorMessage, @"Error message should be nil.");
        XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty.");
        XCTAssertTrue(self.mockDelegate.didUpdateDataCalled, @"Delegate's didUpdateData should be called.");
        XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
        XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO.");
    }];
}

- (void)testViewModel_FetchSuccess_MalformedEmployeeInvalidatesList {
    // Arrange
    Employee *validEmp = [self createValidEmployeeWithUUID:@"1"];
    Employee *malformedEmp = [self createMalformedEmployeeWithUUID:@"malformed"];
    EmployeeListResponse *mockResponse = [self createEmployeeListResponseWithEmployees:@[validEmp, malformedEmp]];
    self.mockService.mockEmployeeListResponse = mockResponse;
    self.mockService.mockError = nil; // No network error, but data is malformed
    self.mockDelegate.testExpectation = [self expectationWithDescription:@"Test Expectation"];

    // Act
    [self.viewModel fetchEmployees];
    
    // Wait a bit so as that assertion is checked after fetch Employees finishes async & viewmodel state is updated.
    [NSThread sleepForTimeInterval:0.5];
    
    // Assert: Check the ViewModel and delegate's final state
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading.");
        XCTAssertNotNil(self.viewModel.errorMessage, @"Error message should not be nil.");
        XCTAssertEqualObjects(self.viewModel.errorMessage, @"Employee List is Malformed.", @"Error message should indicate malformed list.");
        XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty due to malformed data.");
        XCTAssertTrue(self.mockDelegate.didEncounterErrorCalled, @"Delegate's didEncounterError should be called.");
        XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
        XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO.");
    }];
}

- (void)testViewModel_FetchFailure_NetworkError {
    // Arrange
    NSError *mockError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                             code:EmployeeServiceErrorCodeNetworkError
                                         userInfo:@{NSLocalizedDescriptionKey: @"Network connection failed."}];
    self.mockService.mockEmployeeListResponse = nil; // No response
    self.mockService.mockError = mockError; // Mock an error
    self.mockDelegate.testExpectation = [self expectationWithDescription:@"Test Expectation"];

    // Act
    [self.viewModel fetchEmployees];
    
    // Wait a bit so as that assertion is checked after fetch Employees finishes async & viewmodel state is updated.
    [NSThread sleepForTimeInterval:0.5];
    
    // Assert: Check the ViewModel and delegate's final state
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading.");
        XCTAssertNotNil(self.viewModel.errorMessage, @"Error message should not be nil.");
        XCTAssertTrue([self.viewModel.errorMessage containsString:@"Network connection failed."], @"Error message should reflect network error.");
        XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty on error.");
        XCTAssertTrue(self.mockDelegate.didEncounterErrorCalled, @"Delegate's didEncounterError should be called.");
        XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
        XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO.");
    }];
}

- (void)testViewModel_FetchFailure_JSONParsingError {
    // Arrange: Mock JSON parsing error
    NSError *mockError = [NSError errorWithDomain:EmployeeServiceErrorDomain
                                             code:EmployeeServiceErrorCodeJSONParsingFailed
                                         userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse JSON."}];
    self.mockService.mockEmployeeListResponse = nil;
    self.mockService.mockError = mockError;
    self.mockDelegate.testExpectation = [self expectationWithDescription:@"Test Expectation"];

    // Act
    [self.viewModel fetchEmployees];
    
    // Wait a bit so as that assertion is checked after fetch Employees finishes async & viewmodel state is updated.
    [NSThread sleepForTimeInterval:0.5];
    
    // Assert: Check the ViewModel and delegate's final state
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        XCTAssertFalse(self.viewModel.isLoading, @"ViewModel should not be loading.");
        XCTAssertNotNil(self.viewModel.errorMessage, @"Error message should not be nil.");
        XCTAssertTrue([self.viewModel.errorMessage containsString:@"Failed to read employee data."], @"Error message should reflect parsing error.");
        XCTAssertEqual(self.viewModel.employees.count, 0, @"Employees array should be empty on error.");
        XCTAssertTrue(self.mockDelegate.didEncounterErrorCalled, @"Delegate's didEncounterError should be called.");
        XCTAssertTrue(self.mockDelegate.didUpdateLoadingStateCalled, @"Delegate's didUpdateLoadingState should have been called.");
        XCTAssertFalse(self.mockDelegate.isLoadingState, @"Delegate should report loading state as NO.");
    }];
}

- (void)testViewModel_InitializationWithNilService {
    // Arrange: Attempt to initialize ViewModel with a nil service
    EmployeeDirectoryViewModel *nilServiceViewModel = [[EmployeeDirectoryViewModel alloc] initWithEmployeeService:nil];

    // Assert: The initializer should return nil if the service is nil,
    // Based on your ViewModel's `initWithEmployeeService:`, it returns nil if service is nil.
    XCTAssertNil(nilServiceViewModel, @"ViewModel should return nil if initialized with a nil EmployeeService.");
}

@end
