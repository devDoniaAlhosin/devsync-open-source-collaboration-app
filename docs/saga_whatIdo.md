# Saga: اللي عملته في الـ Profile (DevSync)

الفرع: `feature/profile-ui`
الـ feature بتاعي: **Profile + GitHub** (Part 1 في تقرير الـ Remaining Work)
آخر تحديث: 18 Nov 2026

---

## 1) الصورة الكبيرة

الـ Profile بيتبع نفس معمارية الـ auth:

```
Screen (BlocBuilder)
   ↓
ProfileCubit
   ↓
Use cases (GetProfile, UpdateProfile, SaveGithubScan)
   ↓
ProfileRepository (Result / Failure)
   ↓
ProfileRemoteDataSource  → Firestore: users/{uid}.profile
GithubProfileRemoteDataSource → api.github.com (الـ scan الحقيقي)
```

الـ widgets مبتنادّيش Firestore ولا GitHub مباشرة، كل حاجة بتعدّي على الـ Cubit.

---

## 2) المرحلة 1: إصلاح الـ build بعد الـ merge

بعد الـ merge كان المشروع مش بيعمل compile لأن ملفات كانت فاضية أو ناقصة:

| الملف | المشكلة | اللي عملته |
|---|---|---|
| `profile_remote_data_source.dart` | فاضي، والـ DI والـ repository بيستخدموه | كتبته: `fetch()` و`save()` على `users/{uid}` تحت مفتاح `profile` |
| `NotSignedInException` | الـ repository بيستخدمها ومش معرّفة | عرّفتها في نفس ملف الـ remote data source |
| `save_github_scan.dart` | فاضي والـ DI بيسجّله | كتبت `SaveGithubScan` و`SaveGithubScanParams` |
| `profile_state.dart` | ناقص `ProfileSaveFailure` | ضفتها (الـ Cubit وشاشة Edit Profile بيستخدموها) |

**ليه merge على `users/{uid}`؟** عشان ما نمسحش بيانات الـ auth اللي في نفس المستند (email وغيره). الـ profile كله تحت مفتاح `profile`.

---

## 3) المرحلة 2: ربط Connect GitHub بالـ Profile

**المشكلة:** `ConnectGithubScreen` (شغل Emad) كانت بتعمل scan وتروح Edit Profile من غير ما تحفظ حاجة، فالـ skills المقترحة كانت بتضيع.

**الحل:** عملت `ConnectGithubEntry` (wrapper) من غير ما ألمس شاشة Emad:

```
Connect GitHub (scan) → ConnectGithubEntry → ProfileCubit.saveGithubScan → Firestore → Edit Profile
```

- ضفت `saveGithubScan` في `ProfileCubit`.
- غيّرت route الـ `connectGithub` ليفتح `ConnectGithubEntry`.
- شلت route قديم مكرر كان بيمنع الجديد من الشغل.

---

## 4) المرحلة 3 و4: تنضيف

- مسحت `ProfileLocalDataSource` (كان dead code بعد ما بقينا على Firestore).
- مسحت `profile_data.dart` والـ `typedef ProfileData`، وشاشة Edit Profile بقت تستخدم `Profile` مباشرة.
- `LanguageBreakdown`: ضفت empty state ("Connect GitHub to see your languages") وحماية للـ `flex` لو النسبة صفر.

---

## 5) الـ Hardening (مهام التقرير الأربعة)

| # | المهمة في التقرير | الحالة |
|---|---|---|
| 1 | Firestore rules: صاحب الـ uid بس يكتب profile بتاعه | بلوك `users/{userId}` بيحقق ده. ضفت كمان `fcmTokens` (شوف تحت). **محتاجة Publish** |
| 2 | Offline / error UI | Retry موجود في Profile و`EditProfileEntry`. ضفت: زرار الحفظ بيتقفل أثناء الـ Saving، وtimeout 10 ثواني للحفظ بيطلّع SnackBar بدل ما يعلّق |
| 3 | Onboarding | راجعته: Register/Verify → Connect GitHub → Edit Profile (`asOnboarding: true`) → Home. مفيش dead end في الكود |
| 4 | توثيق `GITHUB_TOKEN` | الـ data source بيقرأ `String.fromEnvironment('GITHUB_TOKEN')`، والتوثيق موجود في الـ docs والـ doc comment |

