//
//  PropSetter.m
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

#import "PropSetter.h"
#import "PropSetterSelector.h"
#import "PropSetterInvocationRecord.h"



@implementation PropSetter

@synthesize debug;

+(id) sharedInstance {
	static PropSetter * shared;
	if(!shared){
		shared = [[PropSetter alloc] init];
	}
	return shared;
}

-(id) init {
	if(self = [super init]){
		debug = NO;
		customOperators = [[NSMutableDictionary alloc] init];
		customFunctions = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void) dealloc {
	[customOperators release];
	[customFunctions release];
	[super dealloc];
}

-(void) addTarget:(id)target andSelector:(SEL)selector forCustomOperator:(NSString *)name {
	NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
	NSAssert1([sig numberOfArguments] == 5, @"Custom function selector must accept three arguments, accepts %i", [sig numberOfArguments] - 3);
	NSInvocation * inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setTarget:target];
	[inv setSelector:selector];
	[customOperators setObject:inv forKey:name];
}

-(void) addDelegate:(id<PropSetterOperatorCustomDelegate>)del forCustomOperator:(NSString *)name {
	SEL selector = @selector(customOperatorWithName:withLvalue:andRvalue:);
	NSMethodSignature * sig = [[del class] instanceMethodSignatureForSelector:selector];
	NSInvocation * inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setTarget:del];
	[inv setSelector:selector];
	[customOperators setObject:inv forKey:name];
}

-(void) addTarget:(id)target andSelector:(SEL)selector forCustomFunction:(NSString *)name {
	NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
	NSAssert1([sig numberOfArguments] == 4, @"Custom function selector must accept two arguments, accepts %i", [sig numberOfArguments] - 2);
	PropSetterInvocationRecord * rec = [[PropSetterInvocationRecord alloc] init];
	[rec setTarget:target];
	[rec setSelector:selector];
	[customFunctions setObject:rec forKey:name];
	[rec release];
}

-(void) addDelegate:(id<PropSetterFunctionInvocationDelegate>)del forCustomFunction:(NSString *)name {
	SEL selector = @selector(invokeFunction:withArguments:);
	PropSetterInvocationRecord * rec = [[PropSetterInvocationRecord alloc] init];
	[rec setTarget:del];
	[rec setSelector:selector];
	[customFunctions setObject:rec forKey:name];
	[rec release];
}

-(BOOL) customOperatorWithName:(NSString *)nm withLvalue:(id)lvalue andRvalue:(id)rvalue {
	NSInvocation * i = [customOperators	objectForKey:nm];
	NSAssert1(i != nil, @"There is no operator registered for %@", nm);
	[i setArgument:nm atIndex:2];
	[i setArgument:lvalue atIndex:3];
	[i setArgument:rvalue atIndex:4];
	[i invoke];
	BOOL * result = (BOOL *)malloc(sizeof(BOOL));
	[i getReturnValue:result];
	BOOL res = *result;
	free(result);
	return res;
}

-(id) invokeFunction:(NSString *)n withArguments:(NSArray *)args {
	PropSetterInvocationRecord * i = [customFunctions objectForKey:n];
	NSAssert1(i != nil, @"There is no function registered for %@", n);
	id result = [[i target] performSelector:[i selector] withObject:n withObject:args];
	return result;
}

#pragma mark Selector methods

-(id<PropSetterObjectWithValue>) valueOfExpression:(NSString *)s {
	id<PropSetterObjectWithValue> result = s;
	PropSetterParser * parser = [[PropSetterParser alloc] init];
	[parser setFunctionDelegate:self];
	result = [parser valueFromExpression:s];
	return result;
}

-(PropSetterSelector *) selectorFromString:(NSString *)s {
	PropSetterParser * p = [[PropSetterParser alloc] init];
	[p setFunctionDelegate:self];
	PropSetterSelector * sel = [[[p selectorFromExpression:s] copy] autorelease];
	[p release];
	return sel;
}

-(NSArray *) selectorsFromArray:(NSArray *)s {
	PropSetterParser * p = [[PropSetterParser alloc] init];
	[p setFunctionDelegate:self];
	NSMutableArray * a = [[[NSMutableArray alloc] init] autorelease];
	for(NSString * sel in s){
		[a addObject:[p selectorFromExpression:sel]];
	}
	[p release];
	return a;
}

-(NSDictionary *) selectorsAndValuesFromDictionary:(NSDictionary *)d parsingValues:(BOOL)b {
	PropSetterParser * p = [[PropSetterParser alloc] init];
	[p setFunctionDelegate:self];
	NSMutableDictionary * outd = [[[NSMutableDictionary alloc] init] autorelease];
	for(NSString * sel in d){
		id v = [d objectForKey:sel];
		if([v isKindOfClass:[NSString class]] && [v hasPrefix:@"@"]){
			id<PropSetterObjectWithValue> res = [p valueFromExpression:v];
			if(res){
				v = res;
			}
		}
		[outd setObject:v forKey:[p selectorFromExpression:sel]];
	}
	[p release];
	return outd;
}

