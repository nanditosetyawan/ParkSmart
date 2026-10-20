**PRODUCT REQUIREMENTS DOCUMENT**

**SMART PARKING**

Aplikasi Mobile untuk Pencarian, Booking, dan Pengelolaan Transaksi Parkir

**Versi 1.0**

Baseline requirement untuk pengembangan project Mobile Programming

Tanggal dokumen: 4 Oktober 2026

| Status dokumen Dokumen ini memuat kebutuhan produk, fitur, aturan bisnis, arsitektur, data, API/integrasi, keamanan, acceptance criteria, serta stack teknologi. Detail UI visual/pixel-level sengaja ditunda ke fase desain UI/UX. |
| :---- |

# **0\. Kontrol Dokumen**

| Atribut | Nilai |
| :---- | :---- |
| Nama produk | Smart Parking |
| Jenis | Product Requirements Document (PRD) |
| Versi | 1.0 |
| Status | Requirement baseline / siap dikembangkan |
| Platform utama | Android mobile |
| Framework | Flutter \+ Dart |
| Role | User dan Admin |
| Target biaya | Rp0 untuk project akademik dengan free tier / open-source dan tanpa payment gateway/LLM berbayar |
| IoT | Tidak digunakan |
| Firebase | Tidak digunakan sebagai database/auth utama |
| Detailed UI/UX | Ditunda ke tahap desain berikutnya |

# **Daftar Isi**

* 1\. Ringkasan Produk  
* 2\. Latar Belakang dan Problem Statement  
* 3\. Persona dan Konteks Penggunaan  
* 4\. Product Vision, Goals, dan Non-Goals  
* 5\. Scope dan Prioritas Fitur  
* 6\. Role dan Hak Akses  
* 7\. End-to-End User Flow  
* 8\. Business Rules  
* 9\. Functional Requirements  
* 10\. Admin Requirements  
* 11\. Data Requirements dan Model Database  
* 12\. API dan Integrasi  
* 13\. AI/LLM Requirements  
* 14\. Sensor dan Mini Game  
* 15\. Notification, Currency, dan Timezone  
* 16\. Blockchain Requirements  
* 17\. Authentication, Security, dan Privacy  
* 18\. Non-Functional Requirements  
* 19\. Technology Stack dan Lisensi  
* 20\. Arsitektur Sistem  
* 21\. Acceptance Criteria dan Definition of Done  
* 22\. Test Scenarios Utama  
* 23\. Traceability terhadap Requirement Tugas  
* 24\. Risiko, Constraint, dan Mitigasi  
* 25\. Roadmap Implementasi  
* 26\. Rekap Semua Keputusan dari Sesi PRD  
* 27\. Referensi Teknologi dan Lisensi

# **1\. Ringkasan Produk**

Smart Parking adalah aplikasi mobile yang membantu pengguna kendaraan pribadi menemukan lokasi parkir, melihat harga dan ketersediaan slot, memilih slot tertentu, melakukan booking sebelum tiba, melakukan check-in berbasis lokasi, menyelesaikan sesi parkir, menghitung biaya, mencatat transaksi, dan memverifikasi integritas transaksi menggunakan simple blockchain. Sistem memiliki dua role: User dan Admin.

Nilai utama produk adalah mengurangi ketidakpastian sebelum pengguna tiba di tempat parkir. Pengguna tidak perlu berkeliling mencari tempat kosong tanpa informasi awal; aplikasi menyediakan pencarian, peta, ketersediaan slot, harga, booking, serta alur check-in/check-out yang terintegrasi.

Produk dirancang untuk project akademik Mobile Programming dengan target biaya operasional Rp0 pada tahap pengembangan/demo. Arsitektur menghindari IoT, payment gateway, Google Maps API, dan LLM API berbayar. Stack utama adalah Flutter, Supabase, SQLite, OpenStreetMap/flutter\_map, geolocator, sensors\_plus, local\_auth, local notifications, simple blockchain berbasis SHA-256, serta Ollama \+ model LLM yang lisensinya diverifikasi saat implementasi.

| Prinsip scope Core product tetap berpusat pada parkir. AI, sensor/game, notification, currency/timezone, biometric, dan blockchain adalah fitur pendukung yang sekaligus memenuhi requirement akademik. Detail UI visual tidak dikunci dalam dokumen ini. |
| :---- |

# **2\. Latar Belakang dan Problem Statement**

Mahasiswa atau pekerja yang menggunakan kendaraan pribadi sering kesulitan mendapatkan parkir, terutama di kampus, pusat perbelanjaan, atau tempat ramai. Saat ini mereka biasanya datang langsung ke lokasi, berkeliling mencari slot kosong, bertanya kepada petugas, dan baru mengetahui harga serta ketersediaan parkir setelah tiba. Jika penuh, mereka harus mencari lokasi lain secara manual.

Masalah tersebut tidak hanya berupa kurangnya informasi, tetapi juga ketidakpastian. Pengguna tidak mengetahui apakah slot tertentu masih tersedia, berapa biaya yang akan dibayar, apakah booking dapat dilakukan sebelum tiba, dan apakah waktu kedatangannya masih sesuai dengan reservasi. Akibatnya, waktu terbuang untuk mencari parkir dan pengguna mengalami friksi sebelum aktivitas utama di lokasi dimulai.

Smart Parking memindahkan proses pencarian dan keputusan parkir ke sebelum pengguna tiba. Pengguna dapat melihat lokasi parkir di peta, mencari dan memfilter pilihan, melihat harga dan slot, melakukan booking slot spesifik, kemudian check-in ketika benar-benar berada di sekitar lokasi. Sesudah parkir, sistem mencatat check-out, durasi, biaya, dan transaksi.

## **2.1 Current Workaround**

| Masalah | Cara sekarang | Kelemahan |
| :---- | :---- | :---- |
| Mencari lokasi parkir | Datang langsung / mencari di peta umum | Tidak menjamin slot tersedia |
| Mengetahui slot kosong | Berkeliling atau bertanya petugas | Menghabiskan waktu dan tidak pasti |
| Membandingkan harga | Melihat papan tarif / bertanya | Tidak praktis untuk beberapa lokasi |
| Mengamankan slot | Tidak ada booking atau harus datang dulu | Risiko lokasi sudah penuh |
| Pembayaran | Bayar di lokasi | Riwayat tidak selalu terdokumentasi rapi |
| Riwayat parkir | Struk/catatan manual | Sulit ditelusuri dan tidak terintegrasi |

# **3\. Persona dan Konteks Penggunaan**

## **3.1 Persona Utama: Pengguna Kendaraan Pribadi**

Persona utama adalah mahasiswa atau pekerja yang rutin menggunakan motor atau mobil. Ia sering pergi ke kampus, mall, pusat kegiatan, atau tempat publik lain. Tujuan utamanya bukan memakai aplikasi parkir untuk hiburan, melainkan menghemat waktu, memastikan tempat parkir tersedia, mengetahui biaya lebih awal, dan memiliki bukti transaksi yang rapi.

## **3.2 Cerita Pengguna**

