//
//  XMLElement.h
//  Network1
//
//  Created by Dmitriy Remezov on 30.08.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLElement : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, strong) NSMutableArray *subElement;
@property (nonatomic, weak) XMLElement *parent;

@end
