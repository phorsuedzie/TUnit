//
// (C) Copyright Tilo Prütz
//

#include "TUnit/TTestCase.h"

#pragma .h #include <TFoundation/TFoundation.h>

#pragma .h #include <sys/resource.h>

#pragma .h @class TString;

#include <objc/objc.h>
#include <objc/objc-api.h>

#include "TUnit/TTestException.h"
#include "TUnit/TMockController.h"
#include "TUnit/TMockMessage.h"
#include "TUnit/TObject.Mock.h"


#pragma .h typedef void(TUnitCallBack)();
#pragma .h extern TUnitCallBack *tUnitBeforeSetUp;

TUnitCallBack *tUnitBeforeSetUp = NULL;


#pragma .h #define _ASSERT(sel) [self sel file: __FILE__ line: __LINE__]; [self clearHint];

#pragma .h #define ASSERTEQUALSINT(int1, int2) _ASSERT(_assertInt: int1 equalsInt: int2)

#pragma .h #define ASSERTISGREATERTHANINT(int1, int2) _ASSERT(_assertInt: int2 isGreaterThan: int1)

#pragma .h #define ASSERTISLESSTHANINT(int1, int2) _ASSERT(_assertInt: int2 isLessThan: int1)

#pragma .h #define ASSERTEQUALS(obj1, obj2) _ASSERT(_assert: obj1 equals: obj2)

#pragma .h #define ASSERTIDENTICAL(obj1, obj2) _ASSERT(_assert: obj1 isIdenticalTo: obj2)

#pragma .h #define ASSERT(x) _ASSERT(_assert: @#x isTrue: x shouldBeFalse: NO)

#pragma .h #define ASSERTFALSE(x) _ASSERT(_assert: @#x isTrue: x shouldBeFalse: YES)

#pragma .h #define ASSERTNIL(x) ASSERT((x) == nil);

#pragma .h #define ASSERTNOTNIL(x) ASSERT((x) != nil);

#pragma .h #define ASSERTKINDOF(expectedClass, obj) _ASSERT(_assert: obj isKindOf: expectedClass)

#pragma .h #define ASSERTLISTCONTENTSEQUAL(expected, got)\
#pragma .h         _ASSERT(_assertList: got containsEqualElementsAs: expected)

#pragma .h #define ASSERTLISTCONTAINS(expected, got)\
#pragma .h         _ASSERT(_assertList: got containsElementsFrom: expected)

#pragma .h #define ASSERTSUBSTRING(expected, got) _ASSERT(_assert: got hasSubstring: expected)

#pragma .h #define ASSERTMATCHES(expected, result) _ASSERT(_assert: result matches: expected)

#pragma .h #define ASSERTISFASTERTHAN(fast, slow, howMany) {\
#pragma .h     long long __fastTime__ = [TTime currentTimeMillis];\
#pragma .h \
#pragma .h     for (int __i__ = 0; __i__ < howMany; ++__i__) {\
#pragma .h         fast;\
#pragma .h     }\
#pragma .h     __fastTime__ = [TTime currentTimeMillis] - __fastTime__;\
#pragma .h \
#pragma .h     long long __slowTime__ = [TTime currentTimeMillis];\
#pragma .h \
#pragma .h     for (int __i__ = 0; __i__ < howMany; ++__i__) {\
#pragma .h         slow;\
#pragma .h     }\
#pragma .h     __slowTime__ = [TTime currentTimeMillis] - __slowTime__;\
#pragma .h     ASSERTISLESSTHANINT(__slowTime__, __fastTime__);\
#pragma .h }

#pragma .h #define ASSERTISFAST(expectedMaxMilliSeconds, method, howMany) {\
#pragma .h     long long __expected__ = (long long)expectedMaxMilliSeconds;\
#pragma .h     struct rusage __usage__;\
#pragma .h     long long __before__;\
#pragma .h     long long __after__;\
#pragma .h     getrusage(RUSAGE_SELF, &__usage__);\
#pragma .h     __before__ = (long long)__usage__.ru_utime.tv_sec * 1000000 +\
#pragma .h             (long long)__usage__.ru_utime.tv_usec;\
#pragma .h \
#pragma .h     for (int __i__ = 0; __i__ < howMany; ++__i__) {\
#pragma .h         method;\
#pragma .h     }\
#pragma .h     getrusage(RUSAGE_SELF, &__usage__);\
#pragma .h     __after__ = (long long)__usage__.ru_utime.tv_sec * 1000000 +\
#pragma .h             (long long)__usage__.ru_utime.tv_usec;\
#pragma .h \
#pragma .h     ASSERTISLESSTHANINT(__expected__, (__after__ - __before__) / 1000);\
#pragma .h }

