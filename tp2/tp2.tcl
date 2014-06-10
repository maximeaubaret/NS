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
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Création du lien
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail

# Positionnement des noeuds
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

# Taille du buffer entre n2 et n3
$ns queue-limit $n2 $n3 10

# Création de l'agent TCP
set agent_tcp [new Agent/TCP]
$agent_tcp set class_ 1
$ns attach-agent $n0 $agent_tcp

# Création de l'agent UDP
set agent_udp [new Agent/UDP]
$agent_udp set class_ 2
$ns attach-agent $n1 $agent_udp

# Création de la source de trafic FTP
set ftp [new Application/FTP]
$ftp attach-agent $agent_tcp

# Création de la source de trafic CBR
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $agent_udp
$cbr set packetSize_ 1024
$cbr set rate_ 1mb

# Création de l'agent Sink
set agent_sink [new Agent/TCPSink]
$ns attach-agent $n3 $agent_sink
$ns connect $agent_tcp $agent_sink

# Création de l'agent Null
set agent_null [new Agent/UDP]
$ns attach-agent $n3 $agent_null
$ns connect $agent_udp $agent_null


# Appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"

$ns at 5.0 "finish"

# Exécuter la simulation
$ns run
