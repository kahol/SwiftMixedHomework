/*
    DetailViewController.swift
    InternationalMountains

    A simple UIViewController that shows a localized label that contains
    detail information, including height and date data, about the user-
    selected mountain.
*/

import UIKit
import Foundation

class DetailViewController: UIViewController {

    // Key names for values in mountain dictionary entries.
    let kMountainNameString = "name"
    let kMountainHeightString = "height"
    let kMountainClimbedDateString = "climbedDate"
    
    var mountainDictionary = NSDictionary()
    
    // Formatter instances that we'll re-use.
    private var numberFormatter = NSNumberFormatter()
    private var dateFormatter = NSDateFormatter()
    
    @IBOutlet weak var mountainDetails: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateLabelWithMountainName(self.mountainDictionary[kMountainNameString] as! String, height: self.mountainDictionary[kMountainHeightString] as! NSNumber, climbedDate: self.mountainDictionary[kMountainClimbedDateString] as? NSDate)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentLocaleOrTimeZoneDidChange:", name: NSCurrentLocaleDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentLocaleOrTimeZoneDidChange:", name: NSSystemTimeZoneDidChangeNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.mountainDetails.preferredMaxLayoutWidth = self.mountainDetails.bounds.size.width
        self.view.layoutIfNeeded()
    }

    // MARK: Notification Handler
    
    // When user changed the locale (region format) or time zone in Settings,
    // we are notified here to update the date format in UI.
    func currentLocaleOrTimeZoneDidChange(notif: NSNotification) {
        self.updateLabelWithMountainName(self.mountainDictionary[kMountainNameString] as! String, height: self.mountainDictionary[kMountainHeightString] as! NSNumber, climbedDate: self.mountainDictionary[kMountainClimbedDateString] as? NSDate)
    }
    
    // MARK: Helper Methods
    
    // Create the localized UI label in the detail view using
    // Localizable.strings and the passed-in mountain information.
    // climbedDate is optional.
    func updateLabelWithMountainName(name: String, height: NSNumber, climbedDate: NSDate?) {
        var sentence: NSString = ""
        var format: NSString = ""
        
        if climbedDate != nil {
            format = NSLocalizedString("sentenceFormat", comment: "A sentence with the mountain's name (first parameter), height (second parameter), and climbed date (third parameter)")
            sentence = String(format: format as String, name, self.heightAsString(height), self.dateAsString(climbedDate!))
        } else {
            // Some mountains do not have a climbed date in our database, so use
            // an alternate label sentence for these.
            format = NSLocalizedString("undatedSentenceFormat", comment: "A sentence with the mountain's name (first parameter), and height (second parameter), but no climbed date")
            sentence = String(format: format as String, name, self.heightAsString(height))
        }
        
        self.mountainDetails.text = sentence as String
    }

    /* Create a single string expressing a mountain's height.  Based on the
    Region Format (as determined using NSLocale information), we need to
    allow for the possibility that the user is using either metric or
    non-metric units.  If the units are non-metric, we will need to manually
    convert.  Also, note that we need to use the properly localized measurement
    units format (meters/feet) as NSFormatter does not handle measurement
    units (although it will handle decimal numbers for us). */
    func heightAsString(heightNumber: NSNumber) -> NSString {
        var returnValue: NSString = ""
        
        var format: NSString = "%d"
        var height = heightNumber.integerValue
        
        // **PROBLEM** I had a rough time with this. Trying to rewrite the check
        // they did in Objective-C did not work, it complained about trying to
        // give the logical binary && operator two Bools and it failed.
        var usesMetricSystemNumber: NSNumber? = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as? NSNumber
        var usesMetricSystem: Bool = usesMetricSystemNumber != nil ? usesMetricSystemNumber!.boolValue : false
        
        if usesMetricSystem {
            // Convert the height to feet
            height = Int(Double(height) * 3.280839895)
            format = NSLocalizedString("footFormat", comment: "Use to express a height in feet")
        } else {
            format = NSLocalizedString("meterFormat", comment: "Use to express a height in meters")
        }
        
        /* Use a NSNumberFormatter for properly formatting decimal values for
        the current locale/region format settings.  For the measurement string,
        we've already loaded the localized string above. */
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        returnValue = String(format: format as String, numberFormatter.stringFromNumber(height)!)
        
        return returnValue
    }
    
    /* Create a single string expressing a mountain's climbed date,
    properly localized */
    func dateAsString(date: NSDate) -> NSString {
        var returnValue: NSString = ""
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        returnValue = dateFormatter.stringFromDate(date)
        
        return returnValue
    }
    
}
