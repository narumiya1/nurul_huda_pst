import 'dart:io';

import 'package:epesantren_mob/app/api/address/provinsi/provinsi_model.dart';
import 'package:epesantren_mob/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("REGISTER")),
      body: Obx(() {
        switch (controller.stepIndex.value) {
          case 0:
            return const RegisterDataDiriView();
          case 1:
            return const RegisterAlamatView();
          case 2:
            return const RegisterPelengkapView();
          case 3:
            return const RegisterPendidikanView();
          case 4:
            return const RegisterOrganisasiView();
          case 5:
            return const RegisterUploadBerkasView();
          case 6:
            return const RegisterUploadFotoProfilView();
          default:
            return const RegisterDataDiriView();
        }
      }),
    );
  }
}

class RegisterDataDiriView extends GetView<RegisterController> {
  const RegisterDataDiriView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Data Diri",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          dropdownPengguna(),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: " Nama *",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: " Nama Lengkap*",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: " No NIK/ KTP*",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: " No Hp*",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: " Tempat Lahir*",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: " Tanggal Lahir*",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              onChanged: (value) {},
              decoration: InputDecoration(
                labelText: " Jenis Kelamin*",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // textInput("Nama Lengkap", controller.namaLengkap),
          // textInput("Nama Panggilan", controller.namaPanggilan),
          // textInput("NIK", controller.nik),
          // textInput("Nomor Handphone", controller.phone),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.prevStep,
                  child: const Text("Batal"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.nextStep,
                  child: const Text("Lanjut"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget dropdownPengguna() {
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: DropdownButtonFormField<String>(
            initialValue: controller.pengguna.value.isEmpty
                ? null
                : controller.pengguna.value,
            hint: const Text("Pilih Pengguna"),
            items: const [
              DropdownMenuItem(
                  value: "Santri Baru", child: Text("Santri Baru")),
              DropdownMenuItem(value: "Guru", child: Text("Guru")),
            ],
            onChanged: (v) => controller.pengguna.value = v ?? '',
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ));
  }

  Widget textInput(String label, RxString rx) {
    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: TextField(
            onChanged: (v) => rx.value = v,
            decoration: InputDecoration(
              labelText: "$label *",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ));
  }
}

class RegisterAlamatView extends GetView<RegisterController> {
  const RegisterAlamatView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Data Alamat",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          /**  textInput("Provinsi", controller.provinsi),
          textInput("Kabupaten", controller.kabupaten),
          textInput("Kecamatan", controller.kecamatan),
          textInput("Desa/Kelurahan", controller.desa), **/
          Obx(() => DropdownButtonFormField<ProvinsModel>(
                initialValue: controller.selectedProvinsi.value,
                items: controller.provinsiDataList
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name),
                        ))
                    .toList(),
                onChanged: (value) {
                  controller.selectedProvinsi.value = value;

                  // RESET TURUNAN 🔥
                  controller.selectedDistrict.value = null;
                  controller.selectedKecamatan.value = null;
                  controller.selectedDesaKelurahan.value = null;

                  controller.districtList.clear();
                  controller.allKecamatanDataList.clear();
                  controller.allDesaKelurahanDataList.clear();

                  if (value != null) {
                    controller.fetchDistrict(value.id);
                  }
                },
                hint: const Text("Pilih Provinsi"),
              )),
          Obx(() => DropdownButtonFormField<ProvinsModel>(
                initialValue: controller.selectedDistrict.value,
                items: controller.districtList
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.name),
                        ))
                    .toList(),
                onChanged: controller.districtList.isEmpty
                    ? null
                    : (value) {
                        controller.selectedDistrict.value = value;

                        controller.selectedKecamatan.value = null;
                        controller.selectedDesaKelurahan.value = null;
                        controller.allKecamatanDataList.clear();
                        controller.allDesaKelurahanDataList.clear();

                        if (value != null) {
                          controller.fetchKecamatan(value.id);
                        }
                      },
                hint: const Text("Pilih Kabupaten"),
              )),
          // Obx(() => DropdownButtonFormField<ProvinsModel>(
          //       decoration: const InputDecoration(
          //         labelText: 'Kecamatan',
          //       ),
          //       items: controller.allKecamatanDataList
          //           .map((d) => DropdownMenuItem(
          //                 value: d,
          //                 child: Text(d.name),
          //               ))
          //           .toList(),

          //       /// 🔥 KUNCI UTAMA
          //       onChanged: controller.allKecamatanDataList.isEmpty
          //           ? null
          //           : (value) {
          //               controller.selectedDesaKelurahan.value = value;
          //               if (value != null) {
          //                 controller.fetchDesaKelurahan(value.id);
          //               }
          //             },

          //       hint: controller.isLoadingKecamatan.value
          //           ? const Text('Memuat Desa / Kelurahan...')
          //           : const Text('Pilih Kecamatan'),
          //     )),
          Obx(() => DropdownButtonFormField<ProvinsModel>(
                initialValue: controller.selectedKecamatan.value,
                decoration: const InputDecoration(
                  labelText: 'Kecamatan',
                ),
                items: controller.allKecamatanDataList
                    .map(
                      (k) => DropdownMenuItem<ProvinsModel>(
                        value: k,
                        child: Text(k.name),
                      ),
                    )
                    .toList(),
                onChanged: controller.allKecamatanDataList.isEmpty
                    ? null
                    : (value) {
                        controller.selectedKecamatan.value = value;

                        // 🔥 RESET TURUNAN
                        controller.selectedDesaKelurahan.value = null;
                        controller.allDesaKelurahanDataList.clear();

                        if (value != null) {
                          controller.fetchDesaKelurahan(value.id);
                        }
                      },
                hint: controller.isLoadingKecamatan.value
                    ? const Text('Memuat kecamatan...')
                    : const Text('Pilih Kecamatan'),
              )),

          // Obx(() => DropdownButtonFormField<ProvinsModel>(
          //       decoration: const InputDecoration(
          //         labelText: 'Desa / Kelurahan',
          //       ),
          //       items: controller.allDesaKelurahanDataList
          //           .map((d) => DropdownMenuItem(
          //                 value: d,
          //                 child: Text(d.name),
          //               ))
          //           .toList(),

          //       /// 🔥 KUNCI UTAMA
          //       onChanged: controller.allDesaKelurahanDataList.isEmpty
          //           ? null
          //           : (value) {
          //               controller.selectedDesaKelurahan.value = value;
          //             },

          //       hint: controller.isLoadingKecamatan.value
          //           ? const Text('Memuat Desa / Kelurahan...')
          //           : const Text('Pilih Desa / Kelurahan'),
          //     )),
          Obx(() => DropdownButtonFormField<ProvinsModel>(
                initialValue: controller.selectedDesaKelurahan.value,
                decoration: const InputDecoration(
                  labelText: 'Desa / Kelurahan',
                ),
                items: controller.allDesaKelurahanDataList
                    .map(
                      (d) => DropdownMenuItem<ProvinsModel>(
                        value: d,
                        child: Text(d.name),
                      ),
                    )
                    .toList(),
                onChanged: controller.allDesaKelurahanDataList.isEmpty
                    ? null
                    : (value) {
                        controller.selectedDesaKelurahan.value = value;
                      },
                hint: controller.isLoadingDesaKelurahan.value
                    ? const Text('Memuat desa / kelurahan...')
                    : const Text('Pilih Desa / Kelurahan'),
              )),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              maxLines: 4,
              onChanged: (v) => controller.alamatLengkap.value = v,
              decoration: InputDecoration(
                labelText: "Alamat Lengkap *",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: controller.prevStep,
                      child: const Text("Kembali"))),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                      onPressed: controller.nextStep,
                      child: const Text("Lanjutkan"))),
            ],
          )
        ],
      ),
    );
  }

  Widget textInput(String label, RxString rx) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        onChanged: (v) => rx.value = v,
        decoration: InputDecoration(
          labelText: "$label *",
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class RegisterPelengkapView extends GetView<RegisterController> {
  const RegisterPelengkapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Data Pelengkap"),
          textInput("Upload KTP (link)", controller.uploadKTP),
          textInput("Upload KK (link)", controller.uploadKK),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: controller.prevStep,
                      child: const Text("Kembali"))),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                      onPressed: controller.nextStep,
                      child: const Text("Lanjutkan"))),
            ],
          )
        ],
      ),
    );
  }

  Widget textInput(String label, RxString rx) {
    return TextField(
      onChanged: (v) => rx.value = v,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class RegisterUploadBerkasView extends GetView<RegisterController> {
  const RegisterUploadBerkasView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Upload Berkas",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          cardUpload(
            "Foto Profil",
            controller.fotoProfil,
            controller.pickFotoProfil,
          ),
          cardUpload(
            "Upload Berkas 1 (Camera)",
            controller.fotoBerkas1,
            controller.pickBerkas1,
          ),
          cardUpload(
            "Upload Berkas 2 (Gallery)",
            controller.fotoBerkas2,
            controller.pickBerkas2,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.prevStep,
                  child: const Text("Kembali"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.nextStep,
                  child: const Text("Kirim"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget cardUpload(
    String title,
    Rxn<File> fileRx,
    VoidCallback onPick,
  ) {
    return Obx(() => Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(title),
                const SizedBox(height: 10),
                fileRx.value == null
                    ? const Icon(Icons.image, size: 60)
                    : Image.file(
                        fileRx.value!,
                        height: 120,
                      ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.upload),
                  label: const Text("Pilih Gambar"),
                )
              ],
            ),
          ),
        ));
  }
}

