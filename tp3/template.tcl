# Définir les options
...

# Création d'une instance du simulateur et des différents fichiers trace
set ns [new Simulator]
set tracefd [open simple.tr w]
set windowVsTime2 [open win.tr w]
set namtrace [open simwrls.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# Création de la topographie
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

#
# Création des noeuds mobiles
#

# Configuration d'un noeud mobile
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channelType $val(chan) \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace ON

# Déclaration des noeuds
...

# Définition de la position initiale de chaque noeur en attribuant les valeurs correspondantes aux attributes X_ ; Y_ ; Z_ d'un noeur mobile.
...

# Génération des mouvements des fifférents noeuds
$ns at temps "$node setdest 250.0 250.0 3.0"

# Partie indépendante de la partie sans fil : agents, trafic...
...

# Procédure d'enregistrement
proc plotWindo {tcpSource file} {
  global ns
  set time 0.01
  set now [$ns now]
  set cwnd [$tcpSource set cwnd_]
  puts $file "$now $cwnd"
  $ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 10.1 "plotWindow $tcp $windowVsTime2"

# Définition de la position initiale des différents noeuds dans nam
...
# Définition de la taille d'un noeud dans nam (30)
$ns initial_node_pos $node 30
...

# Informer chaque noeud de la fin de simulation
for {set i 0} .... {
  $ns at temps "$node reset";
}

# Finir la simulation et l'utilisation de nam
$ns at temps "$ns nam-end-wireless temps"
$ns at temps "stop"
$ns at 150.01 "puts \"fin de la simulation\" ; $ns halt"

proc stop {} {
  global ns tracefd namtrace
  $ns flush-trace
  close $tracefd
  close $namtrace
}

# Exécution de la simulation
$ns run
