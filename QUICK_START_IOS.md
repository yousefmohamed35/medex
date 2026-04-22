# 🚀 تشغيل المشروع على iOS - دليل سريع

## ⚠️ تشغيل على آيفون حقيقي (مهم)

على **جهاز آيفون فعلي** يجب استخدام وضع **Profile** وليس Debug، وإلا يحدث كراش (`mprotect failed: 13`).

- **من Cursor / VS Code:** من قائمة **Run and Debug** اختر **"Flutter (Profile) — افتراضي للتشغيل على الآيفون"** ثم شغّل ▶️ (هذا الإعداد هو الأول في القائمة).
- **من Xcode:** **Product** → **Clean Build Folder** ثم اختر جهازك واضغط Run ▶️ (المخطط مضبوط على Profile).

تفاصيل كاملة: `ios/IOS_REAL_DEVICE_CRASH_FIX.md`

---

## ✅ تم إعداد المشروع لـ iOS

المشروع جاهز للتشغيل على iOS. تم:
- ✅ إنشاء بنية iOS ورفع الحد الأدنى إلى 15.5 (لمكتبة mobile_scanner)
- ✅ تثبيت التبعيات (CocoaPods و Flutter)
- ✅ إصلاح توافق المكتبات (intl، google_fonts، CardTheme)
- ✅ دعم محاكي iPhone 17 Pro

## 📱 تشغيل على محاكي iPhone 17 Pro

### الطريقة الموصى بها: من Xcode

1. **افتح المشروع في Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **اختر المحاكي:** من القائمة العلوية اختر **iPhone 17 Pro** (أو أي محاكي iOS).

3. **شغّل التطبيق:** اضغط زر التشغيل ▶️ أو `Cmd + R`.

بهذا يتم البناء للتطبيق لبنية المحاكي (arm64) وتشغيله على iPhone 17 Pro.

### من Terminal (بعد البناء من Xcode مرة واحدة)

إذا أردت استخدام Flutter من الطرفية:
```bash
export PATH="/Users/mac/.gem/ruby/2.6.0/bin:$PATH"
export RUBYOPT="-r logger"
cd /Users/mac/Downloads/anmka-stp-main-main
flutter run -d "iPhone 17 Pro"
```
ملاحظة: قد يظهر خطأ "Unable to find a destination" من xcodebuild؛ في هذه الحالة استخدم Xcode للتشغيل.

### بناء للمحاكي فقط (من Terminal)

```bash
export PATH="/Users/mac/.gem/ruby/2.6.0/bin:$PATH"
export RUBYOPT="-r logger"
cd /Users/mac/Downloads/anmka-stp-main-main
flutter build ios --simulator
```
التطبيق الناتج: `build/ios/iphonesimulator/Runner.app`

## ⚠️ إذا واجهت مشاكل

### CocoaPods "broken" أو لا يعمل
قبل أي أمر يستخدم Pods، شغّل:
```bash
export RUBYOPT="-r logger"
export PATH="/Users/mac/.gem/ruby/2.6.0/bin:$PATH"
```

### "No simulators available"
- **Xcode** → **Settings** → **Platforms** → تأكد من تثبيت iOS Simulator.

### "Code signing error"
- في Xcode: **Runner** → **Signing & Capabilities** → اختر **Team** وغيّر **Bundle Identifier** إذا لزم.

### "Unable to find a destination matching"
- شغّل التطبيق من داخل Xcode بعد اختيار iPhone 17 Pro من القائمة العلوية.

## 🎯 الميزات المدعومة

- ✅ دعم RTL كامل للعربية
- ✅ خط Cairo
- ✅ جميع الشاشات جاهزة
- ✅ الحد الأدنى iOS 15.5

---

**لتشغيل على iPhone 17 Pro: افتح `ios/Runner.xcworkspace` في Xcode، اختر iPhone 17 Pro، ثم اضغط ▶️**


