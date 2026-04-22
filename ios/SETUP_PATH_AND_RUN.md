# تشغيل flutter و pod من الطرفية (عند ظهور command not found)

إذا ظهرت رسالة `zsh: command not found: flutter` أو `pod`، استخدم الأوامر التالية **بالمسار الكامل**:

## أوامر جاهزة (انسخ والصق)

```bash
cd /Users/mac/Downloads/anmka-stp-main-main

# تحديث حزم Flutter (يعمل بهذا المسار)
/Users/mac/flutter/bin/flutter pub get
```

**ملاحظة عن `pod install`:** إذا فشل الأمر `pod` (مثلاً بسبب إصدار Ruby قديم)، يمكنك:
- فتح المشروع في Xcode: `open /Users/mac/Downloads/anmka-stp-main-main/ios/Runner.xcworkspace` ثم البناء من Xcode (Product → Build)؛ Xcode يستخدم الـ Pods المثبتة مسبقاً.
- أو تثبيت Ruby أحدث عبر Homebrew ثم تثبيت CocoaPods من جديد.

---

## إعداد PATH مرة واحدة (اختياري)

لكي يعمل أمر `flutter` في أي طرفية بدون كتابة المسار الكامل، أضف السطور التالية إلى ملف `~/.zshrc` ثم أعد فتح الطرفية:

```bash
# Flutter
export PATH="$PATH:/Users/mac/flutter/bin"

# Ruby gems (CocoaPods) - إذا كان pod يعمل عندك
export PATH="$PATH:/Users/mac/.gem/ruby/2.6.0/bin"
```

**طريقة الإضافة من الطرفية:**
```bash
echo '' >> ~/.zshrc
echo '# Flutter' >> ~/.zshrc
echo 'export PATH="$PATH:/Users/mac/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

بعدها يمكنك استخدام `flutter pub get` و `flutter run` مباشرة.
