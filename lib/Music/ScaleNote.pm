package Music::ScaleNote;

# ABSTRACT: Position of notes in a scale

our $VERSION = '0.0102';

use Carp;
use Moo;
use strictures 2;
use namespace::clean;

use List::Util qw( first );
use Music::Note;
use Music::Scales;

=head1 SYNOPSIS

  use Music::ScaleNote;
  my $msn = Music::ScaleNote->new(
    scale_note => 'C',
    scale_name => 'pminor',
  );
  my $note = $msn->get_offset(
    note_name   => 'C4',
    note_format => 'ISO',
    offset      => 1,
  );
  print $note->format('ISO'), "\n"; # D#4


=head1 DESCRIPTION

A C<Music::ScaleNote> object manipulates the position of notes in a given scale.

=head1 ATTRIBUTES

=head2 scale_note

This is the name of the note that starts the given B<scale_name>.

Default: C

=cut

has scale_note => (
    is      => 'ro',
    default => sub { 'C' },
);

=head2 scale_name

See L<Music::Scales/SCALES> for the possible names.

Default: major

=cut

has scale_name => (
    is => 'ro',
);

=head1 METHODS

=head2 new()

  $msn = Music::ScaleNote->new(%arguments);

Create a new C<Music::ScaleNote> object.

=head2 get_offset()

  $note = $msn->get_offset(%arguments);

Return a new L<Music::Note> object based on the given B<note_name>,
B<note_format> and B<offset>.

=cut

sub get_offset {
    my ( $self, %args ) = @_;

    croak 'note_name, note_format or offset not provided'
        unless $args{note_name} || $args{note_format} || $args{offset};

    my $rev;  # Going in reverse?

    my $note = Music::Note->new( $args{note_name}, $args{note_format} );
#warn(__PACKAGE__,' L',__LINE__,". MARK: $args{note_name} - ",$note->format('ISO'),"\n");

    my @scale = get_scale_notes( $self->scale_note, $self->scale_name );
#warn(__PACKAGE__,' L',__LINE__,". MARK: @scale",,"\n");
    if ( $args{offset} < 0 ) {
        $rev++;
        $args{offset} = abs $args{offset};
        @scale  = reverse @scale;
    }

    my $posn = first { $scale[$_] eq $note->format('isobase') } 0 .. $#scale;
#warn(__PACKAGE__,' L',__LINE__,". MARK: $args{note_name}=$posn\n") if $posn;

    $args{offset} += $posn if $posn;

    my $octave = $note->octave;
    my $factor = int( $args{offset} / @scale );

    if ( $rev ) {
        $octave -= $factor;
    }
    else {
        $octave += $factor;
    }

    $note = Music::Note->new( $scale[ $args{offset} % @scale ] . $octave, 'ISO' );
#warn(__PACKAGE__,' L',__LINE__,". MARK: $args{offset} => ",$note->format('ISO') .' - '.$note->format($args{note_format}),"\n");

    return $note;
}

1;

=head1 SEE ALSO

L<Moo>

L<List::Util>

L<Music::Note>

L<Music::Scales>

=cut