Seorang mahasiswa bernama Andi hendak ke kampus dan menggunakan motor. Ia membuka Smart Parking sebelum berangkat. Aplikasi langsung menampilkan parkir terdekat, harga, dan slot yang tersedia. Andi memilih lokasi yang paling sesuai, memilih slot A-05, menentukan waktu dan durasi, lalu melakukan booking. Saat tiba, aplikasi memeriksa GPS dan memastikan Andi berada dalam radius lokasi serta booking masih valid. Setelah check-in, sesi parkir aktif. Ketika selesai, Andi melakukan check-out, sistem menghitung biaya, mencatat transaksi, dan menyediakan verifikasi blockchain. Pada kunjungan berikutnya, Andi dapat membuka riwayat dan menerima notifikasi pengingat booking.

## **3.3 Job To Be Done**

Ketika saya akan pergi ke lokasi ramai menggunakan kendaraan pribadi, saya ingin mengetahui parkir yang tersedia, harganya, dan dapat mengunci slot sebelum datang, sehingga saya tidak perlu berkeliling mencari tempat kosong atau baru mengetahui masalah parkir setelah tiba.

# **4\. Product Vision, Goals, dan Non-Goals**

## **4.1 Product Vision**

Menjadikan pencarian dan pemesanan parkir sebagai proses yang dapat diputuskan sebelum pengguna tiba, dengan informasi slot, harga, lokasi, dan transaksi yang terintegrasi dalam satu aplikasi mobile.

## **4.2 Product Goals**

* Memungkinkan pengguna melihat parkir terdekat melalui LBS dan peta.  
* Memungkinkan pengguna memilih slot spesifik dan melakukan booking dari jauh.  
* Mencegah check-in dari lokasi yang tidak sesuai dengan lokasi parkir.  
* Menghitung tarif berdasarkan durasi dan jenis kendaraan.  
* Menyediakan riwayat transaksi yang terstruktur.  
* Menambahkan AI yang benar-benar relevan terhadap pencarian dan rekomendasi parkir.  
* Memenuhi requirement akademik untuk dua sensor, biometric, notification, currency/time conversion, mini game, dan blockchain.  
* Mempertahankan biaya pengembangan/demo pada target Rp0 dengan free tier dan software open-source/permisif.

## **4.3 Non-Goals**

* Tidak membangun hardware IoT, sensor parkir fisik, ESP32, Arduino, RFID, atau ultrasonic sensor.  
* Tidak menjadi payment gateway atau memproses uang nyata pada fase akademik.  
* Tidak menggunakan blockchain publik/cryptocurrency untuk pembayaran.  
* Tidak bergantung pada Google Maps API berbayar.  
* Tidak bergantung pada Firebase sebagai database/auth utama.  
* Tidak membuat sistem manajemen operasional parkir dunia nyata yang kompleks seperti gate controller pada fase ini.  
* Tidak mengunci desain UI pixel-level dalam PRD; desain visual menjadi dokumen/tahap berikutnya.

# **5\. Scope dan Prioritas Fitur**

Prioritas produk membedakan core parking flow dengan fitur pendukung. Semua fitur tetap masuk scope project karena beberapa merupakan requirement akademik, tetapi tingkat prioritas membantu implementasi jika waktu terbatas.

| Fitur | Prioritas | Nilai produk | Catatan |
| :---- | :---- | :---- | :---- |
| Peta parkir terdekat | P0 | Core | Fitur utama untuk menemukan parkir |
| Booking slot spesifik | P0 | Core | Nilai pembeda utama |
| Check-in/check-out GPS | P0 | Core | Mengikat booking ke lokasi |
| Tarif dan transaksi | P0 | Core | Membentuk alur parkir lengkap |
| Admin location/slot/pricing | P0 | Core | Mengelola data parkir |
| Authentication \+ session | P0 | Core | Required |
| Biometric | P1 | Academic | Requirement dosen |
| AI Parking Assistant | P1 | Academic \+ product | Mendukung natural language search |
| Mini game \+ 2 sensor | P1 | Academic | Accelerometer \+ Gyroscope |
| Notification | P1 | Academic | Booking/reminder/expiry |
| Currency conversion | P1 | Academic | IDR/USD/EUR/GBP |
| Timezone conversion | P1 | Academic | WIB/WITA/WIT/London |
| Simple blockchain | P1 | Academic \+ integrity | Hash transaksi |
| Saran dan kesan | P1 | Academic | Feedback course |
| UI polish lanjutan | P2 | UX | Dikerjakan setelah requirements |

# **6\. Role dan Hak Akses**

## **6.1 User**

* Register/login/logout dan session.  
* Melihat lokasi parkir, slot, harga, jam operasional.  
* Search/filter dan melihat detail.  
* Memilih kendaraan dan slot spesifik.  
* Membuat/membatalkan booking sesuai aturan.  
* Check-in/check-out berbasis GPS.  
* Melihat transaksi dan riwayat.  
* Menerima notification.  
* Menggunakan AI assistant.  
* Menggunakan mini game.  
* Mengatur biometric, currency, timezone, profil, dan feedback.

## **6.2 Admin**

* Login sebagai admin.  
* CRUD lokasi parkir.  
* Mengatur koordinat, foto, jam operasional, dan kapasitas.  
* CRUD slot spesifik.  
* CRUD pricing rule berdasarkan kendaraan dan durasi.  
* Melihat dan mengelola user, booking, sesi parkir, transaksi.  
* Melihat status blockchain verification.  
* Melihat feedback pengguna.

| Catatan otorisasi Role disimpan sebagai atribut yang dapat digunakan oleh Row Level Security (RLS). Client Flutter tidak boleh memegang service role key. Akses admin harus divalidasi di database/backend, bukan hanya dengan menyembunyikan tombol di UI. |
| :---- |

# **7\. End-to-End User Flow**

## **7.1 First Open / First Value**

Saat pertama kali membuka aplikasi, satu hal yang paling bernilai untuk selesai terlebih dahulu adalah pengguna dapat melihat parkir terdekat. Registrasi tetap diperlukan sebelum tindakan yang membutuhkan identitas seperti booking, tetapi first value produk adalah menemukan parkir.

| Buka aplikasi  \-\> Home / lokasi pengguna  \-\> Lihat parkir terdekat  \-\> Cari / filter  \-\> Detail parkir  \-\> Login/register bila hendak booking |
| :---- |

## **7.2 Core Flow**

| Login / Register  \-\> Home  \-\> Map / Search  \-\> Pilih lokasi parkir  \-\> Lihat harga \+ slot  \-\> Pilih kendaraan  \-\> Pilih slot spesifik  \-\> Pilih waktu \+ durasi  \-\> Konfirmasi booking  \-\> Slot \= RESERVED  \-\> Datang ke lokasi  \-\> GPS radius \+ booking valid  \-\> Check-in  \-\> Slot \= OCCUPIED  \-\> Parkir  \-\> Check-out  \-\> Hitung durasi \+ tarif  \-\> Simulasi bayar dalam aplikasi ATAU bayar di lokasi  \-\> Transaction finalized  \-\> Blockchain block/hash  \-\> Verify transaction  \-\> History |
| :---- |

## **7.3 Admin Flow**

| Admin login  \-\> Dashboard  \-\> Kelola lokasi  \-\> Kelola slot  \-\> Kelola pricing  \-\> Pantau booking/session  \-\> Pantau transaksi  \-\> Kelola user  \-\> Review feedback |
| :---- |

