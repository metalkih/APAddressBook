//
//  APContact.m
//  APAddressBook
//
//  Created by Alexey Belkevich on 1/10/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APContact.h"
#import "APPhoneWithLabel.h"
#import "APEmailWithLabel.h"
#import "APAddress.h"
#import "APSocialProfile.h"
#import "APInstantMessages.h"
#import "APURLWithLabel.h"

@interface APContact ()
@property (nonatomic, strong) NSData *vCardData;
@end

@implementation APContact

#pragma mark - life cycle

- (id)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(APContactField)fieldMask
{
    self = [super init];
    if (self)
    {
        ABRecordRef people[1];
        people[0] = recordRef;
        CFArrayRef peopleArray = CFArrayCreate(NULL, (void *)people, 1, &kCFTypeArrayCallBacks);
        NSData *vCardData = CFBridgingRelease(ABPersonCreateVCardRepresentationWithPeople(peopleArray));
        self.vCardData = vCardData;

        _fieldMask = fieldMask;
        if (fieldMask & APContactFieldFirstName)
        {
            _firstName = [self stringProperty:kABPersonFirstNameProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldMiddleName)
        {
            _middleName = [self stringProperty:kABPersonMiddleNameProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldLastName)
        {
            _lastName = [self stringProperty:kABPersonLastNameProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldCompositeName)
        {
            _compositeName = [self compositeNameFromRecord:recordRef];
        }
        if (fieldMask & APContactFieldCompany)
        {
            _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldPhones)
        {
            _phones = [self arrayProperty:kABPersonPhoneProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldPhonesWithLabels)
        {
            _phonesWithLabels = [self arrayOfPhonesWithLabelsFromRecord:recordRef];
        }
        if (fieldMask & APContactFieldEmails)
        {
            _emails = [self arrayProperty:kABPersonEmailProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldPhoto)
        {
            _photo = [self imagePropertyFullSize:YES fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldThumbnail)
        {
            _thumbnail = [self imagePropertyFullSize:NO fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldAddresses)
        {
            _addresses = [self arrayOfAddressWithLabelsFromRecord:recordRef];
        }
        if (fieldMask & APContactFieldRecordID)
        {
            _recordID = [NSNumber numberWithInteger:ABRecordGetRecordID(recordRef)];
        }
        if (fieldMask & APContactFieldCreationDate)
        {
            _creationDate = [self dateProperty:kABPersonCreationDateProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldModificationDate)
        {
            _modificationDate = [self dateProperty:kABPersonModificationDateProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldSocialProfiles)
        {
            NSMutableArray *profiles = [[NSMutableArray alloc] init];
            NSArray *array = [self arrayProperty:kABPersonSocialProfileProperty fromRecord:recordRef];
            for (NSDictionary *dictionary in array)
            {
                APSocialProfile *profile = [[APSocialProfile alloc] initWithSocialDictionary:dictionary];
                [profiles addObject:profile];
            }
            
            _socialProfiles = profiles;
        }
        if (fieldMask & APContactFieldNote)
        {
            _note = [self stringProperty:kABPersonNoteProperty fromRecord:recordRef];
        }
        if (fieldMask == APContactFieldAll)
        {
            _birthDay = [self dateProperty:kABPersonBirthdayProperty fromRecord:recordRef];
            
            _emailsWithLabels = [self arrayOfEmailsWithLabelsFromRecord:recordRef];
            _urlWithLabels = [self arrayOfURLWithLabelsFromRecord:recordRef];

            //Instant Message
            NSMutableArray *instantMessages = [[NSMutableArray alloc] init];
            NSArray *array = [self arrayProperty:kABPersonInstantMessageProperty fromRecord:recordRef];
            for (NSDictionary *dictionary in array)
            {
                APInstantMessages *profile = [[APInstantMessages alloc] initWithInstantDictionary:dictionary];
                [instantMessages addObject:profile];
            }
            
            _instantMessages = instantMessages;
        }
    }
    return self;
}

#pragma mark - private

- (NSString *)stringProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFTypeRef valueRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSString *)valueRef;
}

- (NSArray *)arrayProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:property fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
    {
        CFTypeRef value = ABMultiValueCopyValueAtIndex(multiValue, index);
        NSString *string = (__bridge_transfer NSString *)value;
        if (string)
        {
            [array addObject:string];
        }
    }];
    return array.copy;
}


- (NSDate *)dateProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFDateRef dateRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSDate *)dateRef;
}

- (NSArray *)arrayOfPhonesWithLabelsFromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:kABPersonPhoneProperty fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
    {
        CFTypeRef rawPhone = ABMultiValueCopyValueAtIndex(multiValue, index);
        NSString *phone = (__bridge_transfer NSString *)rawPhone;
        if (phone)
        {
            NSString *label = [self localizedLabelFromMultiValue:multiValue index:index];
            APPhoneWithLabel *phoneWithLabel = [[APPhoneWithLabel alloc] initWithPhone:phone
                                                                                 label:label];
            [array addObject:phoneWithLabel];
        }
    }];
    return array.copy;
}

- (NSArray *)arrayOfEmailsWithLabelsFromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:kABPersonEmailProperty fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
     {
         CFTypeRef rawPhone = ABMultiValueCopyValueAtIndex(multiValue, index);
         NSString *email = (__bridge_transfer NSString *)rawPhone;
         if (email)
         {
             NSString *label = [self localizedLabelFromMultiValue:multiValue index:index];
             APEmailWithLabel *phoneWithLabel = [[APEmailWithLabel alloc] initWithEmail:email
                                                                                  label:label];
             [array addObject:phoneWithLabel];
         }
     }];
    return array.copy;
}

