<?php
class OpsWorksDb {
  public $adapter, $database, $encoding, $host, $username, $password, $reconnect;

  public function __construct() {
    $this->adapter = '';
    $this->database = 'sequencer';
    $this->encoding = 'utf8';
    $this->host = 'localhost';
    $this->username = 'sequencer';
    $this->password = 'sequencer';
    $this->reconnect = 'false';
  }
}


?>
