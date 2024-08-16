use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;
use utf8;

# Daftar domain Google yang akan digunakan untuk pencarian
my @google_domains = (
    'google.com',
    'google.co.uk',
    'google.co.jp',
    'google.com.au',
    'google.ca',
    'google.de',
    'google.fr',
    'google.it',
    'google.es',
    'google.co.in',
    'google.com.sg',
    # Tambahkan lebih banyak domain jika diperlukan
);

# Fungsi untuk mendapatkan input query secara interaktif
print "Masukkan kata kunci pencarian Google: ";
my $query = <STDIN>;
chomp($query);  # Menghapus newline di akhir input

# Cek jika query kosong
if (!$query) {
    die "Query tidak boleh kosong!";
}

# Ganti spasi dengan '+' untuk query URL Google
$query =~ s/ /+/g;

# Inisialisasi user agent
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

# File untuk menyimpan hasil pencarian
open(my $fh, '>', 'hasil_pencarian.txt') or die "Tidak bisa membuka file: $!";

# Variabel untuk menyimpan jumlah URL dan hash untuk memeriksa duplikasi
my $total_urls = 0;
my %seen_urls;

# Loop untuk setiap domain Google
foreach my $domain (@google_domains) {
    print "\nMencari di $domain...\n";

    # Iterasi untuk setiap halaman hasil pencarian (misal 10 halaman)
    for (my $start = 0; $start < 100; $start += 10) {
        # URL Google Search dengan parameter pagination dan domain
        my $url = "https://www.$domain/search?q=$query&start=$start";

        # Membuat request
        my $response = $ua->get($url);

        # Cek apakah request berhasil
        if ($response->is_success) {
            my $content = $response->decoded_content;

            # Parsing HTML
            my $tree = HTML::TreeBuilder->new_from_content($content);

            # Mencari semua tag <a> yang mengandung URL
            foreach my $a_tag ($tree->find_by_tag_name('a')) {
                if (my $href = $a_tag->attr('href')) {
                    if ($href =~ m{^/url\?q=(http[^&]+)}) {
                        my $clean_url = $1;

                        # Cek apakah URL sudah pernah ditemukan
                        unless (exists $seen_urls{$clean_url}) {
                            # Tampilkan URL di konsol
                            print "$clean_url\n";

                            # Simpan URL jika belum pernah ditemukan
                            print $fh "$clean_url\n";
                            $seen_urls{$clean_url} = 1;  # Tandai URL sebagai sudah ditemukan
                            $total_urls++;
                        }
                    }
                }
            }

            # Bersihkan tree HTML
            $tree->delete;

            # Beri jeda kecil untuk menghindari blokir
            sleep(10);
        } else {
            warn "Gagal mengambil halaman dari $domain: " . $response->status_line;
            last;  # Jika gagal mengambil halaman, keluar dari loop
        }
    }
}

close($fh);

print "\nTotal URL yang ditemukan (tanpa duplikat): $total_urls\n";
print "Hasil pencarian disimpan ke 'hasil_pencarian.txt'\n";