-(NSArray *) objectsFromArray:(NSArray *)a matchingSelector:(PropSetterSelector *)selector {
	NSMutableArray * ret = [NSMutableArray array];
	for(id o in a){
		if([selector evaluateWithObject:o andOperatorDelegate:self]){
			[ret addObject:o];
		}
	}
	return ret;
}

-(NSArray *) setValue:(id)value forObjectsInArray:(NSArray *)a matchingSelector:(PropSetterSelector *)selector {
	NSMutableArray * ret = [NSMutableArray array];
	BOOL hasProperty = [selector property] != nil;
	for(id o in a){
		if([selector evaluateWithObject:o andOperatorDelegate:self]){
			[ret addObject:o];
			if(hasProperty){
				[[selector property] setPropertyOfObject:o toValue:value];
			}
		}
	}
	return ret;
}

-(NSArray *) setValueforObjectsInArray:(NSArray *)a matchingSelector:(PropSetterSelector *)selector withTarget:(id)target andSelector:(SEL)sel{
	NSMutableArray * ret = [NSMutableArray array];
	BOOL hasProperty = [selector property] != nil;
	for(id o in a){
		if([selector evaluateWithObject:o andOperatorDelegate:self]){
			[ret addObject:o];
			if(hasProperty){
				[[selector property] setPropertyOfObject:o toValue:[target performSelector:sel withObject:o]];
			} else {
				[target performSelector:sel withObject:o];
			}
		}
	}
	return ret;
}

-(BOOL) setValueforObject:(id)object usingSelector:(PropSetterSelector *)selector withTarget:(id)target andSelector:(SEL)sel {
	BOOL result = NO;
	if(result = [selector evaluateWithObject:object andOperatorDelegate:self]){
		if([selector property]){
			[[selector property] setPropertyOfObject:object toValue:[target performSelector:sel withObject:object]];
		} else {
			[target performSelector:sel withObject:object];
		}
	}
	return result;
}


-(BOOL) setValue:(id)value forObject:(id)object usingSelector:(PropSetterSelector *)selector {
	BOOL result = NO;
	if(result = [selector evaluateWithObject:object andOperatorDelegate:self]){
		if([selector property]){
			[[selector property] setPropertyOfObject:object toValue:value];
		} else {
			result = NO;
		}
	}
	return result;
}


-(BOOL) doesSelector:(PropSetterSelector *)selector matchObject:(id)object {
	return [selector evaluateWithObject:object andOperatorDelegate:self];
}

-(id) valueOfSelector:(PropSetterSelector *)selector forObject:(id)object {
	id result = nil;
	if([selector evaluateWithObject:object andOperatorDelegate:self]){
		if([selector property]){
			result = [[selector property] valueWithObject:object];
		} else {
			result = object;
		}
	}
	return result;
}


#pragma mark Selector from string methods

-(NSArray *) objectsFromArray:(NSArray *)a matchingString:(NSString *)s {
	PropSetterSelector * selector = [self selectorFromString:s];
	NSArray * ret = [self objectsFromArray:a matchingSelector:selector];
	return ret;
}

-(NSArray *) setValue:(id)value forObjectsInArray:(NSArray *)a matchingString:(NSString *)s {
	PropSetterSelector * selector = [self selectorFromString:s];
	NSArray * ret = [self setValue:value forObjectsInArray:a matchingSelector:selector];
	return ret;
}

-(NSArray *) setValueforObjectsInArray:(NSArray *)a matchingString:(NSString *)s withTarget:(id)target andSelector:(SEL)sel{
	PropSetterSelector * selector = [self selectorFromString:s];
	NSArray * ret = [self setValueforObjectsInArray:a matchingSelector:selector withTarget:target andSelector:sel];
	return ret;
}

-(BOOL) setValueforObject:(id)object usingString:(NSString *)s withTarget:(id)target andSelector:(SEL)sel {
	PropSetterSelector * selector = [self selectorFromString:s];
	BOOL result = [self setValueforObject:object usingSelector:selector withTarget:target andSelector:sel];
	return result;
}


-(BOOL) setValue:(id)value forObject:(id)object usingString:(NSString *)s {
	PropSetterSelector * selector = [self selectorFromString:s];
	BOOL result = [self setValue:value forObject:object usingSelector:selector];
	return result;
}


-(BOOL) doesString:(NSString *)s matchObject:(id)object {
	PropSetterSelector * selector = [self selectorFromString:s];
	BOOL result = [selector evaluateWithObject:object andOperatorDelegate:self];
	return result;
}

-(id) valueOfString:(NSString *)s forObject:(id)object {
	PropSetterSelector * selector = [self selectorFromString:s];
	id result = [self valueOfSelector:selector forObject:object];
	return result;
}





@end

