#! /usr/bin/perl

use JSON;
use Digest::MD5 qw(md5_hex);
$json_parser = JSON->new->utf8;

# We need an id to continue
if (@ARGV != 1) {
	print "Usage: download.pl id\nWhere id - is the numeric id of file\n";
	exit;
};

$track_id = $ARGV[0];

# Quaility = {0,1}. Do as you want it to be
$quality = 0;

$first_URL = "https://music.yandex.ru/api/v2.1/handlers/track/$track_id/track/download/m";
$first_json = `curl --url $first_URL --get -d "hq=1" --header "X-Retpath-Y: https://music.yandex.ru/"`;

$second_URL = ($json_parser->decode($first_json))->{src};

@second_get_data = ("format=json","external-domain=music.yandex.ru","overembed=no",("__t=" . time));
$_ = "-d \"" . $_ . "\"" foreach @second_get_data;

$second_json_string = `curl --url $second_URL --get @second_get_data`;

%second_json = $json_parser->decode($second_json_string);
$s = $second_json{s};
$ts = $second_json{ts};
$path = $second_json{path};
$host = $second_json{host};

$md5_salt = "XGRlBW9FXlekgbPrRHuSiA";
$string_to_hash = $md5_salt . substr($path, 1) . $s;
$md5_hash = md5_hex($string_to_hash);

$third_URL = "https://$host/get-mp3/$md5_hash/$ts$path";
system("curl --url $third_URL -d \"track-id=$track_id\" -o $track_id.mp3");
