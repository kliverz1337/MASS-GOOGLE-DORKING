#!/usr/bin/perl
use if $^O eq "MSWin32", Win32::Console::ANSI;
use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;
use URI;
use Term::ANSIColor;
use utf8;

# Variabel debug (aktifkan dengan mengubah ke 1)
my $debug = 0;

# Daftar domain Google yang paling banyak digunakan
my @google_domains = (
    { domain => 'google.com',     description => 'Global' },
    { domain => 'google.co.id',   description => 'Indonesia' },
    { domain => 'google.co.uk',   description => 'United Kingdom' },
    { domain => 'google.ca',      description => 'Canada' },
    { domain => 'google.de',      description => 'Germany' },
    { domain => 'google.co.jp',   description => 'Japan' },
    { domain => 'google.com.au',  description => 'Australia' },
);

# Fungsi untuk menampilkan banner
sub banner() {
    system("title Google Dorking by kliverz");
    if ($^O =~ /MSWin32/) { system("cls"); } else { system("clear"); }

    print color('reset');
    print colored ("################################################################",'white'),"\n";
    print colored ("##               Google Dorking Tool by Kliverz               ##",'white'),"\n";
    print colored ("##             Contact : kliverz1337(at)gmail.com             ##",'white'),"\n";	
    print colored ("##  THANKS TO : JATIMCOM, BLACKUNIX CREW, KILL -9 CREW, BKHT  ##",'white'),"\n";
    print colored ("################################################################",'white'),"\n\n";
    print color('reset');
}

sub item
{
    my $n = shift // '+';
    return color('bold red')," ["
    , color('bold green'),"$n"
    , color('bold red'),"] "
    , color("bold white")
    ;
}

# Fungsi untuk mengecek apakah IP diblokir oleh Google
sub check_ip_block {
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;

    my $url = "https://www.google.com";
    my $response = $ua->get($url);

    if ($response->is_success) {
        my $content = $response->decoded_content;

        if ($content =~ /detected unusual traffic|captcha/i) {
			print item();
            print color('bold red');
            print "WARNING: IP Anda mungkin diblokir oleh Google!\n";
            print color('reset');
        } else {
			print item();
            print color('bold green');
            print "IP Anda tidak diblokir oleh Google.\n\n";
            print color('reset');
        }
    } else {
		print item();
        print color('bold yellow');
        print "Tidak dapat menghubungi Google untuk memeriksa status IP.\n";
        print color('reset');
    }
}

# Tampilkan banner dan cek IP
banner();
check_ip_block();

# Fungsi untuk mendapatkan input query secara interaktif
print color('bold green');
print "Masukkan Google Dork: ";
print color('reset');
my $query = <STDIN>;
chomp($query);  # Menghapus newline di akhir input

# Cek jika query kosong
if (!$query) {
    die color('bold red') . "Query tidak boleh kosong!\n" . color('reset');
}

# Ganti spasi dengan '+' untuk query URL Google
$query =~ s/ /+/g;

# Pilih mode pencarian: satu domain atau semua
print color('bold green');
print "\nPilih mode pencarian:\n";
print "1. Gunakan satu domain Google\n";
print "2. Gunakan semua domain Google\n";
print color('reset');
print "Masukkan pilihan (1 atau 2): ";
my $mode = <STDIN>;
chomp($mode);

# Validasi input mode
if ($mode ne '1' && $mode ne '2') {
    die color('bold red') . "Pilihan tidak valid!\n" . color('reset');
}

# Inisialisasi user agent
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

# File untuk menyimpan hasil pencarian
open(my $fh, '>', 'hasil_pencarian.txt') or die color('bold red') . "Tidak bisa membuka file: $!\n" . color('reset');

# Variabel untuk menyimpan jumlah domain dan hash untuk memeriksa duplikasi
my $total_domains = 0;
my %seen_domains;

# Jika mode 1 (satu domain), minta pengguna memilih domain
if ($mode eq '1') {
    print color('bold green'), "\nPilih domain Google:\n";
    for my $i (0 .. $#google_domains) {
        my $index = $i + 1;
        my $domain = $google_domains[$i]->{domain};
        my $description = $google_domains[$i]->{description};
        print "$index. $domain - $description\n";
    }
    print color('reset');
    print "Masukkan nomor domain (1-" . scalar(@google_domains) . "): ";
    my $domain_choice = <STDIN>;
    chomp($domain_choice);

    # Validasi input domain
    if ($domain_choice < 1 || $domain_choice > scalar(@google_domains)) {
        die color('bold red') . "Pilihan domain tidak valid!\n" . color('reset');
    }

    # Set domain yang dipilih
    @google_domains = ($google_domains[$domain_choice - 1]);
}

# Loop untuk setiap domain Google
foreach my $google_domain (@google_domains) {
    my $domain = $google_domain->{domain}; # Ambil domain dari hash
    print color('bold cyan');
    print "\nMencari di $domain...\n";
    print color('reset');

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

                        # Debug: Tampilkan URL yang ditemukan
                        if ($debug) {
                            print color('bold blue');
                            print "Debug: URL ditemukan: $clean_url\n";
                            print color('reset');
                        }

                        # Ekstrak domain menggunakan URI
                        my $uri = URI->new($clean_url);
                        my $domain_only = $uri->host;

                        # Cek apakah domain sudah pernah ditemukan
                        unless (exists $seen_domains{$domain_only}) {
                            # Tampilkan domain di konsol dengan warna kuning
                            print color('bold yellow');
                            print "$domain_only\n";
                            print color('reset');

                            # Simpan domain jika belum pernah ditemukan
                            print $fh "$domain_only\n";
                            $seen_domains{$domain_only} = 1;  # Tandai domain sebagai sudah ditemukan
                            $total_domains++;
                        }
                    }
                }
            }

            # Bersihkan tree HTML
            $tree->delete;

            # Debug: Tampilkan informasi halaman yang diproses
            if ($debug) {
                print color('bold blue');
                print "Debug: Halaman diproses: $start\n";
                print color('reset');
            }

            # Beri jeda acak untuk menghindari blokir
            my $sleep_time = 20 + int(rand(41));  # Angka acak antara 20-60 detik
            print color('bold blue');
            print "Menunggu selama $sleep_time detik sebelum mengambil halaman berikutnya...\n";
            print color('reset');
            sleep($sleep_time);
        } else {
            print color('bold red');
            warn "Gagal mengambil halaman dari $domain: " . $response->status_line;
            print color('reset');
            last;  # Jika gagal mengambil halaman, keluar dari loop
        }
    }
}

close($fh);

print color('bold green');
print "\nTotal domain yang ditemukan (tanpa duplikat): $total_domains\n";
print "Hasil pencarian disimpan ke 'hasil_pencarian.txt'\n";
print color('reset');
