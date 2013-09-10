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
#import "forecastClass.h"

@interface ViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, NSXMLParserDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

- (IBAction)getWeather:(id)sender;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property NSXMLParser *parser;
@property BOOL *enabledGeo;

@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;
@property (weak, nonatomic) IBOutlet UILabel *addressLine;
@property (weak, nonatomic) IBOutlet UISwitch *geoSwitch;

@property (weak, nonatomic) IBOutlet UILabel *actualCityName;
@property (weak, nonatomic) IBOutlet UILabel *actualTemp;
@property (weak, nonatomic) IBOutlet UILabel *actualPress;
@property (weak, nonatomic) IBOutlet UIImageView *mainForecastImage;
@property (weak, nonatomic) IBOutlet UILabel *actualPeopleTemp;
@property (weak, nonatomic) IBOutlet UILabel *actualHum;

- (IBAction)setEditing:(id)sender;



@property NSMutableArray *forecastArray;





@property NSString *latitudeString;
@property NSString *longitudeString;
@property NSString *cityName;

@property XMLElement *rootElement;
@property XMLElement *currentElementPointer;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndictor;


@end
