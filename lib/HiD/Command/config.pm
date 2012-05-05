package HiD::Command::config;
# ABSTRACT: HiD 'config' subcmd
use 5.010;
use Mouse;
extends 'HiD::Command';

sub _run {
  my( $self , $opts , $args ) = @_;

  $args = [ 'config' ] unless $args->[0];

  use DDP;
  my $out;
  $out .= p $self->hid->$_ foreach @$args;

  print $out;
}

__PACKAGE__->meta->make_immutable;
1;
