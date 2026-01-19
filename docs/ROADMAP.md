# Mobile App Roadmap & Implementation Plan

Based on the analysis of the current mobile codebase versus backend capabilities, the following features are prioritized for implementation.

## 1. Modul Interaktif Siswa & Santri (Priority: High) ✅ COMPLETED
Transform the app from a read-only dashboard into an interactive tool for students.

### A. Pengajuan Perizinan (Izin Pulang/Sakit) ✅
**Goal**: Allow Santri/Wali to submit permission requests digitally.
- **Backend API**: 
  - `POST /api/my-perizinan` (Controller: `SantriDisciplineController@requestPerizinan`)
  - `GET /api/my-perizinan` (List history)
- **Mobile Implementation**: ✅ Done
  - Added "Ajukan Izin" FAB in `AbsensiView`.
  - Integrated tabbed UI for Riwayat Absensi & Perizinan.
  - Input fields: Jenis Izin (Sakit/Pulang/Keluar), Tanggal Keluar, Tanggal Kembali, Alasan.

### B. Pengumpulan Tugas (Assignment Submission) ✅
**Goal**: Allow Siswa to upload files or text for school assignments.
- **Backend API**:
  - `POST /api/sekolah/tugas/submit` (Controller: `TugasSekolahController@submit`)
- **Mobile Implementation**: ✅ Done
  - Added "Tugas Sekolah" menu in `AkademikPondokView`.
  - Implemented file picker (Image) and text submission.
  - Connected to backend API.

### C. Lihat Pelanggaran (Tahkim) ✅
**Goal**: Transparency for disciplinary records.
- **Backend API**:
  - `GET /api/kedisiplinan/pelanggaran` (Filter by `santri_id`)
- **Mobile Implementation**: ✅ Done
  - New `PelanggaranModule` created.
  - Access via "Catatan Pelanggaran" menu in `ProfilView`.

## 2. Modul Operasional Guru & Musyrif (Priority: Medium) ✅ COMPLETED
Empower staff to manage daily operations via mobile.

### A. Input Absensi Harian ✅
**Goal**: Teachers can checklist student attendance.
- **Backend API**:
  - `POST /api/absensi-siswa`
- **Mobile Implementation**: ✅ Done
  - New Module: `TeacherAreaView` with tabbed interface.
  - Tab "Input Absensi": Class selection -> Student List -> Toggle H/I/S/A.
  - Connected to `GuruRepository.createAbsensi()`.

### B. Input Setoran Tahfidz ✅
**Goal**: Musyrif records new memorization progress.
- **Backend API**:
  - `POST /api/tahfidz/hafalan`
- **Mobile Implementation**: ✅ Done
  - Tab "Setoran Tahfidz" in `TeacherAreaView`.
  - Select Santri -> Input Surah/Ayat/Juz -> Grade -> Save.

## 3. Modul Keuangan (Priority: Low/Future) ✅ COMPLETED
### Manual Payment with Bank Details ✅
- **Backend API**: `GET /api/payment-methods` (displays active bank accounts)
- **Mobile Implementation**: ✅ Done
  - "Lihat Rekening Pembayaran" button in `KeuanganView` student header.
  - Bottom sheet displaying list of active bank accounts.
  - Copy-to-clipboard functionality for account numbers.
  - Instructions for manual confirmation after transfer.

## 4. General Improvements ✅ COMPLETED

### A. Profile Edit ✅
**Goal**: Allow users to update their profile information.
- **Backend API**: `POST /api/user/update-profile`
- **Mobile Implementation**: ✅ Done
  - "Edit Profil" button in `ProfilView` menu.
  - Bottom sheet form with: Full Name, Email, Phone, Address.
  - Connected to backend API with local storage update.

### B. Change Password ✅
**Goal**: Allow users to change their password securely.
- **Backend API**: `POST /api/change-password`
- **Mobile Implementation**: ✅ Done
  - "Ubah Password" button in `ProfilView` menu.
  - Bottom sheet form with: Old Password, New Password, Confirm Password.
  - Password visibility toggle and validation.

### C. About & Help ✅
- **About Dialog**: Shows app version and description.
- **Help Dialog**: Shows contact information for support.

### D. Notifications (Placeholder)
- Menu item exists but functionality pending backend notification system.
- Can be extended with Firebase Cloud Messaging (FCM) in future.

---

# 🎉 ROADMAP COMPLETED!

All major features have been implemented:
- ✅ Student Interactive Features (Perizinan, Tugas, Pelanggaran)
- ✅ Teacher/Staff Features (Absensi, Tahfidz)
- ✅ Finance Features (Manual Bank Payment)
- ✅ General Improvements (Profile Edit, Password Change, About/Help)

