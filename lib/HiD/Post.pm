package HiD::Post;
use Mouse;
use namespace::autoclean;

use autodie;
use DateTime;
use HiD::Types;
use YAML::XS;

=attr categories

=cut

has categories => (
  is      => 'ro' ,
  isa     => 'ArrayRef' ,
  default => sub {[]} ,
);

=attr content

=cut

has content => (
  is       => 'ro',
  isa      => 'Str',
  required => 1 ,
);

=attr date

=cut

has date => (
  is       => 'ro' ,
  isa      => 'DateTime' ,
  required => 1,
);

=attr extension

=cut

has extension => (
  is       => 'ro' ,
  isa      => 'HiD_FileExtension' ,
  required => 1 ,
);

=attr filename

=cut

has filename =>(
  is       => 'ro' ,
  isa      => 'HiD_FilePath',
  required => 1 ,
);

=attr layout

=cut

has layout => (
  is      => 'ro' ,
  isa     => 'HiD::Layout' ,
  default => sub { "FIXME fetch layouts by name" }
);

=attr metadata

=cut

has metadata => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  default => sub {{}} ,
);

=attr permalink

=cut

has permalink => (
  is      => 'ro',
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_permalink' ,
);

=attr processed_content

=cut

has processed_content => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => 'process_content' ,
);

=attr tags

=cut

has tags => (
  is      => 'ro' ,
  isa     => 'ArrayRef',
  default => sub {[]} ,
);

=attr title

=cut

has title => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] && ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  die "filename required for post"
    unless $args{filename};

  my( $year , $month , $day , $extension ) = $args{filename}
    =~ m|^.*?/([0-9]{4})-([0-9]{2})-([0-9]{2})-(?:.+?)\.(.+)$|;

  $args{date}      = DateTime->new( year => $year , month => $month , day => $day );
  $args{extension} = $extension;

  my $metadata;
  open( my $IN , '<' , $args{filename} );
  my $first = <$IN>;
  if ( $first =~ /^---$/ ) {
    my $line = <$IN>;
    while ( $line !~ /^---$/ ) {
      $metadata .= $line;
      $line = <$IN>;
    }
    # FIXME handle exceptions;
    $args{metadata} = Load($metadata);
  }
  {
    local $/;
    $args{content} = <$IN>;
  }
  close( $IN );

  $args{title} = ( ref $args{metadata}{title} )
    ? ${$args{metadata}{title} }
    : $args{metadata}{title}  // 'NO TITLE';

  my $layout_name = $args{metadata}{layout} // 'post';
  $args{layout} = $args{hid}->get_layout_by_name( $layout_name );

  if ( my $new_date = $args{metadata}{date} ) {
    my( $year , $month , $day ) = $new_date =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})/;
    $args{date} = DateTime->new( year => $year , month => $month , day => $day );
  }

  ## TODO parse categories and tags out of metadata

  return \%args;
}

__PACKAGE__->meta->make_immutable;
1;