# **8\. Business Rules**

## **8.1 Slot State Machine**

| AVAILABLE \-\> RESERVED \-\> OCCUPIED \-\> AVAILABLE                     |                     \+-\> EXPIRED / CANCELLED \-\> AVAILABLE |
| :---- |

| Rule ID | Aturan | Expected behavior |
| :---- | :---- | :---- |
| BR-01 | Slot hanya dapat dibooking jika AVAILABLE. | Booking ditolak bila slot sudah RESERVED/OCCUPIED. |
| BR-02 | Booking memiliki waktu mulai dan durasi. | Sistem menyimpan start\_at dan end\_at. |
| BR-03 | Grace period berlaku. | Jika user tidak check-in sampai batas grace, booking EXPIRED dan slot kembali AVAILABLE. |
| BR-04 | Check-in membutuhkan GPS radius. | Check-in ditolak jika di luar radius konfigurasi. |
| BR-05 | Booking harus valid saat check-in. | Expired/cancelled booking tidak dapat check-in. |
| BR-06 | Check-in mengubah slot menjadi OCCUPIED. | Slot tidak dapat dibooking user lain. |
| BR-07 | Check-out menghitung biaya. | Total berasal dari durasi dan pricing rule. |
| BR-08 | Pembayaran dapat disimulasikan atau dibayar di lokasi. | Status payment dicatat tanpa payment gateway. |
| BR-09 | Transaksi final tidak diedit oleh User. | User hanya dapat melihat hasil akhir. |

## **8.2 Booking Rule**

Booking menggunakan kombinasi waktu/durasi dan grace period. Rekomendasi baseline adalah grace period 30 menit setelah waktu mulai booking. Nilai ini dibuat configurable agar Admin dapat mengubahnya tanpa mengubah kode inti.

## **8.3 GPS Rule**

Baseline radius check-in adalah 100 meter dari koordinat lokasi parkir. Radius dibuat configurable. Validasi harus menghitung jarak GPS user terhadap titik parkir; hanya tombol UI tidak cukup sebagai kontrol keamanan.

## **8.4 Pricing Rule**

Tarif menggunakan kombinasi durasi dan jenis kendaraan. Contoh baseline: motor memiliki tarif awal dan tarif per jam berikutnya yang berbeda dari mobil. Rumus aktual disimpan sebagai pricing rule agar Admin dapat mengubahnya per lokasi dan jenis kendaraan.

| Total \= base\_rate(vehicle\_type, parking\_location)        \+ additional\_rate(vehicle\_type, parking\_location)          berdasarkan blok durasi parkir |
| :---- |

## **8.5 Payment Rule**

Tidak ada payment gateway nyata pada fase akademik. Opsi yang tersedia: (1) simulasi pembayaran di dalam aplikasi, atau (2) bayar langsung di lokasi. Aplikasi hanya mencatat status payment dan metode. Ini menjaga project tetap tanpa biaya transaksi eksternal.

# **9\. Functional Requirements**

## **9.1 Authentication & Session**

* User dapat register dengan email/password.  
* User dapat login dan logout.  
* Session dipertahankan sesuai mekanisme Supabase Auth.  
* Password tidak disimpan pada tabel aplikasi sebagai plaintext.  
* Biometric dapat digunakan sebagai unlock/login convenience setelah session account tersedia.  
* Forgot/reset password menggunakan alur Supabase Auth yang sesuai.  
* Role User/Admin menentukan hak akses data dan fitur.

## **9.2 Home & Parking Discovery**

* Menampilkan lokasi pengguna bila permission GPS diberikan.  
* Menampilkan daftar parkir terdekat.  
* Menampilkan availability dan harga ringkas.  
* Membuka detail lokasi parkir.  
* Menampilkan booking aktif.  
* Menampilkan akses ke AI assistant.

## **9.3 Search & Selection**

* Search berdasarkan nama/alamat area.  
* Filter jarak, harga, ketersediaan, jenis kendaraan, dan status buka.  
* Sort berdasarkan jarak terdekat atau harga termurah.  
* Memilih lokasi parkir dan kemudian slot spesifik.

## **9.4 Parking Detail**

* Nama dan foto lokasi.  
* Alamat.  
* Koordinat.  
* Jarak dari user.  
* Jam operasional.  
* Pricing per vehicle type/duration.  
* Daftar slot dan status.  
* Tombol booking.  
* Tombol navigasi eksternal bila diperlukan.

## **9.5 Booking**

* Memilih kendaraan.  
* Memilih slot spesifik.  
* Memilih waktu mulai.  
* Memilih durasi.  
* Melihat estimasi biaya.  
* Menyetujui booking.  
* Membatalkan booking sesuai aturan.  
* Melihat countdown menuju waktu mulai/expiry.

## **9.6 Check-in / Check-out**

* Check-in hanya bila berada dalam radius lokasi.  
* Booking harus masih valid.  
* Sistem mencatat timestamp check-in.  
* Slot berubah RESERVED \-\> OCCUPIED.  
* Check-out mencatat timestamp.  
* Sistem menghitung durasi dan biaya.  
* Slot berubah OCCUPIED \-\> AVAILABLE setelah sesi selesai.

## **9.7 Transaction & History**

* Menyimpan ID transaksi.  
* Menampilkan lokasi, slot, kendaraan, waktu, durasi, total, payment method, payment status.  
* Menampilkan hash/block verification.  
* User melihat miliknya; Admin melihat seluruh transaksi.

## **9.8 Profile & Feedback**

* Foto profil dan data account.  
* Kendaraan.  
* Pengaturan biometric.  
* Preferensi currency/timezone.  
* Saran dan kesan untuk mata kuliah Mobile Application Programming.  
* Logout.

# **10\. Admin Requirements**

## **10.1 Location Management**

Admin membuat lokasi parkir dengan nama, alamat, latitude, longitude, foto, jam buka/tutup, status operasional, dan konfigurasi radius check-in. Lokasi dummy diizinkan untuk demo selama dokumentasi menyatakan bahwa data tersebut adalah data simulasi/test data dan bukan klaim fasilitas parkir resmi.

## **10.2 Slot Management**

Admin dapat membuat daftar slot seperti A-01, A-02, A-03, menentukan jenis slot bila diperlukan (motor/mobil), dan melihat status slot.

## **10.3 Pricing Management**

Admin mengatur tarif per lokasi dan jenis kendaraan dengan aturan base rate dan additional rate. Aturan dapat memiliki effective period bila diperlukan pada pengembangan lanjutan.

## **10.4 Monitoring**

| Area | Admin can |
| :---- | :---- |
| Users | lihat daftar, status, kendaraan, dan account metadata yang diperlukan |
| Bookings | lihat aktif, cancelled, expired, checked-in |
| Sessions | lihat kendaraan/slot yang sedang occupied |
| Transactions | lihat detail, payment status, blockchain verification |
| Feedback | lihat saran, kesan, rating |

# **11\. Data Requirements dan Model Database**

Database online utama menggunakan Supabase PostgreSQL. SQLite digunakan sebagai penyimpanan lokal untuk cache, preferensi, data sementara, dan kebutuhan offline sederhana. Password dan session credentials tidak boleh dipindahkan menjadi plaintext ke tabel SQLite.

