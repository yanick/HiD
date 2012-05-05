package HiD::Command::publish;
# ABSTRACT: HiD 'publish' sub-command
use 5.010;
use Mouse;
extends 'HiD::Command';

use File::Remove qw/ remove /;
use Path::Class  qw/ file /;

has written_files => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  traits  => [ qw/ Hash NoGetopt / ] ,
  default => sub {{}},
  handles => {
    add_written_file  => 'set' ,
    written_file      => 'get' ,
    all_written_files => 'keys' ,
    wrote_file        => 'defined' ,
  },
);

sub _run {
  my( $self , $opts , $args ) = @_;

  # bootstrap data structures -- FIXME should have a more explicit way to do this
  $self->hid->regular_files;

  $self->add_written_file( $self->site_dir => '_sitedir' );

  foreach my $file ( $self->all_objects ) {
    $file->publish;

    my $path;
    foreach my $part ( split '/' , $file->destination ) {
      $path = file( $path , $part )->stringify;
      $self->add_written_file( $path => 1 );
    }
  }

  foreach ( File::Find::Rule->in( $self->site_dir )) {
    $self->wrote_file($_) or remove \1 , $_;
  }
}

__PACKAGE__->meta->make_immutable;
1;
