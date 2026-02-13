# TIMNET Format Sonrası Hızlı Kurulum

Bu proje, format sonrası temel programları tek ekrandan kurmak için hazırlanmış bir **Windows PowerShell + WinForms** arayüzüdür.

## Önizleme

- **Web tasarım önizlemesi (mock):** `index.html` dosyası (koyu tema + sarı TIMNET çizgisi).
- **Asıl çalışan uygulama:** `installer-ui.ps1` (Windows WinForms).

> Not: Bu Linux container ortamında WinForms penceresi açılamadığı için sadece web mock ekranı görsel olarak önizlenebilir.

## Kullanım

1. USB/klasör içinde bu proje yapısını koruyun.
2. `installers/` klasörüne kurmak istediğiniz `.exe` veya `.msi` dosyalarını atın.
3. Gönderdiğiniz logoyu `assets/logo.png` olarak ekleyin.
4. Windows'ta `installer-ui.ps1` dosyasını çalıştırın.

## Özellikler

- `installers` klasörünü tarayıp kurulum dosyalarını otomatik listeler.
- Seçili dosyaları sırayla çalıştırır.
- Alt kısımdaki terminal alanında:
  - "şu program kuruluyor"
  - "şu program kuruldu"
  - hata/çıkış kodu
  gibi bilgileri canlı gösterir.

## Not

- Bazı kurulumlar kullanıcı etkileşimi isteyebilir.
- Yönetici yetkisi gerekiyorsa PowerShell'i "Yönetici olarak çalıştır" ile açın.


## Açılmıyor / Not Defteri açılıyor sorunu

Eğer `installer-ui.ps1` dosyasına çift tıklayınca Not Defteri açılıyorsa bu normaldir; `.ps1` uzantısı bazen metin dosyası olarak ilişkilendirilir.

### Kolay yöntem (önerilen)
- `Baslat.bat` dosyasına çift tıklayın.
- Bu dosya, scripti doğru şekilde PowerShell ile çalıştırır.

### Manuel yöntem
1. PowerShell'i **Yönetici olarak** açın.
2. USB klasörüne gidin.
3. Aşağıdaki komutları çalıştırın:
   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\installer-ui.ps1
   ```
