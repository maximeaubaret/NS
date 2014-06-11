# Création d'une instance de l'objet Simulator
set ns [new Simulator]

# Ouvrir le fichier trace pour nam
set nf [open out.nam w]
$ns namtrace-all $nf

# Définir la procédure de terminaison de la simulation
proc finish {} {
  global ns nf
  $ns flush-trace
  # fermer le fichier trace
  close $nf
  # exécuter le nam avec en entrée le fichier trace
  exec nam out.nam &
  exit 0
}

# Coloration des flux
$ns color 1 Blue
$ns color 2 Red

# Création des nodes
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]

# Création des liens
$ns duplex-link $n1 $n3 10Mb 10ms DropTail
$ns duplex-link-op $n1 $n3 orient right-down
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns duplex-link-op $n2 $n3 orient left-down
$ns duplex-link $n3 $n4 10Mb 10ms DropTail
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link $n4 $n6 10Mb 10ms DropTail
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link $n5 $n3 10Mb 10ms DropTail
$ns duplex-link-op $n5 $n3 orient right-up
$ns duplex-link $n5 $n8 10Mb 10ms DropTail
$ns duplex-link-op $n5 $n8 orient right-down
$ns duplex-link $n6 $n7 10Mb 10ms DropTail
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link $n7 $n8 10Mb 10ms DropTail
$ns duplex-link-op $n7 $n8 orient left

# Définition des agents
set agent_udp_n1 [new Agent/UDP]
$agent_udp_n1 set class_ 1
$ns attach-agent $n1 $agent_udp_n1

set agent_udp_n2 [new Agent/UDP]
$agent_udp_n2 set class_ 2
$ns attach-agent $n2 $agent_udp_n2

set agent_null_n8 [new Agent/Null]
$ns attach-agent $n8 $agent_null_n8
$ns connect $agent_udp_n1 $agent_null_n8
$ns connect $agent_udp_n2 $agent_null_n8

$ns rtproto DV

# Définition des générateurs de trafic
set cbr_n1 [new Application/Traffic/CBR]
$cbr_n1 attach-agent $agent_udp_n1
$cbr_n1 set packetSize_ 500
$cbr_n1 set interval_ 0.005s

set cbr_n2 [new Application/Traffic/CBR]
$cbr_n2 attach-agent $agent_udp_n2
$cbr_n2 set packetSize_ 500
$cbr_n2 set interval_ 0.005s

$ns at 1.0 "$cbr_n1 start"
$ns at 2.0 "$cbr_n2 start"
$ns at 6.0 "$cbr_n2 stop"
$ns at 7.0 "$cbr_n1 stop"

# Arret des liens
$ns rtmodel-at 4 down $n8 $n5
$ns rtmodel-at 5 up $n8 $n5

$ns at 8.0 "finish"

# Exécuter la simulation
$ns run