#pragma .h #define _FAIL(x, eClass, eId, expectedE, code...) {\
#pragma .h     eClass e = nil;\
#pragma .h     id unexpectedException = nil;\
#pragma .h \
#pragma .h     @try {\
#pragma .h         x;\
#pragma .h     } @catch(eClass caught) {\
#pragma .h         e = caught;\
#pragma .h     } @catch(id u) {\
#pragma .h         unexpectedException = u;\
#pragma .h     }\
#pragma .h     if (e == nil && unexpectedException == nil) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withMessage: @#x @" did not fail"];\
#pragma .h     } else if (expectedE != nil && ![expectedE isEqualTo: e]) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withFormat: @#x @" failed with unexpected exception %@ instead of %@",\
#pragma .h                 e, expectedE];\
#pragma .h     } else if (unexpectedException != nil) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withFormat: @#x @" failed with unexpected exception %@ instead of %@",\
#pragma .h                 unexpectedException, @#eClass];\
#pragma .h     } else if (eId != 0 && eId != [(id)e errorId]) {\
#pragma .h         @throw [TTestException exceptionAt: __FILE__ : __LINE__ \
#pragma .h                 withFormat: @#x@" failed with unexpected exception ID %d instead of %d",\
#pragma .h                 [(id)e errorId], eId];\
#pragma .h     }\
#pragma .h     code;\
#pragma .h }

//#pragma .h #define FAIL(x) _FAIL(x, id, 0, nil,)
#pragma .h #define FIXME_FAIL(x) _FAIL(x, id, 0, nil,)

#pragma .h #define FAIL_WITH(exceptionClass, x, code...) _FAIL(x, exceptionClass *, 0, nil, code)

#pragma .h #define FAIL_WITH_CLASS(exceptionClass, x)\
#pragma .h         _FAIL(x, exceptionClass *, 0, nil,)

#pragma .h #define FAIL_WITH_CLASS_AND_ID(exceptionClass, exceptionId, x)\
#pragma .h         _FAIL(x, exceptionClass *, exceptionId, nil,)

#pragma .h #define FAIL_WITH_EQUAL(expectedException, x) _FAIL(x, id, 0, expectedException,)


@implementation TTestCase:TObject
{
    TString *_hint;
}


- (void)dealloc
{
    [_hint release];
    [super dealloc];
}


- (TString *)assertionMessage: (TString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *reason = [TString stringWithFormat: format andArglist: &args];
    va_end(args);
    TString *message = [TString stringWithFormat: @"Assertion failed: %@", reason];
    if (_hint != nil) {
        message = [TString stringWithFormat: @"%@ (%@)", message, _hint];
    }
    return message;
}


- (void)_assert: obj1 equals: obj2 file: (const char *)file line: (int)line
{
    if ((obj1 != nil || obj2 != nil) && ![obj1 isEqual: obj2]) {
        TString *msg = nil;
        if ([obj1 isKindOf: [TDictionary class]] && [obj2 isKindOf: [TDictionary class]]) {
            msg = [self _dictDiff: obj1 : obj2];
        }
        @throw [TTestException exceptionAt: file : line
                withFormat: @"Assertion failed: %@ is not equal %@%s%@",
                obj1, obj2, msg != nil ? ":\n" : "", msg];
    }
}


- (TString *)_dictDiff: (TDictionary *)dict1 : (TDictionary *)dict2
{
    TMutableArray *msgs = [TMutableArray array];
    TMutableArray *keys1 = [TMutableArray arrayWithArray: [dict1 allKeys]];
    TMutableArray *keys2 = [TMutableArray arrayWithArray: [dict2 allKeys]];

    for (id <TIterator> i = [dict1 keyIterator]; [i hasCurrent]; [i next]) {
        id key = [i current];
        id value1 = [dict1 objectForKey: key];
        id value2 = [dict2 objectForKey: key];
        if (value2 != nil) {
            if (![value1 isEqual: value2]) {
                TString *msg = nil;
                if ([value1 isKindOf: [TDictionary class]] &&
                        [value2 isKindOf: [TDictionary class]]) {
                    msg = [self _dictDiff: value1 : value2];
                }
                [msgs addObject: [TString stringWithFormat: @"%@: %@ != %@%s%@",
                        [self objDescription: key], [self _description: value1],
                        [self _description: value2], msg != nil ? ":\n" : "", msg]];
            }
            [keys1 removeObject: key];
            [keys2 removeObject: key];
        }
    }
    if ([keys1 containsData]) {
        [msgs addObject: [TString stringWithFormat: @"Only in expected dict: %@\n",
                [self objDescription:
                [keys1 arrayByFilteringWithObject: self andSelector: @selector(_description:)]]]];
    }
    if ([keys2 containsData]) {
        [msgs addObject: [TString stringWithFormat: @"Only in result dict: %@\n",
                [self objDescription:
                [keys2 arrayByFilteringWithObject: self andSelector: @selector(_description:)]]]];
    }
    return [msgs componentsJoinedByString: @"\n\n"];
}


