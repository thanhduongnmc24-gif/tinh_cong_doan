import UIKit

final class ONgay: UICollectionViewCell {
    static let ma = "ONgay"

    private let soDuong = UILabel()
    private let ngayAm = UILabel()
    private let thongTin = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1

        soDuong.font = .systemFont(ofSize: 15, weight: .bold)
        ngayAm.font = .systemFont(ofSize: 8, weight: .regular)
        ngayAm.textColor = .secondaryLabel
        thongTin.font = .systemFont(ofSize: 9, weight: .semibold)
        thongTin.numberOfLines = 1
        thongTin.adjustsFontSizeToFitWidth = true
        thongTin.minimumScaleFactor = 0.7

        [soDuong, ngayAm, thongTin].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            soDuong.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            soDuong.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),

            ngayAm.topAnchor.constraint(equalTo: soDuong.bottomAnchor, constant: 1),
            ngayAm.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            ngayAm.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),

            thongTin.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            thongTin.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -3),
            thongTin.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Khong ho tro coder")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.layer.borderWidth = 1
        contentView.layer.shadowOpacity = 0
        contentView.transform = .identity
    }

    func gan(ngay: Date, duLieu: DuLieuNgay) {
        let lich = TienIchNgay.lich
        soDuong.text = "\(lich.component(.day, from: ngay))"
        ngayAm.text = TienIchNgay.chuNgayAm(ngay)
        thongTin.text = duLieu.daTinh ? String(format: "%.2f%%", duLieu.phanTram) : ""

        if duLieu.nghiLam {
            contentView.backgroundColor = .systemRed.withAlphaComponent(0.12)
            contentView.layer.borderColor = UIColor.systemRed.cgColor
        } else if duLieu.phutLam < 480 {
            contentView.backgroundColor = .systemPurple.withAlphaComponent(0.12)
            contentView.layer.borderColor = UIColor.systemPurple.cgColor
        } else {
            contentView.backgroundColor = .secondarySystemGroupedBackground
            contentView.layer.borderColor = UIColor.separator.cgColor
        }

        if lich.isDateInToday(ngay) {
            contentView.layer.borderWidth = 2.5
            contentView.layer.borderColor = UIColor.systemBlue.cgColor
            contentView.layer.shadowColor = UIColor.systemBlue.cgColor
            contentView.layer.shadowOpacity = 0.28
            contentView.layer.shadowRadius = 4
            contentView.layer.shadowOffset = .zero
            soDuong.textColor = .systemBlue
        } else {
            soDuong.textColor = .label
        }
    }
}
