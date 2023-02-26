//
//  AllowablsDatePicker.swift
//
//  Created by Hasan Hasanov on 01.02.23.
//

import UIKit
enum AvailabilityEnum{
    case day
    case month
    case year
    case allComponents
}
class AllowablsDatePicker:  UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var locale = Locale(identifier: "en")
    var text: String?{
        get{
            let dateComponent = DateComponents(year: selectedYearIndex + 1970, month: selectedMonthIndex + 1, day: days[selectedDay])
            if let date = Calendar.current.date(from: dateComponent){
                if isEnabledComponent(date: date, for: .allComponents){
                    let formatter = DateFormatter()
                    formatter.locale = locale
                    formatter.dateFormat = "dd MMMM yyyy"
                    return formatter.string(from: date)
                }else{
                    return nil
                }
            }
            return nil
        }
    }
    private var days = Array(1...31)
    private var selectedDay = 0{
        didSet{
            reloadAllComponents()
        }
    }
    private let disabledColor = UIColor.lightGray
    private let enabledColor = UIColor.label
    private var selectedMonthIndex = 0{
        didSet{
            let selectedYear = selectedYearIndex + 1970
            if selectedMonthIndex == 1 && selectedYear % 4 == 0 && selectedYear % 100 != 0 {
                days = Array(1...29)
                reloadAllComponents()
            }else if selectedMonthIndex == 1{
                days = Array(1...28)
                reloadAllComponents()
            }else{
                days = Array(1...31)
                reloadAllComponents()
            }
        }
    }
    private var selectedYearIndex = 0{
        didSet{
            let selectedYear = selectedYearIndex + 1970
            if selectedMonthIndex == 1 && selectedYear % 4 == 0 && selectedYear % 100 != 0 {
                days = Array(1...29)
                reloadAllComponents()
            }else if selectedMonthIndex == 1{
                days = Array(1...28)
                reloadAllComponents()
            }else{
                days = Array(1...31)
                reloadAllComponents()
            }
        }
    }
    private var sortedArrays = [(start: Date, end: Date)](){
        didSet{
            reloadAllComponents()
        }
    }
    var allowableDates: [(start: Date, end: Date)] = []{
        didSet{
            sortedArrays = allowableDates.sorted(by: { first, second in
                if first.start < second.start{
                    return true
                }else if first.start == second.start{
                    if first.end <= second.end{
                        return true
                    }else{
                        return false
                    }
                }else{
                    return false
                }
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        delegate = self
        dataSource = self
        let currentDate = Date()
        let calendar = Calendar.current
        allowableDates = [
        (calendar.date(byAdding: .month, value: -3, to: currentDate)!, calendar.date(byAdding: .day, value: -3, to: currentDate)!),
        (calendar.date(byAdding: .month, value: -10, to: currentDate)!, calendar.date(byAdding: .month, value: -7, to: currentDate)!),
        (calendar.date(byAdding: .month, value: 3, to: currentDate)!, calendar.date(byAdding: .year, value: 1, to: currentDate)!),
        (calendar.date(byAdding: .year, value: 3, to: currentDate)!, calendar.date(byAdding: .year, value: 4, to: currentDate)!)
        ]
        selectedDay = Calendar.current.component(.day, from: currentDate) - 1
        selectedMonthIndex = Calendar.current.component(.month, from: currentDate) - 1
        selectedYearIndex = Calendar.current.component(.year, from: currentDate) - 1970
        selectRow(days[selectedDay], inComponent: 0, animated: false)
        selectRow(selectedMonthIndex, inComponent: 1, animated: false)
        selectRow(selectedYearIndex, inComponent: 2, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return days.count
        case 1:
            return 12
        case 2:
            return 80
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedDay = row
        case 1:
            selectedMonthIndex = row
        case 2:
            selectedYearIndex = row
        default:
            break
        }
    }
    private func isEnabledComponent(date: Date, for component: AvailabilityEnum) -> Bool{
        let calendar = Calendar.current
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let allowYear = sortedArrays.contains { start, end in
            let upperYear = calendar.component(.year, from: end)
            let lowwerYear = calendar.component(.year, from: start)
            if lowwerYear <= year, year <= upperYear{
                return true
            }else{
                return false
            }
        }
        let allowMonth = sortedArrays.contains { start, end in
            let dateComponent = DateComponents(year: year, month: month)
            if let date = calendar.date(from: dateComponent), date <= end, date >= start{
                return true
            }else{
                return false
            }
        }
        let allowDay = sortedArrays.contains { start, end in
            let dateComponent = DateComponents(year: year, month: month, day: day)
            if let date = calendar.date(from: dateComponent), date <= end, date >= start{
                return true
            }else{
                return false
            }
        }
        switch component {
        case .day:
            return allowDay
        case .month:
            return allowMonth
        case .year:
            return allowYear
        case .allComponents:
            return allowDay && allowYear && allowMonth
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        let calendar = Calendar.current
        switch component {
        case 0:
            let dateComponent = DateComponents(year: selectedYearIndex + 1970, month: selectedMonthIndex + 1, day: days[row])
            if let date = calendar.date(from: dateComponent){
                if isEnabledComponent(date: date, for: .day){
                    label.textColor = enabledColor
                }else{
                    label.textColor = disabledColor
                }
            }
            label.text = "\(days[row])"
        case 1:
            let dateComponent = DateComponents(year: selectedYearIndex + 1970, month: row + 1)
            if let date = calendar.date(from: dateComponent){
                if isEnabledComponent(date: date, for: .month){
                    label.textColor = enabledColor
                }else{
                    label.textColor = disabledColor
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            dateFormatter.locale = locale
            let date = calendar.date(from: DateComponents(month: row + 1))!
            let monthName = dateFormatter.string(from: date)
            label.text = monthName
        case 2:
            let dateComponent = DateComponents(year: row + 1970)
            if let date = calendar.date(from: dateComponent){
                if isEnabledComponent(date: date, for: .year){
                    label.textColor = enabledColor
                }else{
                    label.textColor = disabledColor
                }
            }
            label.text = "\(row + 1970)"
        default:
            break
        }
        return label
    }
}
