import UIKit

final class BarChartRenderer: UIView {

    struct BarEntry {
        let label: String
        let value: Double
        let color: UIColor
    }

    var entries: [BarEntry] = [] { didSet { setNeedsDisplay() } }
    var maxValue: Double = 1.0
    var title: String = "" { didSet { titleLabel.text = title } }

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        titleLabel.font = PrismTheme.Glyph.subhead(13)
        titleLabel.textColor = PrismTheme.Pigment.frost
        addSubview(titleLabel)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 20)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard !entries.isEmpty, let ctx = UIGraphicsGetCurrentContext() else { return }

        let topPad: CGFloat = 24
        let bottomPad: CGFloat = 28
        let leftPad: CGFloat = 8
        let chartH = rect.height - topPad - bottomPad
        let barW = (rect.width - leftPad) / CGFloat(entries.count) - 6
        let peak = maxValue > 0 ? maxValue : 1

        for (i, entry) in entries.enumerated() {
            let barH = CGFloat(entry.value / peak) * chartH
            let x = leftPad + CGFloat(i) * ((rect.width - leftPad) / CGFloat(entries.count))
            let y = topPad + chartH - barH

            // Gradient bar
            let colors = [entry.color.cgColor, entry.color.withAlphaComponent(0.4).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
            ctx.saveGState()
            let barRect = CGRect(x: x, y: y, width: barW, height: barH)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
            ctx.addPath(path.cgPath)
            ctx.clip()
            ctx.drawLinearGradient(gradient, start: CGPoint(x: x, y: y), end: CGPoint(x: x, y: y + barH), options: [])
            ctx.restoreGState()

            // Glow
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: 6, color: entry.color.withAlphaComponent(0.6).cgColor)
            entry.color.withAlphaComponent(0.01).setFill()
            path.fill()
            ctx.restoreGState()

            // Value label
            let valStr = entry.value < 0.01 ? String(format: "%.3f", entry.value) : String(format: "%.1f%%", entry.value * 100)
            let valAttr: [NSAttributedString.Key: Any] = [
                .font: PrismTheme.Glyph.mono(9),
                .foregroundColor: PrismTheme.Pigment.frost
            ]
            let valSize = (valStr as NSString).size(withAttributes: valAttr)
            (valStr as NSString).draw(at: CGPoint(x: x + (barW - valSize.width) / 2, y: y - 14), withAttributes: valAttr)

            // X label
            let labelAttr: [NSAttributedString.Key: Any] = [
                .font: PrismTheme.Glyph.corpus(9),
                .foregroundColor: PrismTheme.Pigment.mist
            ]
            let labelSize = (entry.label as NSString).size(withAttributes: labelAttr)
            (entry.label as NSString).draw(
                at: CGPoint(x: x + (barW - labelSize.width) / 2, y: rect.height - bottomPad + 4),
                withAttributes: labelAttr
            )
        }
    }
}

final class MatrixChartRenderer: UIView {

    var labels: [String] = [] { didSet { setNeedsDisplay() } }
    var matrix: [[Double]] = [] { didSet { setNeedsDisplay() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard !labels.isEmpty, matrix.count == labels.count else { return }
        let n = labels.count
        let labelW: CGFloat = 50
        let cellSize = min((rect.width - labelW) / CGFloat(n), (rect.height - labelW) / CGFloat(n))

        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let headerAttr: [NSAttributedString.Key: Any] = [
            .font: PrismTheme.Glyph.mono(10),
            .foregroundColor: PrismTheme.Pigment.mist
        ]

        for (col, label) in labels.enumerated() {
            let x = labelW + CGFloat(col) * cellSize + (cellSize - 30) / 2
            (label as NSString).draw(at: CGPoint(x: x, y: 4), withAttributes: headerAttr)
        }

        for (row, rowLabel) in labels.enumerated() {
            let y = labelW + CGFloat(row) * cellSize + (cellSize - 14) / 2
            (rowLabel as NSString).draw(at: CGPoint(x: 4, y: y), withAttributes: headerAttr)

            for col in 0..<n {
                let val = row < matrix.count && col < matrix[row].count ? matrix[row][col] : 0
                let cellRect = CGRect(x: labelW + CGFloat(col) * cellSize + 2, y: labelW + CGFloat(row) * cellSize + 2, width: cellSize - 4, height: cellSize - 4)
                let alpha = CGFloat(min(val * 10, 1.0))
                let cellColor = row == col ? PrismTheme.Pigment.vault : PrismTheme.Pigment.nebula.withAlphaComponent(alpha)
                ctx.setFillColor(cellColor.cgColor)
                let path = UIBezierPath(roundedRect: cellRect, cornerRadius: 4)
                ctx.addPath(path.cgPath)
                ctx.fillPath()

                if row != col && val > 0 {
                    let valStr = String(format: "%.1f%%", val * 100)
                    let valAttr: [NSAttributedString.Key: Any] = [
                        .font: PrismTheme.Glyph.mono(9),
                        .foregroundColor: UIColor.white.withAlphaComponent(0.9)
                    ]
                    let sz = (valStr as NSString).size(withAttributes: valAttr)
                    (valStr as NSString).draw(at: CGPoint(x: cellRect.midX - sz.width / 2, y: cellRect.midY - sz.height / 2), withAttributes: valAttr)
                }
            }
        }
    }
}

final class HistogramRenderer: UIView {

    var samples: [Double] = [] { didSet { setNeedsDisplay() } }
    var accentColor: UIColor = PrismTheme.Pigment.nebula

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard samples.count > 1, let ctx = UIGraphicsGetCurrentContext() else { return }

        let buckets = 20
        let minV = samples.min() ?? 0
        let maxV = samples.max() ?? 1
        let range = maxV - minV > 0 ? maxV - minV : 1
        var counts = Array(repeating: 0, count: buckets)
        for s in samples {
            let idx = min(Int((s - minV) / range * Double(buckets)), buckets - 1)
            counts[idx] += 1
        }
        let maxCount = counts.max() ?? 1
        let barW = rect.width / CGFloat(buckets)
        let chartH = rect.height - 20

        for (i, count) in counts.enumerated() {
            let barH = CGFloat(count) / CGFloat(maxCount) * chartH
            let x = CGFloat(i) * barW
            let y = chartH - barH
            let barRect = CGRect(x: x + 1, y: y, width: barW - 2, height: barH)
            let alpha = 0.4 + 0.6 * CGFloat(count) / CGFloat(maxCount)
            ctx.setFillColor(accentColor.withAlphaComponent(alpha).cgColor)
            ctx.setShadow(offset: .zero, blur: 4, color: accentColor.withAlphaComponent(0.4).cgColor)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 2)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }

        // Axis labels
        let minAttr: [NSAttributedString.Key: Any] = [.font: PrismTheme.Glyph.mono(9), .foregroundColor: PrismTheme.Pigment.mist]
        (String(format: "%.2f", minV) as NSString).draw(at: CGPoint(x: 2, y: rect.height - 16), withAttributes: minAttr)
        let maxStr = String(format: "%.2f", maxV)
        let maxSz = (maxStr as NSString).size(withAttributes: minAttr)
        (maxStr as NSString).draw(at: CGPoint(x: rect.width - maxSz.width - 2, y: rect.height - 16), withAttributes: minAttr)
    }
}
