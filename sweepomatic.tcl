#!/bin/sh

# sweep-o-matic
# (C) 1999 Kristian Wiklund <kw@dtek.chalmers.se>
# All rights reserved.
# This program may be distributed free-of-charge, providing that it
# is not modified IN ANY WAY.
# There are no warranties. Use it if you like, but do not expect it to
# give correct values or work as other minesweeper programs. 

# \
	exec wish $0 $*; exit

set top .

############################################################

# create a game board with height 'height', width 'width' and mines 'mines'
proc buildboard {p height width mines} {
    global minefield
    global know
    global pangbom
    global stats

    set pangbom 0

    set minefield(h) $height
    set minefield(w) $width
    set minefield(m) $mines
    set minefield(mh) -1
    set minefield(mw) -1

    set f [frame $p.f]
    pack $f

    set minefield(f) $f

    for {set i 0} {$i<$height} {incr i} {

	for {set j 0} {$j<$width} {incr j} {

	    set c [label $f.x${j}y${i} -relief raised -borderwidth 1 -width 1 -height 1 -background lightgrey]
	    grid $c -column $j -row $i -rowspan 1 -columnspan 1

	    set minefield($j,$i) 0
	    set know($j,$i) -2
	}
    }



    place_mines

}


proc clear_board { } {
    global minefield
    global know

    set f $minefield(f)
    set height $minefield(h)
    set width $minefield(w)

    set minefield(mh) -1
    set minefield(mw) -1

    for {set i 0} {$i<$height} {incr i} {

	for {set j 0} {$j<$width} {incr j} {

	    $f.x${j}y${i} configure -bg lightgrey -text ""

	    set minefield($j,$i) 0
	    set know($j,$i) -2
	}
    }

    place_mines

}

proc place_mines { } {
    global minefield
    global stats
    global minesleft

    set f $minefield(f)
    set height $minefield(h)
    set width $minefield(w)

    set stats(boxesleft) [expr $height*$width]
    set minesleft $minefield(m)

#    puts "placing mines"


    for {set i 0} {$i<$minefield(m)} {incr i} {
	
	set apa 1

	while {$apa} {
	    set x [expr int(rand()*$width)]
	    set y [expr int(rand()*$height)]

	    if {$minefield($x,$y) == 0} {
		set apa 0
		set minefield($x,$y) -1
#		$f.x${x}y${y} configure -bg red
	    }
	}
    }

#    puts "mines are placed"

    calculate_numbers
}



proc mis {x y} {
    global minefield

    if {($x<0) || ($y<0)} { 
	return 0
    }



    if {($x>=$minefield(w)) || ($y>=$minefield(h))} { 
	return 0
    }



    if {$minefield($x,$y) == -1} { 
	return 1
    }



    return 0

}

proc mines_near_square {x y} {
    global minefield

    if {$minefield($x,$y) == -1} {
	return -1
    }

    set tot 0

    for {set dx -1} {$dx<2} {incr dx} {
	for {set dy -1} {$dy<2} {incr dy} {

#	    puts "mis($x,$y) = [mis [expr $x+$dx] [expr $y+$dy]]"
	    set tot [expr $tot+[mis [expr $x+$dx] [expr $y+$dy]]]

	}

    }

    return $tot
}

# calculate how many mines are "visible" from each square
proc calculate_numbers { } {
    global minefield

#    puts "calculating numbers"

    set f $minefield(f)

    for {set x 0} {$x<$minefield(w)} {incr x} {
	for {set y 0} {$y<$minefield(h)} {incr y} {

	    set minefield($x,$y) [mines_near_square $x $y]	    
#	    if {$minefield($x,$y) > 0 } {
#		$f.x${x}y${y} configure -bg yellow
#	    }
	}
    }

#    puts "numbers are calculated"
#    dumpboard
#    dumpknow
}

proc dumpboard { } {
    global minefield

    for {set y 0} {$y<$minefield(h)} {incr y} {
	for {set x 0} {$x<$minefield(w)} {incr x} {

	    puts -nonewline "$minefield($x,$y) "
	    

	}
	puts " "
    }

}

proc dumpknow { } {
    global know
    global minefield

    for {set y 0} {$y<$minefield(h)} {incr y} {
	for {set x 0} {$x<$minefield(w)} {incr x} {

	    puts -nonewline "$know($x,$y) "
	    

	}
	puts " "
    }

}

# "field.tcl" generated a minefield, an array containing
# numbers. "-1" is a mine. a positive number tells how many
# mines are near that square.
# minefield(h) - height
# minefield(w) - width
# minefield(f) - frame

