import UIKit

final class ManHinhTonCongDoan: UIViewController, UITextFieldDelegate {
    private let cuon = UIScrollView()
    private let noiDung = UIStackView()
    private let danhSach = UIStackView()
    private weak var oDangNhap: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Công đoạn dư"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Hủy", style: .plain, target: self, action: #selector(huy))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cộng dồn", style: .done, target: self, action: #selector(luu))
        taoGiaoDien()
        taoBanPhim()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func taoGiaoDien() {
        let moTa = UILabel()
        moTa.text = "Nhập số tờ và phần trăm. Mỗi lần bấm Cộng dồn, dữ liệu sẽ được cộng vào đúng loại phần trăm tương ứng."
        moTa.font = .systemFont(ofSize: 13)
        moTa.textColor = .secondaryLabel
        moTa.numberOfLines = 0
        danhSach.axis = .vertical
        danhSach.spacing = 10
        themDong(tuDongNhap: false)

        let nutThem = UIButton(type: .system)
        nutThem.setTitle("＋ Thêm công đoạn dư", for: .normal)
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
            cuon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cuon.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cuon.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cuon.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noiDung.topAnchor.constraint(equalTo: cuon.contentLayoutGuide.topAnchor, constant: 18),
            noiDung.bottomAnchor.constraint(equalTo: cuon.contentLayoutGuide.bottomAnchor, constant: -30),
            noiDung.leadingAnchor.constraint(equalTo: cuon.frameLayoutGuide.leadingAnchor, constant: 18),
            noiDung.trailingAnchor.constraint(equalTo: cuon.frameLayoutGuide.trailingAnchor, constant: -18)
        ])
    }

    private func taoTieuDeCot() -> UIStackView {
        let soTo = nhan("Số tờ"), phanTram = nhan("Phần trăm"), choXoa = UIView()
        choXoa.widthAnchor.constraint(equalToConstant: 42).isActive = true
        let hang = UIStackView(arrangedSubviews: [soTo, phanTram, choXoa])
        hang.spacing = 8
        soTo.widthAnchor.constraint(equalTo: phanTram.widthAnchor).isActive = true
        return hang
    }

    private func nhan(_ chu: String) -> UILabel {
        let nhan = UILabel()
        nhan.text = chu
        nhan.font = .systemFont(ofSize: 13, weight: .bold)
        nhan.textAlignment = .center
        return nhan
    }

    private func cauHinh(_ oNhap: UITextField, goiY: String) {
        oNhap.borderStyle = .roundedRect
        oNhap.keyboardType = .decimalPad
        oNhap.placeholder = goiY
        oNhap.delegate = self
        let thanh = UIToolbar()
        thanh.sizeToFit()
        thanh.items = [.init(systemItem: .flexibleSpace), .init(title: "Xong", style: .done, target: self, action: #selector(tatBanPhim))]
        oNhap.inputAccessoryView = thanh
    }

    private func themDong(tuDongNhap: Bool) {
        let soTo = UITextField(), phanTram = UITextField(), xoa = UIButton(type: .system)
        cauHinh(soTo, goiY: "Số tờ")
        cauHinh(phanTram, goiY: "%")
        xoa.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        xoa.tintColor = .systemRed
        xoa.widthAnchor.constraint(equalToConstant: 42).isActive = true
        let hang = UIStackView(arrangedSubviews: [soTo, phanTram, xoa])
        hang.spacing = 8
        soTo.widthAnchor.constraint(equalTo: phanTram.widthAnchor).isActive = true
        xoa.addAction(UIAction { [weak self, weak hang] _ in
            guard let self, let hang else { return }
            self.danhSach.removeArrangedSubview(hang)
            hang.removeFromSuperview()
        }, for: .touchUpInside)
        danhSach.addArrangedSubview(hang)
        if tuDongNhap {
            view.layoutIfNeeded()
            DispatchQueue.main.async { [weak self, weak soTo] in
                guard let self, let soTo else { return }
                soTo.becomeFirstResponder()
                self.cuon.scrollRectToVisible(soTo.convert(soTo.bounds, to: self.cuon).insetBy(dx: 0, dy: -24), animated: true)
            }
        }
    }

    private func taoBanPhim() {
        let cham = UITapGestureRecognizer(target: self, action: #selector(tatBanPhim))
        cham.cancelsTouchesInView = false
        view.addGestureRecognizer(cham)
        NotificationCenter.default.addObserver(self, selector: #selector(banPhimHien(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(banPhimAn), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func docSo(_ chuoi: String?) -> Double {
        Double(chuoi?.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0
    }

    private func docDanhSach() -> [CongDoan] {
        danhSach.arrangedSubviews.compactMap { view in
            guard let hang = view as? UIStackView,
                  let soTo = hang.arrangedSubviews[0] as? UITextField,
                  let phanTram = hang.arrangedSubviews[1] as? UITextField else { return nil }
            let soLuong = docSo(soTo.text), heSo = docSo(phanTram.text)
            return soLuong == 0 || heSo <= 0 ? nil : CongDoan(soLuong: soLuong, heSo: heSo)
        }
    }

    @objc private func themMoi() { themDong(tuDongNhap: true) }
    @objc private func tatBanPhim() { view.endEditing(true) }
    @objc private func banPhimHien(_ thongBao: Notification) {
        guard let khung = thongBao.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let cao = max(0, view.bounds.maxY - view.convert(khung, from: nil).minY)
        cuon.contentInset.bottom = cao + 12
        cuon.verticalScrollIndicatorInsets.bottom = cao + 12
        if let oDangNhap { cuon.scrollRectToVisible(oDangNhap.convert(oDangNhap.bounds, to: cuon).insetBy(dx: 0, dy: -24), animated: true) }
    }
    @objc private func banPhimAn() { cuon.contentInset.bottom = 0; cuon.verticalScrollIndicatorInsets.bottom = 0 }
    func textFieldDidBeginEditing(_ textField: UITextField) { oDangNhap = textField }
    func textFieldDidEndEditing(_ textField: UITextField) { if oDangNhap === textField { oDangNhap = nil } }
    @objc private func huy() { dismiss(animated: true) }
    @objc private func luu() {
        tatBanPhim()
        KhoCongDoanDu.dungChung.congDon(docDanhSach())
        dismiss(animated: true)
    }
}
