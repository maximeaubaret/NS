# Création d'une instance de l'obejt Simulator
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

# Création des nodes
set n0 [$ns node]
set n1 [$ns node]

# Création du lien
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

# Création de l'agent
set agent_udp [new Agent/UDP]
$ns attach-agent $n0 $agent_udp

# Création de la source de traffic
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $agent_udp
$cbr set packetSize_ 500b
$cbr set interval_ 0.005s

# Création de l'agent Null
set agent_null [new Agent/UDP]
$ns attach-agent $n1 $agent_null
$ns connect $agent_udp $agent_null

# Appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 1.0 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

# Exécuter la simulation
$ns run