# a procedure to "autofill" from a guess.
# if we hit a "0" square, uncover squares until
# we find a rim of nonzero squares.
# update "knowledge", what the player knows.
# know(x,y) = -2 => knows nothing
#             -1 => we know it is a mine
#             >0 => we know that there are n mines near this square

proc autofill {x y} {
    global minefield
    global know
    global stats

# check limits first

    if {($x<0) || ($y<0)} {
	return
    }

    if {($x >= $minefield(w)) || ($y >= $minefield(h))} {
	return
    }

    if {$know($x,$y) != -2} {
	return
    }

    if {$minefield(mh) == -1} {
	
	set minefield(mw) $x
	set minefield(mh) $y
	
	set minefield(miw) $x
	set minefield(mih) $y
		
    } else {
	if {$minefield(mw) < $x} {
	    set minefield(mw) $x
	}
	
	if {$minefield(mh) < $y} {
	    set minefield(mh) $y
	}

	if {$minefield(miw) > $x} {
	    set minefield(miw) $x
	}

	if {$minefield(mih) > $y} {
	    set minefield(mih) $y
	}
    }

    set f $minefield(f)


    if {$minefield($x,$y) >= 0} {
	set know($x,$y) $minefield($x,$y)
    }

    $f.x${x}y${y} configure -bg blue

    set stats(boxesleft) [expr $stats(boxesleft)-1]


    if {$minefield($x,$y) == 0} {
	autofill $x [expr $y-1]
	autofill $x [expr $y+1]
	autofill [expr $x-1] $y
	autofill [expr $x+1] $y
    } else {
	$f.x${x}y${y} configure -text $minefield($x,$y) -foreground white
    }
}

proc guess {x y} {
    global minefield
    global pangbom
    global stats
    global labels

#    puts "player guessed $x $y"

    incr stats(clicks)
    incr stats(totclicks)

    $labels(clicks) configure -text $stats(clicks)


    if {$minefield($x,$y) == -1} {
#	bell
	set pangbom 1
	$minefield(f).x${x}y${y} configure -bg yellow
	update 
#idletasks

#	tk_messageBox -message "kaboom" -type ok


	incr stats(fail)

	return 1
    }

    autofill $x $y
    update 
#idletasks

    return 0
}






############################################################

proc ucsh {x y} {
    global minefield
    global know

    if {($x<0) || ($y<0)} { 
	return ""
    }

    if {($x>=$minefield(w)) || ($y>=$minefield(h))} { 
	return ""
    }

    if {$know($x,$y) == -2} {
	return "$x $y"
    }

    return ""
}

# unknown_close_to_square
# find the unknown squares close to (x,y)

proc unknown_close_to_square {x y} {
    global know

    set l ""

    for {set dx -1} {$dx<2} {incr dx} {
	for {set dy -1} {$dy<2} {incr dy} {
	    
	    set a [ucsh [expr $x+$dx] [expr $y+$dy]]
	    
	    if {[llength $a] > 0} {
		lappend l $a
	    }
	    
	}
    }
	
    return $l
}

proc mark_as_mine {x y} {
    global know
    global minefield
    global mines
    global stats
    global labels
    global minesleft

    set know($x,$y) -1
    set f $minefield(f)

    $f.x${x}y${y} configure -bg red

    incr mines
    set minesleft [expr $minesleft-1]

    incr stats(clicks)
    incr stats(totclicks)
    incr stats(totmines)

    $labels(clicks) configure -text $stats(clicks)


    $labels(mines) configure -text $mines
    set stats(boxesleft) [expr $stats(boxesleft)-1]
    update

    if {$minefield(mh) == -1} {

	set minefield(mw) $x
	set minefield(mh) $y

	set minefield(miw) $x
	set minefield(mih) $y
	

    } else {
	if {$minefield(mw) < $x} {
	    set minefield(mw) $x
	}

	if {$minefield(mh) < $y} {
	    set minefield(mh) $y
	}

	if {$minefield(miw) > $x} {
	    set minefield(miw) $x
	}

	if {$minefield(mih) > $y} {
	    set minefield(mih) $y
	}
    }
}

proc cmh {x y} {
    global minefield
    global know

    if {($x<0) || ($y<0)} { 
	return 0
    }

    if {($x>=$minefield(w)) || ($y>=$minefield(h))} { 
	return 0
    }

    if {$know($x,$y) == -1} {
	return 1
    }

    return 0
}

# count how many squares we _know_ are mines
# (based on know)
proc count_nearby_mines {x y} {

    set l 0

    for {set dx -1} {$dx<2} {incr dx} {
	for {set dy -1} {$dy<2} {incr dy} {
	    
	    set l [expr $l+[cmh [expr $x+$dx] [expr $y+$dy]]]
	}
    }
	
    return [list $l]

}

