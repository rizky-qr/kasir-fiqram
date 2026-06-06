-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for transaksi
CREATE DATABASE IF NOT EXISTS `transaksi` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `transaksi`;

-- Dumping structure for table transaksi.chat
CREATE TABLE IF NOT EXISTS `chat` (
  `id_chat` int NOT NULL AUTO_INCREMENT,
  `id_penjualan` int NOT NULL,
  `pengirim` varchar(20) NOT NULL,
  `pesan` text NOT NULL,
  `tanggal` datetime NOT NULL,
  PRIMARY KEY (`id_chat`),
  KEY `id_penjualan` (`id_penjualan`),
  CONSTRAINT `chat_ibfk_1` FOREIGN KEY (`id_penjualan`) REFERENCES `penjualan` (`id_penjualan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table transaksi.chat: ~2 rows (approximately)
INSERT INTO `chat` (`id_chat`, `id_penjualan`, `pengirim`, `pesan`, `tanggal`) VALUES
	(8, 10, 'pelanggan', 'Halo', '2026-06-05 15:38:48'),
	(9, 10, 'pelanggan', 'p', '2026-06-05 15:45:32'),
	(10, 10, 'pelanggan', 'anj', '2026-06-05 15:49:24'),
	(11, 10, 'pelanggan', 'R', '2026-06-05 15:52:26'),
	(12, 10, 'admin', 'm', '2026-06-05 16:08:48'),
	(13, 10, 'pelanggan', ',axmax', '2026-06-05 16:09:15'),
	(15, 10, 'pelanggan', ',s,,s', '2026-06-06 01:20:20');

-- Dumping structure for table transaksi.detail_penjualan
CREATE TABLE IF NOT EXISTS `detail_penjualan` (
  `id_detail` int NOT NULL AUTO_INCREMENT,
  `id_penjualan` int DEFAULT NULL,
  `id_produk` int DEFAULT NULL,
  `qty` int DEFAULT NULL,
  `harga` int DEFAULT NULL,
  `subtotal` int DEFAULT NULL,
  `satuan` varchar(10) COLLATE utf8mb4_general_ci DEFAULT 'KG',
  PRIMARY KEY (`id_detail`),
  KEY `id_penjualan` (`id_penjualan`),
  KEY `id_produk` (`id_produk`),
  CONSTRAINT `detail_penjualan_ibfk_1` FOREIGN KEY (`id_penjualan`) REFERENCES `penjualan` (`id_penjualan`),
  CONSTRAINT `detail_penjualan_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table transaksi.detail_penjualan: ~0 rows (approximately)

-- Dumping structure for table transaksi.kategori
CREATE TABLE IF NOT EXISTS `kategori` (
  `id_kategori` int NOT NULL AUTO_INCREMENT,
  `nama_kategori` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `keterangan` text COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id_kategori`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table transaksi.kategori: ~1 rows (approximately)
INSERT INTO `kategori` (`id_kategori`, `nama_kategori`, `keterangan`) VALUES
	(6, 'Bawang Merah', 'Super');

-- Dumping structure for table transaksi.pelanggan
CREATE TABLE IF NOT EXISTS `pelanggan` (
  `id_pelanggan` int NOT NULL AUTO_INCREMENT,
  `nama_pelanggan` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `alamat` text COLLATE utf8mb4_general_ci,
  `telepon` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_pelanggan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table transaksi.pelanggan: ~0 rows (approximately)

-- Dumping structure for table transaksi.penjualan
CREATE TABLE IF NOT EXISTS `penjualan` (
  `id_penjualan` int NOT NULL AUTO_INCREMENT,
  `tanggal` datetime DEFAULT NULL,
  `total` int DEFAULT NULL,
  `bayar` int DEFAULT NULL,
  `kembali` int DEFAULT NULL,
  `id_user` int DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_general_ci DEFAULT 'Menunggu Verifikasi',
  PRIMARY KEY (`id_penjualan`),
  KEY `id_user` (`id_user`),
  CONSTRAINT `penjualan_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table transaksi.penjualan: ~0 rows (approximately)
INSERT INTO `penjualan` (`id_penjualan`, `tanggal`, `total`, `bayar`, `kembali`, `id_user`, `status`) VALUES
	(10, '2026-06-05 15:37:29', 95000, 95000, 0, 3, 'Menunggu Verifikasi');

-- Dumping structure for table transaksi.produk
CREATE TABLE IF NOT EXISTS `produk` (
  `id_produk` int NOT NULL AUTO_INCREMENT,
  `nama_produk` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `id_kategori` int DEFAULT NULL,
  `harga` int DEFAULT NULL,
  `stok` int DEFAULT NULL,
  `foto` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_produk`),
  KEY `id_kategori` (`id_kategori`),
  CONSTRAINT `produk_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table transaksi.produk: ~1 rows (approximately)
INSERT INTO `produk` (`id_produk`, `nama_produk`, `id_kategori`, `harga`, `stok`, `foto`) VALUES
	(3, 'Bawang Merah Super', 6, 80000, 9094, 'default.png');

-- Dumping structure for table transaksi.stok
CREATE TABLE IF NOT EXISTS `stok` (
  `id_stok` int NOT NULL AUTO_INCREMENT,
  `id_produk` int NOT NULL,
  `tanggal` date DEFAULT NULL,
  `stok_masuk` int DEFAULT NULL,
  `keterangan` text COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id_stok`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table transaksi.stok: ~0 rows (approximately)
INSERT INTO `stok` (`id_stok`, `id_produk`, `tanggal`, `stok_masuk`, `keterangan`) VALUES
	(2, 3, '2026-06-05', 10000, '');

-- Dumping structure for table transaksi.tokens
CREATE TABLE IF NOT EXISTS `tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_user` int NOT NULL,
  `token` varchar(64) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table transaksi.tokens: ~1 rows (approximately)
INSERT INTO `tokens` (`id`, `id_user`, `token`, `created_at`) VALUES
	(51, 3, '9b0762d9c59716dab22d212fb94485be00082fbcc5bb54de6dc1fabdf42b6951', '2026-06-06 09:20:05');

-- Dumping structure for table transaksi.user
CREATE TABLE IF NOT EXISTS `user` (
  `id_user` int NOT NULL AUTO_INCREMENT,
  `nama_user` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `level` enum('admin','kasir','pelanggan') COLLATE utf8mb4_general_ci NOT NULL,
  PRIMARY KEY (`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Dumping data for table transaksi.user: ~0 rows (approximately)
INSERT INTO `user` (`id_user`, `nama_user`, `username`, `password`, `level`) VALUES
	(1, 'Administrator', 'admin', '0192023a7bbd73250516f069df18b500', 'admin'),
	(2, 'kasir1', 'kasir1', 'de28f8f7998f23ab4194b51a6029416f', 'kasir'),
	(3, 'alfiqram', 'alfiq', '9b55d9d616eec7ba1e77a947c2e2ca6a', 'pelanggan');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
