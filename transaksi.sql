-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: localhost    Database: transaksi
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `transaksi`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `transaksi` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `transaksi`;

--
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat` (
  `id_chat` int NOT NULL AUTO_INCREMENT,
  `id_penjualan` int NOT NULL,
  `pengirim` varchar(20) NOT NULL,
  `pesan` text NOT NULL,
  `tanggal` datetime NOT NULL,
  PRIMARY KEY (`id_chat`),
  KEY `id_penjualan` (`id_penjualan`),
  CONSTRAINT `chat_ibfk_1` FOREIGN KEY (`id_penjualan`) REFERENCES `penjualan` (`id_penjualan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat`
--

LOCK TABLES `chat` WRITE;
/*!40000 ALTER TABLE `chat` DISABLE KEYS */;
INSERT INTO `chat` VALUES (8,10,'pelanggan','Halo','2026-06-05 15:38:48'),(9,10,'pelanggan','p','2026-06-05 15:45:32'),(10,10,'pelanggan','anj','2026-06-05 15:49:24'),(11,10,'pelanggan','R','2026-06-05 15:52:26'),(12,10,'admin','m','2026-06-05 16:08:48'),(13,10,'pelanggan',',axmax','2026-06-05 16:09:15'),(15,10,'pelanggan',',s,,s','2026-06-06 01:20:20'),(16,10,'admin','test','2026-06-06 02:31:58'),(17,10,'admin','test','2026-06-06 02:40:40'),(20,10,'pelanggan','test','2026-06-06 02:55:38'),(21,10,'admin','fiq','2026-06-06 03:00:12'),(22,11,'pelanggan','test','2026-06-06 03:01:20'),(23,11,'admin','hallo','2026-06-06 03:01:26');
/*!40000 ALTER TABLE `chat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detail_penjualan`
--

DROP TABLE IF EXISTS `detail_penjualan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detail_penjualan` (
  `id_detail` int NOT NULL AUTO_INCREMENT,
  `id_penjualan` int DEFAULT NULL,
  `id_produk` int DEFAULT NULL,
  `qty` int DEFAULT NULL,
  `harga` int DEFAULT NULL,
  `subtotal` int DEFAULT NULL,
  `satuan` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'KG',
  PRIMARY KEY (`id_detail`),
  KEY `id_penjualan` (`id_penjualan`),
  KEY `id_produk` (`id_produk`),
  CONSTRAINT `detail_penjualan_ibfk_1` FOREIGN KEY (`id_penjualan`) REFERENCES `penjualan` (`id_penjualan`),
  CONSTRAINT `detail_penjualan_ibfk_2` FOREIGN KEY (`id_produk`) REFERENCES `produk` (`id_produk`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detail_penjualan`
--

