# إصلاح كراش التطبيق على الآيفون الحقيقي (mprotect / FileUtils)

## تم حل المشكلة تلقائياً

تم ضبط المشروع كالتالي:
- **مخطط Xcode (Runner)** يستخدم **Profile** عند Run ▶️ من Xcode.
- إعداد تشغيل في **Cursor/VS Code**: **"Flutter (Profile) — للتشغيل على الآيفون الحقيقي"** — استخدمه عند التشغيل على جهاز حقيقي من الـ IDE.

**مهم:** الكراش يحدث لأن التطبيق يعمل بوضع **Debug** (JIT) على الجهاز. يجب أن يعمل دائماً بوضع **Profile** على الآيفون الحقيقي.

---

## ماذا تفعل حسب طريقة التشغيل

### إذا شغّلت من Cursor أو VS Code

1. وصّل الآيفون واختره كجهاز (من شريط Run أو من الأسفل).
2. من قائمة **Run and Debug** (أو زر التشغيل) **لا تختر "Flutter"** — اختر **"Flutter (Profile) — للتشغيل على الآيفون الحقيقي"**.
3. اضغط تشغيل ▶️.

بهذا يُبنى التطبيق ويُشغّل بوضع Profile ولن يظهر كراش `mprotect`.

### إذا شغّلت من Xcode

1. **نظّف البناء ثم شغّل** حتى لا يستخدم Xcode بناء Debug قديماً:
   - **Product** → **Clean Build Folder** (أو Shift+Cmd+K).
   - ثم اختر جهاز الآيفون واضغط **Run** ▶️.
2. تأكد أن المخطط هو **Runner** وأن **Run** مضبوط على **Profile**:
   - **Product** → **Scheme** → **Edit Scheme** → **Run** → **Build Configuration** = **Profile**.

### إذا شغّلت من الطرفية

```bash
cd /Users/mac/Downloads/anmka-stp-main-main
/Users/mac/flutter/bin/flutter run --profile -d <device-id>
```

لمعرفة `device-id`: `flutter devices` (أو `/Users/mac/flutter/bin/flutter devices`).

---

## المشكلة (للمرجع)

عند التشغيل على **جهاز آيفون حقيقي** يحدث كراش مع الرسائل:

1. **`mprotect failed: 13 (Permission denied)`** — الخطأ الرئيسي الذي يوقف التطبيق.
2. **`Class FileUtils is implemented in both ... OSAnalytics ... and ... file_picker`** — تحذير قد يسبب سلوكاً غريباً لاحقاً.

---

## السبب

- من **iOS 18.4** فما فوق، Apple منعت التطبيقات من استخدام ذاكرة قابلة للتنفيذ والتعديل (JIT) على الجهاز الحقيقي.
- وضع **Debug** في Flutter يستخدم JIT، فيفشل `mprotect` على الجهاز فيحدث الكراش.
- وضع **Profile** أو **Release** يستخدم AOT (بدون JIT)، فلا يحدث هذا الخطأ.

---

## الحل: التشغيل بوضع Profile على الجهاز الحقيقي

### من Xcode

1. من القائمة: **Product** → **Scheme** → **Edit Scheme…** (أو من القائمة المنسدلة بجانب Runner اختر **Edit Scheme**).
2. من الجهة اليسرى اختر **Run**.
3. في **Build Configuration** غيّر من **Debug** إلى **Profile**.
4. اضغط **Close**.
5. اختر جهاز الآيفون الحقيقي ثم اضغط **Run** ▶️.

بعدها التطبيق يُبنى ويُشغّل بوضع Profile ولن يحدث كراش `mprotect` على الجهاز.

> إذا أردت لاحقاً التشغيل على المحاكي بوضع Debug، ارجع إلى **Edit Scheme** → **Run** → **Build Configuration** → **Debug**.

### من الطرفية (Terminal)

```bash
cd /Users/mac/Downloads/anmka-stp-main-main
flutter run --profile -d <device-id>
```

لمعرفة `device-id`:

```bash
flutter devices
```

ثم انسخ معرف الجهاز الحقيقي (مثل `00008103-001234567890001E`) واستخدمه مكان `<device-id>`.

---

## بخصوص تحذير FileUtils

الرسالة تقول إن كلاس `FileUtils` موجود في إطار Apple (OSAnalytics) وفي إضافة **file_picker**. هذا قد يسبب لاحقاً أخطاء غريبة.

- يمكنك **تحديث file_picker** إلى آخر إصدار على أمل أن يكون الاسم تغيّر أو تم تجنب التعارض:
  ```bash
  flutter pub upgrade file_picker
  cd ios && pod install && cd ..
  ```
- إذا استمرت مشاكل بعد التحديث، يمكن مناقشة استبدال أو تقليل استخدام `file_picker` لاحقاً.

---

## ملخص

| ما تريد            | ما تفعله |
|--------------------|----------|
| تشغيل على آيفون حقيقي | استخدم **Profile** (Edit Scheme → Run → Build Configuration → Profile) أو `flutter run --profile -d <device-id>` |
| تشغيل على المحاكي مع Hot Reload | استخدم **Debug** كالمعتاد |

بعد ضبط **Profile** للتشغيل على الجهاز الحقيقي، كراش `mprotect failed: 13` يجب أن يختفي.
