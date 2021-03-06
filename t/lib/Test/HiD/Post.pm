package Test::HiD::Post;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::File;
use namespace::autoclean;

use HiD::Post;

has converted_excerpt_regexp => (
  is      => 'ro' ,
  isa     => 'RegexpRef' ,
  lazy    => 1 ,
  default => sub { shift->converted_content_regexp }
);

has output_regexp => (
  is       => 'ro' ,
  isa      => 'RegexpRef' ,
  required => 1 ,
);

has subject => (
  is       => 'ro' ,
  isa      => 'HiD::Post' ,
  required => 1 ,
);

test "has converted excerpt" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  like( $subject->converted_excerpt , $test->converted_excerpt_regexp );
};

test "output filename" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  my $permalink = $subject->get_metadata( 'permalink' ) // 'none';

 SKIP:{
    skip "invalid if permalink" , 2
      unless ( $permalink eq 'none' or $permalink eq 'pretty' );

    like( $subject->output_filename , qr|.html$| , 'ends in html' );

  SKIP: {
      skip "invalid if date set" , 1
        if ( $subject->get_metadata( 'date') );

      my( $year , $month , $day ) = $subject->input_filename
        =~ /([0-9]{4})-([0-9]{2})-([0-9]{2})-/;

      like( $subject->output_filename , qr|$year/$month/$day/| ,
            'contains date parts');
    }
  };
};

test "publish" => sub {
  my $test = shift;
  my $subject = $test->subject;

  my $output = $subject->output_filename;

  file_not_exists_ok( $output , 'no output yet' );
  $subject->publish;
  file_exists_ok( $output , 'and now output' );

  file_contains_like( $output , $test->output_regexp );
};
