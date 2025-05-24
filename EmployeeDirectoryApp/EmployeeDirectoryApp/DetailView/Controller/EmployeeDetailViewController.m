//
//  EmployeeDetailViewController.m
//  EmployeeDirectoryApp
//
//  Created by Zeeshan Shakeel on 24/05/2025.
//

#import "EmployeeDetailViewController.h"

@interface EmployeeDetailViewController ()
// No additional private properties needed here, as all UI elements are IBOutlets
@end

@implementation EmployeeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Employee Details";
    self.view.backgroundColor = [UIColor systemBackgroundColor]; // Adapts to dark/light mode
    
    [self setupInitialUIState];

    [self configureUI];
}

#pragma mark - UI Configuration

// Initial setup of UI (e.g., placeholders, default states)
- (void)setupInitialUIState {
    // Apply basic styling/placeholders that don't depend on ViewModel data
    self.employeePhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.employeePhotoImageView.clipsToBounds = YES;
    self.employeePhotoImageView.layer.cornerRadius = (self.employeePhotoImageView.bounds.size.width / 2.0); // Will adjust in configureUI after constraints
    self.employeePhotoImageView.backgroundColor = [UIColor systemGray5Color]; // Placeholder background
    self.employeePhotoImageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"]; // Default SF Symbols placeholder
    self.employeePhotoImageView.tintColor = [UIColor systemGrayColor];

    // Hide activity indicator initially
    [self.photoActivityIndicator stopAnimating];

    // Basic label styling
    self.fullNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
    self.fullNameLabel.textColor = [UIColor labelColor];
    self.fullNameLabel.textAlignment = NSTextAlignmentCenter;

    self.teamLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2];
    self.teamLabel.textColor = [UIColor secondaryLabelColor];
    self.teamLabel.textAlignment = NSTextAlignmentCenter;

    self.employeeTypeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.employeeTypeLabel.textColor = [UIColor tertiaryLabelColor];
    self.employeeTypeLabel.textAlignment = NSTextAlignmentCenter;

    // Detail labels
    self.phoneLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.phoneLabel.textColor = [UIColor labelColor];
    self.phoneLabel.textAlignment = NSTextAlignmentLeft;
    
    self.emailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.emailLabel.textColor = [UIColor labelColor];
    self.emailLabel.textAlignment = NSTextAlignmentLeft;
    
    self.biographyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.biographyLabel.textColor = [UIColor labelColor];
    self.biographyLabel.textAlignment = NSTextAlignmentLeft;
    self.biographyLabel.numberOfLines = 0; // Allow multiple lines for biography
}

- (void)configureUI {
    if (!self.viewModel) {
        NSLog(@"Error: EmployeeDetailViewModel not set for EmployeeDetailViewController.");
        return;
    }

    // Populate labels
    self.fullNameLabel.text = self.viewModel.fullName;
    self.teamLabel.text = self.viewModel.team;
    self.employeeTypeLabel.text = self.viewModel.employeeType;

    // Handle optional fields: hide parent stack view if data is missing
    self.phoneLabel.text = self.viewModel.phoneNumber;
    self.phoneStackView.hidden = (self.viewModel.phoneNumber == nil || self.viewModel.phoneNumber.length == 0);

    self.emailLabel.text = self.viewModel.emailAddress;
    self.emailStackView.hidden = (self.viewModel.emailAddress == nil || self.viewModel.emailAddress.length == 0);

    self.biographyLabel.text = self.viewModel.biography;
    self.biographyStackView.hidden = (self.viewModel.biography == nil || self.viewModel.biography.length == 0);


    // --- Image Loading ---
    [self.photoActivityIndicator startAnimating];
    
    NSURL *imageURL = self.viewModel.photoURLLarge;

    if (imageURL) {
        __weak typeof(self) weakSelf = self;
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return; // View controller might have been deallocated

            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.photoActivityIndicator stopAnimating]; // Stop indicator on main thread
                strongSelf.photoActivityIndicator.hidden = YES;
                if (error) {
                    NSLog(@"Error loading detail image: %@", error.localizedDescription);
                    strongSelf.employeePhotoImageView.image = [UIImage systemImageNamed:@"exclamationmark.circle.fill"]; // Error placeholder
                    strongSelf.employeePhotoImageView.tintColor = [UIColor systemRedColor];
                } else if (data) {
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        strongSelf.employeePhotoImageView.image = image;
                        strongSelf.employeePhotoImageView.tintColor = nil; // Remove tint for actual image
                    } else {
                        strongSelf.employeePhotoImageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"]; // Fallback if data is not an image
                        strongSelf.employeePhotoImageView.tintColor = [UIColor systemGrayColor];
                    }
                } else {
                    strongSelf.employeePhotoImageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"]; // Fallback if no data
                    strongSelf.employeePhotoImageView.tintColor = [UIColor systemGrayColor];
                }
            });
        }];
        [dataTask resume];
    } else {
        // No image URL provided, stop indicator and show default placeholder
        [self.photoActivityIndicator stopAnimating];
        self.employeePhotoImageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"];
        self.employeePhotoImageView.tintColor = [UIColor systemGrayColor];
    }
}

// Ensure the photo image view is circular after its size is determined by Auto Layout
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.employeePhotoImageView.layer.cornerRadius = self.employeePhotoImageView.bounds.size.width / 2.0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