class RegisterPendidikanView extends GetView<RegisterController> {
  const RegisterPendidikanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Data Riwayat Pendidikan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            input("SD/MI", controller.sd),
            input("SMP/SLTP/MTs", controller.smp),
            input("SMA/MA", controller.sma),
            input("S1", controller.s1),
            input("S2", controller.s2),
            input("S3", controller.s3),
            const SizedBox(height: 16),
            const Text("Pendidikan Non Formal",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() => Column(
                  children:
                      List.generate(controller.pendidikanNonFormal.length, (i) {
                    return TextField(
                      onChanged: (v) => controller.pendidikanNonFormal[i] = v,
                      decoration: InputDecoration(
                        hintText: "Nama Pesantren/Lembaga",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );
                  }),
                )),
            ElevatedButton.icon(
              onPressed: controller.tambahPendidikanNonFormal,
              icon: const Icon(Icons.add),
              label: const Text("Tambah"),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () => controller.prevStep(),
                        child: const Text("Kembali"))),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () => controller.nextStep(),
                        child: const Text("Lanjutkan"))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget input(String label, RxString rx) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        onChanged: (v) => rx.value = v,
        decoration: InputDecoration(
          hintText: "$label *",
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class RegisterOrganisasiView extends GetView<RegisterController> {
  const RegisterOrganisasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Data Riwayat Organisasi"),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: controller.organisasiList.length,
                    itemBuilder: (c, i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: TextField(
                          onChanged: (v) => controller.organisasiList[i] = v,
                          decoration: InputDecoration(
                            hintText: "Riwayat Organisasi *",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            ElevatedButton.icon(
              onPressed: controller.tambahOrganisasi,
              icon: const Icon(Icons.add),
              label: const Text("Tambah"),
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: controller.prevStep,
                        child: const Text("Kembali"))),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        onPressed: controller.nextStep,
                        child: const Text("Lanjutkan"))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RegisterUploadFotoProfilView extends GetView<RegisterController> {
  const RegisterUploadFotoProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Upload Foto Profil",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                controller.fotoProfil.value == null
                    ? const Icon(Icons.person, size: 100)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          controller.fotoProfil.value!,
                          height: 160,
                        ),
                      ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.pickFotoProfil,
                  child: const Text("Pilih Foto"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: controller.prevStep,
                            child: const Text("Kembali"))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: controller.submitAkhir,
                            child: const Text("Selesai"))),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