## **11.1 Entitas Utama**

| Tabel | Tujuan | Relasi utama |
| :---- | :---- | :---- |
| profiles | Profil aplikasi dan role | auth.users |
| vehicles | Data kendaraan user | profiles |
| parking\_locations | Master lokasi parkir | parking\_slots, pricing\_rules |
| parking\_slots | Slot spesifik per lokasi | parking\_locations, reservations, sessions |
| pricing\_rules | Tarif per lokasi/jenis kendaraan/durasi | parking\_locations |
| reservations | Booking slot | profiles, vehicles, parking\_locations, parking\_slots |
| parking\_sessions | Sesi parkir hasil check-in/out | reservations, parking\_slots |
| transactions | Catatan biaya/pembayaran | parking\_sessions, profiles |
| notifications | Riwayat notifikasi aplikasi | profiles |
| blockchain\_blocks | Rantai hash transaksi | transactions |
| feedback | Saran, kesan, rating | profiles |
| game\_scores | Skor mini game | profiles |
| currency\_rates | Kurs yang dikonfigurasi untuk demo | app settings |
| app\_settings | Konfigurasi umum | global |

## **11.2 Contoh Kolom Inti**

| Entitas | Kolom inti (contoh) |
| :---- | :---- |
| profiles | id, full\_name, email, role, photo\_url, created\_at, updated\_at |
| vehicles | id, user\_id, plate\_number, vehicle\_type, brand, model |
| parking\_locations | id, name, address, latitude, longitude, opening\_time, closing\_time, photo\_url, checkin\_radius\_m, is\_active |
| parking\_slots | id, parking\_location\_id, code, vehicle\_type, status |
| pricing\_rules | id, parking\_location\_id, vehicle\_type, base\_rate, additional\_rate, billing\_unit\_minutes, is\_active |
| reservations | id, user\_id, vehicle\_id, parking\_location\_id, slot\_id, start\_at, end\_at, grace\_until, status, estimated\_total |
| parking\_sessions | id, reservation\_id, checkin\_at, checkout\_at, duration\_minutes, final\_total |
| transactions | id, session\_id, user\_id, amount, currency, payment\_method, payment\_status, transaction\_status, finalized\_at |
| blockchain\_blocks | id, block\_index, transaction\_id, transaction\_hash, previous\_hash, block\_hash, created\_at, verified\_at |

## **11.3 Data Ownership**

Supabase PostgreSQL adalah source of truth online. SQLite bukan source of truth untuk transaksi final. Bila terdapat konflik antara cache lokal dan data online, data transaksi dan slot online menjadi acuan setelah sinkronisasi. Data offline hanya boleh memegang informasi yang memang aman untuk cache.

# **12\. API dan Integrasi**

Supabase Data API menjadi API utama aplikasi untuk query/mutation terhadap PostgreSQL. Supabase Flutter SDK dapat berinteraksi dengan database, auth, storage, realtime, dan Edge Functions. API access harus dikombinasikan dengan RLS dan role permissions.

| Integrasi | Teknologi | Fungsi | Status |
| :---- | :---- | :---- | :---- |
| Database API | Supabase Data API / supabase\_flutter | CRUD parkir, slot, booking, transaksi | Wajib |
| Authentication | Supabase Auth | Register/login/session/password | Wajib |
| Storage | Supabase Storage | Foto profil/lokasi | Wajib |
| Realtime | Supabase Realtime | Perubahan status slot/booking | Direkomendasikan |
| Location | geolocator | GPS user dan jarak | Wajib |
| Map | flutter\_map \+ OSM data | Menampilkan peta/marker | Wajib |
| AI | Ollama local HTTP API | Natural-language parking assistant | Wajib |
| Notification | flutter\_local\_notifications | Reminder/status lokal | Wajib |
| Blockchain hashing | Dart crypto | SHA-256 | Wajib |

## **12.1 API Operations Konseptual**

| GET    /parking-locations?near=...GET    /parking-locations/{id}GET    /parking-slots?location\_id=...\&status=AVAILABLEPOST   /reservationsPATCH  /reservations/{id}/cancelPOST   /sessions/{reservation\_id}/check-inPOST   /sessions/{id}/check-outGET    /transactions/{id}GET    /transactions/{id}/verifyGET    /history |
| :---- |

Nama endpoint di atas adalah representasi konseptual. Implementasi dapat menggunakan PostgREST/Supabase SDK dan SQL function/RPC tanpa membuat server REST custom. Prinsip utamanya adalah kontrak data dan authorization, bukan nama URL literal.

## **12.2 Realtime**

Jika slot berubah dari AVAILABLE menjadi RESERVED/OCCUPIED, perubahan dapat didorong ke client melalui Supabase Realtime sehingga daftar slot tidak hanya bergantung pada refresh manual. Realtime tetap tunduk pada authorization dan RLS.

# **13\. AI/LLM Requirements**

AI diwujudkan sebagai AI Parking Assistant, bukan chatbot generik. Fokusnya adalah menerjemahkan permintaan pengguna menjadi kriteria parkir yang dapat dieksekusi oleh aplikasi.

## **13.1 Contoh Prompt**

"Cari parkir paling dekat dari saya, harga di bawah Rp5.000, masih ada slot dan buka sekarang."

## **13.2 Structured Intent**

| {  "max\_price": 5000,  "sort": "nearest",  "availability": true,  "open\_now": true} |
| :---- |

## **13.3 AI Boundaries**

* LLM tidak boleh menjadi source of truth untuk slot, harga, atau transaksi.  
* LLM hanya mengekstrak intent atau menghasilkan jawaban berbasis data yang disediakan aplikasi.  
* Data parkir diambil dari database melalui query terkontrol.  
* LLM tidak boleh mengarang lokasi atau harga.  
* API endpoint / local model harus memiliki timeout dan error fallback.  
* Model yang dipakai harus diverifikasi lisensinya sebelum distribusi project.

## **13.4 Runtime AI**

Target runtime menggunakan Ollama lokal di laptop. Flutter mengirim permintaan ke HTTP API Ollama pada jaringan development/demo. Untuk demo tanpa internet, model dapat berjalan lokal selama hardware laptop memenuhi kebutuhan model terpilih. Model LLM adalah komponen terpisah dari lisensi Ollama; lisensi model harus dibaca dan dicatat sendiri.

# **14\. Sensor dan Mini Game**

Dua sensor wajib digunakan secara bermakna, bukan hanya dibaca nilainya. Accelerometer dan Gyroscope dipakai dalam mini game Parking Challenge.

| Sensor | Fungsi dalam game | Output |
| :---- | :---- | :---- |
| Accelerometer | Mengontrol gerak maju/mundur atau respons gerak kendaraan. | Kecepatan/arah translasi |
| Gyroscope | Mengontrol steering dan perubahan arah. | Rotasi/arah kendaraan |

## **14.1 Game Flow**

| Start game  \-\> Pilih level  \-\> Kontrol kendaraan dengan sensor  \-\> Masuk ke slot parkir  \-\> Validasi posisi  \-\> Score  \-\> Simpan game score |
| :---- |

