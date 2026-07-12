//
//  TransactionStatementPDFGenerator.swift
//  MoneySense
//

import UIKit

struct TransactionStatementPDFGenerator {
    struct BreakdownItem {
        let category: String
        let amount: Double
        let hexColor: String
    }

    struct Configuration {
        let currencyCode: String
        let periodDescription: String
        let sortDescription: String
        let sources: [SpendingSource]
        let breakdown: [BreakdownItem]
    }

    private struct MonthSection {
        let month: Date
        let transactions: [Transaction]
    }

    private final class PDFCanvas {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let margin: CGFloat = 40
        let rowHeight: CGFloat = 22
        let sectionSpacing: CGFloat = 18
        let columnWidths: [CGFloat]

        var context: UIGraphicsPDFRendererContext
        var cursorY: CGFloat
        var pageNumber = 1

        init(context: UIGraphicsPDFRendererContext) {
            self.context = context
            self.cursorY = 40
            self.columnWidths = [70, 130, 82, 82, 151]
            context.beginPage()
        }

        func ensureSpace(_ height: CGFloat) {
            guard cursorY + height > pageRect.height - margin else { return }
            drawPageFooter()
            context.beginPage()
            pageNumber += 1
            cursorY = margin
        }

        func drawPageFooter() {
            let footer = "Page \(pageNumber)"
            let width = (footer as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 10)]).width
            let attributed = NSAttributedString(
                string: footer,
                attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.gray]
            )
            attributed.draw(at: CGPoint(x: (pageRect.width - width) / 2, y: pageRect.height - 28))
        }
    }

    func generatePDF(
        sections: [(month: Date, transactions: [Transaction])],
        configuration: Configuration
    ) throws -> URL {
        let monthSections = sections.map { MonthSection(month: $0.month, transactions: $0.transactions) }
        let allTransactions = monthSections.flatMap(\.transactions)
        let grandTotal = allTransactions.reduce(0.0) { $0 + $1.amount }

        let fileName = "MoneySense-Statement-\(fileDateStamp()).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: url) { context in
            let canvas = PDFCanvas(context: context)

            canvas.cursorY = drawHeader(
                on: canvas,
                configuration: configuration,
                transactionCount: allTransactions.count,
                grandTotal: grandTotal
            )

            if !configuration.breakdown.isEmpty {
                let breakdownTotal = configuration.breakdown.reduce(0) { $0 + $1.amount }
                if breakdownTotal > 0 {
                    canvas.ensureSpace(175)
                    canvas.cursorY = drawBreakdownChart(
                        on: canvas,
                        breakdown: configuration.breakdown,
                        total: breakdownTotal,
                        currencyCode: configuration.currencyCode
                    )
                }
            }

            for (index, section) in monthSections.enumerated() {
                let monthTotal = section.transactions.reduce(0.0) { $0 + $1.amount }
                canvas.cursorY = drawMonthSection(
                    on: canvas,
                    section: section,
                    monthTotal: monthTotal,
                    configuration: configuration
                )
                if index < monthSections.count - 1 {
                    canvas.cursorY += canvas.sectionSpacing
                }
            }

            canvas.ensureSpace(50)
            canvas.cursorY = drawGrandTotal(
                on: canvas,
                total: grandTotal,
                currencyCode: configuration.currencyCode
            )
            canvas.drawPageFooter()
        }

        return url
    }

    private func drawHeader(
        on canvas: PDFCanvas,
        configuration: Configuration,
        transactionCount: Int,
        grandTotal: Double
    ) -> CGFloat {
        var y = canvas.margin

        y = drawText(
            "MoneySense",
            at: CGPoint(x: canvas.margin, y: y),
            font: .boldSystemFont(ofSize: 24),
            color: .black
        )

        y = drawText(
            "Transaction Statement",
            at: CGPoint(x: canvas.margin, y: y + 4),
            font: .systemFont(ofSize: 16, weight: .medium),
            color: .darkGray
        )

        y += 18
        y = drawMetadataLine("Period", value: configuration.periodDescription, startY: y, margin: canvas.margin)
        y = drawMetadataLine("Generated", value: formattedNow(), startY: y, margin: canvas.margin)
        y = drawMetadataLine("Sort", value: configuration.sortDescription, startY: y, margin: canvas.margin)
        y = drawMetadataLine("Transactions", value: "\(transactionCount)", startY: y, margin: canvas.margin)
        y = drawMetadataLine(
            "Statement Total",
            value: formatCurrency(grandTotal, code: configuration.currencyCode),
            startY: y,
            margin: canvas.margin
        )

        y += 10
        drawLine(
            in: canvas.context.cgContext,
            fromY: y,
            margin: canvas.margin,
            pageWidth: canvas.pageRect.width
        )
        return y + 14
    }

    private func drawBreakdownChart(
        on canvas: PDFCanvas,
        breakdown: [BreakdownItem],
        total: Double,
        currencyCode: String
    ) -> CGFloat {
        var y = canvas.cursorY + 10

        y = drawText(
            "Spending Breakdown",
            at: CGPoint(x: canvas.margin, y: y),
            font: .boldSystemFont(ofSize: 14),
            color: .black
        )

        let chartTop = y + 12
        let chartHeight: CGFloat = 130
        let center = CGPoint(x: canvas.margin + 72, y: chartTop + chartHeight / 2)
        let outerRadius: CGFloat = 58
        let innerRadius: CGFloat = 38
        let gapRadians: CGFloat = 0.03

        var startAngle = -CGFloat.pi / 2
        let context = canvas.context.cgContext

        for item in breakdown {
            let fraction = CGFloat(item.amount / total)
            guard fraction > 0 else { continue }

            let sweep = fraction * 2 * .pi
            let endAngle = startAngle + sweep - gapRadians

            context.setFillColor(UIColor(hex: item.hexColor).cgColor)
            context.move(to: CGPoint(
                x: center.x + cos(startAngle) * innerRadius,
                y: center.y + sin(startAngle) * innerRadius
            ))
            context.addArc(
                center: center,
                radius: outerRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            context.addArc(
                center: center,
                radius: innerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: true
            )
            context.closePath()
            context.fillPath()

            startAngle += sweep
        }

        let totalText = formatCurrency(total, code: currencyCode)
        let spentText = "spent"
        let totalWidth = textWidth(totalText, font: .boldSystemFont(ofSize: 12))
        let spentWidth = textWidth(spentText, font: .systemFont(ofSize: 9))

        _ = drawText(
            totalText,
            at: CGPoint(x: center.x - totalWidth / 2, y: center.y - 14),
            font: .boldSystemFont(ofSize: 12),
            color: .black
        )
        _ = drawText(
            spentText,
            at: CGPoint(x: center.x - spentWidth / 2, y: center.y + 2),
            font: .systemFont(ofSize: 9),
            color: .darkGray
        )

        var legendY = chartTop + 8
        let legendX = canvas.margin + 155
        let legendMaxWidth = canvas.pageRect.width - legendX - canvas.margin

        for item in breakdown.prefix(8) {
            let dotRect = CGRect(x: legendX, y: legendY + 3, width: 8, height: 8)
            context.setFillColor(UIColor(hex: item.hexColor).cgColor)
            context.fillEllipse(in: dotRect)

            let label = truncated(item.category, limit: 16)
            let amount = formatCurrency(item.amount, code: currencyCode)
            _ = drawText(
                label,
                at: CGPoint(x: legendX + 14, y: legendY),
                font: .systemFont(ofSize: 10, weight: .medium),
                color: .black
            )

            let amountWidth = textWidth(amount, font: .systemFont(ofSize: 10))
            _ = drawText(
                amount,
                at: CGPoint(x: legendX + legendMaxWidth - amountWidth, y: legendY),
                font: .systemFont(ofSize: 10),
                color: .darkGray
            )

            legendY += 16
        }

        let sectionBottom = max(chartTop + chartHeight, legendY) + 8
        drawLine(
            in: context,
            fromY: sectionBottom,
            margin: canvas.margin,
            pageWidth: canvas.pageRect.width
        )
        return sectionBottom + 14
    }

    private func drawMonthSection(
        on canvas: PDFCanvas,
        section: MonthSection,
        monthTotal: Double,
        configuration: Configuration
    ) -> CGFloat {
        canvas.ensureSpace(28 + canvas.rowHeight)

        var y = canvas.cursorY
        let monthTitle = section.month.formatted(.dateTime.month(.wide).year()).uppercased()

        y = drawText(
            monthTitle,
            at: CGPoint(x: canvas.margin, y: y),
            font: .boldSystemFont(ofSize: 13),
            color: .black
        )

        y += 8
        canvas.ensureSpace(canvas.rowHeight)
        y = drawTableHeader(on: canvas, startY: y)
        canvas.cursorY = y

        for transaction in section.transactions {
            canvas.ensureSpace(canvas.rowHeight)
            y = canvas.cursorY
            y = drawTransactionRow(
                on: canvas,
                transaction: transaction,
                configuration: configuration,
                startY: y
            )
            canvas.cursorY = y
        }

        y = canvas.cursorY + 6
        canvas.ensureSpace(24)
        y = canvas.cursorY

        let totalLabel = "Month Total"
        let totalValue = formatCurrency(monthTotal, code: configuration.currencyCode)
        let totalValueWidth = textWidth(totalValue, font: .boldSystemFont(ofSize: 12))

        _ = drawText(
            totalLabel,
            at: CGPoint(x: canvas.margin, y: y),
            font: .boldSystemFont(ofSize: 12),
            color: .darkGray
        )
        _ = drawText(
            totalValue,
            at: CGPoint(x: canvas.pageRect.width - canvas.margin - totalValueWidth, y: y),
            font: .boldSystemFont(ofSize: 12),
            color: .black
        )

        return y + 18
    }

    private func drawTableHeader(on canvas: PDFCanvas, startY: CGFloat) -> CGFloat {
        let headers = ["Date", "Description", "Category", "Source", "Amount"]
        var x = canvas.margin

        for (index, header) in headers.enumerated() {
            let width = canvas.columnWidths[index]
            if index == headers.count - 1 {
                let headerWidth = textWidth(header, font: .boldSystemFont(ofSize: 11))
                _ = drawText(
                    header,
                    at: CGPoint(x: x + width - headerWidth, y: startY),
                    font: .boldSystemFont(ofSize: 11),
                    color: .darkGray
                )
            } else {
                _ = drawText(
                    header,
                    at: CGPoint(x: x, y: startY),
                    font: .boldSystemFont(ofSize: 11),
                    color: .darkGray
                )
            }
            x += width
        }

        return startY + canvas.rowHeight
    }

    private func drawTransactionRow(
        on canvas: PDFCanvas,
        transaction: Transaction,
        configuration: Configuration,
        startY: CGFloat
    ) -> CGFloat {
        let values: [String] = [
            transaction.date.formatted(date: .abbreviated, time: .omitted),
            truncated(transaction.description ?? "Unnamed", limit: 22),
            truncated(transaction.category?.name ?? "Other", limit: 14),
            truncated(sourceName(for: transaction, sources: configuration.sources), limit: 14),
            formatCurrency(transaction.amount, code: configuration.currencyCode)
        ]

        var x = canvas.margin
        for (index, value) in values.enumerated() {
            let width = canvas.columnWidths[index]
            let font = UIFont.systemFont(ofSize: 11)
            if index == values.count - 1 {
                let valueWidth = textWidth(value, font: font)
                _ = drawText(
                    value,
                    at: CGPoint(x: x + width - valueWidth, y: startY),
                    font: font,
                    color: .black
                )
            } else {
                _ = drawText(value, at: CGPoint(x: x, y: startY), font: font, color: .black)
            }
            x += width
        }

        return startY + canvas.rowHeight
    }

    private func drawGrandTotal(on canvas: PDFCanvas, total: Double, currencyCode: String) -> CGFloat {
        let startY = canvas.cursorY + 8
        drawLine(
            in: canvas.context.cgContext,
            fromY: startY,
            margin: canvas.margin,
            pageWidth: canvas.pageRect.width
        )

        let y = startY + 12
        let label = "Grand Total"
        let value = formatCurrency(total, code: currencyCode)
        let valueWidth = textWidth(value, font: .boldSystemFont(ofSize: 14))

        _ = drawText(label, at: CGPoint(x: canvas.margin, y: y), font: .boldSystemFont(ofSize: 14), color: .black)
        _ = drawText(
            value,
            at: CGPoint(x: canvas.pageRect.width - canvas.margin - valueWidth, y: y),
            font: .boldSystemFont(ofSize: 14),
            color: .black
        )
        return y + 20
    }
}

