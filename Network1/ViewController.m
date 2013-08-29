//
//  ViewController.m
//  Network1
//
//  Created by Dmitriy Remezov on 28.08.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize locationManager, latitudeString, longitudeString, activityIndictor, parser;

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.latitudeString = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longitudeString = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error.description);
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.purpose = @"Разрешить приложению использовать службы геолокации?";
        [self.locationManager startUpdatingLocation];
   }else
    {
        NSLog(@"Location manager not enabled");
    }    
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)getWeather:(id)sender
{
    self.view.userInteractionEnabled = NO;
    activityIndictor.hidden = NO;
    [activityIndictor startAnimating];
    [self performSelector:@selector(showWeather) withObject:nil afterDelay:0.1f];
    
}

- (void) showWeather
{
    while ((self.longitudeString == nil || self.latitudeString == nil))
    {
        nil;
    }
     NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?latlng=%@,%@&sensor=true", self.latitudeString, self.longitudeString];
     NSURL *url = [[NSURL alloc] initWithString:urlString];
     NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
     NSOperationQueue *queue = [[NSOperationQueue alloc] init];
     
     [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
     if ([data length] >0 && error == nil)
     {
         NSString *city = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         NSData *xml = [[NSData alloc] initWithData:data];
         self.parser = [[NSXMLParser alloc] initWithData:xml];
         self.parser.delegate = self;
         
     NSLog(@"City %@", city);
     
     }
     
     }];
    [self.activityIndictor stopAnimating];
    self.view.userInteractionEnabled = YES;

}

@end