- (TString *)_description: obj
{
    return [TString stringWithFormat: @"(%@) %@", [obj className], [self objDescription: obj]];
}


- objDescription: obj
{
    return object_get_class(obj) == [TMock class] ? (id)[TMockController descriptionFor: obj] : obj;
}


- (void)_assertInt: (int)int1 equalsInt: (int)int2 file: (const char *)file line: (int)line
{
    if (int1 != int2) {
        @throw [TTestException exceptionAt: file : line withFormat:
                @"Assertion failed: %d is not equal %d", int1, int2];
    }
}


- (void)_assertInt: (int)int1 isGreaterThan: (int)int2
        file: (const char *)file line: (int)line
{
    if (int1 <= int2) {
        @throw [TTestException exceptionAt: file : line withFormat:
                @"%d is not greater than %d", int1, int2];
    }
}


- (void)_assertInt: (int)int1 isLessThan: (int)int2
        file: (const char *)file line: (int)line
{
    if (int1 >= int2) {
        @throw [TTestException exceptionAt: file : line withFormat:
                @"%d is not less than %d", int1, int2];
    }
}


- (void)_assert: obj1 isIdenticalTo: obj2
        file: (const char *)file line: (int)line
{
    if (obj1 != obj2) {
        @throw [TTestException exceptionAt: file : line withFormat:
                @"Assertion failed: %@(%p) is not identical to %@(%p)",
                obj1, obj1, obj2, obj2];
    }
}


- (void)_assert: (TString *)expression isTrue: (BOOL)isTrue
        shouldBeFalse: (BOOL)shouldBeFalse file: (const char *)file
        line: (int)line
{
    if ((!isTrue && !shouldBeFalse) || (isTrue && shouldBeFalse)) {
        @throw [TTestException exceptionAt: file : line
                withFormat: @"Assertion failed: %@ is not %s", expression,
                shouldBeFalse ? "false" : "true"];
    }
}


- (void)_assert: obj isKindOf: (Class)expectedClass
        file: (const char *)file line: (int)line
{
    if (![obj isKindOf: expectedClass]) {
        @throw [TTestException exceptionAt: file : line withFormat:
                @"object's class %@ is not kind of expected class %@",
                [obj className], [expectedClass className]];
    }
}


- (void)_assertList: (NSArray *)got containsElementsFrom: (NSArray *)expected
        file: (const char *)file line: (int)line
{
    [self _assertList: got containsElementsFrom: expected failOnUnexpected: NO
            file: file line: line];
}


- (void)_assertList: (NSArray *)got containsEqualElementsAs: (NSArray *)expected
        file: (const char *)file line: (int)line
{
    [self _assertList: got containsElementsFrom: expected failOnUnexpected: YES
            file: file line: line];
}


- (void)_assertList: (TArray *)got containsElementsFrom: (TArray *)expected
        failOnUnexpected: (BOOL)failOnUnexpected file: (const char *)file line: (int)line
{
    id unexpected = [TMutableArray array];
    if (failOnUnexpected) {
        for (id <TIterator> i = [got iterator]; [i hasCurrent]; [i next]) {
            if (![expected containsObject: [i current]]) {
                [unexpected addObject: [i current]];
            }
        }
    }
    id missed = [TMutableArray array];
    for (id <TIterator> i = [expected iterator]; [i hasCurrent]; [i next]) {
        if (![got containsObject: [i current]]) {
            [missed addObject: [i current]];
        }
    }
    if ([unexpected count] > 0 || [missed count] > 0) {
        @throw [TTestException exceptionAt: file : line withFormat: @"Assertion failed: "
                @"%@ does not contain the same elements as the expected list %@:%s%@%s%@",
                got, expected,
                [unexpected count] > 0 ? "\nUnexpected: " : "",
                [unexpected count] > 0 ? unexpected : nil,
                [missed count] > 0 ? "\nMissed: " : "",
                [missed count] > 0 ? missed : nil];
    }
}


