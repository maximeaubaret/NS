set ns [new Simulator]

set nf [open out.nam w]
$ns namtrace-all $nf

proc finish {} {
  global ns nf qEC qCS
  $ns flush-trace

  # print useful infos
  $qEC printPolicyTable
  $qEC printPolicerTable
  $qCS printPHBTable
  $qEC printStats

  # fermer le fichier trace
  close $nf
  # exécuter le nam avec en entrée le fichier trace
  # exec nam out.nam &
  exit 0
}

# Variables
set cir1 1000000
set cir2 500000
set cbs 500

set T_min_RED1 4
set T_max_RED1 10
set Proba_Perte1 0.1

set T_min_RED2 2
set T_max_RED2 5
set Proba_Perte2 0.5

# Couleurs
$ns color 1 Blue
$ns color 2 Red

# Création des nodes
set c1 [$ns node] ;# Client #1
set c2 [$ns node] ;# Client #2
set e [$ns node] ;# Edge Router
set c [$ns node] ;# Core Router
set s [$ns node] ;# Server

# Création des liens
$ns simplex-link $c1 $e 1.5Mb 2ms DropTail
$ns simplex-link $c2 $e 1.5Mb 2ms DropTail
# $ns simplex-link $e $c 1.5Mb 2ms DropTail
# $ns simplex-link $c $s 1.5Mb 2ms DropTail
$ns simplex-link $e $c 1.5Mb 2ms dsRED/edge
$ns simplex-link $c $s 1.5Mb 2ms dsRED/core

$ns simplex-link-op $c1 $e orient right-down
$ns simplex-link-op $c2 $e orient right-up
$ns simplex-link-op $e $c orient right
$ns simplex-link-op $c $s orient right

# Agents
set agent_udp_c1 [new Agent/UDP]
$agent_udp_c1 set class_ 1
$ns attach-agent $c1 $agent_udp_c1

set agent_udp_c2 [new Agent/UDP]
$agent_udp_c2 set class_ 2
$ns attach-agent $c2 $agent_udp_c2

set agent_null_s_c1 [new Agent/Null]
$ns attach-agent $s $agent_null_s_c1
$ns connect $agent_udp_c1 $agent_null_s_c1

set agent_null_s_c2 [new Agent/Null]
$ns attach-agent $s $agent_null_s_c2
$ns connect $agent_udp_c2 $agent_null_s_c2

# Sources de trafic
set cbr_c1 [new Application/Traffic/CBR]
$cbr_c1 attach-agent $agent_udp_c1
$cbr_c1 set rate_ [expr $cir1 + 10000]

set cbr_c2 [new Application/Traffic/CBR]
$cbr_c2 attach-agent $agent_udp_c2
$cbr_c2 set rate_ $cir2

# Configuration DiffServ
set qEC [[$ns link $e $c] queue]

$qEC meanPktSize 210

$qEC set numQueues_ 1
$qEC setNumPrec 2

$qEC addPolicyEntry [$c1 id] [$s id] TokenBucket 10 $cir1 $cbs
# $qEC addPolicyEntry [$c2 id] [$s id] TokenBucket 20 $cir2 $cbs
$qEC addPolicyEntry [$c2 id] [$s id] Null 20 ;# $cir2 $cbs

$qEC addPolicerEntry TokenBucket 10 11
# $qEC addPolicerEntry TokenBucket 20 21
$qEC addPolicerEntry Null 20

$qEC addPHBEntry 10 0 0
$qEC addPHBEntry 11 0 1
$qEC addPHBEntry 20 0 1

$qEC configQ 0 0 $T_min_RED1 $T_max_RED1 $Proba_Perte1
$qEC configQ 0 1 $T_min_RED2 $T_max_RED2 $Proba_Perte2

# CS
set qCS [[$ns link $c $s] queue]

$qCS meanPktSize 210
$qCS set numQueues_ 1
$qCS setNumPrec 2

$qCS addPHBEntry 10 0 0
$qCS addPHBEntry 11 0 1
$qCS addPHBEntry 20 0 1

$qCS configQ 0 0 $T_min_RED1 $T_max_RED1 $Proba_Perte1
$qCS configQ 0 1 $T_min_RED2 $T_max_RED2 $Proba_Perte2

# Scenario
$ns at 0.0 "$cbr_c1 start"
$ns at 0.0 "$cbr_c2 start"
$ns at 5.0 "finish"

$ns run
