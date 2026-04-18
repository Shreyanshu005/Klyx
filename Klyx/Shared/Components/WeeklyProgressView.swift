import SwiftUI

/// A brutalist horizontal row showing the current week's (last 7 days) progress for a platform.
struct WeeklyProgressView: View {
    let data: [String: Int]
    let color: Color
    let title: String

    private let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var weeklyData: [(day: String, count: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = Date.now.startOfDay
        

        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let startOfWeek = calendar.date(from: components) else { return [] }
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            let dayIndex = calendar.component(.weekday, from: date) - 1
            let key = date.isoDateString
            let count = data[key] ?? 0
            let isToday = calendar.isDate(date, inSameDayAs: today)
            
            return (day: days[dayIndex], count: count, isToday: isToday)
        }
    }

    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                Text(title.uppercased())
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(1)
                
                Spacer()
                
                let activeCount = weeklyData.filter { $0.count > 0 }.count
                Text("\(activeCount) / 7 DAYS")
                    .clash(size: 14, weight: .bold)
                    .foregroundStyle(color)
            }

            HStack(spacing: 6) {
                ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 8) {
                        ZStack {

                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                            

                            if day.count > 0 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(color)
                                    .opacity(isVisible ? 1.0 : 0.0)
                                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.1), value: isVisible)
                            }
                        }
                        .frame(height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white.opacity(day.isToday ? 0.3 : 0), lineWidth: 2)
                        )
                        
                        Text(day.day)
                            .clash(size: 12, weight: .bold)
                            .foregroundStyle(day.isToday ? color : .white.opacity(0.4))
                            .opacity(isVisible ? 1.0 : 0.0)
                            .animation(.easeIn(duration: 0.3).delay(Double(index) * 0.1), value: isVisible)
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WeeklyProgressView(
            data: ["2026-04-17": 5, "2026-04-16": 2],
            color: Color(red: 1.0, green: 0.85, blue: 0.15),
            title: "LeetCode Weekly"
        )
        .padding()
    }
}
