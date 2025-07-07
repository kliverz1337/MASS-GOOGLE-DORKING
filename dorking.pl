#!/usr/bin/perl
use if $^O eq "MSWin32", Win32::Console::ANSI;
use strict;
use warnings;
use LWP::UserAgent;
use HTML::TreeBuilder;
use URI;
use Term::ANSIColor;
use utf8;
use HTTP::Request::Common;

# Variabel debug (aktifkan dengan mengubah ke 1)
my $debug = 0;

# Daftar User-Agent untuk pemakaian secara acak
my @user_agents = (
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36',
    'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1',
    'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko',
    'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0'
);

# Fungsi untuk memuat domain Google dari file eksternal
sub load_google_domains {
    my $filename = 'google_domains.txt';
    my @domains;

    open(my $fh, '<', $filename) or die "Tidak bisa membuka file $filename: $!";

    while (my $line = <$fh>) {
        chomp $line;
        my ($domain, $description) = split /,/, $line, 2;
        push @domains, { domain => $domain, description => $description };
    }

    close $fh;
    return @domains;
}

# Muat domain Google dari file
my @google_domains = load_google_domains();

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

    # Random User-Agent
    my $random_user_agent = $user_agents[rand @user_agents];
    $ua->agent($random_user_agent);

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
            print "IP Anda tidak diblokir oleh Google.\n";
            print color('reset');
        }
    } else {
        print item();
        print color('bold yellow');
        print "Tidak dapat menghubungi Google untuk memeriksa status IP.\n";
        print color('reset');
    }

    # Tampilkan User-Agent yang digunakan
    print item();
    print color('bold green');
    print "User-Agent : $random_user_agent\n\n";
    print color('reset');
}

# Tampilkan banner dan cek IP
banner();
check_ip_block();

# Fungsi untuk mendapatkan input query secara interaktif
print color('bold white');
print "Masukkan Google Dork --> : ";
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
open(my $fh, '>', 'google_result.txt') or die color('bold red') . "Tidak bisa membuka file: $!\n" . color('reset');

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

        # Random User-Agent
        my $random_user_agent = $user_agents[rand @user_agents];
        $ua->agent($random_user_agent);

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
print "Hasil pencarian disimpan ke 'google_result.txt'\n";
print color('reset');
