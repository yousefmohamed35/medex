# إصلاح خطأ: Unable to find module 'FirebaseCore'

الخطأ يظهر عندما Xcode لا يجد مكتبات CocoaPods (مثل FirebaseCore). السبب غالباً أحد اثنين:

1. **فتح المشروع من الملف الخطأ** → يجب فتح **Runner.xcworkspace** وليس Runner.xcodeproj  
2. **DerivedData قديم أو تالف** → نحتاج مسحه وإعادة البناء

## الخطوات (بالترتيب)

### 1. إغلاق Xcode بالكامل
- اخرج من Xcode (Cmd+Q).

### 2. مسح DerivedData للمشروع
في Terminal:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
```

### 3. فتح المشروع من الـ Workspace (مهم)
```bash
open /Users/mac/Downloads/anmka-stp-main-main/ios/Runner.xcworkspace
```
**لا تفتح** `Runner.xcodeproj` — لو فتحته، الـ Pods (ومنها Firebase) لن تُربط والتطبيق سيعطي خطأ FirebaseCore.

### 4. داخل Xcode
- **Product** → **Clean Build Folder** (أو Cmd+Shift+K).
- اختر الجهاز/المحاكي من الشريط العلوي (مثلاً iPhone 17 Pro).
- **Product** → **Build** (أو Cmd+B).

---

## ملخص
- استخدم دائماً **Runner.xcworkspace** لفتح المشروع.
- بعد مسح DerivedData والـ Clean، أعد البناء من الـ workspace.
