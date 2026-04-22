# إعداد Firebase لـ iOS / Firebase setup for iOS

## المشكلة / The problem

التطبيق يحتاج ملف **GoogleService-Info.plist** من مشروعك في Firebase حتى تعمل خدمات Firebase (مثل تسجيل الدخول، الإشعارات).

The app needs the **GoogleService-Info.plist** file from your Firebase project for Firebase services (e.g. sign-in, notifications) to work.

---

## الخطوات / Steps

### 1. تحميل الملف / Download the file

1. افتح [Firebase Console](https://console.firebase.google.com/) واختر مشروعك (أو أنشئ مشروعاً جديداً).
2. اضغط على أيقونة **iOS** (إضافة تطبيق iOS) أو من **Project settings** (⚙️) → **Your apps**.
3. إذا لم يكن التطبيق مضافاً: أدخل **Bundle ID** الخاص بالتطبيق (مثل `com.example.educationalApp` من Xcode).
4. حمّل ملف **GoogleService-Info.plist**.

### 2. إضافة الملف إلى المشروع / Add the file to the project

1. انسخ الملف المُحمّل إلى مجلد الـ Runner:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
2. في **Xcode**:
   - افتح `ios/Runner.xcworkspace`
   - من القائمة: **File** → **Add Files to "Runner"…**
   - اختر `GoogleService-Info.plist` (من مجلد `Runner`)
   - تأكد أن **Copy items if needed** و **Runner** target مُفعّلان
   - اضغط **Add**
3. أعد تشغيل التطبيق.

---

## ملاحظة / Note

بدون هذا الملف، التطبيق **يعمل** لكن خدمات Firebase (مثل Firebase Auth أو Cloud Messaging) **لن تعمل** حتى تضيف الملف وتُعيد التشغيل.

Without this file, the app **runs** but Firebase services (e.g. Firebase Auth, Cloud Messaging) **will not work** until you add the file and run again.
