import UIKit

final class ManHinhTonCongDoan: UIViewController, UITextFieldDelegate {
    private let cuon = UIScrollView()
    private let noiDung = UIStackView()
    private let danhSach = UIStackView()
    private weak var oDangNhap: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Số tờ hiện có"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Hủy", style: .plain, target: self, action: #selector(huy))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lưu", style: .done, target: self, action: #selector(luu))
        taoGiaoDien()
        taoBanPhim()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func taoGiaoDien() {
        let moTa = UILabel()
        moTa.text = "Chỉ lưu số tờ hiện có của từng loại, không cộng tổng và không tham gia tính sản lượng."
        moTa.font = .systemFont(ofSize: 13)
        moTa.textColor = .secondaryLabel
        moTa.numberOfLines = 0

        danhSach.axis = .vertical
        danhSach.spacing = 10
        let daLuu = KhoTonCongDoan.dungChung.danhSach
        (daLuu.isEmpty ? [TonCongDoan()] : daLuu).forEach { themDong($0, tuDongNhap: false) }

        let nutThem = UIButton(type: .system)
        nutThem.setTitle("＋ Thêm loại công đoạn", for: .normal)
        nutThem.addTarget(self, action: #selector(themMoi), for: .touchUpInside)

        noiDung.axis = .vertical
        noiDung.spacing = 14
        noiDung.translatesAutoresizingMaskIntoConstraints = false
        [moTa, taoTieuDeCot(), danhSach, nutThem].forEach { noiDung.addArrangedSubview($0) }
        cuon.keyboardDismissMode = .interactive
        cuon.alwaysBounceVertical = true
        cuon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cuon)
        cuon.addSubview(noiDung)
        NSLayoutConstraint.activate([
            cuon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), cuon.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cuon.leadingAnchor.constraint(equalTo: view.leadingAnchor), cuon.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noiDung.topAnchor.constraint(equalTo: cuon.contentLayoutGuide.topAnchor, constant: 18),
            noiDung.bottomAnchor.constraint(equalTo: cuon.contentLayoutGuide.bottomAnchor, constant: -30),
            noiDung.leadingAnchor.constraint(equalTo: cuon.frameLayoutGuide.leadingAnchor, constant: 18),
            noiDung.trailingAnchor.constraint(equalTo: cuon.frameLayoutGuide.trailingAnchor, constant: -18)
        ])
    }

    private func taoTieuDeCot() -> UIStackView {
        let ten = nhan("Tên loại"), soTo = nhan("Số tờ"), choXoa = UIView()
        choXoa.widthAnchor.constraint(equalToConstant: 42).isActive = true
        let hang = UIStackView(arrangedSubviews: [ten, soTo, choXoa])
        hang.spacing = 8
        ten.widthAnchor.constraint(equalTo: soTo.widthAnchor).isActive = true
        return hang
    }

    private func nhan(_ chu: String) -> UILabel {
        let n = UILabel(); n.text = chu; n.font = .systemFont(ofSize: 13, weight: .bold); n.textAlignment = .center; return n
    }

    private func cauHinh(_ o: UITextField, banPhim: UIKeyboardType) {
        o.borderStyle = .roundedRect; o.keyboardType = banPhim; o.delegate = self
        let thanh = UIToolbar(); thanh.sizeToFit()
        thanh.items = [.init(systemItem: .flexibleSpace), .init(title: "Xong", style: .done, target: self, action: #selector(tatBanPhim))]
        o.inputAccessoryView = thanh
    }

    private func themDong(_ giaTri: TonCongDoan, tuDongNhap: Bool) {
        let ten = UITextField(), soTo = UITextField(), xoa = UIButton(type: .system)
        cauHinh(ten, banPhim: .default); cauHinh(soTo, banPhim: .decimalPad)
        ten.placeholder = "Tên công đoạn"; soTo.placeholder = "0"
        ten.text = giaTri.tenLoai; soTo.text = giaTri.soTo == 0 ? "" : giaTri.soTo.chuoiGon
        xoa.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal); xoa.tintColor = .systemRed
        xoa.widthAnchor.constraint(equalToConstant: 42).isActive = true
        let hang = UIStackView(arrangedSubviews: [ten, soTo, xoa]); hang.spacing = 8
        ten.widthAnchor.constraint(equalTo: soTo.widthAnchor).isActive = true
        xoa.addAction(UIAction { [weak self, weak hang] _ in guard let self, let hang else { return }; self.danhSach.removeArrangedSubview(hang); hang.removeFromSuperview() }, for: .touchUpInside)
        danhSach.addArrangedSubview(hang)
        if tuDongNhap { view.layoutIfNeeded(); DispatchQueue.main.async { [weak self, weak ten] in guard let self, let ten else { return }; ten.becomeFirstResponder(); self.cuon.scrollRectToVisible(ten.convert(ten.bounds, to: self.cuon).insetBy(dx: 0, dy: -24), animated: true) } }
    }

    private func taoBanPhim() {
        let cham = UITapGestureRecognizer(target: self, action: #selector(tatBanPhim)); cham.cancelsTouchesInView = false; view.addGestureRecognizer(cham)
        NotificationCenter.default.addObserver(self, selector: #selector(banPhimHien(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(banPhimAn), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func docSo(_ s: String?) -> Double { Double(s?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0 }
    private func docDanhSach() -> [TonCongDoan] { danhSach.arrangedSubviews.compactMap { v in
        guard let h = v as? UIStackView, let ten = h.arrangedSubviews[0] as? UITextField, let so = h.arrangedSubviews[1] as? UITextField else { return nil }
        let t = ten.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", n = docSo(so.text)
        return t.isEmpty && n == 0 ? nil : TonCongDoan(tenLoai: t, soTo: n)
    } }

    @objc private func themMoi() { themDong(TonCongDoan(), tuDongNhap: true) }
    @objc private func tatBanPhim() { view.endEditing(true) }
    @objc private func banPhimHien(_ n: Notification) { guard let k = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }; let h = max(0, view.bounds.maxY - view.convert(k, from: nil).minY); cuon.contentInset.bottom = h + 12; cuon.verticalScrollIndicatorInsets.bottom = h + 12 }
    @objc private func banPhimAn() { cuon.contentInset.bottom = 0; cuon.verticalScrollIndicatorInsets.bottom = 0 }
    func textFieldDidBeginEditing(_ textField: UITextField) { oDangNhap = textField }
    func textFieldDidEndEditing(_ textField: UITextField) { if oDangNhap === textField { oDangNhap = nil } }
    @objc private func huy() { dismiss(animated: true) }
    @objc private func luu() { tatBanPhim(); KhoTonCongDoan.dungChung.luu(docDanhSach()); dismiss(animated: true) }
}
