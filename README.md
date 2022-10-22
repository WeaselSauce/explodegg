# explode dot gg
Repo contains a few misc static assets as well as scripts that I used to power our OLD automated wipe and forced wipe detection system.  

These are no longer in use by my platform as I have moved away from a persistent LXC container setup (where the containers were stateful like a VM or bare metal server) to a new Docker based ephemeral container platform.  I'm also no longer implementing forced-wipe specific mechanics like I used to (e.g. Loadout, RP and Backpack wipes at forced wipe) so I no longer need the forced wipe components.

Making these work requires installation of php-cli and monodis packages on your Debian/Ubuntu based linux server, VM, or LXC container and adapting the scripts to fit your working directory structure.  It also assumes a Rust installation managed by LGSM.  Elements of this can be adapted to more modern Docker based solutions (e.g. the didstopia Docker image).  

My new setup using https://github.com/Didstopia/rust-server is dramatically simpler as the image updates Rust and Oxide every time the server restarts.  I require only a modified version of the server-restart.php script (and some Linux network trickery) to initiate automated restarts when oxide is out of date and I run a slightly modified version of autowipe.sh daily to handle automated wipes.  

