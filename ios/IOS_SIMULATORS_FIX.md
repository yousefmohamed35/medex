# تشغيل التطبيق على محاكي iOS (مثل iPhone 17 Pro)

## لماذا يظهر خطأ "built for iOS" عند البناء للمحاكي؟

مكتبة **mobile_scanner** تعتمد على **Google ML Kit** (MLImage، MLKitBarcodeScanning). إطارات ML Kit المُجمَّعة مسبقاً تحتوي على:
- **arm64** لجهاز iOS فقط (وليس للمحاكي)
- **x86_64** للمحاكي فقط

لذلك يجب بناء التطبيق للمحاكي كـ **x86_64** حتى يربط مع الإطارات بشكل صحيح. إن بُنِي للمحاكي كـ arm64 يظهر خطأ:
`linking in object file built for 'iOS'`

## الحل: تشغيل المحاكي بوضع x86_64 (Rosetta) على Apple Silicon

على Mac بمعالج Apple Silicon (M1/M2/M3…)، محاكي iPhone 17 Pro يعمل افتراضياً كـ arm64. لتشغيل التطبيق عليه يجب تشغيل **تطبيق Simulator نفسه** بوضع **Rosetta** (x86_64):

1. **إيقاف Xcode والمحاكي** إن كانا مفتوحين.

2. **تفعيل تشغيل Simulator بوضع Rosetta:**
   - من **Finder** اذهب إلى:
     `/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app`
   - كليك يمين على **Simulator.app** → **Get Info** (الحصول على معلومات).
   - فعّل خيار **"Open using Rosetta"**.
   - أغلق نافذة المعلومات.

3. **فتح المشروع وتشغيل التطبيق:**
   ```bash
   open /Users/mac/Downloads/anmka-stp-main-main/ios/Runner.xcworkspace
   ```
   - في Xcode اختر من القائمة المنسدلة للوجهة: **iPhone 17 Pro** (أو أي محاكي).
   - اضغط **Run** ▶️.

بهذا يعمل المحاكي كـ x86_64 ويتم ربط التطبيق (المُبنى لـ x86_64 للمحاكي) مع إطارات ML Kit بشكل صحيح.

## إلغاء وضع Rosetta لاحقاً

إذا أردت استخدام المحاكي بدون Rosetta لمشاريع أخرى:
- **Get Info** على **Simulator.app** مرة أخرى.
- أزل تحديد **"Open using Rosetta"**.

## ملخص

- البناء للمحاكي يكون **x86_64** بسبب قيود ML Kit.
- على Apple Silicon شغّل **Simulator.app** باستخدام **Open using Rosetta** ثم شغّل التطبيق على iPhone 17 Pro من Xcode.
