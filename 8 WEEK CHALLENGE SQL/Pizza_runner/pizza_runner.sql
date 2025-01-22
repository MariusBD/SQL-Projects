-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: pizza_runner
-- ------------------------------------------------------
-- Server version	8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `customer_orders`
--

DROP TABLE IF EXISTS `customer_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_orders` (
  `order_id` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `pizza_id` int DEFAULT NULL,
  `exclusions` varchar(4) DEFAULT NULL,
  `extras` varchar(4) DEFAULT NULL,
  `order_time` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_orders`
--

LOCK TABLES `customer_orders` WRITE;
/*!40000 ALTER TABLE `customer_orders` DISABLE KEYS */;
INSERT INTO `customer_orders` VALUES (1,101,1,'','','2020-01-01 17:05:02'),(2,101,1,'','','2020-01-01 18:00:52'),(3,102,1,'','','2020-01-02 22:51:23'),(3,102,2,'',NULL,'2020-01-02 22:51:23'),(4,103,1,'4','','2020-01-04 12:23:46'),(4,103,1,'4','','2020-01-04 12:23:46'),(4,103,2,'4','','2020-01-04 12:23:46'),(5,104,1,'null','1','2020-01-08 20:00:29'),(6,101,2,'null','null','2020-01-08 20:03:13'),(7,105,2,'null','1','2020-01-08 20:20:29'),(8,102,1,'null','null','2020-01-09 22:54:33'),(9,103,1,'4','1, 5','2020-01-10 10:22:59'),(10,104,1,'null','null','2020-01-11 17:34:49'),(10,104,1,'2, 6','1, 4','2020-01-11 17:34:49');
/*!40000 ALTER TABLE `customer_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza_names`
--

DROP TABLE IF EXISTS `pizza_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pizza_names` (
  `pizza_id` int DEFAULT NULL,
  `pizza_name` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_names`
--

LOCK TABLES `pizza_names` WRITE;
/*!40000 ALTER TABLE `pizza_names` DISABLE KEYS */;
INSERT INTO `pizza_names` VALUES (1,'Meatlovers'),(2,'Vegetarian');
/*!40000 ALTER TABLE `pizza_names` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza_recipes`
--

DROP TABLE IF EXISTS `pizza_recipes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pizza_recipes` (
  `pizza_id` int DEFAULT NULL,
  `toppings` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_recipes`
--

LOCK TABLES `pizza_recipes` WRITE;
/*!40000 ALTER TABLE `pizza_recipes` DISABLE KEYS */;
INSERT INTO `pizza_recipes` VALUES (1,'1, 2, 3, 4, 5, 6, 8, 10'),(2,'4, 6, 7, 9, 11, 12');
/*!40000 ALTER TABLE `pizza_recipes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pizza_toppings`
--

DROP TABLE IF EXISTS `pizza_toppings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pizza_toppings` (
  `topping_id` int DEFAULT NULL,
  `topping_name` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pizza_toppings`
--

LOCK TABLES `pizza_toppings` WRITE;
/*!40000 ALTER TABLE `pizza_toppings` DISABLE KEYS */;
INSERT INTO `pizza_toppings` VALUES (1,'Bacon'),(2,'BBQ Sauce'),(3,'Beef'),(4,'Cheese'),(5,'Chicken'),(6,'Mushrooms'),(7,'Onions'),(8,'Pepperoni'),(9,'Peppers'),(10,'Salami'),(11,'Tomatoes'),(12,'Tomato Sauce');
/*!40000 ALTER TABLE `pizza_toppings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runner_orders`
--

DROP TABLE IF EXISTS `runner_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runner_orders` (
  `order_id` int DEFAULT NULL,
  `runner_id` int DEFAULT NULL,
  `pickup_time` varchar(19) DEFAULT NULL,
  `distance` varchar(7) DEFAULT NULL,
  `duration` varchar(10) DEFAULT NULL,
  `cancellation` varchar(23) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runner_orders`
--

LOCK TABLES `runner_orders` WRITE;
/*!40000 ALTER TABLE `runner_orders` DISABLE KEYS */;
INSERT INTO `runner_orders` VALUES (1,1,'2020-01-01 18:15:34','20km','32 minutes',''),(2,1,'2020-01-01 19:10:54','20km','27 minutes',''),(3,1,'2020-01-03 00:12:37','13.4km','20 mins',NULL),(4,2,'2020-01-04 13:53:03','23.4','40',NULL),(5,3,'2020-01-08 21:10:57','10','15',NULL),(6,3,'null','null','null','Restaurant Cancellation'),(7,2,'2020-01-08 21:30:45','25km','25mins','null'),(8,2,'2020-01-10 00:15:02','23.4 km','15 minute','null'),(9,2,'null','null','null','Customer Cancellation'),(10,1,'2020-01-11 18:50:20','10km','10minutes','null');
/*!40000 ALTER TABLE `runner_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runners`
--

DROP TABLE IF EXISTS `runners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runners` (
  `runner_id` int DEFAULT NULL,
  `registration_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runners`
--

LOCK TABLES `runners` WRITE;
/*!40000 ALTER TABLE `runners` DISABLE KEYS */;
INSERT INTO `runners` VALUES (1,'2021-01-01'),(2,'2021-01-03'),(3,'2021-01-08'),(4,'2021-01-15');
/*!40000 ALTER TABLE `runners` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-08-25 19:34:16
