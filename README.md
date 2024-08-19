Skrip ini adalah alat keren yang dibikin pakai Perl untuk ngubek-ngubek Google dan ambil domain dari hasil pencarian. Skrip ini punya banyak fitur asik yang bikin pencarian jadi lebih gampang dan efisien. 

### Fitur Utama

- **Mode Pencarian Fleksibel**: 
  - Lo bisa pilih mau nyari pakai satu domain Google aja atau semua domain yang tersedia. Jadi, bisa nyari yang lebih fokus atau lebih luas.

- **Library Mantap**:
  - Skrip ini pake modul-modul Perl yang top kayak `LWP::UserAgent` buat request HTTP, `HTML::TreeBuilder` buat parsing HTML, dan `URI` buat ngurusin URL. Modul-modul ini bikin skrip jadi jago dalam ambil data dari web.

- **Warna-warni di Konsol**:
  - Output di terminal bisa berwarna dengan `Term::ANSIColor`, jadi informasi yang muncul lebih gampang dibaca dan dibedain.

- **Kelola Hasil Pencarian**:
  - Hasil pencarian disimpen di file (`hasil_pencarian.txt`) dan juga dicetak di konsol. Jadi lo bisa simpen dan cek hasil pencarian nanti.

- **Penanganan Error**:
  - Kalo ada masalah waktu ambil halaman dari Google, skrip ini bakal kasih tau lewat pesan error, dan berhenti kalo ada masalah besar. Ini membantu lo buat tau kalo ada yang salah.

- **Jeda Acak**:
  - Skrip ini nambahin jeda acak antara permintaan buat ngindarin pemblokiran dari Google. Jadi, enggak bakal bikin Google curiga.

- **Validasi Input Pengguna**:
  - Skrip ini ngecek input pengguna supaya pilihan mode dan domain yang dimasukin bener. Kalo salah, bakal ada pesan error yang jelas.

- **Kode Bersih**:
  - Kode di skrip ini rapi dengan fungsi-fungsi yang terpisah untuk berbagai tugas, bikin gampang dibaca dan dipelihara.

- **Dukung Banyak OS**:
  - Skrip ini ngecek sistem operasi yang dipake dan bersihin layar sesuai dengan OS-nya (Windows atau Unix-like).

- **Hapus Duplikasi**:
  - Dengan pake hash (`%seen_domains`), skrip ini pastiin cuma domain yang unik yang disimpen dan ditampilkan, jadi enggak ada duplikasi.

### Cara Pakai

1. **Jalanin Skrip**: Eksekusi skrip Perl di terminal.
2. **Masukin Kata Kunci**: Ketik kata kunci yang mau dicari di Google.
3. **Pilih Mode Pencarian**: Pilih antara satu domain Google atau semua domain.
4. **Tunggu Hasil**: Skrip bakal nyari, ambil domain, dan simpen hasilnya ke file `hasil_pencarian.txt`.

### Persyaratan

- Perl 5.x
- Modul Perl: `LWP::UserAgent`, `HTML::TreeBuilder`, `URI`, `Term::ANSIColor`
