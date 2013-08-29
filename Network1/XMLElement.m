//
//  XMLElement.m
//  Network1
//
//  Created by Dmitriy Remezov on 30.08.13.
//  Copyright (c) 2013 Dmitriy Remezov. All rights reserved.
//

#import "XMLElement.h"

@implementation XMLElement

@synthesize name, text, attributes, subElement, parent;

- (NSMutableArray *) subElement
{
    if (subElement == nil)
    {
        subElement = [[NSMutableArray alloc] init];
    }
    return subElement;
}

@end
