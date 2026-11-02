//
//  SpendingTrendChartView.swift
//  ExpenseTracker
//
//  Interactive spending trends chart using Apple's Swift Charts framework.
//

import SwiftUI
import Charts

struct SpendingTrendChartView: View {
    let dataPoints: [DailySpendingPoint]
    @Binding var selectedDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spending Trend")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Daily expense progression")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Picker("Days", selection: $selectedDays) {
                    Text("7D").tag(7)
                    Text("14D").tag(14)
                    Text("30D").tag(30)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }

            if dataPoints.isEmpty || dataPoints.allSatisfy({ $0.amount == 0 }) {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundColor(.secondary.opacity(0.4))
                    Text("No expenses recorded for this timeframe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
            } else {
                Chart {
                    ForEach(dataPoints) { point in
                        // Area gradient fill
                        AreaMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Amount", NSDecimalNumber(decimal: point.amount).doubleValue)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.brandPrimary.opacity(0.35), Color.brandPrimary.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        // Smooth line
                        LineMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Amount", NSDecimalNumber(decimal: point.amount).doubleValue)
                        )
                        .foregroundStyle(Color.brandPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.catmullRom)

                        // Distinct points
                        PointMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Amount", NSDecimalNumber(decimal: point.amount).doubleValue)
                        )
                        .foregroundStyle(Color.brandPrimary)
                        .symbolSize(18)
                    }
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: selectedDays <= 7 ? 7 : 5)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(Color.secondary.opacity(0.2))
                        AxisTick()
                        AxisValueLabel(format: selectedDays <= 7 ? .dateTime.weekday(.abbreviated) : .dateTime.month(.abbreviated).day())
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                            .foregroundStyle(Color.secondary.opacity(0.2))
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text("$\(Int(val))")
                                    .font(.caption2)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}