proc do_safe_guesses { } {
    global know
    global minefield

    set f 0


    if {$minefield(mw) == -1} {
	return
    }

    for {set x $minefield(miw)} {$x<=$minefield(mw)} {incr x} {
	for {set y $minefield(mih)} {$y<=$minefield(mh)} {incr y} {

	    set rem [expr $know($x,$y) - [count_nearby_mines $x $y]]
	    set l [unknown_close_to_square $x $y]
	    
#	    if {$know($x,$y) == -2} {
#		$minefield(f).x${x}y${y} configure -bg green
#	    }


	    # no mines left, but we have unknown squares
	    # click them!
	    if {($rem == 0) && ([llength $l] > 0)} {		
#		puts "sweeping $x $y ($l)"
		foreach i $l {
#		    puts $i
		    if {[guess [lindex $i 0] [lindex $i 1]] != 0} {
			# boom
			return 0

		    }
		}
		set f 1
	    } else {

		if {($rem > 0) && ($rem == [llength $l])} {
#		    puts "marking $x $y"
		    foreach i $l {
			mark_as_mine [lindex $i 0] [lindex $i 1]
		    }
		    set f 1
		}
		
		
	    }
	    
	    
	}
    }
    update
    return $f
}

# sweep: 
# clean the board of all safe guesses
proc sweep { } {
  
    while {[do_safe_guesses] == 1} { 
	update 
#idletasks
    }

}

# take_a_chance:
# make a (reasonably safe) guess on where no mine is located

proc take_a_chance { } {
    global minefield
    global know
    global stats
    global labels
    global minesleft
    global mines
    
    set tp [expr 1-(1.0*$minesleft)/$stats(boxesleft)]
    set sq "{-1 -1}"

    set l ""

    incr stats(guesses)

    for {set x 0} {$x<$minefield(w)} {incr x} {
	for {set y 0} {$y<$minefield(h)} {incr y} {

	    set u [unknown_close_to_square $x $y]
	    set m [count_nearby_mines $x $y]
	    set rem [expr $know($x,$y) - $m]

	    if {$know($x,$y) == -2} {
		lappend l "$x $y"
	    }

	    if {([llength $u] > 0) && ($rem > 0)} {

		# the probability for a square BEING a mine
		# is remaining amount of mines/# of unknown squares
		
		# hence, the probability of a nearby, unknown square
		# _not_being a bomb is
		set p [expr 1.0 - ((1.0*$rem)/[llength $u])]
		
		if {$p>$tp} {
		    set tp $p
		    set sq $u
		}
	    }

	}
    }

    if {$sq == "{-1 -1}"} {

	set i [expr int(rand()*[llength $l])]

	set t [lindex $l $i]

	set x [lindex $t 0]
	set y [lindex $t 1]

#	puts "taking a wild chance on $x $y"
#	puts "\"$l\""

	set stats(tgprob) [expr $stats(tgprob)+(1.0*$minesleft)/$stats(boxesleft)]
	
	#	puts "$minesleft $stats(boxesleft) $stats(tgprob)"
	
	
	if {[guess $x $y] == 1} {
	    incr stats(failguess)
	}

    } else {

#	puts "making a guess: $sq with probability for success $tp"
	
	set sq [lindex $sq [expr int(rand()*[llength $sq])]]
	
	set stats(tgprob) [expr $stats(tgprob)+(1.0-$tp)]

	if {[guess [lindex $sq 0] [lindex $sq 1]] == 1} {
	    incr stats(failguess)
	}
    }

    $labels(guesses) configure -text [format %2.2f [expr (1.0*$stats(failguess))/$stats(guesses)]]
    $labels(tprob) configure -text [format "%2.2f" [expr $stats(tgprob)/$stats(guesses)]]
    update
}

proc play_the_game { } {
    global pangbom
    global mines
    global minefield
    global stats
    global labels

#    puts "playing the game"


    if {$stats(games) > 0} {
	$labels(amines) configure -text [expr $stats(totmines)/$stats(games)]
	$labels(aclicks) configure -text [expr $stats(totclicks)/$stats(games)]
    }

    incr stats(games)



    set stats(clicks) 0
    set pangbom 0
    set mines 0
    $labels(mines) configure -text $mines

    while {$pangbom != 1} {
	take_a_chance
	sweep

	if {$minefield(m) == $mines} {
#	    puts "success"
	    incr stats(success)


	    return
	}
    }
}

