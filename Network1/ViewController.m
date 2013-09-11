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

@synthesize locationManager, latitudeString, longitudeString, activityIndictor, parser, rootElement, currentElementPointer, forecastArray;

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.latitudeString = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longitudeString = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    self.enabledGeo = YES;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error.description);
    self.enabledGeo = NO;
    
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
    
    
    

    self.actualTemp.text = nil;
    self.actualPeopleTemp.text = nil;
    self.mainForecastImage.image = nil;
    self.actualHum.text = nil;
    self.actualPress.text = nil;
}

- (void) viewDidUnload
{
    [super viewDidUnload];
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%@", textField.text);
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
    if(self.enabledGeo)
    {
        if (self.geoSwitch.on)//проверка доступности геолокации
        {
            
            self.latitude.text = self.latitudeString;
            self.longitude.text = self.longitudeString;
        }else
        {
            self.latitudeString = self.latitude.text;
            self.longitudeString = self.longitude.text;        
        }
        //NSString *country =nil;
        //запрос на получение наименования местности
        NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/xml?latlng=%@,%@&sensor=true", self.latitude.text, self.longitude.text];
        NSLog(@"%@", urlString);
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.f];
        NSURLResponse *response;
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
        if (error == NULL)
        {
            self.forecastArray = nil;
            if ([data length] >0 && error == nil)
            {
                NSData *xml = [[NSData alloc] initWithData:data];
                self.parser = [[NSXMLParser alloc] initWithData:xml];
                self.parser.delegate = self;
                [self.parser parse];
                
                self.view.userInteractionEnabled = YES;
                
                self.addressLine.text = nil;
                self.cityName = nil;
                BOOL allDoneNow = NO;
                BOOL isTrue = NO;
                for (XMLElement *item in self.rootElement.subElement )
                {
                    if ([item.text isEqualToString:@"ZERO_RESULTS"])
                    {
                        //если гугл не знает что за место
                        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось установить местоположение" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
                        [errorView show];
                    }else
                    {
                        self.addressLine.text = [[[[self.rootElement.subElement objectAtIndex:1] subElement] objectAtIndex:1] text];
                        NSString *country =nil;
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
                        
                        
                        NSURL  *url1 = [NSURL URLWithString:[[NSString stringWithFormat:@"http://xml.weather.co.ua/1.2/city/?search=%@", self.cityName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        NSLog(@"%@", url1);
                        urlRequest = [NSURLRequest requestWithURL:url1 cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.f];
                        data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
                        //NSLog(@"++++++++++++++++ %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                        if ([data length] >0 && error == nil)
                        {
                            NSData *xml = [[NSData alloc] initWithData:data];
                            self.parser = [[NSXMLParser alloc] initWithData:xml];
                            self.parser.delegate = self;
                            [self.parser parse];
                            self.view.userInteractionEnabled = YES;
                        }
                        
                        NSInteger *cityID = nil;
                        for (XMLElement *item in [[self.rootElement.subElement objectAtIndex:0] subElement] )
                        {
                            
                            if ([item.name isEqualToString:@"country"] && [item.text isEqualToString:(@"%@", country)])
                            {
                                cityID = [[item.parent.attributes objectForKey:@"id"] integerValue];
                                break;
                            }
                        }
                        
                        NSURL  *url2 = [NSURL URLWithString:[[NSString stringWithFormat:@"http://xml.weather.co.ua/1.2/forecast/%ld?dayf=5&userid=&lang=ru", (long)cityID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        NSLog(@"%@", url2);
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
                        
                        self.forecastArray = [[NSMutableArray alloc] init];
                        // NSLog(@"++++++++++++++++ %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                        for (XMLElement *item in self.rootElement.subElement )
                        {
                            if ([item.text isEqualToString:@"CityID wrong or not found"])
                            {
                                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Для данной местности нет прогноза погоды..." delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
                                [errorView show];
                            }else
                            {
                                self.actualCityName.text = self.cityName;
                                int i = 0;
                                int j = 0;
                                if ([[[self.rootElement.subElement objectAtIndex:2] name] isEqualToString:@"current"] && [[[self.rootElement.subElement objectAtIndex:2] attributes] count] !=0 )
                                {
                                    i = 3; j = 0;
                                    
                                    //NSDate *date = [NSDate date];
                                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
                                    [dateFormat setDateFormat:@"dd.MM.YYYY"];
                                    
                                    self.actualTemp.text = [NSString stringWithFormat:@"%@", [[[[self.rootElement.subElement objectAtIndex:2] subElement] objectAtIndex:3] text]];
                                    self.actualPeopleTemp.text = [NSString stringWithFormat:@"%@", [[[[self.rootElement.subElement objectAtIndex:2] subElement] objectAtIndex:4] text]];
                                    self.mainForecastImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"_%@", [[[[self.rootElement.subElement objectAtIndex:2] subElement] objectAtIndex:2] text]] ];
                                    self.actualHum.text = [NSString stringWithFormat:@"%@", [[[[self.rootElement.subElement objectAtIndex:2] subElement] objectAtIndex:9] text]];
                                    self.actualPress.text = [NSString stringWithFormat:@"%@", [[[[self.rootElement.subElement objectAtIndex:2] subElement] objectAtIndex:5] text]];
                                    
                                    
                                }else
                                {
                                    if ([[[self.rootElement.subElement objectAtIndex:2] name] isEqualToString:@"current"])
                                    {
                                        i = 3; 
                                        
                                    }else
                                    {
                                        i = 2;
                                    }
                                    j = 4;
                                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
                                    [dateFormat setDateFormat:@"dd.MM.YYYY"];
                                    
                                    self.actualTemp.text = [NSString stringWithFormat:@"%@", [[[[[[[[self.rootElement.subElement objectAtIndex:i] subElement] objectAtIndex:0] subElement] objectAtIndex:3] subElement] objectAtIndex:0] text]];
                                    self.actualPeopleTemp.text =  @"N/A";
                                    self.mainForecastImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"_%@", [[[[[[self.rootElement.subElement objectAtIndex:i] subElement] objectAtIndex:0] subElement] objectAtIndex:1] text]] ];
                                    self.actualHum.text = [NSString stringWithFormat:@"%@", [[[[[[[[self.rootElement.subElement objectAtIndex:i] subElement] objectAtIndex:0] subElement] objectAtIndex:6] subElement] objectAtIndex:0] text]];
                                    self.actualPress.text = [NSString stringWithFormat:@"%@", [[[[[[[[self.rootElement.subElement objectAtIndex:i] subElement] objectAtIndex:0] subElement] objectAtIndex:4] subElement] objectAtIndex:0] text]];
                                    
                                }
                                NSMutableArray *dateArray = [[NSMutableArray alloc] initWithObjects:self.date1, self.date2, self.date3, self.date4, self.date5, nil];
                                NSMutableArray *imageArray = [[NSMutableArray alloc] initWithObjects:self.image1, self.image2, self.image3, self.image4, self.image5, nil];
                                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithObjects:self.temp1, self.temp2, self.temp3, self.temp4, self.temp5, nil];
                                int k = 0;
                            for (int ii=j; ii<20; ii+=4)
                            {
                                XMLElement *item = [[XMLElement alloc] init];
                                item = [[[[self.rootElement subElement] objectAtIndex:i] subElement] objectAtIndex:ii];
                                [[dateArray objectAtIndex:k] setText:[item.attributes objectForKey:@"date"]];
                                [[imageArray objectAtIndex:k] setImage:[UIImage imageNamed:[[item.subElement objectAtIndex:1] text]]];
                                if ([[[[item.subElement objectAtIndex:3] subElement] objectAtIndex:0] text ] > 0)
                                {
                                    NSString *tempString = [NSString stringWithFormat:@"+ %@", [[[[item.subElement objectAtIndex:3] subElement] objectAtIndex:0] text ]];
                                    [[tempArray objectAtIndex:k] setText:tempString];
                                }else
                                {
                                    [[tempArray objectAtIndex:k] setText:[[[[item.subElement objectAtIndex:3] subElement] objectAtIndex:0] text]];
                                }

                                
                                k++;
                            }
                             
            
                            }
                            break;
                        }
                        break;
                    }
                }
            }
        }else
        {
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось подключится к Интернет, проверьте подключение" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
            [errorView show];
        }
            
    }else
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось установить местоположение, отключена служба геолокации для приложения" delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles: nil];
        [errorView show];
    }
    self.view.userInteractionEnabled = YES;
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

- (IBAction)setEditing:(id)sender
{
    bool longt = self.longitude.enabled;
    bool latti = self.latitude.enabled;
    self.longitude.enabled = !longt;
    self.latitude.enabled = !latti;
}
@end
