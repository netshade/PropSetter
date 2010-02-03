//
//  PropSetterSelector.m
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

#import "PropSetterSelector.h"

#import <objc/runtime.h>

@implementation PropSetterSelector

@synthesize className;
@synthesize clause;
@synthesize property;

-(id) init {
	if(self = [super init]){
		clause = [[PropSetterClause alloc] init];
	}
	return self;
}

-(BOOL) evaluateWithObject:(id)object andOperatorDelegate:(id<PropSetterOperatorCustomDelegate>)del {
	Class c = objc_getClass([className cStringUsingEncoding:NSUTF8StringEncoding]);
	BOOL isOfClass = [object isKindOfClass:c];
	BOOL result = isOfClass;
	if(clause){
		result = result && [clause evaluateWithObject:object andOperatorDelegate:del];
	}
	return result;
}

-(PropSetterExpression *) lastClauseExpression {
	return [[self clause] lastExpression];
}

- (id)copyWithZone:(NSZone *)zone {
	PropSetterSelector * s = [[PropSetterSelector allocWithZone:zone] init];
	[s setClause:clause];
	[s setProperty:property];
	[s setClassName:className];
	return s;
}

-(void) dealloc {
	[property release];
	[className release];
	[clause release];
	[super dealloc];
}

@end
