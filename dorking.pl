#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Response;
use HTML::TreeBuilder;
use URI;
use Term::ANSIColor;
use utf8;

# Daftar domain Google yang paling banyak digunakan beserta deskripsinya
my @google_domains = (
    { domain => 'google.com',     description => 'Global' },
    { domain => 'google.co.id',   description => 'Indonesia' },
    { domain => 'google.co.uk',   description => 'United Kingdom' },
    { domain => 'google.ca',      description => 'Canada' },
    { domain => 'google.de',      description => 'Germany' },
    { domain => 'google.co.jp',   description => 'Japan' },
    { domain => 'google.com.au',  description => 'Australia' },
);

# Banner pada saat script di jalankan
sub banner {
    system($^O eq 'MSWin32' ? 'cls' : 'clear');
    print color('reset'), colored("################################################################", 'white on_red'), "\n";
    print colored("##  THANKS TO : JATIMCOM, BLACKUNIX CREW, KILL -9 CREW, BKHT  ##", 'white on_red'), "\n";
    print colored("################################################################", 'white on_red'), "\n\n";
}
banner();

# Inisialisasi user agent
my $ua = LWP::UserAgent->new(timeout => 10, env_proxy => 1);
$ua->default_header('User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3');

# Cek apakah IP diblokir
sub check_ip_blocked {
    my $test_url = 'https://www.google.com/';
    my $response = $ua->get($test_url);
    
    if ($response->is_success) {
        return 0;  # IP tidak diblokir
    } elsif ($response->code == 403 || $response->code == 429) {
        print color('bold red'), "IP Anda diblokir oleh Google. Silakan coba lagi nanti.\n", color('reset');
        exit;  # Keluar dari skrip jika IP diblokir
    } else {
        print color('bold red'), "Gagal melakukan pengecekan IP: ", $response->status_line, "\n", color('reset');
        exit;  # Keluar dari skrip jika ada masalah dengan pengecekan
    }
}

# Cek IP sebelum lanjut
check_ip_blocked();

# Fungsi untuk mendapatkan input query secara interaktif
print color('bold green'), "Masukkan kata kunci pencarian Google: ", color('reset');
my $query = <STDIN>;
chomp($query);
die color('bold red') . "Query tidak boleh kosong!\n" . color('reset') unless $query;

$query =~ s/ /+/g;

# Pilih mode pencarian: satu domain atau semua
print color('bold green'), "\nPilih mode pencarian:\n1. Gunakan satu domain Google\n2. Gunakan semua domain Google\n", color('reset');
print "Masukkan pilihan (1 atau 2): ";
my $mode = <STDIN>;
chomp($mode);
die color('bold red') . "Pilihan tidak valid!\n" . color('reset') unless $mode eq '1' || $mode eq '2';

# File untuk menyimpan hasil pencarian
open(my $fh, '>', 'hasil_pencarian.txt') or die color('bold red') . "Tidak bisa membuka file: $!\n" . color('reset');

# Variabel untuk menyimpan jumlah domain dan hash untuk memeriksa duplikasi
my $total_domains = 0;
my %seen_domains;

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
    die color('bold red') . "Pilihan domain tidak valid!\n" . color('reset') unless $domain_choice >= 1 && $domain_choice <= scalar(@google_domains);
    @google_domains = ($google_domains[$domain_choice - 1]->{domain});
}

# Loop untuk setiap domain Google
foreach my $domain (@google_domains) {
    print color('bold cyan'), "\nMencari di $domain...\n", color('reset');
    for (my $start = 0; $start < 100; $start += 10) {
        my $url = "https://www.$domain/search?q=$query&start=$start";
        my $response = $ua->get($url);
        if ($response->is_success) {
            my $content = $response->decoded_content;
            my $tree = HTML::TreeBuilder->new_from_content($content);
            foreach my $a_tag ($tree->find_by_tag_name('a')) {
                if (my $href = $a_tag->attr('href')) {
                    if ($href =~ m{^/url\?q=(http[^&]+)}) {
                        my $clean_url = $1;
                        my $uri = URI->new($clean_url);
                        my $domain_only = $uri->host;
                        unless ($seen_domains{$domain_only}++) {
                            print color('bold yellow'), "$domain_only\n", color('reset');
                            print $fh "$domain_only\n";
                            $total_domains++;
                        }
                    }
                }
            }
            $tree->delete;
            my $sleep_time = 20 + int(rand(41));
            print color('bold blue'), "Menunggu selama $sleep_time detik sebelum mengambil halaman berikutnya...\n", color('reset');
            sleep($sleep_time);
        } else {
            print color('bold red'), "Gagal mengambil halaman dari $domain: " . $response->status_line, color('reset');
            last;
        }
    }
}

close($fh);
print color('bold green'), "\nTotal domain yang ditemukan (tanpa duplikat): $total_domains\n", "Hasil pencarian disimpan ke 'hasil_pencarian.txt'\n", color('reset');
