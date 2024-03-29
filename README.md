# ToddlerTown
## ToddlerTown app, v1.1, iOS 14.0+; out this Saturday on the App Store!
Written in Swift, using SwiftUI, UIKit, CoreData, and MapKit.


This app is for an intended audience of adults with young children, making convenient neighborhood guides with all of the toddler- and kid-centric places they enjoy! Features include adding places to maps through simple searches by region, adding notes and images to a place or marking favorites, filtering places by type (parks, attractions, cafes, etc.), and getting directions quickly through the Maps app.


### v1.1 features
 - Search View: Add new places, or filter existing places by type.
 - Add View: Add new places, searching by the map region.
 - Edit View (not shown): Edit place info, and add notes or photos.
 - Map View: View all or filtered places on a map.
 - List View: View all or filtered places in a list. Can favorite places.
 - Detail View: View the details for a place. Press "Directions" button for directions in Maps app.
 - Sharing: Share your places with friends and family!
 - Dark mode available!

### New/updated for v1.1
 - Full dark mode support and improved UI
 - Can share maps with friends and family -- export full maps via email/text/AirDrop as .ttplaces files
 - Can share exported files with ToddlerTown app for auto-import 
 - Added directions via Google Maps
 - Added rich link support when sharing an address
 - Improved performance (removed "sort by distance" from List view)
 - Added "Add Places" button to Map view also for ease-of-use
 - Added functionality to Location icon on Map view -- now centers map when location is authorized
 - Changed clustering for Map annotations -- now all place types cluster for correct numbering
 - Recategorized place types for simpler grouping
 - Added additional info to place details -- full address, phone number, and URL
 - Improved Edit Place screen, including collapsible address fields
 - On Add Places screen, searching by category happens automatically when a new category is selected

### Screens (dark mode)

1. After adding places to the map, select a category to filter Map and List views by type.

![Search View](ToddlerTown/Screens/Search-300.png)

2. Add views by searching for nearby addresses or points-of-interest, then click "+" button to add to your town.

![Add View](ToddlerTown/Screens/Add-300.png)

3. View your places in the Map view. User location shown is simulated.

![Map View](ToddlerTown/Screens/Map-300.png)

4. View your places in the List view. You can "favorite" places here or delete places.

![List View](ToddlerTown/Screens/List-300.png)

5. View details about a place, as well as a map of the location. You can click the "Go" button to open the location in Maps for quick and easy directions.

![Detail View](ToddlerTown/Screens/Detail-300.png)

6. Share your places (or a filtered subset of them) as a JSON file with the extension .ttplaces.
7. 
![Share View](ToddlerTown/Screens/Share-300.png)


Future versions plan to implement features from the following:
1. Curated guides, shared publicly, including possible monetization for advertising from local businesses (akin to neighborhood welcome mailers).
2. Implementing public APIs (Yelp or Wikimedia) or web scraping for public data.
