import UIKit
final class ONgay: UICollectionViewCell {
    static let ma = "ONgay"
    let so = UILabel(), thongTin = UILabel()
    override init(frame:CGRect){ super.init(frame:frame)
        contentView.layer.cornerRadius = 12; contentView.layer.borderWidth = 1
        so.font = .systemFont(ofSize:16,weight:.bold); thongTin.font = .systemFont(ofSize:10,weight:.semibold); thongTin.numberOfLines = 2
        [so,thongTin].forEach{$0.translatesAutoresizingMaskIntoConstraints = false;contentView.addSubview($0)}
        NSLayoutConstraint.activate([so.topAnchor.constraint(equalTo:contentView.topAnchor,constant:7),so.leadingAnchor.constraint(equalTo:contentView.leadingAnchor,constant:8),thongTin.leadingAnchor.constraint(equalTo:contentView.leadingAnchor,constant:6),thongTin.trailingAnchor.constraint(equalTo:contentView.trailingAnchor,constant:-4),thongTin.bottomAnchor.constraint(equalTo:contentView.bottomAnchor,constant:-5)])
    }
    required init?(coder:NSCoder){fatalError()}
    func gan(ngay:Date, duLieu:DuLieuNgay){
        so.text = "\(TienIchNgay.lich.component(.day,from:ngay))"
        if duLieu.nghiLam { thongTin.text = "Nghỉ"; contentView.backgroundColor = .systemRed.withAlphaComponent(0.12); contentView.layer.borderColor = UIColor.systemRed.cgColor }
        else if duLieu.daTinh { thongTin.text = String(format:"%.2f công\n%.2f%%",duLieu.soCong,duLieu.phanTram);contentView.backgroundColor = .systemPurple.withAlphaComponent(0.12);contentView.layer.borderColor = UIColor.systemPurple.cgColor }
        else { thongTin.text = String(format:"%.2f công",duLieu.soCong); let du = duLieu.soCong>=1;contentView.backgroundColor = (du ? UIColor.systemGreen:UIColor.systemOrange).withAlphaComponent(0.12);contentView.layer.borderColor = (du ? UIColor.systemGreen:UIColor.systemOrange).cgColor }
    }
}