proc board {f} {
    global h
    global w
    global m

    buildboard $f $h $w $m
}

proc save_statistics { } {
    global stats
    global env
    global minefield
    global h
    global w
    global m

    catch { file mkdir $env(HOME)/.sweepomatic }

    set fd [open $env(HOME)/.sweepomatic/${w}_${h}_${m} w]
    

    foreach i [array names stats] {

	puts $fd "set stats($i) $stats($i)"
	

    }


    close $fd
}

proc doit { } {
    global minefield
    global mines
    global labels
    global stats

    set f [frame .f]
    pack $f
    set c [frame $f.f1]
    pack $c -side top

    set f2 [frame $f.f2]
    pack $f2 -side top

    font create fetis -family Helvetica -size 16
    font create kleines -family Helvetica -size 8

    label $f2.l1 -font fetis -text "Success:"
    set labels(success) [label $f2.l2 -font fetis -text $stats(success)]
    pack $f2.l1 $f2.l2 -side left

    label $f2.l3 -font fetis -text "Fail:"
    set labels(fail) [label $f2.l4 -font fetis -text $stats(fail)]
    pack $f2.l3 $f2.l4 -side left

    set f3 [frame $f.f3]
    pack $f3 -side top

    label $f3.l1 -font fetis -text "Clicks:"
    set labels(clicks) [label $f3.l2 -font fetis -text $stats(clicks)]
    label $f3.l3 -font fetis -text "Avg:"

    if {$stats(games) > 0} {
	set labels(aclicks) [label $f3.l4 -font fetis -text [expr $stats(totclicks)/$stats(games)]]
    } else {
	set labels(aclicks) [label $f3.l4 -font fetis -text NA]
    }   
    pack $f3.l1 $f3.l2 $f3.l3 $f3.l4 -side left

    set f3 [frame $f.f5]
    pack $f3 -side top

    label $f3.l1 -font fetis -text "Guess prob:"
    if {$stats(guesses) > 0} {
	set labels(guesses) [label $f3.l2 -font fetis 	-text [format %2.2f [expr (1.0*$stats(failguess))/$stats(guesses)]]]
    } else {
	set labels(guesses) [label $f3.l2 -font fetis -text "NA"]
    }   
    
    label $f3.l3 -font fetis -text "Theor:"

    if {$stats(guesses) > 0} {
	set labels(tprob) [label $f3.l4 -font fetis -text [format "%2.2f" [expr $stats(tgprob)/$stats(guesses)]]]
    } else {
	set labels(tprob) [label $f3.l4 -font fetis -text NA]
    }


    pack $f3.l1 $f3.l2 $f3.l3 $f3.l4 -side left

    set f3 [frame $f.f4]
    pack $f3 -side top

    label $f3.l1 -font fetis -text "Mines:"
    set labels(mines) [label $f3.l2 -font fetis -text "0"]
    label $f3.l3 -font fetis -text "Avg:"
    if {$stats(games) > 0} {
	set labels(amines) [label $f3.l4 -font fetis -text [expr $stats(totmines)/$stats(games)]]
    } else {
	set labels(amines) [label $f3.l4 -font fetis -text NA]
    }
    pack $f3.l1 $f3.l2 $f3.l3 $f3.l4 -side left

    set f3 [frame $f.f8]
    pack $f3 -side top

    label $f3.l1 -font kleines -text "(C) 1999 K. Wiklund <kw@dtek.chalmers.se>"
    pack $f3.l1 -side top

    frame $c.f1
    pack $c.f1
    board $c.f1
    
    while {1} {
	set pangbom 0
	set mines 0
	update 
#idletasks
	play_the_game
	save_statistics

#	after 2000

	$labels(success) configure -text $stats(success)
	$labels(fail) configure -text $stats(fail)

#	puts "clearing board"
	clear_board
#	puts "board is clear"
    }
    
    
}

set stats(success) 0
set stats(fail) 0
set stats(games) 0

set stats(totclicks) 0
set stats(totmines) 0

set stats(guesses) 0
set stats(failguess) 0
set stats(tgprob) 0

if {[llength $argv] > 0} {

    if {[llength $argv] == 3} {

	set w [lindex $argv 0]
	set h [lindex $argv 1]
	set m [lindex $argv 2]

    } else {

	puts "USAGE: x-size y-size mines"
	exit

    }

} else {
    set w 30
    set h 16
    set m 99
}

if {[file exists $env(HOME)/.sweepomatic/${w}_${h}_${m}] == 1} {
    source $env(HOME)/.sweepomatic/${w}_${h}_${m}
}

set stats(clicks) 0

doit
