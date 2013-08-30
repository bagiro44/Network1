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

@synthesize locationManager, latitudeString, longitudeString, activityIndictor, parser, rootElement, currentElementPointer;

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
    self.dateLabel.text = @"";
    self.tempLabel.text = @"";
    while ((self.longitudeString == nil || self.latitudeString == nil))
    {
        nil;
    }
    if ([self.latitude.text length] == 0 && [self.longitude.text length]== 0)
    {
        self.latitude.text = self.latitudeString;
        self.longitude.text = self.longitudeString;
    }else
    {
        self.latitudeString = self.latitude.text;
        self.longitudeString = self.longitude.text;        
    }
    NSString *country =nil;
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?latlng=%@,%@&sensor=true", self.latitude.text, self.longitude.text];
    NSLog(@"%@", urlString);
     NSURL *url = [[NSURL alloc] initWithString:urlString];
     NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.f];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
     if ([data length] >0 && error == nil)
     {
         NSData *xml = [[NSData alloc] initWithData:data];
         self.parser = [[NSXMLParser alloc] initWithData:xml];
         self.parser.delegate = self;
         [self.parser parse];
         self.view.userInteractionEnabled = YES;
         self.addressLine.text = [[[[self.rootElement.subElement objectAtIndex:1] subElement] objectAtIndex:1] text];
         self.cityName = nil;
         BOOL allDoneNow = NO;
         BOOL isTrue = NO;
         //NSString *country =nil;
         for (XMLElement *item in [[self.rootElement.subElement objectAtIndex:1] subElement] )
         {
             for (XMLElement *item1 in item.subElement)
             {
                 if ([item1.name isEqualToString:@"long_name"] && isTrue == NO)
                 {
                     self.cityName = item1.text;
                 }
                 if ([item1.text isEqualToString:@"locality"])
                 {
                     //NSLog(@"%@", self.cityName);
                     isTrue = YES;
                     break;
                 }
                 if ([item1.name isEqualToString:@"long_name"] && allDoneNow == NO)
                 {
                     country = item1.text;
                 }
                 if ([item1.text isEqualToString:@"country"])
                 {
                     //NSLog(@"%@", self.cityName);
                     allDoneNow = YES;
                     break;
                 }
                 
             }
             if ((isTrue && allDoneNow) == YES) break;
         }
         NSLog(@"%@", self.cityName);
         NSLog(@"%@", country);
         
         self.test.text = [[[[[[self.rootElement.subElement objectAtIndex:1] subElement] objectAtIndex:5] subElement] objectAtIndex:0] text];
     }

    
    NSURL  *url1 = [NSURL URLWithString:[[NSString stringWithFormat:@"http://xml.weather.co.ua/1.2/city/?search=%@", self.cityName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [NSURLRequest requestWithURL:url1 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.f];
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if ([data length] >0 && error == nil)
    {
        NSData *xml = [[NSData alloc] initWithData:data];
        self.parser = [[NSXMLParser alloc] initWithData:xml];
        self.parser.delegate = self;
        [self.parser parse];
        self.view.userInteractionEnabled = YES;
    }
    
    NSInteger cityID;
    for (XMLElement *item in [[self.rootElement.subElement objectAtIndex:0] subElement] )
    {
        
        if ([item.name isEqualToString:@"country"] && [item.text isEqualToString:(@"%@", country)])
        {
            cityID = [[item.parent.attributes objectForKey:@"id"] integerValue];
        }
    }
    
    NSURL  *url2 = [NSURL URLWithString:[[NSString stringWithFormat:@"http://xml.weather.co.ua/1.2/forecast/%ld?dayf=5&userid=&lang=ru", (long)cityID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    urlRequest = [NSURLRequest requestWithURL:url2 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.f];
    data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if ([data length] >0 && error == nil)
    {
        NSData *xml = [[NSData alloc] initWithData:data];
        self.parser = [[NSXMLParser alloc] initWithData:xml];
        self.parser.delegate = self;
        [self.parser parse];
        self.view.userInteractionEnabled = YES;
    }
    self.dateLabel.hidden = NO;
    self.tempLabel.hidden = NO;
    for (XMLElement *item in [[self.rootElement.subElement objectAtIndex:3] subElement])
    {
        self.dateLabel.text = [NSString stringWithFormat:@"%@ \n %@   %@.00", self.dateLabel.text, [item.attributes objectForKey:@"date"], [item.attributes objectForKey:@"hour"]];
        self.tempLabel.text = [NSString stringWithFormat:@"%@  \n %@ C", self.tempLabel.text, [[[[item.subElement objectAtIndex:3] subElement] objectAtIndex:0] text]];
    }
    
    
    
    [activityIndictor stopAnimating];
    
}

#pragma XMLParsing
#pragma -

- (void) parserDidStartDocument:(NSXMLParser *)parser
{
    self.rootElement = nil;
    self.currentElementPointer = nil;
}

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (self.rootElement == nil)
    {
        self.rootElement = [[XMLElement alloc] init];
        self.currentElementPointer = self.rootElement;
    }else
    {
        XMLElement *newElement = [[XMLElement alloc] init];
        newElement.parent = self.currentElementPointer;
        [self.currentElementPointer.subElement addObject:newElement];
        self.currentElementPointer = newElement;
    }
    self.currentElementPointer.name = elementName;
    self.currentElementPointer.attributes = attributeDict;
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([self.currentElementPointer.text length] > 0)
    {
        self.currentElementPointer.text = [self.currentElementPointer.text stringByAppendingString:string];
    } else {
        self.currentElementPointer.text = string;
    }
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    self.currentElementPointer = self.currentElementPointer.parent;
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    self.currentElementPointer = nil;
}
@end
