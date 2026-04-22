# إظهار جميع محاكيات iOS في Xcode لهذا المشروع

---

## ⚠️ Running on a **physical iOS device** (mprotect / crash)

If the app **crashes on a real iPhone/iPad** with:
- `mprotect failed: 13 (Permission denied)`  
- or a crash during Dart VM init / "compiling in unoptimized JIT mode"

**Cause:** From **iOS 18.4+**, debug builds cannot use JIT (memory protection is restricted). So **debug mode does not work on device** for Flutter.

**Fix:** Run in **Release** or **Profile** mode on the device:

```bash
flutter run --release
# or
flutter run --profile
```

Optional before that: remove the app from the device, then:
```bash
flutter clean
cd ios && rm -rf build Pods Podfile.lock && pod install && cd ..
```

---

## 🇬🇧 English: Why no simulators appear (and how to fix it)

**Problem:** When you build or run this project, **no iOS Simulators appear** in the destination list. Other apps (or other projects) show all simulators.

**Cause:** This app uses **mobile_scanner** (Google ML Kit). ML Kit only supports the **simulator on x86_64**, not arm64. So the project is set to build for the simulator as **x86_64 only**. On **Apple Silicon Macs**, the default iOS Simulator runtime is **arm64 only**. Xcode then treats those simulators as incompatible with this project and **hides them**. Other projects that build for arm64 simulator see all simulators.

**Fix: Install the Universal iOS Simulator runtime** (arm64 + x86_64) so that simulators support x86_64 and appear for this project.

### Steps (one-time)

1. **Open Xcode** (you don’t need to open the project).

2. **Open component settings:**  
   **Xcode** → **Settings** (or **Preferences**) → **Platforms** (or **Components** on older Xcode).

3. **Remove the current iOS Simulator platform:**
   - Find **iOS … Simulator** (e.g. iOS 26.2 or whatever version you have).
   - Click the **"i"** icon or the name, then **Delete** / **Remove**.
   - Wait until removal finishes.

4. **Install the Universal runtime from Terminal:**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   xcodebuild -downloadPlatform iOS -architectureVariant universal
   ```
   - Enter your Mac password if asked.
   - Download may take several minutes.

5. **Quit Xcode completely** (Cmd+Q) and open it again.

6. **Open this project’s workspace:**
   ```bash
   open /Users/mac/Downloads/anmka-stp-main-main/ios/Runner.xcworkspace
   ```

7. In the scheme/destination dropdown next to **Runner**, **iOS Simulators** (e.g. iPhone 17 Pro) should now appear. Pick one and press **Run** ▶️.

**If simulators still don’t show:**  
**Product** → **Destination** → **Destination Architectures** (or **Show All Run Destinations**) and make sure both architectures / all destinations are shown.

---

## جرب أولاً (بدون تحميل جديد)

- من Xcode: **Product** → **Destination** → **Destination Architectures** (أو **Show All Run Destinations**).
- اختر **"Show Both"** أو أي خيار يعرض كل الوجهات (Apple Silicon + Rosetta/x86_64).
- انظر إن ظهرت محاكيات في القائمة المنسدلة بجانب Runner.

إن لم تظهر، استخدم الحل التالي.

---

## لماذا لا تظهر المحاكيات؟

هذا المشروع يستخدم **mobile_scanner** (Google ML Kit). إطارات ML Kit تدعم **المحاكي فقط على x86_64** وليس arm64. لذلك المشروع يُبنى للمحاكي كـ **x86_64 فقط**.

على جهاز **Apple Silicon**، المحاكيات الافتراضية تعمل بـ **arm64**، فيعتبرها Xcode غير متوافقة مع المشروع ولا يعرضها في قائمة الوجهات. مشاريع أخرى لا تستخدم ML Kit فتبنى لـ arm64 للمحاكي فتظهر لها كل المحاكيات.

## الحل: تثبيت نسخة المحاكي "Universal" (arm64 + x86_64)

عند تثبيت **النوع العام (Universal)** من منصة iOS، يصبح لديك محاكيات تدعم **x86_64** فيظهرها Xcode ويمكنك تشغيل التطبيق عليها.

### الخطوات (مرة واحدة)

1. **افتح Xcode** (بدون فتح المشروع ضروري).

2. **افتح إعدادات المكونات:**
   - من القائمة: **Xcode** → **Settings** (أو **Preferences**).
   - اختر تبويب **Platforms** (أو **Components** في إصدارات أقدم).

3. **احذف منصة محاكي iOS الحالية:**
   - ابحث عن **iOS … Simulator** (مثل iOS 26.2 أو الإصدار المثبت عندك).
   - اضغط على أيقونة **"i"** أو الاسم ثم **Delete** / **Remove**.
   - انتظر حتى يكتمل الحذف.

4. **ثبّت النسخة Universal من Terminal:**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   xcodebuild -downloadPlatform iOS -architectureVariant universal
   ```
   - قد يطلب كلمة مرور المسؤول.
   - التحميل قد يستغرق دقائق حسب السرعة.

5. **أعد تشغيل Xcode** بالكامل (Cmd+Q ثم فتحه من جديد).

6. **افتح المشروع من الـ workspace:**
   ```bash
   open /Users/mac/Downloads/anmka-stp-main-main/ios/Runner.xcworkspace
   ```

7. من القائمة المنسدلة بجانب **Runner** يجب أن تظهر الآن **محاكيات iOS** (مثل iPhone 17 Pro وغيره). اختر واحدة واضغط **Run** ▶️.

---

## إذا لم تظهر المحاكيات بعد التثبيت

- من القائمة: **Product** → **Destination** → **Destination Architectures** (أو **Show All Run Destinations**) وتأكد أن الخيار يعرض كل الوجهات أو كلا المعماريتين.
- من **Window** → **Devices and Simulators** → تبويب **Simulators**: تأكد أن المحاكي المطلوب موجود و**Show run destination** مضبوط على **Always** (أو **Automatic**) إن وُجد.

---

## ملخص

| الخطوة | ما تفعله |
|--------|----------|
| 1 | Xcode → Settings → Platforms |
| 2 | احذف منصة iOS Simulator الحالية |
| 3 | نفّذ في Terminal: `xcodebuild -downloadPlatform iOS -architectureVariant universal` |
| 4 | أعد تشغيل Xcode وافتح `Runner.xcworkspace` |
| 5 | اختر محاكي من القائمة المنسدلة ثم Run ▶️ |

بعد ذلك يجب أن تظهر كل محاكيات iOS في قائمة الوجهات وتستطيع التشغيل عليها.
