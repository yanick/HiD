#! perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Test::Routine::Util;
use Test::HiD::Util      qw/ write_fixture_file /;

use Path::Tiny;

use HiD::File;

my $tmpdir = Path::Tiny->tempdir();

my $input_file = Path::Tiny->tempfile( DIR => $tmpdir , SUFFIX => '.html' )->stringify();
write_fixture_file( $input_file => 'this is a regular file.');

my $base = path($input_file)->basename('.html');

run_tests(
  "basic file test" ,
  [ 'Test::HiD::Role::IsPublished' , 'Test::HiD::File' ] ,
  {
    expected_basename => $base ,
    expected_dir      => "$tmpdir" ,
    expected_suffix   => 'html' ,
    expected_url      => $input_file ,
    subject           => HiD::File->new({
      dest_dir       => Path::Tiny->tempdir->stringify() ,
      input_filename => $input_file ,
    }) ,
  },
);

my $dir = Path::Tiny->tempdir();
path($dir , 'nest' )->mkpath();
my $nested_file = path( $dir , 'nest' , 'nested.html' )->stringify();
write_fixture_file( $nested_file => 'this is a nested file' );

run_tests(
  "nested file test" ,
  [ 'Test::HiD::Role::IsPublished' , 'Test::HiD::File' ] ,
  {
    expected_basename => 'nested' ,
    expected_dir      => path( $dir, 'nest')->stringify() ,
    expected_suffix   => 'html' ,
    expected_url      => $nested_file ,
    subject           => HiD::File->new({
      dest_dir       => Path::Tiny->tempdir->stringify() ,
      input_filename => $nested_file ,
    }) ,
  },
);

done_testing();
