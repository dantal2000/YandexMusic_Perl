#! /usr/bin/perl

use JSON;
use Digest::MD5 qw(md5_hex);

# We need an id to continue
if (@ARGV != 1) {
	print "Usage: download.pl id\nWhere id - is the numeric id of file\n";
	exit;
};

$track_id = $ARGV[0];
print "track_id = $track_id\n";

# Quaility = {0,1}. Do as you want it to be
$quality = 0;

$first_URL = "https://music.yandex.ru/api/v2.1/handlers/track/$track_id/track/download/m?hq=$quality";
print "first_url = $first_URL\n";
$first_json = `curl --url $first_URL --header "X-Retpath-Y: https://music.yandex.ru/"`;
print "first_json = $first_json\n";

$second_URL = (JSON->new->utf8->decode($first_json))->{src};

@second_get_data = ("format=json","external-domain=music.yandex.ru","overembed=no",("__t=" . time));
$second_URL .= "&$_" foreach @second_get_data;
print "secon_url = $second_URL";

$second_json_string = `curl --url "$second_URL"`;
print "second_json_string = $second_json_string";

$second_json = JSON->new->utf8->decode($second_json_string);
$s = $second_json->{s};
$ts = $second_json->{ts};
$path = $second_json->{path};
$host = $second_json->{host};

print <<END_LIST;
s = $s
ts = $ts
path = $path
host = $host
END_LIST

$md5_salt = "XGRlBW9FXlekgbPrRHuSiA";
$string_to_hash = $md5_salt . substr($path, 1) . $s;
print "string_to_hash = $string_to_hash\n";
$md5_hash = md5_hex($string_to_hash);

$third_URL = "https://$host/get-mp3/$md5_hash/". $ts . $path . "?track-id=$track_id";
print "third_url = $third_URL\n";
system("curl --url \"$third_URL\" -o $track_id.mp3");

