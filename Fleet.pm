package Fleet;                          # Similar to c++ class declaration

use strict;
use warnings;

sub new {
    my $class  = shift;                 # class name Fleet stored in $class
    my $fleet  = {                      # hash reference stored in $fleet
        CORDS  => [],                   # array of all coordinates
        PICKS  => [],                   # array of picks
        DEST   => [],                   # array of destroyed ships
        GRID   => [],                   # array of ascii grid
        SHIPS  => {
            CARRIER    => $_[0],
            BATTLESHIP => $_[1],        # this class is an hash of arrays (H0A)
            DESTROYER  => $_[2],        # ship coords stored in arrays
            SUBMARINE  => $_[3],        # which are the values, and the
            PATROLBOAT => $_[4],        # ship names are the hash keys
        },
    };
    bless $fleet, $class;               # $fleet blessed into class $class
    $fleet->makeGrid();
    return $fleet;                      # returns reference to Fleet class
}
sub flCoords {                          # Calculate remaining coords of fleet
    my $self = shift;
    my ( @coords );
    foreach my $ship ( keys %{$self->{SHIPS}} ) {  # extract ship names
        push @coords, map { split } $self->{SHIPS}{$ship}; # split coords into int array
    }
    return @coords;
}
sub flSize {                            # Calculate current size of fleet
    my $self = shift;
    my ( $count, @tmp );
    foreach my $ship ( keys %{$self->{SHIPS}} ) {  # extract ship names
        push @tmp, map { split } $self->{SHIPS}{$ship}; # split coords into int array
    }
    return $count = @tmp;               # returns element size of tmp
}
sub flEmpty {                           # returns true(1) or false(0)
    my $self = shift;                   # based on number of keys (ships) left
    return scalar( keys %{$self->{SHIPS}} );
} 
sub isEmpty {                           # Check for empty fleet
    my $self = shift;                   # based on number of keys (ships) left
    my ( $size, @tmp );
    foreach my $ship ( keys %{$self->{SHIPS}} ) { # extract ships from fleet
        @tmp = map { split } $self->{SHIPS}{$ship}; # split coords into int array
        $size = @tmp;                   # get size of ship
        if ( $size == 0 ) {             # zero size = ship destroyed
            delete $self->{SHIPS}{$ship};  # delete ship from fleet
            last if ( $self->flEmpty ); # is fleet at zero size, too???
        }
    }
    return;
}
sub hitCheck {
    my ( $self, $num ) = ( @_ );
    push @{$self->{PICKS}}, $num;
    foreach my $ship ( keys %{$self->{SHIPS}} ) {  # extract ship names
        my @tmp = map { split } $self->{SHIPS}{$ship}; # split coords into int array
        my $i = 0;
        next unless ( $num ~~ @tmp );   # skip loop if no hit to be recorded
        foreach ( @tmp ) {              # loops on each ship coordinate
            if ( $_ == $num ) {
                my ( $y, $x ) = split(//, $_);  # splits coordinates into x/y values
                $self->{GRID}[$x][$y] = "x";  # and places an 'o' into grid
                splice(@tmp, $i, 1);    # hit recorded, remove from ship array
                $self->{SHIPS}{$ship} = "@tmp"; # update ship array minus removed coord
                my $size = @tmp         # get size of ship
                    ? return 1
                    : do {
                          # print "$ship DESTROYED!!!\n";
                          push @{$self->{DEST}}, $ship;
                          $self->isEmpty();
                          return 1;
                      }
            }
            ++$i;                       # increment array index
        }
    }
    return 0;
}
sub makeGrid {
    my $self = shift;
    my @pts = $self->flCoords();        # store fleet coordinates into array
    $self->{CORDS} = [ @pts ];          # store array of coordinates in fleet
    for my $row ( 0 .. 9 ) {
        $self->{GRID}[$row] =           # build 10x10 grid to place ships
            [".", ".", ".", ".", ".", ".", ".", ".", ".", "."];
    }
    for ( @pts ) {
        my ( $row, $col ) = split(//, $_);  # splits coordinates into x/y values
        $self->{GRID}[$col][$row] = "o";    # and places an 'o' into grid
    }
    return;
}
sub showFleet {                         # show ships and coordinates
    my $self = shift;
    my @ships = sort { length( $self->{SHIPS}{$b} ) <=>
                       length( $self->{SHIPS}{$a} ) } keys %{$self->{SHIPS}};
    foreach my $ship (@ships) {         # each key is looped through ...
        print lc($ship), " \t", $self->{SHIPS}{$ship},"\n"; # ... and shown
    }
    return;
}
sub showGrid {                          # show grid of ship positions
    my $self = shift;
    for my $row ( 0 .. 9 ) {
        print "@{$self->{GRID}[$row]}\n";  # in cool ascii!!!
    }
    return;
}
sub showStatus {                        # show fleet status using grids
    my ( $bF, $rF ) = ( @_ );
    print "Blue Fleet\t\tRed Fleet\n";
    for ( 0 .. 9 ) {
        print "@{$bF->{GRID}[$_]}\t@{$rF->{GRID}[$_]}\n";
    }
    return;
}
sub showResults {                       # show final results
    my ( $bF, $rF ) = ( @_ );
    my @fleet = qw( Blue Red );
    my $sumPicks = @{$bF->{PICKS}} + @{$rF->{PICKS}};
    my $winner = $sumPicks % 2;
    printf "\n%s Fleet DESTROYED!!! ", $fleet[!$winner];
    printf "%s WINS!!!\nRemaining ship(s):\n",$fleet[$winner];
    showStatus( $bF, $rF );             # show final fleet grids
    ( $winner ) ? $rF->showFleet()
                : $bF->showFleet();
    print "Total picks:\t$sumPicks\n";
    return;
}
1;
