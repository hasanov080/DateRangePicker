//
//  CalendarView.swift
//  CalendarView
//
//  Created by Hasan Hasanov on 27.02.23.
//

import UIKit
import SwiftUI
import Combine
protocol CalendarViewDelegate: NSObject{
    func didSelectDates(date: [Date])
}
class CalendarView: UIView {
    private var multiSelection = false
    weak var delegate: CalendarViewDelegate?
    var range: [(start: Date, end: Date)] = []{
        didSet{
            setupCalendar(singleSelection: multiSelection)
        }
    }
    private var cancelables = Set<AnyCancellable>()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCalendar()
    }
    convenience init(multiSelection: Bool) {
        self.init()
        setupCalendar(singleSelection: !multiSelection)
        self.multiSelection = multiSelection
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCalendar()
    }
    private func setupCalendar(singleSelection: Bool = false) {
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        let swiftUIView = CalendarSwiftUI(singleSelection: singleSelection, availableRange: range)
        let vc = UIHostingController(rootView: swiftUIView)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            vc.view.topAnchor.constraint(equalTo: topAnchor),
        ])
        swiftUIView.model.$selectedDay
            .sink { dates in
                self.delegate?.didSelectDates(date: dates)
            }
            .store(in: &cancelables)
    }

}
