//
//  CalendarSwiftUI.swift
//  CalendarView
//
//  Created by Hasan Hasanov on 27.02.23.
//

import SwiftUI
enum WeekDays: String, CaseIterable{
    case saturday = "Sat"
    case sunday = "Sun"
    case monday = "Mon"
    case tuesday = "Tue"
    case wensday = "Wen"
    case thursday = "Thu"
    case friday = "Fri"
}
enum AvailabilityEnum{
    case day
    case month
    case year
    case allComponents
}
struct CalendarSwiftUI: View {
    let weeks: [WeekDays] = WeekDays.allCases
    let singleSelection: Bool
    let currentCalendar = Calendar.current
    let availableRange: [(start: Date, end: Date)]
    let sortedArrays: [(start: Date, end: Date)]
    @ObservedObject var model = Model()
    init(singleSelection: Bool, availableRange: [(start: Date, end: Date)]) {
        self.singleSelection = singleSelection
        self.availableRange = availableRange
        self.sortedArrays = availableRange.sorted(by: { first, second in
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
    var header: some View{
        HStack{
            HStack{
                Text("\(getMonthYearString())")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .rotationEffect(model.showPicker ? .degrees(90) : .degrees(0))
            }
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    model.showPicker.toggle()
                }
            }
            .frame(height: 25)
            Spacer()
            if !model.showPicker{
                Button{
                    if let newDate = currentCalendar.date(byAdding: .month, value: -1, to: model.currentDate){
                        withAnimation(.easeInOut(duration: 0.2)) {
                            model.currentDate = newDate
                        }
                        model.changeLayout += 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .font(.system(size: 17, weight: .bold))
                }
                Button{
                    if let newDate = currentCalendar.date(byAdding: .month, value: 1, to: model.currentDate){
                        withAnimation(.easeInOut(duration: 0.2)) {
                            model.currentDate = newDate
                        }
                        model.changeLayout += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                        .font(.system(size: 17, weight: .bold))
                }
            }
        }
    }
    var datesBody: some View{
        HStack(alignment: .top){
            ForEach(weeks, id: \.self) { day in
                VStack(spacing: 15){
                    Text(day.rawValue)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .frame(width: 30)
                        .font(.system(size: 12, weight: .thin))
                    ForEach(getDaysOfMonthInWeek(week: day, date: model.currentDate), id: \.self){ dayOfWeek in
                        if let dayOfWeek{
                            if isEnabledComponent(date: getDate(day: dayOfWeek), for: .allComponents){
                                Text("\(dayOfWeek)")
                                    .foregroundColor(model.selectedDay.contains(getDate(day: dayOfWeek)!) ? .white : .black)
                                    .frame(width: 30, height: 30, alignment: .center)
                                    .background(getColor(dayOfWeek: dayOfWeek))
                                    .cornerRadius(15)
                                    .onTapGesture {
                                        withAnimation(.easeIn(duration: 0.1)){
                                            if singleSelection{
                                                if model.selectedDay.contains(getDate(day: dayOfWeek)!){
                                                    model.selectedDay.removeAll { value in
                                                        return getDate(day: dayOfWeek)!.timeIntervalSince1970 == value.timeIntervalSince1970
                                                    }
                                                }else{
                                                    model.selectedDay.removeAll()
                                                    model.selectedDay.append(getDate(day: dayOfWeek)!)
                                                }
                                            }else{
                                                if model.selectedDay.contains(getDate(day: dayOfWeek)!){
                                                    model.selectedDay.removeAll { value in
                                                        return getDate(day: dayOfWeek)!.timeIntervalSince1970 == value.timeIntervalSince1970
                                                    }
                                                }else{
                                                    model.selectedDay.append(getDate(day: dayOfWeek)!)
                                                }
                                            }
                                        }
                                    }
                            }else{
                                Text("\(dayOfWeek)")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30, alignment: .center)
                            }
                        }else{
                            Text(" ")
                                .frame(width: 30, height: 30, alignment: .center)
                                .cornerRadius(20)
                        }
                    }
                }
                if weeks.firstIndex(of: day) != 6{
                    Spacer()
                }
            }
        }
    }
    var body: some View {
        VStack(spacing: 15){
            header
            ZStack{
                if !model.showPicker{
                    datesBody
                }else{
                    pickerView
                }
            }
        }
        .padding()
    }
    var pickerView: some View{
        MonthYearPicker(currentDate: $model.currentDate)
    }
    func getDaysOfMonthInWeek(week: WeekDays, date: Date) -> [Int?]{
        var dates: [Int?] = []
        let numberOfWeeks = [1, 2, 3, 4, 5, 6]
        switch week {
        case .monday:
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            dates = numberOfWeeks.compactMap{ week -> Int? in
                let component = DateComponents(year: year, month: month, weekday: 2, weekOfMonth: week)
                guard let date = currentCalendar.date(from: component) else {return nil}
                let day = currentCalendar.component(.day, from: date)
                let weekMonth = currentCalendar.component(.month, from: date)
                if weekMonth == month{
                    return day
                }else{
                    return nil
                }
            }
            break
        case .tuesday:
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            dates = numberOfWeeks.compactMap{ week -> Int? in
                let component = DateComponents(year: year, month: month, weekday: 3, weekOfMonth: week)
                guard let date = currentCalendar.date(from: component) else {return nil}
                let day = currentCalendar.component(.day, from: date)
                let weekMonth = currentCalendar.component(.month, from: date)
                if weekMonth == month{
                    return day
                }else{
                    return nil
                }
            }
            break
        case .wensday:
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            dates = numberOfWeeks.compactMap{ week -> Int? in
                let component = DateComponents(year: year, month: month, weekday: 4, weekOfMonth: week)
                guard let date = currentCalendar.date(from: component) else {return nil}
                let day = currentCalendar.component(.day, from: date)
                let weekMonth = currentCalendar.component(.month, from: date)
                if weekMonth == month{
                    return day
                }else{
                    return nil
                }
            }
            break
        case .thursday:
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            dates = numberOfWeeks.compactMap{ week -> Int? in
                let component = DateComponents(year: year, month: month, weekday: 5, weekOfMonth: week)
                guard let date = currentCalendar.date(from: component) else {return nil}
                let day = currentCalendar.component(.day, from: date)
                let weekMonth = currentCalendar.component(.month, from: date)
                if weekMonth == month{
                    return day
                }else{
                    return nil
                }
            }
            break
        case .friday:
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            dates = numberOfWeeks.compactMap{ week -> Int? in
                let component = DateComponents(year: year, month: month, weekday: 6, weekOfMonth: week)
                guard let date = currentCalendar.date(from: component) else {return nil}
                let day = currentCalendar.component(.day, from: date)
                let weekMonth = currentCalendar.component(.month, from: date)
                if weekMonth == month{
                    return day
                }else{
                    return nil
                }
            }
            break
        case .saturday:
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            dates = numberOfWeeks.compactMap{ week -> Int? in
                let component = DateComponents(year: year, month: month, weekday: 0, weekOfMonth: week)
                guard let date = currentCalendar.date(from: component) else {return nil}
                let day = currentCalendar.component(.day, from: date)
                let weekMonth = currentCalendar.component(.month, from: date)
                if weekMonth == month{
                    return day
                }else{
                    return nil
                }
            }
            break
        case .sunday:
            let year = currentCalendar.component(.year, from: date)
            let month = currentCalendar.component(.month, from: date)
            dates = numberOfWeeks.compactMap{ week -> Int? in
                let component = DateComponents(year: year, month: month, weekday: 1, weekOfMonth: week)
                guard let date = currentCalendar.date(from: component) else {return nil}
                let day = currentCalendar.component(.day, from: date)
                let weekMonth = currentCalendar.component(.month, from: date)
                if weekMonth == month{
                    return day
                }else{
                    return nil
                }
            }
            break
        }
        let dateOrder = weeks.firstIndex(of: week)!
        if let firstDate = dates.first!{
            if firstDate > dateOrder + 1{
                dates.insert(nil, at: 0)
            }
        }
        return dates
    }
    func isDateSelected(date: Date) -> Bool{
        return false
    }
    func getMonthYearString() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: model.currentDate)
    }
    func getDate(day: Int) -> Date? {
        let month = currentCalendar.component(.month, from: model.currentDate)
        let year = currentCalendar.component(.year, from: model.currentDate)
        let component = DateComponents(year: year, month: month, day: day)
        let date = currentCalendar.date(from: component)
        return date
    }
    func getColor(dayOfWeek: Int) -> Color{
        return model.selectedDay.contains(getDate(day: dayOfWeek)!) ? .blue : .clear
    }
    private func isEnabledComponent(date: Date?, for component: AvailabilityEnum) -> Bool{
        guard let date else {return false}
        let calendar = Calendar.current
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
                
        let allowYear = sortedArrays.contains { start, end in
            let dateComponent = DateComponents(year: year)
            let endYearComp = calendar.dateComponents([.year], from: end)
            let startYearComp = calendar.dateComponents([.year], from: start)
            
            guard let endYearDate = calendar.date(from: endYearComp) else {return false}
            guard let startYearDate = calendar.date(from: startYearComp) else {return false}
            
            if let date = calendar.date(from: dateComponent), date <= endYearDate, date >= startYearDate  {
                return true
            }else {
                return false
            }
        }
        let allowMonth = sortedArrays.contains { start, end in
            let dateComponent = DateComponents(year: year, month: month)
            let endMonthComp = calendar.dateComponents([.month, .year], from: end)
            let startMonthComp = calendar.dateComponents([.month, .year], from: start)
            guard let endMonthDate = calendar.date(from: endMonthComp) else {return false}
            guard let startMonthDate = calendar.date(from: startMonthComp) else {return false}
            if let date = calendar.date(from: dateComponent), date <= endMonthDate, date >= startMonthDate{
                return true
            }else{
                return false
            }
        }
        let allowDay = sortedArrays.contains { start, end in
            let dateComponent = DateComponents(year: year, month: month, day: day)
            let endDayComp = calendar.dateComponents([.day, .month, .year], from: end)
            let startDayComp = calendar.dateComponents([.day, .month, .year], from: start)
            print("date component  end -> \(endDayComp) startDate -> \(startDayComp)")
            guard let endDayDate = calendar.date(from: endDayComp) else {return false}
            guard let startDayDate = calendar.date(from: startDayComp) else {return false}
            
            if let date = calendar.date(from: dateComponent), date <= endDayDate, date >= startDayDate{
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
}
extension CalendarSwiftUI{
    class Model: ObservableObject{
        @Published var currentDate = Date()
        @Published var month: String = ""
        @Published var backgroundColor = Color.clear
        @Published var selectedDay: [Date] = []
        @Published var showPicker = false
        @Published var changeLayout = 0
    }
}

struct CalendarSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSwiftUI(singleSelection: false, availableRange: [
            (Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
             Calendar.current.date(byAdding: .day, value: 1, to: Date())!),
//            (Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
//             Calendar.current.date(byAdding: .day, value: 2, to: Date())!)
        ])
    }
}
struct MonthYearPicker: UIViewRepresentable{
    let calendar = Calendar.current
    @Binding var currentDate: Date
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UIView {
        let pickerView = UIPickerView()
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        pickerView.selectRow(month - 1, inComponent: 0, animated: false)
        pickerView.selectRow(year - 1970, inComponent: 1, animated: false)
        return pickerView
    }
    func makeCoordinator() -> PickerCoordinator {
        let coordinator = PickerCoordinator()
        coordinator.currentDate = currentDate
        coordinator.didSelectDate = { date in
            self.currentDate = date
        }
        return coordinator
    }
    class PickerCoordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource{
        var currentDate: Date!
        var didSelectDate: ((Date) -> Void)!
        lazy var selectedMonth = Calendar.current.component(.month, from: currentDate)
        lazy var selectedYear = Calendar.current.component(.year, from: currentDate)
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if component == 0{
                return 12
            }else{
                return 100
            }
        }
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if component == 0{
                let dateComponent = DateComponents(month: row + 1)
                guard let date = Calendar.current.date(from: dateComponent) else {return nil}
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM"
                return dateFormatter.string(from: date)
            }else if component == 1{
                return "\(row + 1970)"
            }
            return nil
        }
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            var dateComp: DateComponents?
            if component == 0{
                dateComp = DateComponents(year: selectedYear, month: row + 1)
                selectedMonth = row + 1
            }else if component == 1{
                dateComp = DateComponents(year: row + 1970, month: selectedMonth)
                selectedYear = row + 1970
            }
            guard let dateComp, let date = Calendar.current.date(from: dateComp) else {return}
            print(date)
            didSelectDate(date)
        }
    }
}
