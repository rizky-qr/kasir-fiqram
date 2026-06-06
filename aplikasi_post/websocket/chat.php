<?php
// Tambahkan ini agar VS Code mengenali library Ratchet
require_once __DIR__ . '/vendor/autoload.php';

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

class Chat implements MessageComponentInterface {
    protected $clients = [];

    public function __construct() {
        echo "Server WebSocket Siap!\n";
    }

    public function onOpen(ConnectionInterface $conn) {
        // Gunakan spl_object_id() untuk mendapatkan ID unik tanpa memicu error VS Code
        $id = spl_object_id($conn);
        $this->clients[$id] = $conn;
        
        echo "Koneksi baru masuk: ({$id})\n";
    }

    public function onMessage(ConnectionInterface $from, $msg) {
        $id = spl_object_id($from);
        echo "Pesan diterima dari {$id}, mem-broadcast ke semua user...\n";
        
        // Kirim trigger ke semua client yang sedang terkoneksi
        foreach ($this->clients as $client) {
            $client->send($msg);
        }
    }

    public function onClose(ConnectionInterface $conn) {
        $id = spl_object_id($conn);
        
        // Hapus koneksi dari array saat user keluar/putus
        if (isset($this->clients[$id])) {
            unset($this->clients[$id]);
        }
        
        echo "Koneksi terputus: ({$id})\n";
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
        echo "Error: {$e->getMessage()}\n";
        $conn->close();
    }
}