- (void)_assert: obj hasSubstring: (TString *)string file: (const char *)file line: (int)line
{
    if (obj == nil || string == nil ||
            strstr([[obj stringValue] cString], [string cString]) == NULL) {
        @throw [TTestException exceptionAt: file : line
                withFormat: @"Assertion failed: %@ does not have the substring %@", obj, string];
    }
}


- (void)_assert: (TString *)value matches: (TString *)expected
        file: (const char *)file line: (int)line
{
    if (![value matches: expected]) {
        @throw [TTestException exceptionAt: file : line withMessage: [self assertionMessage:
                @"value %@ does not match expression %@.", value, expected]];
    }
}


- (void)setHint: (NSString *)hint
{
    if (_hint != hint) {
        [_hint release];
        _hint = [hint retain];
    }
}


- (void)clearHint
{
    [_hint release];
    _hint = nil;
}


- (void)setUp
{
}


- (void)tearDown
{
}


+ (void)noTest
{
    @throw [TTestException exceptionAt: __FILE__ : __LINE__ withMessage:
            @"TTestCase runs selectors without prefix 'test'."];
}


- (void)noTest
{
    @throw [TTestException exceptionAt: __FILE__ : __LINE__ withMessage:
            @"TTestCase runs selectors without prefix 'test'."];
}


- (void)printRunning
{
    [TUserIO print: @"objc."];
    [TUserIO print: [self className]];
    [TUserIO print: @" "];
}


- (int)run: (NSString *)methodFilter
{
    int failures = 0;
    TAutoreleasePool *pool = [[TAutoreleasePool alloc] init];
    struct objc_method_list *list = [self class]->methods;

    [self printRunning];
    while (list != NULL) {
        for (int i = list->method_count; i-- > 0;) {
            TAutoreleasePool *testPool = [[TAutoreleasePool alloc] init];
            SEL sel = list->method_list[i].method_name;
            TString *method = [TUtils stringFromSelector: sel];

            if (([method hasPrefix: @"test"] || [method hasPrefix: @"itShould"]) &&
                    (nil == methodFilter || [method matches: methodFilter]) &&
                    ![method matches: @"Broken$"]) {
                TStack *exceptions = [TStack stack];
                @try {
                    [self clearHint];
                    [TMockMessage cleanupOrderedMessages];
                    if (tUnitBeforeSetUp != NULL) {
                        tUnitBeforeSetUp();
                    }
                    [self setUp];
                    @try {
                        [TUserIO print: @"."];
                        [self perform: sel];
                    } @catch(id e) {
                        [exceptions push: e];
                    } @finally {
                        @try {
                            verifyAndCleanupMocks();
                        } @catch(id e) {
                            [exceptions push: e];
                        } @finally {
                            [self tearDown];
                        }
                    }
                } @catch(id e) {
                    [exceptions push: e];
                }
                if ([exceptions containsData]) {
                    ++failures;
                    [TUserIO eprintln: @"ERROR: Test %@:%@ failed - %@",
                            [self className], method, [exceptions pop]];
                    while ([exceptions containsData]) {
                        [TUserIO eprintln: @"Root cause:\n%@", [exceptions pop]];
                    }
                }
            }
            [testPool release];
        }
        list = list->method_next;
    }
    [TUserIO println: failures == 0 ? @" OK" : @" FAILED"];
    [pool release];
    return failures;
}


@end


int objcmain(int argc, char *argv[])
{
    int result = 0;
    void *classIterator = NULL;
    Class class;
    Class testCaseClass = [TTestCase class];
    TString *classFilter = nil;
    if (argc > 1) {
        classFilter = [TString stringWithCString: argv[1]];
    }
    TString *methodFilter = nil;
    if (argc > 2) {
        methodFilter = [TString stringWithCString: argv[2]];
    }
    if ([classFilter hasSuffix: @"Test"]) {
        classFilter = [classFilter substringToIndex: [classFilter length] - 4];
    }

    while ((class = objc_next_class(&classIterator)) != Nil) {
        if (class_get_class_method(class->class_pointer, @selector(isKindOf:)) &&
                [class isKindOf: testCaseClass] && ![[class className] matches: @"TestCase$"] &&
                (classFilter == nil || [[class className] matches: classFilter])) {
            TTestCase *test = nil;
            @try {
                test = [[class alloc] init];
                result += [test run: methodFilter];
            } @finally {
                [test release];
            }
        }
    }
    return result;
}
