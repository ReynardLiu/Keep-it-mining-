# KEEP IT MINING ⚒️

[![Engine](https://img.shields.io/badge/Engine-Godot-blue?logo=godotengine)](https://godotengine.org/)
[![Genre](https://img.shields.io/badge/Genre-Mining%20%7C%20Adventure%20%7C%20Casual-green)](#)
[![Platform](https://img.shields.io/badge/Platform-PC%20%7C%20Android-orange)](#)
[![Visual Style](https://img.shields.io/badge/Visual-2D%20Pixel%20Art-purple)](#)

**Keep It Mining** adalah game simulasi pertambangan 2D bergaya *pixel art* yang memadukan aktivitas eksplorasi, *resource gathering*, strategi upgrade, dan tantangan asah otak melalui teka-teki matematika.

---

## 📋 Daftar Isi
- [Latar Belakang & Deskripsi Game](#-latar-belakang--deskripsi-game)
- [Cerita & Plot](#-cerita--plot)
- [Gameplay](#-gameplay)
  - [Gameplay Loop](#gameplay-loop)
  - [Fitur Utama](#fitur-utama)
- [Game Design & Visual](#-game-design--visual)
  - [Karakter & Environment](#karakter--environment)
  - [UI & Skema Warna](#ui--skema-warna)
- [Musik & Sound Design](#-musik--sound-design)
- [Timeline Pengembangan](#-timeline-pengembangan)
- [Budget & Estimasi Biaya](#-budget--estimasi-biaya)
- [Aset & Lisensi](#-aset--lisensi)
- [Target Akhir](#-target-akhir)

---

## 📜 Latar Belakang & Deskripsi Game

Pemain berperan sebagai seorang *miner* yang menjelajahi area pertambangan bawah tanah untuk mengumpulkan berbagai jenis mineral dan sumber daya berharga. Game ini berfokus pada mekanisme yang intuitif namun tetap memberikan progresibilitas yang memuaskan melalui sistem *upgrade* peralatan serta pembukaan area baru yang semakin dalam.

* **Genre:** Mining, Adventure, Casual
* **Platform:** PC
* **Engine:** Godot Engine
* **Visual Style:** 2D Pixel Art
* **Target Player:** Remaja hingga dewasa, penggemar game kasual, eksplorasi, dan pengumpulan sumber daya (*resource gathering*).

---

## 📖 Cerita / Plot

Perjalanan dimulai dari sebuah area pertambangan kecil yang terbengkalai namun menyimpan potensi kekayaan alam yang melimpah. Sebagai seorang penambang muda, kamu tertantang untuk menggali lebih dalam, memecahkan misteri di dalam tambang, serta mengumpulkan mineral berharga.

Semakin dalam kamu menambang, semakin menantang medan yang dihadapi dan semakin langka *ore* yang bisa didapatkan. Tujuan utamanya adalah mengembangkan kemampuan dan peralatan tambang hingga mampu mencapai lapisan terdalam bumi untuk menemukan sumber daya paling legendaris.

---

## 🎮 Gameplay

### Gameplay Loop
1. **Eksplorasi:** Masuk ke area pertambangan bawah tanah.
2. **Pencarian:** Mencari bongkahan batu, kristal, dan *ore* langka.
3. **Menambang (Mining):** Menambang mineral menggunakan *pickaxe*.
4. **Teka-teki Matematika (Rare Ore Challenge):** Saat menemukan *ore* langka (*rare*), pemain harus menyelesaikan teka-teki matematika cepat untuk berhasil mendapatkannya.
5. **Pengumpulan (Inventory):** Mineral yang berhasil ditambang disimpan di dalam *backpack*.
6. **Manajemen & Penjualan:** Kembali ke permukaan untuk menjual mineral dan mengelola *resource*.
7. **Upgrade:** Menggunakan uang hasil penjualan untuk meningkatkan ketahanan *pickaxe*, kapasitas *backpack*, dan peralatan lainnya.
8. **Eksplorasi Lanjutan:** Membuka area tambang baru yang lebih dalam dengan tantangan yang lebih tinggi.

### Fitur Utama
* ⛏️ **Mining System:** Menambang batu dan mineral dengan efek *shake* dan animasi visual yang memuaskan.
* 🧠 **Math Puzzle Mini-Game:** Soal matematika cepat setiap kali menemukan *ore* dengan tingkat kelangkaan *rare* ke atas.
* 🎒 **Simple Inventory System:** Pengelolaan barang hasil tambang yang intuitif.
* 📈 **Equipment & Tool Upgrade:** Peningkatan performa *pickaxe*, penerangan/lampu, dan alat pendukung lainnya.
* 🗺️ **Depth-Based Progression:** Area tambang bertingkat dengan variasi mineral, tingkat kesulitan, dan visual yang berbeda.
* 💰 **Economy System:** Jual-beli hasil bumi untuk akumulasi modal eksplorasi.

---

## 🎨 Game Design & Visual

### Karakter & Environment
* **Karakter Utama:** Seorang penambang (*miner*) bertopi proyek (*helmet* dengan lampu), membawa *backpack*, dan mengayunkan *pickaxe*.
* **Environment:** Lingkungan bawah tanah yang kaya detail:
  * Batuan biasa, kristal berkilau, dan urat mineral (*ores*).
  * Rel kereta tambang (*minecart tracks*) dan kayu penyangga lorong (*wooden supports*).
  * Pos istirahat dan bangunan pengolahan di permukaan.

### UI & Skema Warna
* **Visual Style:** 2D Pixel Art yang bersih dan *retro-friendly*.
* **Palet Warna:** 
  * *Warna Hangat (Oranye & Kuning):* Memberikan pencahayaan alami dari lampu helm dan obor tambang.
  * *Warna Dingin (Biru & Ungu):* Digunakan pada area kristal serta kedalaman tambang yang misterius.
* **User Interface:** Didesain menggunakan nuansa papan kayu dan elemen besi tempa agar menyatu rapat dengan tema pertambangan.

---

## 🎵 Musik & Sound Design

Suasana audio didesain untuk memberikan rasa petualangan yang santai namun tetap menggugah rasa ingin tahu.

### Background Music (BGM)
* **Main Menu:** Musik petualangan akustik ringan.
* **Area Tambang Atas:** Musik *ambient* menenangkan dengan nuansa misterius.
* **Area Tambang Dalam:** Musik yang lebih berat, intens, dan menggema.
* **Area Khusus / Rare Ore Zone:** Musik ber tempo cepat saat minigame teka-teki berlangsung.

### Sound Effect (SFX)
* Suara benturan *pickaxe* menghantam batu/mineral.
* Suara retakan batu hancur (*crunch/break*).
* Suara *coin/money* saat transaksi penjualan.
* Suara umpan balik UI (tombol kayu/besi).
* Suara indikator teka-teki (benar/salah).

---

## 📅 Timeline Pengembangan

| Tahap | Durasi | Kegiatan Utama |
| :--- | :---: | :--- |
| **Perencanaan** | 1 Minggu | Finalisasi konsep, *GDD*, dan mekanik dasar. |
| **Prototype** | 2 Minggu | Pengembangan pergerakan karakter & mekanik *mining* dasar. |
| **Gameplay Systems** | 2 Minggu | *Inventory*, mini-game matematika, *upgrade*, & sistem uang. |
| **Environment & Art** | 1–2 Minggu | Penyusunan *tilemap*, sprite mineral, & dekorasi tambang. |
| **UI Design** | 1 Minggu | Pembuatan *Main Menu*, HUD *inventory*, & toko *upgrade*. |
| **Audio Implementation** | 1 Minggu | Integrasi BGM, SFX tambang, & respons audio UI. |
| **Testing & Balancing** | 1 Minggu | Uji coba *bug*, balancing harga *ore*, & kesulitan teka-teki. |
| **Finalisasi** | 1 Minggu | *Polishing* visual, ekspor *build*, & pengerjaan dokumentasi. |

> **Estimasi Total Waktu:** ±10 – 11 Minggu

---

## 💰 Budget & Estimasi Biaya

Project direncanakan menggunakan aset *open-source* / gratis dan piranti lunak bebas biaya untuk menekan pengeluaran.

| Kebutuhan | Lisensi / Alat | Estimasi Biaya |
| :--- | :--- | :---: |
| **Game Engine** | Godot Engine (MIT License) | Rp0 |
| **Software Pendukung** | Aseprite / GIMP / Audacity | Rp0 |
| **Visual Assets** | Buatan Sendiri / CC0 Pixel Art | Rp0 |
| **Audio Assets** | CC0 Audio / Freesound.org | Rp0 |
| **Hosting & Distribusi** | Itch.io / Steam (Internal Testing) | Rp0 |
| **TOTAL ESTIMASI** | | **Rp0** |

---

## 🎨 Aset & Lisensi

Seluruh aset yang dimasukkan ke dalam game mengikuti ketentuan hukum hak cipta yang ketat:
1. **Visual Asset:** Karakter miner + animasi, variasi batu/kristal, dekorasi lingkungan, UI kit kayu, serta efek partikel pertambangan.
2. **Audio Asset:** BGM *ambient*, SFX penambangan, audio UI, dan *sound effect* minigame.
3. **Ketentuan Lisensi:**
   * Aset buatan sendiri (*original work*).
   * Aset gratis berlisensi domain publik (CC0) atau atribusi (*CC-BY*).
   * Seluruh sumber aset eksternal dicatat secara rapi dalam dokumen *Credits*.

---

## 🎯 Target Akhir

Target utama dari project **Keep It Mining** adalah menghasilkan sebuah game pertambangan 2D yang solid, menyenangkan untuk dimainkan secara santai, serta memiliki alur progresibilitas yang jelas. Kombinasi mekanik *gathering*, tantangan teka-teki matematika, dan gaya visual *pixel art* diharapkan dapat memberikan nilai unik serta pengalaman bermain yang adiktif bagi para pemain.
