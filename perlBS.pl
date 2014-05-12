#!/usr/bin/perl

use strict;
use warnings;
use feature qw( state switch );
use DoDump;
use Fleet;
use Tk;
use Tk::LabFrame;
use Tk::JPEG;
use Tk::ROText;

my ( $carX, $carY, $carO, $batX, $batY, $batO, $desX, $desY, $desO );
my ( $subX, $subY, $subO, $patX, $patY, $patO );
my ( $bFleet, $rFleet, @blFleet, @rdFleet );
my ( @bBtnRefs, @rBtnRefs, @bPicks, @rPicks );
my ( $mw_lblFont, $mg_lblFont, $ss_lblFont, $mg_status );
my ( $ss_frlblFont, $ss_cordFont, $ss_btnWidth );
my ( $mw_btnWidth, $mg_gbtnWidth, $mg_gbtnHeight );
my $mwSplash = 'Battleship_6x4.jpg';
my $ttlColor = 'black';
my @fltColor = ( 'dark blue', 'dark red' );
state $turn = 0;
given ( $^O ) {
    when(/Win32/) {
        $mw_lblFont     = ['helvetica', '18', 'bold'];
        $mg_lblFont     = ['helvetica', '18', 'bold'];
        $ss_lblFont     = ['helvetica', '18', 'bold'];
        $ss_frlblFont   = ['helvetica', '10', 'bold'];
        $ss_cordFont    = ['helvetica', '10', 'bold'];
        $mw_btnWidth    = 12;
        $ss_btnWidth    = 10;
        $mg_gbtnWidth   = 4;
        $mg_gbtnHeight  = 2;
        };
    when (/cygwin/) {
        $mw_lblFont     = ['helvetica', '18', 'bold'];
        $mg_lblFont     = ['helvetica', '18', 'bold'];
        $ss_lblFont     = ['helvetica', '18', 'bold'];
        $ss_frlblFont   = ['helvetica', '12', 'bold'];
        $ss_cordFont    = ['helvetica', '10', 'bold'];
        $mw_btnWidth    = 8;
        $ss_btnWidth    = 8;
        $mg_gbtnWidth   = 2;
        $mg_gbtnHeight  = 2;
        };
    default       {
        $mw_lblFont     = ['helvetica', '20', 'bold'];
        $mg_lblFont     = ['helvetica', '18', 'bold'];
        $ss_lblFont     = ['helvetica', '20', 'bold'];
        $ss_frlblFont   = ['helvetica', '12', 'bold'];
        $ss_cordFont    = ['helvetica', '10', 'bold'];
        $mw_btnWidth    = 8;
        $ss_btnWidth    = 8;
        $mg_gbtnWidth   = 2;
        $mg_gbtnHeight  = 2;
        };
};

my $mw = MainWindow->new( -title => 'Battleship' );
   $mw->geometry('640x480+50+50');
   $mw->resizable(0,0);

my $mwCan = $mw->Canvas( -width => 1, -height => 1,
   )->pack;
my $mwImg = $mw->Photo( -file => $mwSplash );
   $mwCan->createImage( 0, 0, -image => $mwImg, -anchor => 'nw' );
   $mwCan->configure(
        -width  => $mwImg->width,
        -height => $mwImg->height,
        -scrollregion => [ 0, 0, $mwImg->width,
                                $mwImg->height - 2,
                         ],
   );
my $canLbl = $mwCan->Label(
        -text => 'Battleship - The Game ... the Experience',
        -font => $mw_lblFont,
        -background => 'light blue',
        -foreground => $ttlColor,
   )->pack;
   $mwCan->createWindow( 250,50, -window => $canLbl );

my $canOne = $mwCan->Button(
        -text    => 'One Player',
        -width   => $mw_btnWidth,
        -command => [ \&setShips, 0 ]
   );
   $mwCan->createWindow( 75,100, -window  => $canOne );
my $canTwo = $mwCan->Button(
        -text    => 'Two Player',
        -width   => $mw_btnWidth,
        -command => [ \&setShips, 1 ]
   );
   $mwCan->createWindow( 175,100, -window => $canTwo );
my $canHow = $mwCan->Button(
        -text    => 'How to Play',
        -width   => $mw_btnWidth,
        -command => sub { print "I know how, already!\n"; }
   );
   $mwCan->createWindow( 275,100, -window => $canHow );
my $canExit = $mwCan->Button(
        -text    => 'Exit',
        -width   => $mw_btnWidth,
        -command => sub { $mw->destroy(); }
   );
   $mwCan->createWindow( 375,100, -window => $canExit );