## **14.2 Aturan Penyimpanan Skor Arcade (Sistem Overwrite - Maksimal 2 Baris)**

Penyimpanan skor game arcade (`arcade_scores`) menerapkan aturan penimpaan (*overwriting*) ketat untuk menjaga performa database agar baris data tidak membengkak tanpa batas:
1. **Rekor Tertinggi (`score_type = 'highest'`)**: Tepat 1 baris per pengguna per jenis game yang hanya diperbarui jika pemain berhasil mencetak skor lebih tinggi dari rekor sebelumnya.
2. **Skor Terakhir (`score_type = 'current'`)**: Tepat 1 baris per pengguna per jenis game yang selalu ditimpa (*upsert*) setiap kali permainan berakhir.
3. **Reward Poin & Koin**: Poin yang diperoleh dari game balapan dan mesin capit langsung ditambahkan ke atribut `points` dan `wallet_balance` pada tabel `users`.
4. **Total Baris Maksimal**: Tepat 2 baris data per pengguna per jenis permainan pada tabel `arcade_scores` menggunakan *unique constraint* `(user_id, game_name, score_type)`.

## **14.3 Batasan & Optimasi Mobile (Cache Balancer & Kompresi Brutal 95%)**

* **Database Request Balancer (Local Caching)**: Seluruh modul mobile (Android & iOS) dilengkapi layer penyeimbang database (`DatabaseCacheBalancerService`) dengan in-memory cache dan local persistent cache ber-TTL 3-15 menit untuk mencegah request berulang kali ke Supabase saat membuka halaman yang sama. Cache hanya di-invalidasi ketika terjadi mutasi data baru (Insert, Update, Delete).
* **Kompresi Brutal 95% KYC & Kendaraan**: Fitur kamera KTP, STNK, dan Selfie wajah menerapkan utility kompresi brutal ~95% (`ImageCompressionUtil`) di background isolate sebelum berkas diunggah ke Supabase Storage bucket `kyc-documents`, menjaga ukuran file tetap di kisaran 50–100 KB sehingga hemat bandwidth dan cepat saat ditinjau Super Admin untuk proses persetujuan (ACC).

# **15\. Notification, Currency, dan Timezone**

## **15.1 Notification**

* Booking berhasil.  
* Pengingat waktu booking.  
* Peringatan booking mendekati grace period.  
* Booking expired.  
* Check-in berhasil.  
* Check-out dan transaksi selesai.

Untuk target biaya Rp0, fase akademik menggunakan local notification. Push notification server-side tidak diwajibkan dan Firebase tidak digunakan.

## **15.2 Currency Conversion**

Minimum mata uang: IDR, USD, EUR. GBP ditambahkan sebagai opsi keempat. Untuk menjaga cost dan deterministik demo, kurs dapat dikelola sebagai seed/configuration table di Supabase dan diperbarui secara manual. Integrasi API kurs eksternal menjadi future enhancement, bukan ketergantungan wajib.

## **15.3 Timezone Conversion**

Sistem menyimpan timestamp secara konsisten (disarankan UTC) lalu menampilkan waktu berdasarkan timezone pilihan pengguna. Minimum tampilan: WIB (Asia/Jakarta), WITA (Asia/Makassar), WIT (Asia/Jayapura), dan London (Europe/London). Library timezone menggunakan database IANA.

# **16\. Blockchain Requirements**

Blockchain bersifat sederhana dan edukatif. Ia tidak digunakan sebagai database utama dan tidak digunakan sebagai payment rail. Perannya adalah memberi bukti integritas untuk transaksi parkir yang telah selesai.

## **16.1 Block Structure**

| Block {  index  timestamp  transaction\_id  transaction\_hash  previous\_hash  block\_hash} |
| :---- |

## **16.2 Hashing**

Hash dibuat dari payload transaksi yang sudah difinalkan. Implementasi menggunakan SHA-256 melalui package crypto. Block hash menggabungkan metadata block, transaction hash, dan previous hash. Verification menghitung ulang hash dan memeriksa keterhubungan previous\_hash.

## **16.3 Lifecycle**

| Checkout selesai  \-\> Final transaction  \-\> Canonical transaction payload  \-\> SHA-256 transaction hash  \-\> Ambil previous block hash  \-\> Buat block baru  \-\> Simpan block  \-\> Verify on demand |
| :---- |

| Keamanan desain Untuk hasil yang lebih kuat, proses append/finalisasi block sebaiknya dijalankan di sisi database function/Edge Function/trusted backend agar client tidak bisa mengubah block sesuka hati. Flutter hanya meminta finalisasi dan membaca hasil verification. |
| :---- |

# **17\. Authentication, Security, dan Privacy**

## **17.1 Authentication**

Supabase Auth menangani identitas dan session. Password tidak disimpan di tabel aplikasi sebagai plaintext. Transport data menggunakan koneksi aman. Role/authorization ditegakkan dengan RLS/permissions. Session menggunakan access/refresh token dari Supabase Auth.

## **17.2 Biometric**

local\_auth digunakan sebagai device-level unlock/reauth convenience. Biometric tidak menggantikan identitas backend. Aplikasi harus tetap memiliki account session yang valid.

## **17.3 Authorization / RLS**

| Objek | User | Admin |
| :---- | :---- | :---- |
| profiles | read/update own | manage allowed fields/users |
| parking\_locations | read active | CRUD |
| parking\_slots | read active/status | CRUD/status |
| reservations | CRUD own per rules | read/manage all |
| sessions | read own | read all |
| transactions | read own | read all |
| blockchain\_blocks | read verification | read/controlled finalize |
| feedback | create/read own | read all |

## **17.4 Secret Management**

* Jangan menaruh service role key di Flutter.  
* Jangan menyimpan API key rahasia di source control.  
* Gunakan environment/configuration yang sesuai untuk development.  
* AI/local server URL dapat dikonfigurasi untuk development; secret model/API bila ada harus berada server-side.

## **17.5 Privacy**

Data yang dikumpulkan dibatasi pada kebutuhan aplikasi: identitas account, kendaraan, booking, transaksi, lokasi saat diperlukan untuk check-in, dan feedback. Lokasi tidak perlu direkam terus-menerus di background pada MVP.

# **18\. Non-Functional Requirements**

| Kategori | Requirement |
| :---- | :---- |
| Performance | Daftar parkir utama tampil dalam waktu yang wajar pada jaringan development; query memakai filter dan index yang tepat. |
| Reliability | Status booking/slot tidak boleh berubah ganda akibat double-submit. |
| Consistency | Transisi slot dan reservation harus atomik sebisa mungkin melalui transaction/RPC. |
| Security | RLS aktif pada tabel online; tidak ada service-role key di client. |
| Usability | Core flow dari cari \-\> booking \-\> check-in \-\> check-out harus mudah dipahami tanpa instruksi panjang. |
| Offline | Cache lokal boleh dipakai untuk data non-kritis; transaksi final tetap online source of truth. |
| Maintainability | Konfigurasi tarif, grace period, radius, currency rates tidak hard-coded bila dapat disimpan sebagai data konfigurasi. |
| Scalability | Model data mendukung lebih dari satu lokasi dan banyak slot tanpa perubahan struktur. |
| Observability | Error API, booking failure, AI timeout, dan notification failure harus punya log lokal/development. |

