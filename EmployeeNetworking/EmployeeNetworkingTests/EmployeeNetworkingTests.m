//
//  EmployeeNetworkingTests.m
//  EmployeeNetworkingTests
//
//  Created by Zeeshan Shakeel on 22/05/2025.
//

#import <XCTest/XCTest.h>
#import <EmployeeNetworking/EmployeeService.h>
#import <EmployeeNetworking/EmployeeListResponse.h>
#import <EmployeeNetworking/Employee.h>
#import "MockURLSession.h"


// Define the error domain constants for access in tests
extern NSString *const EmployeeServiceErrorDomain;


@interface EmployeeNetworkingTests : XCTestCase

@end

@implementation EmployeeNetworkingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Helper Methods for Test Data

- (NSData *)sampleValidEmployeeJSONData {
    NSString *jsonString = @"{\"employees\":[{\"uuid\":\"1\",\"full_name\":\"John Doe\",\"email_address\":\"john.doe@example.com\",\"team\":\"Engineering\",\"employee_type\":\"FULL_TIME\"}]}";
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)sampleInvalidEmployeeJSONData {
    // Missing "employees" array, or malformed JSON
    NSString *jsonString = @"{\"malformed\": \"data\"}";
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Test Cases

- (void)testFetchEmployees_Success {
    // 1. Arrange: Prepare mock data
    NSData *mockData = [self sampleValidEmployeeJSONData];
    NSURLResponse *mockResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://test.com"] statusCode:200 HTTPVersion:nil headerFields:nil];

    // Configure the mock session
    MockURLSession *mockSession = [[MockURLSession alloc] init];
    mockSession.mockData = mockData;
    mockSession.mockResponse = mockResponse;
    mockSession.mockError = nil;

    // Create the service with the mock session
    EmployeeService *service = [[EmployeeService alloc] initWithBaseURLString:@"https://test.com" andSession:(NSURLSession *)mockSession];
    XCTAssertNotNil(service, @"Service should be initialized.");

    // Create an XCTestExpectation to wait for the async callback
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch employees success"];

    // 2. Act: Call the method under test
    [service fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        // 3. Assert: Verify the results
        XCTAssertNil(error, @"Error should be nil on success.");
        XCTAssertNotNil(employeeList, @"Employee list should not be nil.");
        XCTAssertTrue(employeeList.employees.count == 1, @"Should parse 1 employee.");
        XCTAssertTrue([employeeList.employees.firstObject isKindOfClass:[Employee class]], @"First object should be an Employee.");

        Employee *employee = employeeList.employees.firstObject;
        XCTAssertEqualObjects(employee.fullName, @"John Doe", @"Full name should match.");
        XCTAssertEqual(employee.employeeType, EmployeeTypeFullTime, @"Employee type should be FULL_TIME.");

        // Fulfill the expectation to signal the test is complete
        [expectation fulfill];
    }];

    // Wait for the expectation to be fulfilled (or timeout)
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFetchEmployees_NetworkError {
    // 1. Arrange: Prepare mock error
    NSError *mockError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:nil];

    MockURLSession *mockSession = [[MockURLSession alloc] init];
    mockSession.mockData = nil;
    mockSession.mockResponse = nil;
    mockSession.mockError = mockError;

    EmployeeService *service = [[EmployeeService alloc] initWithBaseURLString:@"https://test.com" andSession:(NSURLSession *)mockSession];
    XCTAssertNotNil(service, @"Service should be initialized.");

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch employees network error"];

    // 2. Act
    [service fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        // 3. Assert
        XCTAssertNil(employeeList, @"Employee list should be nil on network error.");
        XCTAssertNotNil(error, @"Error should not be nil.");
        XCTAssertEqualObjects(error.domain, EmployeeServiceErrorDomain, @"Error domain should be service's domain.");
        XCTAssertEqual(error.code, EmployeeServiceErrorCodeNetworkError, @"Error code should indicate network error.");
        XCTAssertTrue([error.localizedDescription containsString:@"Network request failed."], @"Error description should be correct.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFetchEmployees_InvalidJSON {
    // 1. Arrange
    NSData *mockData = [@"Invalid JSON" dataUsingEncoding:NSUTF8StringEncoding];
    NSURLResponse *mockResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://test.com"] statusCode:200 HTTPVersion:nil headerFields:nil];

    MockURLSession *mockSession = [[MockURLSession alloc] init];
    mockSession.mockData = mockData;
    mockSession.mockResponse = mockResponse;
    mockSession.mockError = nil;

    EmployeeService *service = [[EmployeeService alloc] initWithBaseURLString:@"https://test.com" andSession:(NSURLSession *)mockSession];
    XCTAssertNotNil(service, @"Service should be initialized.");

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch employees invalid JSON"];

    // 2. Act
    [service fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        // 3. Assert
        XCTAssertNil(employeeList, @"Employee list should be nil on invalid JSON.");
        XCTAssertNotNil(error, @"Error should not be nil.");
        XCTAssertEqualObjects(error.domain, EmployeeServiceErrorDomain, @"Error domain should be service's domain.");
        XCTAssertEqual(error.code, EmployeeServiceErrorCodeJSONParsingFailed, @"Error code should indicate JSON parsing failure.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFetchEmployees_Non200StatusCode {
    // 1. Arrange
    NSData *mockData = [self sampleValidEmployeeJSONData]; // Data can be valid, but status code implies error
    NSURLResponse *mockResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://test.com"] statusCode:404 HTTPVersion:nil headerFields:nil]; // 404 Not Found

    MockURLSession *mockSession = [[MockURLSession alloc] init];
    mockSession.mockData = mockData;
    mockSession.mockResponse = mockResponse;
    mockSession.mockError = nil;

    EmployeeService *service = [[EmployeeService alloc] initWithBaseURLString:@"https://test.com" andSession:(NSURLSession *)mockSession];
    XCTAssertNotNil(service, @"Service should be initialized.");

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch employees non-200 status code"];

    // 2. Act
    [service fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        // 3. Assert
        XCTAssertNil(employeeList, @"Employee list should be nil on non-200 status code.");
        XCTAssertNotNil(error, @"Error should not be nil.");
        XCTAssertEqualObjects(error.domain, EmployeeServiceErrorDomain, @"Error domain should be service's domain.");
        XCTAssertEqual(error.code, 404, @"Error code should be 404."); // Using HTTP status as error code
        XCTAssertTrue([error.localizedDescription containsString:@"Server returned non-200 status code: 404"], @"Error description should be correct.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testFetchEmployees_NoData {
    // 1. Arrange
    NSData *mockData = nil; // Simulate no data received
    NSURLResponse *mockResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"https://test.com"] statusCode:200 HTTPVersion:nil headerFields:nil];

    MockURLSession *mockSession = [[MockURLSession alloc] init];
    mockSession.mockData = mockData;
    mockSession.mockResponse = mockResponse;
    mockSession.mockError = nil;

    EmployeeService *service = [[EmployeeService alloc] initWithBaseURLString:@"https://test.com" andSession:(NSURLSession *)mockSession];
    XCTAssertNotNil(service, @"Service should be initialized.");

    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch employees no data"];

    // 2. Act
    [service fetchEmployeesWithCompletion:^(EmployeeListResponse * _Nullable employeeList, NSError * _Nullable error) {
        // 3. Assert
        XCTAssertNil(employeeList, @"Employee list should be nil when no data.");
        XCTAssertNotNil(error, @"Error should not be nil.");
        XCTAssertEqualObjects(error.domain, EmployeeServiceErrorDomain, @"Error domain should be service's domain.");
        XCTAssertEqual(error.code, EmployeeServiceErrorCodeNoData, @"Error code should indicate no data.");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

@end

