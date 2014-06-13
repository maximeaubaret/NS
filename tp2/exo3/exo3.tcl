set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
  global ns nf
  $ns flush-trace

  # fermer le fichier trace
  close $nf
  # exécuter le nam avec en entrée le fichier trace
  exec nam out.nam &
  exit 0
}

# Variables
set cir0 1000000
set cbs0 10000
set cir1 1000000
set cbs1 10000

set rate0 4000000
set rate1 4000000

set T_min_RED1 20
set T_max_RED1 40
set Proba_Perte1 0.02

set T_min_RED2 10
set T_max_RED2 20
set Proba_Perte2 0.01

set packetSize 1000

set testTime 85

# Couleurs
$ns color 1 Blue
$ns color 2 Red

# Création des nodes
set S1 [$ns node] ;# Client #1
set S2 [$ns node] ;# Client #2
set E1 [$ns node] ;# Edge Router 1
set CORE [$ns node] ;# Core Router
set E2 [$ns node] ;# Edge Router 2
set DEST [$ns node] ;# Destination

# Création des liens
$ns duplex-link $S1 $E1 10Mb 5ms DropTail
$ns duplex-link $S2 $E1 10Mb 5ms DropTail
$ns duplex-link $E1 $CORE 10Mb 5ms dsRED/edge
$ns duplex-link $CORE $E2 5Mb 5ms dsRED/core
$ns duplex-link $E2 $DEST 10Mb 5ms DropTail
# $ns duplex-link $E1 $CORE 10Mb 5ms DropTail
# $ns duplex-link $CORE $E2 10Mb 5ms DropTail
# $ns duplex-link $E2 $DEST 10Mb 5ms DropTail

$ns duplex-link-op $S1 $E1 orient right-down
$ns duplex-link-op $S2 $E1 orient right-up
$ns duplex-link-op $E1 $CORE orient right
$ns duplex-link-op $CORE $E2 orient right
$ns duplex-link-op $E2 $DEST orient right

# Agents
set agent_udp_s1 [new Agent/UDP]
$agent_udp_s1 set class_ 1
$ns attach-agent $S1 $agent_udp_s1

set agent_udp_s2 [new Agent/UDP]
$agent_udp_s2 set class_ 2
$ns attach-agent $S2 $agent_udp_s2

set agent_null_dest_s1 [new Agent/Null]
$ns attach-agent $DEST $agent_null_dest_s1
$ns connect $agent_udp_s1 $agent_null_dest_s1

set agent_null_dest_s2 [new Agent/Null]
$ns attach-agent $DEST $agent_null_dest_s2
$ns connect $agent_udp_s2 $agent_null_dest_s2

# Sources de trafic
set cbr_s1 [new Application/Traffic/CBR]
$cbr_s1 attach-agent $agent_udp_s1
$cbr_s1 set packetSize_ $packetSize
$cbr_s1 set rate_ $rate0

set cbr_s2 [new Application/Traffic/CBR]
$cbr_s2 attach-agent $agent_udp_s2
$cbr_s2 set packetSize_ $packetSize
$cbr_s2 set rate_ $rate1

# Diffserv: E1 -> CORE
set qE1C [[$ns link $E1 $CORE] queue]
$qE1C meanPktSize $packetSize

$qE1C set numQueues_ 1
$qE1C setNumPrec 2

$qE1C addPolicyEntry [$S1 id] [$DEST id] TokenBucket 10 $cir0 $cbs0
$qE1C addPolicyEntry [$S2 id] [$DEST id] TokenBucket 20 $cir1 $cbs1

$qE1C addPolicerEntry TokenBucket 10 11
$qE1C addPolicerEntry TokenBucket 20 21

$qE1C addPHBEntry 10 0 0
$qE1C addPHBEntry 11 0 1
$qE1C addPHBEntry 20 1 0
$qE1C addPHBEntry 21 1 1

$qE1C configQ 0 0 $T_min_RED1 $T_max_RED1 $Proba_Perte1
$qE1C configQ 0 1 $T_min_RED2 $T_max_RED2 $Proba_Perte2

# DiffServ: CORE -> E1
set qCE1 [[$ns link $CORE $E1] queue]
$qCE1 meanPktSize $packetSize

$qCE1 set numQueues_ 1
$qCE1 setNumPrec 2

$qCE1 addPHBEntry 10 0 0
$qCE1 addPHBEntry 11 0 1
$qCE1 addPHBEntry 20 0 0
$qCE1 addPHBEntry 21 0 1

$qCE1 configQ 0 0 $T_min_RED1 $T_max_RED1 $Proba_Perte1
$qCE1 configQ 0 1 $T_min_RED2 $T_max_RED2 $Proba_Perte2

# DiffServ: E2 -> CORE
set qE2C [[$ns link $E2 $CORE] queue]
$qE2C meanPktSize $packetSize

$qE2C set numQueues_ 1
$qE2C setNumPrec 2

$qE2C addPHBEntry 10 0 0
$qE2C addPHBEntry 11 0 1
$qE2C addPHBEntry 20 0 0
$qE2C addPHBEntry 21 0 1

$qE2C configQ 0 0 $T_min_RED1 $T_max_RED1 $Proba_Perte1
$qE2C configQ 0 1 $T_min_RED2 $T_max_RED2 $Proba_Perte2

# DiffServ: CORE -> E2
set qCE2 [[$ns link $CORE $E2] queue]
$qCE2 meanPktSize $packetSize

$qCE2 set numQueues_ 2
$qCE2 setNumPrec 2

$qCE2 addPHBEntry 10 0 0
$qCE2 addPHBEntry 11 0 1
$qCE2 addPHBEntry 20 1 0
$qCE2 addPHBEntry 21 1 1

$qCE2 configQ 0 0 $T_min_RED1 $T_max_RED1 $Proba_Perte1
$qCE2 configQ 0 1 $T_min_RED2 $T_max_RED2 $Proba_Perte2

# Scenario
$ns at 0.0 "$cbr_s1 start"
$ns at 0.0 "$cbr_s2 start"

$ns at 20.0 "$qE1C printStats"
# $ns at 20.0 "$qE2C printStats"
# $ns at 20.0 "$qCE1 printStats"
$ns at 20.0 "$qCE2 printStats"

$ns at 40.0 "$qE1C printStats"
# $ns at 40.0 "$qE2C printStats"
# $ns at 40.0 "$qCE1 printStats"
$ns at 40.0 "$qCE2 printStats"

$ns at 60.0 "$qE1C printStats"
# $ns at 60.0 "$qE2C printStats"
# $ns at 60.0 "$qCE1 printStats"
$ns at 60.0 "$qCE2 printStats"

$ns at 80.0 "$qE1C printStats"
# $ns at 80.0 "$qE2C printStats"
# $ns at 80.0 "$qCE1 printStats"
$ns at 80.0 "$qCE2 printStats"

$ns at $testTime "finish"

$ns run
