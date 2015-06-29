# ``TrueVault`` iOS SDK
## iOS HIPAA Compliance made easy.

Creating a mobile health application that is HIPAA compliant used to require expert knowledge into implementing a backend that would support HIPAA. Now with using TrueVault's iOS SDK, you can create a HIPAA compliant iOS app within hours compared to weeks or even months.

Download our iOS SDK + an example weight tracker application [here](http://go.truevault.com/ios-download/clkg/https/s3.amazonaws.com/truevault-cdn/file/TrueVault-iOS-SDK-20140929.zip).

## Adding the SDK to an existing Xcode project:
1. Drag and drop the `TrueVaultLibrary` folder into your project. The `TrueVaultLibrary` folder contains the _`libTrueVault.a`_ library and all of the header files.
2. In the Build Phases tab of your project's target, add the `SystemConfiguration.framework` in the Link Binary With Libraries list.
3. In the Build Phases tab of your project's target, check that the _`libTrueVault.a`_ library has been included in the the Link Binary With Libraries list. If it's not there, add the library.

## Configure your TrueVault API Key and Vault ID
Import _`"TrueVault.h"`_ into your App Delegate and call the +[TrueVault setVaultID:APIKey:] method with your ``TrueVault`` API Key and Vault ID.

```objective-c
#import "TAAppDelegate.h"
#import "TrueVault.h"

@implementation TAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Setup the TrueVault SDK.
    [TrueVault setVaultID:@"a8ffc73b-d66e-4884-be38-f19aa50f8ead" APIKey:@"43c334f6-101d-4545-a063-a813e8dd3d0f"];

    return YES;
}

@end
```
## Representing a Document
First create a header file that imports `"TVObject.h"`.

Next, define an interface that implements TVObject. These fields should be analogous to TrueVault Schemas. The types will be converted as follows:

* NSNumber -> double
* NSDate -> date
* NSString -> string

In the example application, a Weight object is represent as such:

```objective-c
#import "TVObject.h"

@interface TAWeight : TVObject

@property (nonatomic, strong) NSNumber <TVIndexed> *weight;
@property (nonatomic, strong) NSNumber <TVIndexed> *beforeMeal;
@property (nonatomic, strong) NSDate <TVIndexed> *date;

@end
```

For this quick start guide, we'll ignore the "personObjectID" parameter that exists in the example.

When these objects are saved in TrueVault, they will be preceded by the creation of a Schema that will index based on what you've defined in your object. In this example, a Schema will be created in TrueVault that would look like so:

```
"fields": [
    {
        "index": 1,
        "name": "date",
        "type": "date"
    },
    {
        "index": 1,
        "name": "beforeMeal",
        "type": "double"
    },
    {
        "index": 1,
        "name": "weight",
        "type": "double"
    }
]
```

Each object will be created with a reference to this Schema's ID as their schema_id field.

## Creating and Updating a Document

First allocate and instantiate the object with desired values:

```objective-c
TAWeight *newWeight = [[TAWeight alloc] init];
newWeight.date = @(date);
newWeight.weight = @(weight);
newWeight.beforeMeal = @(beforeMeal);
```

To save these values into TrueVault, call the `saveWithCompletionHandler` function:

```objective-c
[newWeight saveWithCompletionHandler:^(NSError *error) {
    if (error) {
        // Log the error
        NSLog(@"Save Error: %@", error);
    } else {
        // Save is successful
        [self.tableView reloadData];
    }
}];
```
The endpoint that is called during the creation of this object is the [Create a Document](https://docs.truevault.com/Documents#create-a-document) endpoint using a POST command.

If you make any changes to the TrueVault object you have allocated in memory, you can update the Document in TrueVault by again using the `saveWithCompletionHandler` method. This time, the [Update a Document](https://docs.truevault.com/Documents#update-a-document) endpoint will be called using a PUT command.

## Deleting a Document

The concept is the same here as the creation and updating of an object, except instead of `saveWithCompletionHandler` being called, you would use `deleteWithCompletionHandler` in a similar fashion:

```objective-c
[newWeight deleteWithCompletionHandler:^(NSError *error) {
    if (error) {
        // Log the error
        NSLog(@"Deletion Error: %@", error);
    } else {
        // Deletion is successful
    }
}];
```

## Searching for Documents

To utilize the TrueVault Search API via iOS, you need to create a `TVQuery` object that is populated with `TVFilter` and `TVSorts` objects. The flow is like this:

1. Create a filters array:

    ```objective-c
    NSArray *filters = nil;
    ```

2. Populate the filters array with your desired filters. The full list of possibilities is located in `TVFilters.h`.

    ```objective-c
    filters = @[
        [TVFilter filterWhereKey:@"person" isEqualTo:@"me"],
        [TVFilter filterWhereKey:@"beforeMeal" isEqualTo:@(1)],
    ];
    ```

3. Create a query from your TVObject previously created:

    ```objective-c
    TVQuery *query = [TAWeight queryWithFilters:filters];
    ```

4. With that returned query, you can assign a `TVSort` object to `query.sorts`:

    ```objective-c
     query.sorts = @[[TVSort sortDescendingWithKey:@"date"]];
    ```

5. To actually run the query, you will need to call the query's `findObjectsWithCompletionHandler` method:

    ```objective-c
    [query findObjectsWithCompletionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"Query Error: %@", error);
        } else {
            // Data returned successfully
            self.weights = results;
            [self.tableView reloadData];
        }
    }];
    ```

## Creating, Updating, and Deleting BLOBs

In the TrueVault iOS SDK, BLOBs are represented as `TVFile` objects. The methods of `TVFile` objects are similar `TVObject` methods.

In our example application, we allow the end user to choose an Icon to represent themselves by tapping the Person icon in the left-hand corner. Upon tapping this icon, some way of choosing a picture pops up (e.g. choose from the Camera Roll, take a new picture, etc.). Upon choosing a picture, `didFinishPickingMediaWithInfo` is called:

```objective-c
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    self.personImage = image;
    [self setImageIntoPersonBarButtonIcon:image];

    // Save image to TrueVault and then save File's ObjectID into Person
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    TVFile *imageFile = [TVFile fileWithName:@"photo.jpg" data:imageData];
    [imageFile saveWithCompletionHandler:^(NSError *error) {
        self.currentPerson.photoFileID = imageFile.objectID;
        [self.currentPerson saveWithCompletionHandler:NULL];
    }];
}
```

Let's break this down:

1. The image is taken from from the `info` parameter and stored as the `image` UIImage object.

2. We set the actual icon image in the UI by calling `[self setImageIntoPersonBarButtonIcon:image]`

3. Then we actually store this image in TrueVault to be retrieved whenever this person uses the application.

The way an image is stored into TrueVault is as follows:

1. Create an `NSData` object out of `image` (in the example, we convert it to a JPEG data object).

2. We create a `TVFile` object with both the data and a chosen name for the object: `[TVFile fileWithName:@"photo.jpg" data:imageData]`

3. Finally, call the `TVFile`'s `saveWithCompletionHandler` method to store the data in TrueVault.

- **Bonus:** The image can be associated with a specific person by updating the `self.currentPerson` object with the `imageFile`'s objectID. This is then saved by calling the `saveWithCompletionHandler` method on the `self.currentPerson` `TVObject`.

## Conclusion

This covers all of the functionality that is present in our iOS SDK. There are many ways of making TrueVault work with your iOS app. For a view into how these pieces are put together to make a full application, please examine the example application included with our [SDK](http://go.truevault.com/ios-download/clkg/https/s3.amazonaws.com/truevault-cdn/file/TrueVault-iOS-SDK-20140929.zip).


