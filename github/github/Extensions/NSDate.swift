import Foundation

extension NSDate {
    func lastWeek() -> String {
        let lastWeek = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYear, value: -1, toDate: NSDate(), options: NSCalendarOptions())
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(lastWeek!)
    }
    
    func daysFrom(date: NSDate) -> Int {
        let components = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: date, toDate: self, options: NSCalendarOptions())
        return components.day
    }
}

extension NSDate {
    convenience init(fromGitHubString gitHubString: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
        
        if let date = dateFormatter.dateFromString(gitHubString) {
            self.init(timeInterval: 0, sinceDate: date)
        } else {
            self.init()
        }
    }
}