MainLoop;

do {
    Fleet::showStatus( $bFleet, $rFleet );
#     do_dump( {%$bFleet}, "Blue" . ref($bFleet));
#     do_dump( {%$rFleet}, "Red"  . ref($rFleet));
} if ( @blFleet && @rdFleet );

exit;
### functions ###
sub makeGrid {
    my $plyrs = shift;
    do {
        Fleet::showStatus( $bFleet, $rFleet );
#     do_dump( {%$bFleet}, "Blue" . ref($bFleet));
#     do_dump( {%$rFleet}, "Red"  . ref($rFleet));
    } if ( @blFleet && @rdFleet );
    my ( $bState, $bBack, $rState, $rBack, $status )
        = ( $plyrs )
            ? ( 'disabled', 'gray', 'normal', 'indian red' ) 
            : ( 'normal', 'light blue', 'disabled', 'gray' ); 
    my $mg_tl = $mw->Toplevel( -title => 'BATTLESHIP!' );
    $mg_tl->geometry('1000x600+200+50');
    $mg_tl->resizable(0,0);
    $mg_tl->Label(
        -text => 'BATTLESHIP',
        -font => $mg_lblFont,
        -foreground  => 'black',
    )->pack( -side   => 'top',
             -expand => '0',
           );
    $mg_status = $mg_tl->Label(
        -text        => $status,
        -font        => $mg_lblFont,
        -foreground  => 'black'
    )->pack( -side   => 'top',
             -expand => '0',
           );
    my $mg_exit_b = $mg_tl->Button(
        -text    => 'Exit',
        -command => sub { clrFleet();
                          $mg_tl->destroy();
                          $mw->deiconify();
                    }
    )->pack;
    my ( $blueFrame, $redFrame, $blHitFrame, $rdHitFrame );
    $blueFrame = $mg_tl->Frame;
    $redFrame  = $mg_tl->Frame;
### Blue Grid
    for my $row ( 0 .. 9 ) {
        for my $col ( 0 .. 9 ) {
            $blueFrame->Button(
                -text       => $col . $row, 
                -width      => $mg_gbtnWidth,
                -height     => $mg_gbtnHeight,
                -background => $bBack,
                -state      => $bState,
                -command    => [ \&goCheck ],
            )->grid( -row => $row, -column => $col );
        }
    }
### Red Grid
    for my $row ( 0 .. 9 ) {
        for my $col ( 0 .. 9 ) {
            $redFrame->Button(
                -text       => $col . $row,
                -width      => $mg_gbtnWidth,
                -height     => $mg_gbtnHeight,
                -background => $rBack,
                -state      => $rState,
                -command    => [ \&goCheck ],
            )->grid( -row => $row, -column => $col );
        }
    }

    $blueFrame->pack( -side => 'left',  -padx => '10' );
    $redFrame->pack( -side  => 'right', -padx => '10' );
    @bBtnRefs = $blueFrame->gridSlaves();
    @rBtnRefs = $redFrame->gridSlaves();
    return;
}
sub goCheck {
    my $this = $Tk::widget;
    my $pick = $this->cget( -text );
    $turn ? do { my $lbl = $rFleet->hitCheck( $pick )
                     ? 'X'
                     : 'O';
                 push @rPicks, $this;
                 $this->configure( -text => $lbl );
            }
          : do { my $lbl = $bFleet->hitCheck( $pick )
                     ? 'X'
                     : 'O';
                 push @bPicks, $this;
                 $this->configure( -text => $lbl );
            };
    toggleButtons();
    endGame( $mg_status ) unless ( $bFleet->flEmpty && $rFleet->flEmpty );
    $this->configure( -state => 'disabled' );
    return;
}
sub disBtns {
    my @list = ( @_ );
    for ( 0 .. 1 ) {
        foreach my $btn ( @{$list[$_]} ) {
            $_ ? $btn->configure( -state => 'disable' )
               : $btn->configure( -state => 'normal'  );
        }
    }
    $turn = !( $turn );
    return;
}
sub toggleButtons {
    my $bg = 'light blue';
    for my $list ( \@bBtnRefs, \@rBtnRefs ) {
        my ($state, $background) = 'disabled' eq $list->[0]->cget( '-state' )
                                   ? ( 'normal', $bg )
                                   : qw/disabled gray/;
        for my $button (@$list) {
            $button->configure( -state      => $state,
                                -background => $background );
        }
        $bg = 'indian red';
    }
    for my $picks ( \@bPicks, \@rPicks ) {
        for my $button ( @$picks ) {
            $button->configure( -state      => 'disabled',
                                -background => 'gray' );
        }
    }
    $turn = !( $turn );
    return;
}
sub clrFleet {
    ( $bFleet, $rFleet, @blFleet, @rdFleet, @bBtnRefs, @rBtnRefs, @bPicks, @rPicks )
        = ( undef ) x (8);
    return;
}
sub endGame {
    my $mg_status = shift;
    disBtns( \@bBtnRefs, \@rBtnRefs );
    $mg_status->configure( -text => 'Game Over' );
    Fleet::showResults( $bFleet, $rFleet );
    return;
}    
sub setShips {
    my $plyrs = shift;
    my ( $ss_tl, $coordFrame, $canvasFrame, $textFrame );
    my ( $chkCanvas, $doneCanvas, $chkGrid, $chkText );
    $mw->iconify();
    $ss_tl = $mw->Toplevel( -title => 'Battleship Coordinates Input Screen' );
    $ss_tl->geometry( '500x250+200+100' );
    $ss_tl->resizable( 0,0 );
    $ss_tl->Label( -text => 'Battleship Coordinates Input Screen',
                   -font => $ss_lblFont,
                   -foreground => $fltColor[$plyrs]
                 )->pack( -side => 'top',
                          -expand => '1',
                        );

    $coordFrame  = $ss_tl->LabFrame( -label => 'Start Point and Coordinates',
                                     -padx  => 5,
                                     -pady  => 5,
                                     -font  => $ss_frlblFont,
                                     -labelside => 'top' );
    $canvasFrame = $ss_tl->Frame;
    $textFrame   = $ss_tl->LabFrame( -label => 'Fleet Coordinates',
                                     -font  => $ss_frlblFont,
                                     -labelside => 'top' );

### Carrier Row
    $coordFrame->Label( -text => 'Carrier(5)-',
                        -font => $ss_cordFont,
                        -foreground => $fltColor[$plyrs]
    )->grid(
        $coordFrame->Label( -text => 'X:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$carX, -width => 1 ),
        $coordFrame->Label( -text => 'Y:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$carY, -width => 1 ),
        $coordFrame->Label( -text => 'O:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$carO, -width => 1 ),
                            -sticky => 'e',
    );

### Battleship Row
    $coordFrame->Label( -text => 'Battleship(4)-',
                        -font => $ss_cordFont,
                        -foreground => $fltColor[$plyrs]
    )->grid(
        $coordFrame->Label( -text => 'X:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$batX, -width => 1 ),
        $coordFrame->Label( -text => 'Y:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$batY, -width => 1 ),
        $coordFrame->Label( -text => 'O:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$batO, -width => 1 ),
                            -sticky => 'e',
    );

### Destroyer Row
    $coordFrame->Label( -text => 'Destroyer(3)-',
                        -font => $ss_cordFont,
                        -foreground => $fltColor[$plyrs],
    )->grid(
        $coordFrame->Label( -text => 'X:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$desX, -width => 1 ),
        $coordFrame->Label( -text => 'Y:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$desY, -width => 1 ),
        $coordFrame->Label( -text => 'O:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$desO, -width => 1 ),
                            -sticky => 'e',
    );

### Submarine Row
    $coordFrame->Label( -text => 'Submarine(3)-',
                        -font => $ss_cordFont,
                        -foreground => $fltColor[$plyrs],
    )->grid(
        $coordFrame->Label( -text => 'X:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$subX, -width => 1 ),
        $coordFrame->Label( -text => 'Y:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$subY, -width => 1 ),
        $coordFrame->Label( -text => 'O:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$subO, -width => 1 ),
                            -sticky => 'e',
    );

### Patrol Boat Row
    $coordFrame->Label( -text => 'Patrol Boat(2)-',
                        -font => $ss_cordFont,
                        -foreground => $fltColor[$plyrs],
    )->grid(
        $coordFrame->Label( -text => 'X:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$patX, -width => 1 ),
        $coordFrame->Label( -text => 'Y:', -font => $ss_cordFont,
                            -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$patY, -width => 1 ),
        $coordFrame->Label( -text => 'O:', -font => $ss_cordFont,
                        -foreground   => $fltColor[$plyrs] ),
        $coordFrame->Entry( -textvariable => \$patO, -width => 1 ),
                            -sticky => 'e',
    );

    $coordFrame->Button(
        -text    => 'Clear Values',
        -width   => $ss_btnWidth,
        -command => sub { clrCoords( $chkGrid, $chkText, $plyrs ); }
    )->grid(
        $coordFrame->Button(
            -text    => 'Auto Pick',
            -width   => $ss_btnWidth,
            -command => ( $plyrs )
                ? sub {
                      @rdFleet = &coordGen();
                      makeLines( $chkGrid, $plyrs, @rdFleet );
                      makeCoords( $chkText, @rdFleet );
                  }
                : sub {
                      @blFleet = &coordGen(); 
                      makeLines( $chkGrid, $plyrs, @blFleet );
                      makeCoords( $chkText, @blFleet );
                      return;
                  }
        ), "-", "-", "-", -columnspan => 2
    );

    $chkCanvas = $canvasFrame->Button(
        -text    => 'Check',
        -width   => $ss_btnWidth,
        -command => ( $plyrs )
            ? sub { @rdFleet = &check( $chkGrid, $chkText, $plyrs ); }
            : sub { @blFleet = &check( $chkGrid, $chkText, $plyrs ); }
    )->grid;

    $chkGrid = $canvasFrame->Canvas(
        -width        => 100,
        -height       => 100,
        -scrollregion => [ 0,0,100,100 ],
        -borderwidth  => 2,
        -relief       => 'groove',
    )->grid;

    $doneCanvas = $canvasFrame->Button(
        -text    => 'Done',
        -width   => $ss_btnWidth,
        -command => ( $plyrs )
            ? sub {
                  $ss_tl->destroy();
                  $plyrs = 0;
                  clrCoords();
                  setShips( $plyrs );
              }
            : sub {
                  $ss_tl->destroy(); 
                  @rdFleet = &coordGen() unless ( @rdFleet );
                  $bFleet = Fleet->new( @blFleet );
                  $rFleet = Fleet->new( @rdFleet );
                  makeGrid( $plyrs );
                  return;
              }
    )->grid;

    $chkText = $textFrame->ROText(
        -width      => 20,
        -height     => 9,
        -background => 'white',
        -relief     => 'groove',
    )->grid;

    $coordFrame->pack(
        -side => 'left',
        -padx => 7,
    );
    $canvasFrame->pack( -side => 'left', );
    $textFrame->pack(
        -side => 'left',
        -padx => 7,
        -pady => 5,
    );
    return;
}
sub clrCoords {
    my ( $chkGrid, $chkText, $plyrs ) = ( @_ );
    ( $carX, $carY, $carO, $batX, $batY, $batO, $desX, $desY, $desO )
        = ( undef ) x 9;
    ( $subX, $subY, $subO, $patX, $patY, $patO )
        = ( undef ) x 6;
    check( $chkGrid, $chkText, $plyrs ) if ( @_ );
    return;
}
sub check {
    my ( $chkGrid, $chkText, $plyrs ) = ( @_ );
    my ( $x1, $x2, $y1, $y2 );
    my @myCar   = placeShip( $carX, $carY, 5, $carO );
    my @myBat   = placeShip( $batX, $batY, 4, $batO );
    my @myDes   = placeShip( $desX, $desY, 3, $desO );
    my @mySub   = placeShip( $subX, $subY, 3, $subO );
    my @myPat   = placeShip( $patX, $patY, 2, $patO );
    my @allCrds = ( "@myCar", "@myBat", "@myDes", "@mySub", "@myPat" );

    $chkGrid->delete( 'all' );
    $chkText->delete( '1.0', 'end' );
    $chkText->insert( '1.0', "@myCar\n" );
    $chkText->insert( '2.0', "@myBat\n" );
    $chkText->insert( '3.0', "@myDes\n" );
    $chkText->insert( '4.0', "@mySub\n" );
    $chkText->insert( '5.0', "@myPat\n" );
    $chkText->insert( '6.0', coordCheckStr( @allCrds ) );

    foreach my $ea ( @allCrds ) {
        next unless ( $ea );
        my @str = map { split / / } $ea;
        ( $x1, $x2, $y1, $y2 ) = splitInt( $str[0], $str[-1] );
        $chkGrid->createLine(
            $x1,$x2,$y1,$y2,
            -fill => $fltColor[$plyrs],
            -width => 2
        );
    }
    return @allCrds;
}
sub makeLines {
    my ( $chkGrid, $plyrs, @crds ) = ( @_ );
    my ( $x1, $x2, $y1, $y2 );
    $chkGrid->delete( 'all' );
    foreach my $ea ( @crds ) {
        next unless ( $ea );
        my @str = map { split / / } $ea;
        ( $x1, $x2, $y1, $y2 ) = splitInt( $str[0], $str[-1] );
        $chkGrid->createLine(
            $x1,$x2,$y1,$y2,
            -fill => $fltColor[$plyrs],
            -width => 2
        );
    }
    return;
}
sub makeCoords {
    my ( $chkText, @crds ) = ( @_ );
    my @str;
    $chkText->delete( '1.0', 'end' );
    foreach my $ea ( @crds ) {
        next unless ( $ea );
        push @str, "$ea";
    }
    $chkText->insert( '1.0', "$str[0]\n" );
    $chkText->insert( '2.0', "$str[1]\n" );
    $chkText->insert( '3.0', "$str[2]\n" );
    $chkText->insert( '4.0', "$str[3]\n" );
    $chkText->insert( '5.0', "$str[4]\n" );
    return;
}
sub splitInt {
  no warnings;
    my ( $c1, $c2, $d1, $d2 ) = map { split // } @_;
       ( $c1, $c2, $d1, $d2 )
           = map { ( $_ * 9 ) + 10 } ( $c1, $c2, $d1, $d2 );
    return ( $c1, $c2, $d1, $d2 );
}
sub ranO {                                      # generate orientation...
    ( int( rand(100) % 2 ) ) ? return 'v'
                             : return 'h';
}
sub placeShip {                                 # takes x, y and orientation
  no warnings;
    my ( $x, $y, $s, $ch ) = @_;                # and generates ship placement
    my @str;
    if ( ( $ch =~ /v/i ) &&
       ( ( $x < 0 || $x > 9 ) || ( $y < 0 || $y > 10 - $s ) ) ) {
        return @str = qw"Out of Range";
    }
    elsif ( ( $ch =~ /h/i  ) &&
       ( ( $x < 0 || $x > 10 - $s ) || ( $y < 0 || $y > 9 ) ) ) {
        return @str = qw"Out of Range";
    }
    for ( my $n = 0; $n < $s; $n++ ) {
        given ( $ch ) {
            when ( /v/i ) { push @str, $x . ${\( $y + $n )}; }
            when ( /h/i ) { push @str, ${\( $x + $n )} . $y; }
        }
    }
    return @str;
}
sub coordCheckStr {  # 0 <= coords <= 99 and no duplicates
    my @allPos = map { split } @_;
    my ( $i, $j, $curr, @fnd, $next, $str );
    my $n = @allPos;
    my $num = 0;
    return $str = "" if ( $n < 17 );
    for ( $i = 0; $i < $n; $i++ ) {
        $curr = $allPos[$i];
        for ( $j = $i + 1; $j < $n; $j++ ) {
            $next = $allPos[$j];
            if ( $curr == $next ) {
                ++$num;
                push @fnd, $curr;
            }
        }
    }
    ( $num == 0 ) ? return $str = "Coordinates OK!\n"
                  : return $str = "$num duplicates found!\n@fnd";
    return;
}
sub coordGen {                                  # generate coordinates...
    my ( $i, $x, $y, $str, $o, @tmp );
    my @shipSize = qw( 5 4 3 3 2 );             # array of ship sizes
    my $sCount   = @shipSize;                   # ship count
    do {
        undef @tmp;                             # reset tmp array
        for ( $i = 0; $i < $sCount; $i++ ) {
            $o = ranO();                        # using random o value...
            $x = int( rand(10) );               # using random x and y values...
            $y = int( rand(10) );               # ...pushes into array...
            push ( @tmp, "@{[ placeShip( $x, $y, $shipSize[$i], $o ) ]}" );
        }
    } while ( !coordCheck(@tmp) );              # ...until unique and within grid range
    return @tmp;
}
sub coordCheck {                                # 0 <= coords <= 99 and no duplicates
  no warnings;
    my @allPos = map { split } @_;
    my ( $i, $j, $n, $len, $curr, $next );
    $n = @allPos;
    for ( $i = 0; $i < $n; $i++ ) {
        $curr = $allPos[$i];
        $len = length($curr);
        for ( $j = $i + 1; $j < $n; $j++ ) {
            $next = $allPos[$j];
            return 0 if ( $len > 2 || $curr == $next || $curr > 99 || $next > 99 );
        }
    }
    return 1;
}