# **19\. Technology Stack dan Lisensi**

Target project adalah menggunakan software open-source/permisif dan free tier sehingga pengembangan akademik dapat dilakukan tanpa biaya layanan berbayar. “Gratis” tidak berarti tanpa lisensi; setiap komponen tetap tunduk pada lisensinya masing-masing. Untuk distribusi, notice dan attribution yang diwajibkan harus dipertahankan.

| Layer | Teknologi | Peran | Lisensi / cost note |
| :---- | :---- | :---- | :---- |
| Mobile framework | Flutter \+ Dart | Aplikasi mobile | Flutter open-source, BSD-3-Clause |
| Online DB/backend | Supabase PostgreSQL | Database, API, Auth, Storage, Realtime | Free plan \$0 dengan quota/limits; plan dapat berubah |
| Data API | Supabase Data API / PostgREST via SDK | CRUD data | Bagian dari Supabase |
| Local DB | SQLite \+ sqflite | Cache/data lokal | sqflite BSD-2-Clause |
| Map UI | flutter\_map | Render map | BSD-3-Clause |
| Map data | OpenStreetMap | Data geospasial | ODbL; wajib attribution dan patuhi service/tile policy |
| GPS | geolocator | Lokasi perangkat | MIT |
| Sensors | sensors\_plus | Accelerometer/Gyroscope | BSD-3-Clause |
| Biometric | local\_auth | Fingerprint/Face auth | BSD-3-Clause |
| AI runtime | Ollama | Local LLM runtime | MIT |
| AI model | Model yang dipilih sesuai lisensi | LLM | Lisensi model harus diverifikasi terpisah |
| Hashing | crypto | SHA-256 | BSD-3-Clause |
| Timezone | timezone | IANA time zone data | BSD-2-Clause |
| Notification | flutter\_local\_notifications | Local notifications | BSD-3-Clause |

| Catatan map/free-cost OpenStreetMap adalah open data dengan ODbL, tetapi OSMF menyatakan mereka tidak menyediakan free-of-charge map API atau map tiles untuk pihak ketiga. Karena itu PRD tidak menganggap public tile server OSM sebagai unlimited free API. Saat implementasi, gunakan tile provider yang mengizinkan penggunaan project, atau strategi tile/offline yang sesuai. Attribution OpenStreetMap wajib. |
| :---- |

| Catatan Supabase Supabase saat ini menyediakan Free plan \$0/bulan dengan batas resource. Quota dan status plan harus dicek kembali saat implementasi/deployment karena kebijakan provider dapat berubah. |
| :---- |

# **20\. Arsitektur Sistem**

|                          SMART PARKING                              │                ┌─────────────┴─────────────┐                │        Flutter App        │                └─────────────┬─────────────┘                              │        ┌─────────────────────┼─────────────────────┐        │                     │                     │        ▼                     ▼                     ▼   Supabase              Device APIs           Local Storage   ├─ Auth               ├─ GPS                 └─ SQLite   ├─ Data API           ├─ Biometric   ├─ PostgreSQL         ├─ Accelerometer   ├─ Storage            └─ Gyroscope   └─ Realtime        │        ├──────────────► Parking/Booking/Transaction data        │        └──────────────► Blockchain metadataAI Path:Flutter ──HTTP──\> Ollama (local laptop) ──\> LLM modelMap Path:Flutter ──\> flutter\_map ──\> compliant OSM tile/data source |
| :---- |

## **20.1 Data Flow: Booking**

| User selects slot   \-\> Flutter validates form   \-\> Supabase transaction/RPC checks slot status   \-\> Reservation inserted   \-\> Slot set RESERVED   \-\> Notification scheduled   \-\> UI updated / Realtime event |
| :---- |

## **20.2 Data Flow: Check-in**

| User presses Check-in   \-\> geolocator gets location   \-\> distance to parking coordinate   \-\> radius \<= configured threshold?       yes \-\> verify reservation valid \-\> create session \-\> OCCUPIED       no  \-\> reject |
| :---- |

## **20.3 Data Flow: Check-out**

| Check-out   \-\> calculate duration   \-\> calculate pricing   \-\> create/finalize transaction   \-\> free slot   \-\> generate canonical hash   \-\> append blockchain block   \-\> notification \+ history |
| :---- |

# **21\. Acceptance Criteria dan Definition of Done**

| ID | Acceptance criteria |
| :---- | :---- |
| AC-01 | User dapat register/login/logout dan session bertahan sesuai konfigurasi. |
| AC-02 | Biometric dapat membuka akses ke session yang sudah terdaftar pada device. |
| AC-03 | User melihat parkir terdekat dengan lokasi dan availability. |
| AC-04 | User dapat mencari dan memfilter parkir. |
| AC-05 | User dapat memilih slot spesifik. |
| AC-06 | Booking menyimpan waktu mulai, durasi, grace\_until, dan status. |
| AC-07 | Slot tidak dapat dibooking dua user pada waktu yang bertabrakan. |
| AC-08 | Booking expired mengembalikan slot menjadi AVAILABLE. |
| AC-09 | Check-in di luar radius 100 m (atau configured radius) ditolak. |
| AC-10 | Check-in valid mengubah slot menjadi OCCUPIED. |
| AC-11 | Check-out menghitung durasi dan biaya sesuai pricing rule. |
| AC-12 | Pembayaran dapat dicatat sebagai simulated atau onsite. |
| AC-13 | Riwayat transaksi hanya dapat diakses user yang berhak. |
| AC-14 | AI dapat menerjemahkan setidaknya contoh pencarian natural-language menjadi filter. |
| AC-15 | AI tidak membuat data parkir yang tidak ada di database. |
| AC-16 | Accelerometer dan Gyroscope digunakan dalam mini game. |
| AC-17 | Local notification dijadwalkan untuk booking/reminder/expiry. |
| AC-18 | Currency minimal IDR/USD/EUR dan timezone WIB/WITA/WIT/London tersedia. |
| AC-19 | Transaksi selesai dapat dibuat menjadi blockchain block dan diverifikasi. |
| AC-20 | Admin dapat CRUD lokasi, slot, dan pricing. |
| AC-21 | RLS/authorization mencegah user biasa melakukan operasi admin. |
| AC-22 | Tidak ada IoT hardware atau payment gateway berbayar sebagai dependency MVP. |

## **21.1 Definition of Done**

* Source code build/run pada environment target.  
* Database schema, RLS, dan seed data tersedia.  
* Core user flow pass test.  
* Admin flow pass test.  
* AI demo berhasil atau memiliki fallback yang jelas.  
* Licenses/attribution dependencies didokumentasikan.  
* No secret key hard-coded.  
* Screenshots dan evidence dapat diambil untuk laporan project.  
* Error cases utama diuji.

# **22\. Test Scenarios Utama**