### ليه ضفت `fcmTokens` في الـ Rules؟

قواعد Firestore **مبتنزلش للـ subcollections**. قاعدة `users/{userId}` بتغطي المستند بس، فالكتابة في `users/{uid}/fcmTokens/{token}` (حفظ الـ FCM token، شغل Mohey) كانت بتترفض بـ `permission-denied`. ضفت:

```
match /fcmTokens/{tokenId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

صاحب الـ uid بس يكتب الـ tokens بتاعته. **لازم تتنشر على Firebase Console عشان تشتغل.**

### ليه الـ timeout في الحفظ؟

لما النت يكون مقفول، Firestore مش بيرمي error، بيحط الكتابة في queue وينتظر، فالزرار كان هيفضل "Saving…" للأبد. دلوقتي بعد 10 ثواني بيرمي `FirebaseException(code: 'unavailable')` والـ repository بيحوّله لـ `ProfileSaveFailure` والـ UI بيعرض الرسالة.

---

## 6) مشاكل ظهرت وكانت مش من كودي

| المشكلة | السبب | الحل |
|---|---|---|
| شاشة بيضا على Chrome | `firebase_options.dart` مش مظبوط للـ web | شغّلت على Android |
| `Could not close incremental caches` وGradle cache تالف | cache اتبوظ + درايف C: مليان | مسح الـ cache وتفضيّة مساحة |
| `device offline` | ADB | `adb kill-server` وإعادة توصيل الكابل |
| `not enough space on the disk` | درايف C: مليان (الـ Temp والـ Gradle) | تفضيّة مساحة |
| Google Sign-In مش بيفتح | غالباً SHA-1 جهازي مش متسجل في Firebase | لسه محتاج يتأكد |
| `permission-denied` على `fcmTokens` | الـ Rules المنشورة قديمة | نشر الـ Rules |
| `Cannot emit new states after calling close` في `MatchingCubit` | شغل Emad: `emit` بعد `await` من غير `isClosed` | بلّغت Emad |

---

## 7) اللي فاضل

- [ ] نشر `firestore.rules` على Firebase Console (Rules ثم Publish)
- [ ] `git push origin feature/profile-ui` وإبلاغ Donia
- [ ] اختبار على الموبايل: Airplane mode في Edit Profile
- [ ] اختبار الـ onboarding كامل بحساب جديد (Register ثم Connect GitHub ثم Edit Profile ثم Home)
- [ ] التأكد من ظهور `users/{uid}.profile` و`fcmTokens` في Firestore Console
- [ ] SHA-1 لجهازي في Firebase (للـ Google Sign-In)

**ملحوظة:** أنا لسه ما اختبرتش الـ onboarding والـ Airplane mode على الجهاز، فمينفعش أقول إنهم "اتجربوا" لحد ما أجربهم.

---

## 8) ملفات الـ Profile اللي اشتغلت عليها

```
lib/features/profile/
├── data/
│   ├── datasources/profile_remote_data_source.dart   (كتبته + timeout)
│   ├── models/profile_model.dart
│   └── repositories/profile_repository_impl.dart
├── domain/usecases/save_github_scan.dart              (كتبته)
└── presentation/
    ├── cubit/profile_cubit.dart                       (saveGithubScan)
    ├── cubit/profile_state.dart                       (ProfileSaveFailure)
    ├── screens/connect_github_entry.dart              (كتبته)
    ├── screens/edit_profile_screen.dart               (زرار الحفظ)
    └── widgets/language_breakdown.dart                (empty state)
firestore.rules                                        (fcmTokens)
```
