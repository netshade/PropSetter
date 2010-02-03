//
//  PropSetterExpression.m
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

#import "PropSetterExpression.h"
#import "PropSetterError.h"

@implementation PropSetterExpression

@synthesize lvalue;
@synthesize rvalue;
@synthesize op;
@synthesize next;
@synthesize level;
@synthesize empty;

-(id) init {
	if(self = [super init]){
		empty = YES;
	}
	return self;
}

-(void) setLvalue:(id<PropSetterObjectWithValue>) lval {
	[lvalue release];
	lvalue = [lval retain];
	empty = NO;
}

-(void) setRvalue:(id<PropSetterObjectWithValue>) rval {
	[rvalue release];
	rvalue = [rval retain];
	empty = NO;
}

-(NSString *) description {
	return [NSString stringWithFormat:@"PropSetterExpression(LVALUE: %@, RVALUE: %@, OP: %i, NEXT: %i, LEVEL: %i, EMPTY: %i)", lvalue, rvalue, op, next, level, empty];
}


-(NSArray *) affectedKeyPaths {
	NSMutableArray * a = [NSMutableArray array];
	NSString * p = nil;
	if(lvalue && (p = [lvalue affectedKeyPath])){
		[a addObject:p];
	}
	if(rvalue && (p = [rvalue affectedKeyPath])){
		[a addObject:p];
	}
	return a;
}

-(BOOL) evaluateWithObject:(id)object andOperatorDelegate:(id<PropSetterOperatorCustomDelegate>)del {
	// single expression
	BOOL result = YES;
	id l = [lvalue valueWithObject:object];
	if(!rvalue){
		if([l respondsToSelector:@selector(boolValue)]){
			result = [l boolValue];
		} else if(!empty){
			result = [lvalue valueWithObject:object] != nil;
		}
	} else {
		id r = [rvalue valueWithObject:object];
		BOOL bothSameClass = [l isKindOfClass:[r class]];
		BOOL canBeCompared = bothSameClass && [l respondsToSelector:@selector(compare:)]  && [r respondsToSelector:@selector(compare:)];
		BOOL canContain = [l respondsToSelector:@selector(containsObject:)];
		BOOL canBeEnumerated = [l isKindOfClass:[NSEnumerator class]] || [l conformsToProtocol:@protocol(NSFastEnumeration)];
		PropSetterComparisonOperator optype = [op type];
		if(!canBeCompared && (optype == PSCOMPOP_GT || optype == PSCOMPOP_GTE || optype == PSCOMPOP_LT || optype == PSCOMPOP_LTE)){
			PropSetterRuntimeError(@"%@ and %@ cannot be compared to each other", l, r);
		}
		if(!canContain && !canBeEnumerated && optype == PSCOMPOP_CONTAINS){
			PropSetterRuntimeError(@"%@ cannot have the contains(=>) operator applied to it", l);
		}
		NSComparisonResult res;
		switch(optype){
			case PSCOMPOP_EQ:
				result = (r == nil) ? l == nil : [l isEqual:r];
				break;
			case PSCOMPOP_NE:
				result = (r == nil) ? l != nil : ![l isEqual:r];
				break;
			case PSCOMPOP_GT:
				result = [l compare:r] == NSOrderedDescending;
				break;
			case PSCOMPOP_LT:
				result = [l compare:r] == NSOrderedAscending;
				break;
			case PSCOMPOP_GTE:
				res = [l compare:r];
				result = res == NSOrderedDescending || res == NSOrderedSame;
				break;
			case PSCOMPOP_LTE:
				res = [l compare:r];
				result = res == NSOrderedAscending || res == NSOrderedSame;
				break;
			case PSCOMPOP_CONTAINS:
				if(canContain){
					result = [l containsObject:r];
				} else if(canBeEnumerated){
					for(id lso in l){
						result = [lso isEqual:r];
						if(result) break;
					}
				}
				break;
			case PSCOMPOP_CUSTOM:
				result = [del customOperatorWithName:[op name] withLvalue:l andRvalue:r];
				break;
			case PSCOMPOP_NONE:
				NSLog(@"No comparison operator specified between %@ and %@, error!", l, r);
				break;
		}
	}
	return result;
}

-(void) dealloc {
	[lvalue release];
	[rvalue release];
	[op release];
	[super dealloc];
}

@end
