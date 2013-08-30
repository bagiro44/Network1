//
//  ViewController.h
//  Network1
//
//  Created by Dmitriy Remezov on 28.08.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "XMLElement.h"

@interface ViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, NSXMLParserDelegate>

- (IBAction)getWeather:(id)sender;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property NSXMLParser *parser;

@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;
@property (weak, nonatomic) IBOutlet UILabel *addressLine;
@property (weak, nonatomic) IBOutlet UILabel *test;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;

@property NSString *latitudeString;
@property NSString *longitudeString;
@property NSString *cityName;

@property XMLElement *rootElement;
@property XMLElement *currentElementPointer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndictor;


@end