| TC | Skenario | Expected result |
| :---- | :---- | :---- |
| TC-01 | Login user valid | Login berhasil, session aktif |
| TC-02 | Login admin dengan account user biasa | Akses admin ditolak |
| TC-03 | Booking slot AVAILABLE | Booking berhasil, slot RESERVED |
| TC-04 | Booking slot OCCUPIED | Booking ditolak |
| TC-05 | Booking tidak check-in sampai grace | Booking EXPIRED, slot AVAILABLE |
| TC-06 | Check-in dari luar radius | Ditolak |
| TC-07 | Check-in dalam radius dengan booking valid | Sukses, slot OCCUPIED |
| TC-08 | Check-out normal | Durasi dan total benar, transaksi selesai |
| TC-09 | Dua user booking slot sama secara bersamaan | Hanya satu booking sukses |
| TC-10 | AI query dengan kriteria harga/jarak | Intent/filter sesuai, hasil berasal dari DB |
| TC-11 | AI tidak menemukan parkir | Jawaban menyatakan tidak ada hasil, tidak mengarang |
| TC-12 | Mini game sensor | Accelerometer/Gyroscope memengaruhi kontrol |
| TC-13 | Notification booking | Notifikasi muncul sesuai jadwal |
| TC-14 | Currency switch | Harga ditampilkan pada currency terpilih |
| TC-15 | Timezone switch | Timestamp dikonversi benar |
| TC-16 | Blockchain verify valid | Hash chain valid |
| TC-17 | Data transaction diubah secara ilegal | Verification mendeteksi ketidaksesuaian |

# **23\. Traceability terhadap Requirement Tugas**

| Requirement akademik | Implementasi Smart Parking | Evidence |
| :---- | :---- | :---- |
| Project concept | Pencarian, booking, check-in/out, transaksi parkir | PRD \+ app demo |
| Login \+ encryption \+ session, bukan Firebase | Supabase Auth, TLS, password hashing, JWT/session, no plaintext passwords | Login demo \+ DB/Auth config |
| Biometric login | local\_auth | Biometric demo |
| Local \+ online database | SQLite \+ Supabase PostgreSQL | Schema \+ local DB evidence |
| Web service/API | Supabase Data API | Network/API flow |
| LBS relevan | GPS \+ map \+ nearby parking \+ radius check-in | Map \+ GPS check-in |
| Bottom navigation | Home / Map / Booking / Profile; Profile berisi photo, saran/kesan, logout | UI implementation |
| Currency min 3 | IDR, USD, EUR (+ GBP) | Currency setting / transaction |
| Time min 4 zones | WIB, WITA, WIT, London | Timezone setting / history |
| Min 2 sensors | Accelerometer \+ Gyroscope untuk parking game | Game demo |
| AI/LLM | AI Parking Assistant via Ollama \+ LLM | Natural-language search demo |
| Mini game | Parking Challenge | Game screen/demo |
| Search & selection | Search/filter \+ pilih lokasi \+ pilih slot | User flow |
| Mobile notifications | Local notification booking/reminder/expiry | Notification demo |
| Simple blockchain | Transaction hash \+ chained blocks \+ verify | Blockchain verification demo |

# **24\. Risiko, Constraint, dan Mitigasi**

| Risiko/constraint | Dampak | Mitigasi |
| :---- | :---- | :---- |
| Free tier provider berubah | Biaya atau limit berubah | Lock scope, monitor quota, siapkan local/demo fallback |
| OSM tile usage policy | Map tidak boleh dipakai unlimited | Gunakan provider compliant atau offline/local tiles; tampilkan attribution |
| LLM model terlalu berat | AI lambat di laptop | Pilih model ringan dan batasi prompt/context |
| LLM license tidak cocok | Masalah legal distribusi | Verifikasi license model sebelum dipilih; simpan notice |
| GPS indoor tidak akurat | Check-in gagal/false negative | Radius configurable, tampilkan accuracy, retry GPS |
| Race condition booking | Double booking | Gunakan atomic DB transaction/RPC \+ constraint |
| SQLite stale cache | Data lokal salah | Cache only non-critical; online source of truth |
| Biometric tidak tersedia | User tidak bisa biometrik | Fallback ke session/password |
| Notification permission ditolak | Reminder tidak muncul | Tampilkan status permission dan tetap simpan booking |
| Scope terlalu besar | Project terlambat | Prioritaskan P0 core flow, lalu P1 academic features |

# **25\. Roadmap Implementasi**

| Fase | Output | Prioritas |
| :---- | :---- | :---- |
| F1 \- Foundation | Flutter project, Supabase project, Auth, schema dasar | P0 |
| F2 \- Parking Data | Location, slot, pricing, admin CRUD | P0 |
| F3 \- Core User Flow | Map, search/filter, booking, state machine | P0 |
| F4 \- Session & Transaction | GPS check-in/out, pricing calc, payment simulation/onsite | P0 |
| F5 \- Security | RLS, role control, session/biometric | P0/P1 |
| F6 \- Academic Features | AI, sensors/game, notifications, currency/timezone, blockchain | P1 |
| F7 \- Testing | Test scenarios, seed data, bug fixing | P0 |
| F8 \- Documentation | Screenshot, report, source explanation, evaluation evidence | P0 |
| F9 \- UI polish | Detail UI/UX visual, accessibility, polish | P2 |

## **25.1 Suggested Demo Data**

Baseline demo terdiri dari 1 Admin dan 2 User. Seed dapat memuat beberapa lokasi parkir simulasi dengan koordinat valid, masing-masing memiliki slot motor/mobil dan tarif berbeda. Dokumentasi harus menyatakan bahwa data parkir tersebut adalah data simulasi/test.

# **26\. Rekap Semua Keputusan dari Sesi PRD**

Bagian ini sengaja mencatat seluruh simulasi pertanyaan dan jawaban yang terjadi selama sesi penyusunan PRD, sehingga tidak ada keputusan penting yang hilang saat PRD dikembangkan.

| No | Simulasi pertanyaan | Keputusan yang masuk PRD |
| :---- | :---- | :---- |
| 1 | Ceritakan seseorang yang butuh aplikasi ini. Sekarang mereka ngapain? | Mahasiswa/pekerja pengguna kendaraan pribadi. Saat ini datang langsung, berkeliling mencari slot, bertanya petugas, baru tahu harga/ketersediaan; jika penuh mencari lokasi lain manual. |
| 2 | Begitu buka aplikasi pertama kali, satu hal apa yang harus beres? | Lihat parkir terdekat. First value produk adalah menemukan parkir; login diperlukan sebelum booking. |
| 3 | Pilih 3 fitur paling wajib. | Peta parkir terdekat; pesan slot dari jauh; riwayat & bayar parkir. |
| 4 | Apa yang membuat lebih enak daripada cara manual? | Tidak muter-muter; sudah pesan dari rumah; tahu harga duluan. |
| 5 | Apa yang membuat user kembali lagi? | Sering parkir di mall/kampus/tempat tujuan; riwayat parkir rapi; notifikasi pengingat. |
| 6 | Role aplikasi? | Cukup 2 role: User dan Admin. |
| 7 | Kondisi slot? | User memilih slot spesifik seperti A-01, A-02, A-03; status slot dikelola. |
| 8 | Pembayaran? | Keduanya: simulasi pembayaran di aplikasi dan bayar langsung di lokasi. |
| 9 | Kondisi data parkir? | Kombinasi data dummy untuk demo \+ Admin dapat membuat/mengelola lokasi sendiri. |
| 10 | Alur booking \-\> check-in \-\> parkir \-\> checkout? | Disetujui: booking \-\> RESERVED \-\> datang \-\> validasi GPS \-\> check-in \-\> OCCUPIED \-\> check-out \-\> transaksi. |
| 11 | Model tarif? | Kombinasi durasi \+ jenis kendaraan (D). |
| 12 | Booking rule? | Kombinasi waktu/durasi \+ grace period (D). Baseline grace 30 menit dan configurable. |
| 13 | Check-in? | Kombinasi GPS radius \+ booking masih valid (D). Baseline radius 100 m dan configurable. |
| 14 | Apakah pertanyaan lanjutan perlu selalu diminta? | Tidak. User menyatakan rancangan simulasi berikutnya dianggap ACC otomatis, kecuali dibatalkan/diubah. |
| 15 | Apakah UI detail harus diproduksi sekarang? | Tidak. Detail UI visual ditunda; requirement, fitur, arsitektur, dan stack dikunci lebih dahulu. |

