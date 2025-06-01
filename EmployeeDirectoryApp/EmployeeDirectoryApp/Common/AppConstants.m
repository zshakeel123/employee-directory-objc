//
//  AppConstants.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import "AppConstants.h"

// API Urls
NSString *const kEmployeeAPIURLEmployees = @"https://s3.amazonaws.com/sq-mobile-interview/employees.json";
NSString *const kEmployeeAPIURLEmptyList = @"https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json";
NSString *const kEmployeeAPIURLMalformed = @"https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json";
NSString *const kEmployeeAPIBaseURL = kEmployeeAPIURLEmployees;

// Segues
NSString *const kShowEmployeeDetailSegueIdentifier = @"ShowEmployeeDetailSegue";

