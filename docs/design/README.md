# Tasarım

Stitch'ten alınan ekran tasarımları burada durur. QA ajanı bu dizindeki PNG'leri golden test çıktılarıyla karşılaştırır, bu yüzden dosya adları sabit kalmalıdır.

## Dizinler

- `screens/`: her ekran için bir PNG. Karşılaştırmanın kaynağı bu dosyalardır.
- `stitch/`: Stitch'in ham export'u (HTML, kod, varlıklar). Yalnız başvuru içindir.

## Ekran adları

Adlar `<sıra>-<ekran>.png` biçimindedir, küçük harf ve tire kullanılır:

| Dosya | Ekran |
|---|---|
| `01-phone-login.png` | Telefon numarası girişi |
| `02-otp.png` | OTP doğrulama (statik kod `1234`) |
| `03-location-permission.png` | Konum izni açıklaması |
| `04-home.png` | Ana ekran: harita, "Nereye?", "Taksi çağır" |
| `05-destination.png` | Varış noktası seçimi |
| `06-finding-driver.png` | Sürücü bulunuyor |
| `07-ride.png` | Yolculuk |
| `08-rating.png` | Yolculuk puanlama |
| `09-menu.png` | Hamburger menü |
| `10-trip-history.png` | Trip History |
| `11-account.png` | Account |
| `12-payment-methods.png` | Payment Methods |

Golden test dosyası aynı ekranın adını taşır (ör. `test/goldens/linux/04-home.png`). Böylece golden ile tasarım eşleşmesi addan bulunur.