## **26.1 Design Assumptions yang Disepakati**

* Grace period baseline 30 menit.  
* GPS radius baseline 100 meter.  
* Status slot AVAILABLE / RESERVED / OCCUPIED dengan EXPIRED/CANCELLED sebagai outcome booking.  
* 1 Admin \+ 2 User sebagai baseline demo.  
* Payment gateway nyata tidak digunakan.  
* Data lokasi parkir dapat berupa data simulasi; harus diberi label test/simulation.  
* AI menggunakan Ollama lokal \+ model yang lisensinya diperiksa.  
* Mini game menggunakan Accelerometer \+ Gyroscope.  
* Notification menggunakan local notification.  
* Blockchain hanya untuk integritas transaksi, bukan penyimpanan seluruh data aplikasi.  
* UI/pixel-level design dikerjakan setelah requirement baseline ini.

# **27\. Referensi Teknologi dan Lisensi**

Referensi berikut dipakai untuk memvalidasi fitur dan status lisensi yang relevan saat PRD disusun. Paket yang dipasang saat implementasi tetap harus diperiksa kembali versinya dan lisensinya karena dependency dapat berubah.

**Flutter:** Flutter repository; BSD-3-Clause/open-source \- [https\://github.com/flutter/flutter](https://github.com/flutter/flutter)

**Supabase Flutter:** Dokumentasi Flutter integration, Data API, Auth, Realtime, Storage \- [https\://supabase.com/docs/reference/dart/introduction](https://supabase.com/docs/reference/dart/introduction)

**Supabase pricing:** Free plan saat dokumen disusun; quota dapat berubah \- [https\://supabase.com/pricing](https://supabase.com/pricing)

**Supabase password security:** Password hashing, auth guidance \- [https\://supabase.com/docs/guides/auth/password-security](https://supabase.com/docs/guides/auth/password-security)

**Supabase sessions:** Session/access token/refresh token \- [https\://supabase.com/docs/guides/auth/sessions](https://supabase.com/docs/guides/auth/sessions)

**flutter\_map:** BSD-3-Clause \- [https\://pub.dev/packages/flutter\_map/license](https://pub.dev/packages/flutter_map/license)

**OpenStreetMap:** ODbL \+ attribution \+ tile/service policy \- [https\://www\.openstreetmap.org/copyright/en](https://www.openstreetmap.org/copyright/en)

**geolocator:** MIT \- [https\://pub.dev/packages/geolocator/license](https://pub.dev/packages/geolocator/license)

**sensors\_plus:** BSD-3-Clause \- [https\://pub.dev/packages/sensors\_plus/license](https://pub.dev/packages/sensors_plus/license)

**local\_auth:** BSD-3-Clause \- [https\://pub.dev/packages/local\_auth/license](https://pub.dev/packages/local_auth/license)

**sqflite:** BSD-2-Clause \- [https\://pub.dev/packages/sqflite/license](https://pub.dev/packages/sqflite/license)

**crypto:** BSD-3-Clause \- [https\://pub.dev/packages/crypto/license](https://pub.dev/packages/crypto/license)

**timezone:** BSD-2-Clause \- [https\://pub.dev/packages/timezone/license](https://pub.dev/packages/timezone/license)

**flutter\_local\_notifications:** BSD-3-Clause \- [https\://pub.dev/packages/flutter\_local\_notifications](https://pub.dev/packages/flutter_local_notifications)

**Ollama:** MIT \- [https\://github.com/ollama/ollama/blob/main/LICENSE](https://github.com/ollama/ollama/blob/main/LICENSE)

## **Catatan Lisensi**

Lisensi permissive seperti MIT/BSD tetap mensyaratkan pemeliharaan copyright/license notices sesuai ketentuannya. OSM memakai ODbL untuk data dan memiliki kewajiban attribution; penggunaan layanan tile harus mengikuti kebijakan penyedia. LLM model bukan otomatis berlisensi sama dengan Ollama sehingga license model harus diperlakukan sebagai dependency terpisah.

# **Lampiran A \- Ringkasan Satu Halaman**

| Item | Keputusan final |
| :---- | :---- |
| Produk | Smart Parking |
| Problem | Parkir sulit diprediksi; pengguna masih mencari manual setelah tiba |
| Core value | Lihat parkir terdekat, pesan slot, tahu harga sebelum datang |
| Role | User \+ Admin |
| Slot | Spesifik (A-01, A-02, dst.) |
| Tarif | Durasi \+ jenis kendaraan |
| Booking | Waktu/durasi \+ grace period |
| Check-in | GPS radius \+ booking valid |
| Payment | Simulasi in-app \+ onsite |
| Online DB | Supabase PostgreSQL |
| Local DB | SQLite |
| API | Supabase Data API |
| Map/LBS | flutter\_map \+ OpenStreetMap \+ geolocator |
| AI | Ollama \+ licensed model |
| Sensors | Accelerometer \+ Gyroscope |
| Biometric | local\_auth |
| Notification | Local notification |
| Blockchain | Simple SHA-256 chain |
| IoT | Tidak ada |
| Firebase | Tidak digunakan sebagai backend utama |
| UI detail | Tahap berikutnya |

\=== UPDATES DARI AI \===

\[8.4 Pricing Rule Update\]

Admin dapat mengatur billing\_unit\_minutes secara dinamis (misal per 60 menit atau 15 menit).

Total \= base\_rate \+ (additional\_rate \* jumlah blok waktu terlewati).

\[12. API dan Integrasi Update\]

- Currency API: Exchangerate.host / Fixer (Wajib)  
- Holiday API: Nager.Date / Calendarific (Wajib)  
- Geocoding API: Positionstack / OSM Nominatim (Wajib)

\[14. Sensor dan Mini Game Update\]

Mini Game Balap/Parkir Mobil 2D Landscape:

- Gyroscope: Setir (steering) dengan memiringkan device kiri/kanan.  
- Accelerometer: Pedal gas (maju) dan rem (mundur) dengan memiringkan device depan/belakang.

\[16. Blockchain Concurrency Update\]

Untuk mencegah Race Condition saat checkout bersamaan, gunakan Database Function (RPC) di Supabase dengan Row-Level Lock (SELECT … FOR UPDATE) agar previous\_hash tetap sekuensial.