private extension TransactionStatementPDFGenerator {
    func drawMetadataLine(_ label: String, value: String, startY: CGFloat, margin: CGFloat) -> CGFloat {
        _ = drawText(
            "\(label):",
            at: CGPoint(x: margin, y: startY),
            font: .systemFont(ofSize: 11, weight: .semibold),
            color: .darkGray
        )
        return drawText(
            value,
            at: CGPoint(x: margin + 110, y: startY),
            font: .systemFont(ofSize: 11),
            color: .black
        )
    }

    func drawLine(in context: CGContext, fromY: CGFloat, margin: CGFloat, pageWidth: CGFloat) {
        context.setStrokeColor(UIColor.systemGray3.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: margin, y: fromY))
        context.addLine(to: CGPoint(x: pageWidth - margin, y: fromY))
        context.strokePath()
    }

    @discardableResult
    func drawText(
        _ text: String,
        at point: CGPoint,
        font: UIFont,
        color: UIColor
    ) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        NSAttributedString(string: text, attributes: attributes).draw(at: point)
        return point.y + font.lineHeight
    }

    func textWidth(_ text: String, font: UIFont) -> CGFloat {
        (text as NSString).size(withAttributes: [.font: font]).width
    }

    func truncated(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        return String(text.prefix(limit - 1)) + "…"
    }

    func sourceName(for transaction: Transaction, sources: [SpendingSource]) -> String {
        guard let sourceId = transaction.sourceId,
              let source = sources.first(where: { $0.id == sourceId }) else {
            return "—"
        }
        return source.name
    }

    func formatCurrency(_ amount: Double, code: String) -> String {
        amount.formatted(.currency(code: code))
    }

    func formattedNow() -> String {
        Date().formatted(date: .long, time: .omitted)
    }

    func fileDateStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
