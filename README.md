# Cheers
Happy Hour Finder CS Senior Project (COMP 495 @ USD)


## How to install + run
1. In your Xcode project, pull from `develop`.
2. Open `terminal` (`Command + Space`, then search for "terminal").
3. `cd` into the same directory as where your code for Cheers is stored.

    For example, if my code is on the Desktop, then I'll need to use `cd Desktop/Cheers`.
4. Use the following commands to install `CocoaPods`:
  
    `sudo gem install cocoapods`
    
    `pod setup`   <-- this is a big file, it may take a few minutes
    
    `pod install`
5. Once the installation has finished, quit Xcode.
6. Open Cheers in Finder. In your Cheers folder you should see two Xcode files, a blue one that ends in `.xcodeproj` and a white one that ends in `.xcworkspace`. Double click on the white `.xcworkspace` file to open the project (you'll have to use white icon from now on).
7. `Command + R` to build and run!

If you have any issues, please refer to [this helpful Stack Overflow post](https://stackoverflow.com/questions/20755044/how-to-install-cocoapods).


## How to fix Lyft iOS API CocoaPod
1. Navigate to your Pods project, it's the second blue icon in the file directory below Cheers (NOT a folder).
2. In Pods/LyftSDK/Core, open `LyftButton.swift`
3. Change Line 47 from:
```
private var pressUpAction: ((Void) -> Void)?
```
to:
```
private var pressUpAction: (() -> Void)?
```
4. In Pods/LyftSDK/Core, open `LyftAPIURLEncoding.swift`
5. Replace Line 32 with:
```
var localVariable = urlComponents 
urlComponents?.queryItems = (localVariable?.queryItems ?? []) + queryItems 
```
6. In Pods/LyftSDK/Core/Resources, open `LyftButtonNone.xib`
7. In the view hierarchy, there are two different views. A higher level view (we'll call this View #1) contains a button and another view (we'll call this View #2). Select View #1 and in the Attribute Inspector, set the `Background` to `Default` (no color). Do the same for View #2. This step fixes the button UI and does not affect functionality.
8. You will have to do this everytime you run a pod commmand (i.e. `pod install`, `pod update`, etc.)


## How to upload to the database
Look to `BarNames.txt` for the template...
1. Pull and checkout the branch called `database`. It will be a complete separate app for database management.
2. Start an empty `.txt` file on your local machine. For your selected neighborhood, add bars in the following format:

```
barName1
neighborhoodName
happyHour1Day1
happyHour1Time1
happyHour1Day2
happyHour1Time2
...
happyHour1DayN
happyHour1TimeN
END OF RECORD
barName2
neighborhoodName
...
happyHour2TimeN
END OF RECORD
```

For example, if I wanted to upload two bars for Pacific Beach, it would look like this:
```
Firehouse
Pacific Beach
Monday
5 pm - 12 am
Tuesday
5 pm - 12 am
Wednesday
5 pm - 12 am
Thursday
5 pm - 2 am
Friday
5 pm - 10 pm
Sunday
9 am - 3 pm
END OF RECORD
Pacific Beach Ale House
Pacific Beach
Monday
3 pm - 6 pm
Tuesday
3 pm - 6 pm
Wednesday
3 pm - 6 pm
Thursday
3 pm - 6 pm
Friday
3 pm - 6 pm
END OF RECORD
```

Make sure that your neighborhood matches **EXACTLY** the raw value of the `enum Neighborhood` in `Neighborhoods.swift`. If I am doing North Park, my neighborhood line in my `.txt` file needs to match "North Park" exactly -- "north park", "North park", and "northpark" will all cause errors.

2. Add the `.txt` file to your project by right-clicking on the top-level folder in your Xcode project (the folder called "Cheers") and then select "Add files to Cheers...". Then select your new `.txt` file.
3. Commit and push the file to whatever branch you're working on.
4. MAKE SURE TO MANUALLY ADD YOUR NEW `.txt` FILE WHEN YOU COMMIT SO IT'S ADDED TO THE REPO.
5. In the `Controller` folder of the Xcode project, open the file `DatabaseTableViewController.swift`. Locate the function `writeToDB()` (Line 130 as of writing this).
6. The first line in `writeToDB()` contains the following:

    `let file = Bundle.main.path(forResource: "records", ofType: "txt")`

    Change the value of the `forResource:` parameter `"records"` to the name of your `.txt` file. Do not include the `.txt` extension. For example, if my file was named `fileName.txt`, then my line would look like: `let file = Bundle.main.path(forResource: "fileName", ofType: "txt")`.

7. Your bars will be pulled from Yelp and uploaded to the database! Go to [Firebase](https://firebase.google.com/) and log in using the credentials listed in the Team Drive -- confirm that your bars were indeed uploaded.
