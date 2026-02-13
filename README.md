# TIMNET Format Sonrası Hızlı Kurulum

Bu proje, format sonrası temel programları tek ekrandan kurmak için hazırlanmış bir **Windows PowerShell + WinForms** arayüzüdür.

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
