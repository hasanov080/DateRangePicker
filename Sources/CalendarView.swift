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
    var swiftUIView = CalendarSwiftUI(singleSelection: true, availableRange: [])
    var multiSelection = false{
        didSet{
            setupCalendar(singleSelection: !multiSelection)
        }
    }
    weak var delegate: CalendarViewDelegate?
    var range: [(start: Date, end: Date)] = []{
        didSet{
            setupCalendar(singleSelection: !multiSelection)
        }
    }
    private var cancelables = Set<AnyCancellable>()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCalendar()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCalendar()
    }
    private func setupCalendar(singleSelection: Bool = false) {
        subviews.forEach { view in
            view.removeFromSuperview()
        }
        swiftUIView = CalendarSwiftUI(singleSelection: singleSelection, availableRange: range)
        let vc = UIHostingController(rootView: swiftUIView)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            vc.view.topAnchor.constraint(equalTo: topAnchor),
        ])
        vc.view.autoresizingMask = [.flexibleHeight]
        swiftUIView.model.$selectedDay
            .sink { dates in
                self.delegate?.didSelectDates(date: dates)
            }
            .store(in: &cancelables)
        swiftUIView.model.$changeLayout
            .sink { value in
                self.invalidateIntrinsicContentSize()
                self.frame.size = vc.view.systemLayoutSizeFitting(vc.view.frame.size, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .dragThatCannotResizeScene)
            }
            .store(in: &cancelables)
    }
}