- (NSArray *)arrayOfAddressWithLabelsFromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:kABPersonAddressProperty fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
     {
         CFTypeRef rawAddress = ABMultiValueCopyValueAtIndex(multiValue, index);
         NSDictionary *addressDic = (__bridge_transfer NSDictionary *)rawAddress;
         if (addressDic)
         {
             NSString *label = [self localizedLabelFromMultiValue:multiValue index:index];
             APAddress *address = [[APAddress alloc] initWithAddressDictionary:addressDic label:label];
             [array addObject:address];
         }
     }];
    return array.copy;
}

- (NSArray *)arrayOfURLWithLabelsFromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:kABPersonURLProperty fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
     {
         CFTypeRef rawObject = ABMultiValueCopyValueAtIndex(multiValue, index);
         NSString *object = (__bridge_transfer NSString *)rawObject;
         if (object)
         {
             NSString *label = [self localizedLabelFromMultiValue:multiValue index:index];
             APURLWithLabel *url = [[APURLWithLabel alloc] initWithURL:object label:label];
             [array addObject:url];
         }
     }];
    return array.copy;
}

- (UIImage *)imagePropertyFullSize:(BOOL)isFullSize fromRecord:(ABRecordRef)recordRef
{
    ABPersonImageFormat format = isFullSize ? kABPersonImageFormatOriginalSize :
                                 kABPersonImageFormatThumbnail;
    NSData *data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordRef, format);
    return [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
}

- (NSString *)localizedLabelFromMultiValue:(ABMultiValueRef)multiValue index:(NSUInteger)index
{
    NSString *label;
    CFTypeRef rawLabel = ABMultiValueCopyLabelAtIndex(multiValue, index);
    if (rawLabel)
    {
        CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(rawLabel);
        if (localizedLabel)
        {
            label = (__bridge_transfer NSString *)localizedLabel;
        }
        CFRelease(rawLabel);
    }
    return label;
}

- (NSString *)compositeNameFromRecord:(ABRecordRef)recordRef
{
    CFStringRef compositeNameRef = ABRecordCopyCompositeName(recordRef);
    return (__bridge_transfer NSString *)compositeNameRef;
}

- (void)enumerateMultiValueOfProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
                            withBlock:(void (^)(ABMultiValueRef multiValue, NSUInteger index))block
{
    ABMultiValueRef multiValue = ABRecordCopyValue(recordRef, property);
    NSUInteger count = (NSUInteger)ABMultiValueGetCount(multiValue);
    for (NSUInteger i = 0; i < count; i++)
    {
        block(multiValue, i);
    }
    CFRelease(multiValue);
}

@end
