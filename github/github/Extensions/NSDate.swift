import Foundation

extension Date {
    func lastWeek() -> String {
        let lastWeek = (Calendar.current as NSCalendar).date(byAdding: .weekOfYear, value: -1, to: Date(), options: NSCalendar.Options())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: lastWeek!)
    }
    
    func daysFrom(_ date: Date) -> Int {
        let components = (Calendar.current as NSCalendar).components(NSCalendar.Unit.day, from: date, to: self, options: NSCalendar.Options())
        return components.day!
    }
}

extension Date {
    init(fromGitHubString gitHubString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssXXX"
        
        if let date = dateFormatter.date(from: gitHubString) {
            self.init(timeInterval: 0, since: date)
        } else {
            self.init()
        }
    }
}
