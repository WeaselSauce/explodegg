#!/usr/bin/php
<?php

if (file_exists("/home/rustserver/countdown.lock"))
{
    // abort if countdown lock file already exists
    // so as not to enter a countdown loop
    exit(0);
}

// https://oxidemod.org/threads/php-web-rcon.22894/
// https://github.com/Textalk/websocket-php

require_once 'vendor/autoload.php';

use WebSocket\Client;

$ip = "xxx.xxx.xxx.xxx"; // server IP-address
$rcon_port = "28016"; // server RCON-port
$rcon_pass = "xxxxxxx"; // server RCON-password

$client = new Client("ws://{$ip}:{$rcon_port}/{$rcon_pass}");

$warn = array(
    'Identifier' => 0,
    'Message' => 'say "<color=red><size=20>AUTOMATED SERVER SOFTWARE UPDATE INCOMING</color></size>"', // command
    'Stacktrace' => '',
    'Type' => 3
);

$restart = array(
    'Identifier' => 0,
    'Message' => 'restart 300 "automated software update"', // command
    'Stacktrace' => '',
    'Type' => 3
);


try {
    // this is a really low effort way to check if oxide is up to date with latest version
    // but has worked just fine for YEARS so not gonna sweat it (grep'ing strings output for the latest oxide version)
    // we wrap this in a try block in case the shell commands / curl call throws an error (e.g. 500 error)
    $oxide_strings = shell_exec("/usr/bin/strings /home/rustserver/serverfiles/RustDedicated_Data/Managed/Oxide.Rust.dll");
    $latest_oxide = shell_exec("/usr/bin/curl -s https://api.github.com/repos/OxideMod/Oxide.Rust/releases/latest | grep tag_name | cut -d : -f 2 | awk '{print $1}'");
    $latest_oxide = str_replace('"', '', $latest_oxide);
    $latest_oxide = str_replace(',', '', $latest_oxide);
} catch (Exception $e) {
    exit(0);
}

// validate value of $latest_oxide
try {
  list($x, $y, $z) = explode(".", trim($latest_oxide));
}
catch (Exception $e) {
  print "failed - exception";
  exit(0);
}


// string should look like 2.33.293 in structure
if (ctype_digit($x) && ctype_digit($y) && ctype_digit($z))
{
        if (!strpos($oxide_strings,$latest_oxide))
        {
                // can't find latest oxide value in  oxide DLL
                // this means oxide is out of date.  issue restart
                // checker.sh will detect server down and issue commands
                // to update rust, oxide, and restart
                $client->send(json_encode($warn));
                $client->send(json_encode($restart));
                touch("/home/rustserver/countdown.lock"); // set countdown lock file to avoid endless loop
        } else {
                print "latest_oxide string matches.  no action taken";
        }

} else {
        print "latest_oxide string validation failed";
}

?>