LOCK TABLES `detail_penjualan` WRITE;
/*!40000 ALTER TABLE `detail_penjualan` DISABLE KEYS */;
INSERT INTO `detail_penjualan` VALUES (9,13,3,1,80000,80000,'KG'),(10,14,3,1,80000,80000,'KG'),(11,15,3,1,80000,80000,'KG'),(12,16,3,1,80000,80000,'KG'),(13,17,3,1,80000,80000,'KG'),(14,18,3,1,80000,80000,'KG'),(15,19,3,1,80000,80000,'KG'),(16,20,3,3,80000,240000,'KG');
/*!40000 ALTER TABLE `detail_penjualan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kategori`
--

DROP TABLE IF EXISTS `kategori`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kategori` (
  `id_kategori` int NOT NULL AUTO_INCREMENT,
  `nama_kategori` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `keterangan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id_kategori`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kategori`
--

LOCK TABLES `kategori` WRITE;
/*!40000 ALTER TABLE `kategori` DISABLE KEYS */;
INSERT INTO `kategori` VALUES (6,'Bawang Merah','Super');
/*!40000 ALTER TABLE `kategori` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `penjualan`
--

DROP TABLE IF EXISTS `penjualan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `penjualan` (
  `id_penjualan` int NOT NULL AUTO_INCREMENT,
  `tanggal` datetime DEFAULT NULL,
  `total` int DEFAULT NULL,
  `bayar` int DEFAULT NULL,
  `kembali` int DEFAULT NULL,
  `id_user` int DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'Menunggu Verifikasi',
  `metode_pembayaran` varchar(50) COLLATE utf8mb4_general_ci DEFAULT 'COD',
  `ongkir` int DEFAULT '0',
  `kota_tujuan` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '',
  PRIMARY KEY (`id_penjualan`),
  KEY `id_user` (`id_user`),
  CONSTRAINT `penjualan_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `penjualan`
--

LOCK TABLES `penjualan` WRITE;
/*!40000 ALTER TABLE `penjualan` DISABLE KEYS */;
INSERT INTO `penjualan` VALUES (10,'2026-06-05 15:37:29',95000,95000,0,3,'Menunggu Verifikasi','COD',0,''),(11,'2026-06-06 03:00:53',80000,80000,0,3,'Terverifikasi','COD',0,''),(12,'2026-06-06 04:59:11',80000,80000,0,3,'Menunggu Verifikasi','COD',0,''),(13,'2026-06-06 05:33:29',102000,102000,0,4,'Menunggu Verifikasi','COD',22000,'Kota Surabaya, Jawa Timur'),(14,'2026-06-06 05:36:27',92000,92000,0,4,'Menunggu Verifikasi','COD',12000,'Kota Jakarta Timur, DKI Jakarta'),(15,'2026-06-06 05:40:51',102000,102000,0,4,'Menunggu Verifikasi','COD',22000,'Kota Jakarta Barat, DKI Jakarta'),(16,'2026-06-06 08:00:42',1130000,1130000,0,4,'Menunggu Verifikasi','COD',1050000,'Kec. TAMAN BALI, BANGLI, BANGLI, BALI (80614)'),(17,'2026-06-06 08:21:40',94000,94000,0,4,'Menunggu Verifikasi','QRIS',14000,'Kec. DAHA, HU\'U, DOMPU, NUSA TENGGARA BARAT (NTB) (84271)'),(18,'2026-06-06 08:26:32',94000,94000,0,4,'Menunggu Verifikasi','COD',14000,'000000000000000000, Kec. ADU, HU\'U, DOMPU, NUSA TENGGARA BARAT (NTB) (84271)'),(19,'2026-06-06 08:29:26',94000,94000,0,4,'Menunggu Verifikasi','COD',14000,'qwertyui, Kec. CEMPI JAYA, HU\'U, DOMPU, NUSA TENGGARA BARAT (NTB) (84271)'),(20,'2026-06-06 08:36:12',285000,285000,0,4,'Menunggu Verifikasi','COD',45000,'000000000000000000, Kec. MATARAM TIMUR, MATARAM, MATARAM, NUSA TENGGARA BARAT (NTB) (83121)');
/*!40000 ALTER TABLE `penjualan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produk`
--

DROP TABLE IF EXISTS `produk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `produk` (
  `id_produk` int NOT NULL AUTO_INCREMENT,
  `nama_produk` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `id_kategori` int DEFAULT NULL,
  `harga` int DEFAULT NULL,
  `stok` int DEFAULT NULL,
  `berat` int DEFAULT '1000',
  `foto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  PRIMARY KEY (`id_produk`),
  KEY `id_kategori` (`id_kategori`),
  CONSTRAINT `produk_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produk`
--

LOCK TABLES `produk` WRITE;
/*!40000 ALTER TABLE `produk` DISABLE KEYS */;
INSERT INTO `produk` VALUES (3,'Bawang Merah Super',6,80000,9088,1000,'default.png');
/*!40000 ALTER TABLE `produk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stok`
--

DROP TABLE IF EXISTS `stok`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stok` (
  `id_stok` int NOT NULL AUTO_INCREMENT,
  `id_produk` int NOT NULL,
  `tanggal` date DEFAULT NULL,
  `stok_masuk` int DEFAULT NULL,
  `keterangan` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id_stok`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stok`
--

LOCK TABLES `stok` WRITE;
/*!40000 ALTER TABLE `stok` DISABLE KEYS */;
INSERT INTO `stok` VALUES (2,3,'2026-06-05',10000,'');
/*!40000 ALTER TABLE `stok` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tokens`
--

DROP TABLE IF EXISTS `tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_user` int NOT NULL,
  `token` varchar(64) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tokens`
--

LOCK TABLES `tokens` WRITE;
/*!40000 ALTER TABLE `tokens` DISABLE KEYS */;
INSERT INTO `tokens` VALUES (65,3,'610529c2002f11dfdcf4d28010fe36efa0712be8d571ed836d6bff2b2703a1eb','2026-06-06 11:58:28'),(82,1,'f810e53ffea8267fa18a154b0fcf3a2bee1657daacb7394a275a5e10cf00fb4f','2026-06-06 15:34:40'),(83,4,'5ec5304a86b59982dedbf6e1547811a24824c4592a69cf48ec9390ee809eb36c','2026-06-06 15:43:46');
/*!40000 ALTER TABLE `tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id_user` int NOT NULL AUTO_INCREMENT,
  `nama_user` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `level` enum('admin','kasir','pelanggan') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci DEFAULT '',
  `no_hp` varchar(20) COLLATE utf8mb4_general_ci DEFAULT '',
  `alamat` text COLLATE utf8mb4_general_ci,
  PRIMARY KEY (`id_user`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'Administrator','admin','0192023a7bbd73250516f069df18b500','admin','','',NULL),(2,'kasir1','kasir1','de28f8f7998f23ab4194b51a6029416f','kasir','','',NULL),(3,'alfiqram','alfiq','9b55d9d616eec7ba1e77a947c2e2ca6a','pelanggan','','000000','00000000'),(4,'rizky','rizky','96ba210301f08a2eb677df096c3d48fe','pelanggan','','000000000','000000000000000000');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-06 15:50:01
