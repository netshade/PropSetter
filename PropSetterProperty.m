//
//  PropSetterProperty.m
//  PropSetter
//
// Copyright (c) 2010 StarMedia
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

//

#import "PropSetterProperty.h"
#import <objc/runtime.h>
#import "PropSetterError.h"

static inline NSString * NSStringToCamelCase(NSString * subject){
    NSMutableString *ret = [NSMutableString string];
	[ret appendString:[[subject substringWithRange:NSMakeRange(0, 1)] uppercaseString]];
	[ret appendString:[subject substringFromIndex:1]];
    return ret;
}

@implementation PropSetterPropertyMember

@synthesize name;

-(void) dealloc {
	[name release];
	[super dealloc];
}

@end


@implementation PropSetterProperty


-(id) init {
	if(self = [super init]){
		members = [[NSMutableArray alloc] init];
	}
	return self;
}

-(id) valueWithObject:(id)object {
	NSString * nm = [self name];
	id val = [object valueForKeyPath:nm];
	// TODO: This is a bad way to infer that the given property path is not really a keyPath
	if(!val){
		val = [object performSelector:NSSelectorFromString([members objectAtIndex:0])];
		for(int i = 1; i < [members count]; i++){
			val = [val performSelector:NSSelectorFromString([members objectAtIndex:i])];
		}
	}
	return val;
}

-(void) setPropertyOfObject:(id)object toValue:(id)value {
	id v = value;
	if([value conformsToProtocol:@protocol(PropSetterObjectWithValue)]){
		v = [value valueWithObject:object];
	}
	if([members count] > 1){
		[object setValue:v forKeyPath:[self name]];
	} else {
		[object setValue:v forKey:[self name]];
	}

}

-(NSString *) name {
	return [members componentsJoinedByString:@"."];
}

-(NSString *) affectedKeyPath {
	return [self name];
}

-(void) addMember:(PropSetterPropertyMember *)mem {
	NSString * s = [mem name];
	[members insertObject:s atIndex:0];
}

-(NSString *) description {
	return [NSString stringWithFormat:@"PropSetterProperty(NAME:%@)", [self name]];
}

-(void) dealloc {
	[members release];
	[super dealloc];
}

@end
