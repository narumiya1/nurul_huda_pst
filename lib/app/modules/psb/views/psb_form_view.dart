import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../controllers/psb_controller.dart';

class PsbFormView extends GetView<PsbController> {
  const PsbFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Form Pendaftaran'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stepper indicator
          _buildStepIndicator(),

          // Form content
          Expanded(
            child: Obx(() => _buildStepContent()),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.softShadow,
      ),
      child: Obx(() => Row(
            children: [
              _buildStepDot(0, 'Santri'),
              _buildStepLine(0),
              _buildStepDot(1, 'Orang Tua'),
              _buildStepLine(1),
              _buildStepDot(2, 'Sekolah'),
            ],
          )),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = controller.currentStep.value >= step;
    final isCurrent = controller.currentStep.value == step;

    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 40 : 32,
            height: isCurrent ? 40 : 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : Colors.grey.shade300,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: isActive
                  ? (step < controller.currentStep.value
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text(
                          '${step + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = controller.currentStep.value > step;

    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildDataSantriForm();
      case 1:
        return _buildDataOrangTuaForm();
      case 2:
        return _buildDataSekolahForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDataSantriForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Calon Santri',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lengkapi data diri calon santri dengan benar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: controller.namaLengkapController,
            labelText: 'Nama Lengkap *',
            hintText: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.nisnController,
            labelText: 'NISN',
            hintText: 'Masukkan NISN (opsional)',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.tempatLahirController,
                  labelText: 'Tempat Lahir *',
                  hintText: 'Kota/Kabupaten',
                  prefixIcon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectTanggalLahir(Get.context!),
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: controller.tanggalLahirController,
                      labelText: 'Tanggal Lahir *',
                      hintText: 'DD/MM/YYYY',
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Jenis Kelamin *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildGenderOption('L', 'Laki-laki', Icons.male),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderOption('P', 'Perempuan', Icons.female),
                  ),
                ],
              )),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.anakKeController,
            labelText: 'Anak Ke-',
            hintText: 'Contoh: 2',
            prefixIcon: Icons.family_restroom_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.alamatController,
            labelText: 'Alamat Lengkap *',
            hintText: 'Masukkan alamat lengkap',
            prefixIcon: Icons.home_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller.noHpSantriController,
                  labelText: 'No. HP Santri',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: controller.emailSantriController,
                  labelText: 'Email Santri',
                  hintText: 'email@contoh.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = controller.jenisKelamin.value == value;

    return GestureDetector(
      onTap: () => controller.jenisKelamin.value = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataOrangTuaForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Orang Tua/Wali',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lengkapi data orang tua/wali calon santri',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.man, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Data Ayah',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.namaAyahController,
                  labelText: 'Nama Ayah *',
                  hintText: 'Masukkan nama ayah',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: controller.pekerjaanAyahController,
                  labelText: 'Pekerjaan Ayah',
                  hintText: 'Contoh: Wiraswasta',
                  prefixIcon: Icons.work_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.woman, color: Colors.pink),
                    SizedBox(width: 8),
                    Text(
                      'Data Ibu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.namaIbuController,
                  labelText: 'Nama Ibu *',
                  hintText: 'Masukkan nama ibu',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: controller.pekerjaanIbuController,
                  labelText: 'Pekerjaan Ibu',
                  hintText: 'Contoh: Ibu Rumah Tangga',
                  prefixIcon: Icons.work_outline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Kontak Orang Tua',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.noHpOrtuController,
            labelText: 'No. HP/WhatsApp *',
            hintText: '08xxxxxxxxxx',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.emailOrtuController,
            labelText: 'Email',
            hintText: 'email@contoh.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildDataSekolahForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Asal Sekolah',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lengkapi data asal sekolah calon santri',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: controller.asalSekolahController,
            labelText: 'Nama Sekolah Asal *',
            hintText: 'Contoh: SDN 01 Jakarta',
            prefixIcon: Icons.school_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: controller.tahunLulusController,
            labelText: 'Tahun Lulus',
            hintText: 'Contoh: 2025',
            prefixIcon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 32),

          // Upload Dokumen Section
          const Text(
            'Upload Dokumen Persyaratan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Format: PDF, JPG, PNG (Maks. 2MB)',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // KK Upload
          Obx(() => _buildDocumentUploadCard(
                docType: 'kk',
                label: 'Kartu Keluarga (KK)',
                icon: Icons.family_restroom,
                file: controller.fileKK.value,
                isOptional: true,
              )),
          const SizedBox(height: 12),

          // Akta Upload
          Obx(() => _buildDocumentUploadCard(
                docType: 'akta',
                label: 'Akta Kelahiran',
                icon: Icons.article_outlined,
                file: controller.fileAkta.value,
                isOptional: true,
              )),
          const SizedBox(height: 12),

          // Ijazah Upload
          Obx(() => _buildDocumentUploadCard(
                docType: 'ijazah',
                label: 'Ijazah / Surat Keterangan Lulus',
                icon: Icons.school_outlined,
                file: controller.fileIjazah.value,
                isOptional: true,
              )),
          const SizedBox(height: 12),

          // Pas Foto Upload
          Obx(() => _buildPhotoUploadCard(
                file: controller.fileFoto.value,
              )),

          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Informasi Penting',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem(
                    '• Dokumen bersifat opsional, dapat dilengkapi kemudian'),
                _buildInfoItem(
                    '• Simpan nomor pendaftaran yang akan diberikan'),
                _buildInfoItem(
                    '• Status pendaftaran dapat dicek dengan nomor pendaftaran'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String docType,
    required String label,
    required IconData icon,
    required dynamic file,
    bool isOptional = false,
  }) {
    final bool hasFile = file != null;
    final fileName = hasFile ? controller.getFileName(file) : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? AppColors.success : Colors.grey.shade300,
          width: hasFile ? 2 : 1,
        ),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasFile
                  ? AppColors.success.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: hasFile ? AppColors.success : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    if (isOptional)
                      Text(
                        ' (Opsional)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
                if (hasFile) ...[
                  const SizedBox(height: 4),
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (hasFile)
            IconButton(
              onPressed: () => controller.removeFile(docType),
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              tooltip: 'Hapus',
            )
          else
            ElevatedButton.icon(
              onPressed: () => controller.pickDocument(docType),
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Pilih'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadCard({required dynamic file}) {
    final bool hasFile = file != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? AppColors.success : Colors.grey.shade300,
          width: hasFile ? 2 : 1,
        ),
        boxShadow: AppShadows.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: hasFile ? null : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              image: hasFile
                  ? DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasFile
                ? null
                : const Icon(Icons.person, color: Colors.grey, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Pas Foto 3x4',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' (Opsional)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hasFile ? 'Foto berhasil dipilih' : 'Belum ada foto',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasFile ? AppColors.success : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (hasFile)
                      TextButton.icon(
                        onPressed: () => controller.removeFile('foto'),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Hapus'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    else ...[
                      TextButton.icon(
                        onPressed: () => controller.pickPhoto(fromCamera: true),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Kamera'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () =>
                            controller.pickPhoto(fromCamera: false),
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: const Text('Galeri'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              if (controller.currentStep.value > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 8),
                        Text('Sebelumnya'),
                      ],
                    ),
                  ),
                ),
              if (controller.currentStep.value > 0) const SizedBox(width: 12),
              Expanded(
                flex: controller.currentStep.value > 0 ? 1 : 2,
                child: controller.currentStep.value < 2
                    ? PrimaryButton(
                        text: 'Selanjutnya',
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          if (controller
                              .validateStep(controller.currentStep.value)) {
                            controller.nextStep();
                          }
                        },
                      )
                    : PrimaryButton(
                        text: 'Daftar Sekarang',
                        icon: Icons.check_circle_outline,
                        isLoading: controller.isSubmitting.value,
                        onPressed: controller.submitRegistration,
                      ),
              ),
            ],
          )),
    );
  }
}
