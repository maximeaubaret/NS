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

# Insérer votre propre code pour la création de la topologie
# et la définition des agents, des évènements...

# Appeler la procédure de terminaison après un temps t (ex t=5s)
$ns at 5.0 "finish"

# Exécuter la simulation
$ns run
