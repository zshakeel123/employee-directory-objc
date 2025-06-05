//
//  AppConstants.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 23/05/2025.
//

#import "AppConstants.h"

// API Urls
NSString *const kEmployeeAPIURLEmployees = @"https://dummyjson.com/c/9bb7-7c58-4a98-93a7"; //@"https://s3.amazonaws.com/sq-mobile-interview/employees.json";
NSString *const kEmployeeAPIURLEmptyList = @"https://dummyjson.com/c/f54b-e6d1-4835-8a0f"; //@"https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json";
NSString *const kEmployeeAPIURLMalformed = @"https://dummyjson.com/c/850c-1043-4724-b862"; //@"https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json";
NSString *const kEmployeeAPIBaseURL = kEmployeeAPIURLEmployees;

// Segues
NSString *const kShowEmployeeDetailSegueIdentifier = @"ShowEmployeeDetailSegue";

