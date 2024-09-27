-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 11, 2024 at 08:19 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `stratego`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `clean_board` ()   BEGIN
	REPLACE INTO board SELECT * FROM board_empty;
    UPDATE `players` set token=null, `user_name` = NULL;
    UPDATE `game_status` set `status`='not active', `p_turn`=null, `result`=null;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `move_piece` (`x1` TINYINT, `y1` TINYINT, `x2` TINYINT, `y2` TINYINT)   BEGIN
	
    DECLARE p_color enum('B','R');
    DECLARE p enum('Flag','Bomb','Spy','Scout','Miner','Sergeant','Lieutenant','Captain','Major','Colonel','General','Marshal');
    DECLARE defender_p enum('Flag','Bomb','Spy','Scout','Miner','Sergeant','Lieutenant','Captain','Major','Colonel','General','Marshal');
    DECLARE p_strength INT;
    DECLARE defender_p_strength INT;
    DECLARE defender_p_color enum('B','R');
    
    
    
    
	SELECT piece,piece_color INTO p, p_color
	FROM `board` WHERE x=x1 AND y=y1;
    
    SELECT piece, piece_color INTO defender_p, defender_p_color
    FROM board WHERE x=x2 AND y=y2;
    
    SET p_strength= CASE p
    WHEN 'Marshal' THEN 10
    WHEN 'General' THEN 9
    WHEN 'Colonel' THEN 8
    WHEN 'Major' THEN 7
    WHEN 'Captain' THEN 6
    WHEN 'Lieutenant' THEN 5
    WHEN 'Sergeant' THEN 4
    WHEN 'Miner' THEN 3
    WHEN 'Scout' THEN 2
    WHEN 'Spy' THEN 1
    WHEN 'Bomb' THEN 11
	ELSE 0
    END;
    
    SET defender_p_strength= CASE defender_p
    WHEN 'Marshal' THEN 10
    WHEN 'General' THEN 9
    WHEN 'Colonel' THEN 8
    WHEN 'Major' THEN 7
    WHEN 'Captain' THEN 6
    WHEN 'Lieutenant' THEN 5
    WHEN 'Sergeant' THEN 4
    WHEN 'Miner' THEN 3
    WHEN 'Scout' THEN 2
    WHEN 'Spy' THEN 1
    WHEN 'Bomb' THEN 11
    ELSE 0
    END;
    
    

	IF  defender_p = 0 THEN
		UPDATE board
		SET piece=p, piece_color=p_color
		WHERE x=x2 AND y=y2;
    
		UPDATE board
		SET piece_color=NULL,piece=NULL
		WHERE x=x1 AND y=y1;
        
	ELSEIF defender_p='Flag' THEN
		UPDATE game_status SET status='ended', p_turn=NULL, result=p_color;
    
    	ELSEIF p='Spy' AND defender_p='Marshal' THEN
		UPDATE board SET piece=p, piece_color=p_color WHERE x=x2 AND y=y2;
		UPDATE board SET piece=NULL, piece_color=NULL WHERE x=x1 AND y=y1;
        
	ELSEIF p='Miner' AND defender_p='Bomb' THEN
		UPDATE board SET piece=p, piece_color=p_color WHERE x=x2 AND y=y2;
		UPDATE board SET piece=NULL, piece_color=NULL WHERE x=x1 AND y=y1;
        
	ELSEIF p_strength = defender_p_strength THEN
		UPDATE board SET piece=NULL, piece_color=NULL WHERE x=x1 AND y=y1;
		UPDATE board SET piece=NULL, piece_color=NULL WHERE x=x2 AND y=y2;
        
	ELSEIF p_strength > defender_p_strength THEN
		UPDATE board SET piece=p, piece_color=p_color WHERE x=x2 AND y=y2;
		UPDATE board SET piece=NULL, piece_color=NULL WHERE x=x1 AND y=y1;
	ELSE 
		UPDATE board SET piece=NULL, piece_color=NULL WHERE x=x1 AND y=y1;
	END IF;
    
    UPDATE game_status SET p_turn=if(p_turn='B','R','B');
	
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `board`
--

CREATE TABLE `board` (
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece_color` enum('B','R') DEFAULT NULL,
  `piece` enum('Flag','Bomb','Spy','Scout','Miner','Sergeant','Lieutenant','Captain','Major','Colonel','General','Marshal') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `board`
--

INSERT INTO `board` (`x`, `y`, `piece_color`, `piece`) VALUES
(1, 1, 'B', 'Miner'),
(1, 2, 'B', 'Scout'),
(1, 3, 'B', 'Scout'),
(1, 4, 'B', 'Lieutenant'),
(1, 5, NULL, NULL),
(1, 6, NULL, NULL),
(1, 7, 'R', 'Lieutenant'),
(1, 8, 'R', 'Scout'),
(1, 9, 'R', 'Bomb'),
(1, 10, 'R', 'Sergeant'),
(2, 1, 'B', 'Captain'),
(2, 2, 'B', 'Miner'),
(2, 3, 'B', 'Colonel'),
(2, 4, 'B', 'Scout'),
(2, 5, NULL, NULL),
(2, 6, NULL, NULL),
(2, 7, 'R', 'Sergeant'),
(2, 8, 'R', 'Lieutenant'),
(2, 9, 'R', 'Captain'),
(2, 10, 'R', 'Bomb'),
(3, 1, 'B', 'Scout'),
(3, 2, 'B', 'Captain'),
(3, 3, 'B', 'Bomb'),
(3, 4, 'B', 'Bomb'),
(3, 5, NULL, NULL),
(3, 6, NULL, NULL),
(3, 7, 'R', 'Captain'),
(3, 8, 'R', 'Colonel'),
(3, 9, 'R', 'Major'),
(3, 10, 'R', 'Miner'),
(4, 1, 'B', 'Lieutenant'),
(4, 2, 'B', 'Major'),
(4, 3, 'B', 'Sergeant'),
(4, 4, NULL, NULL),
(4, 5, 'B', 'Marshal'),
(4, 6, NULL, NULL),
(4, 7, 'R', 'General'),
(4, 8, 'R', 'Spy'),
(4, 9, 'R', 'Bomb'),
(4, 10, 'R', 'Miner'),
(5, 1, 'B', 'Scout'),
(5, 2, 'B', 'Sergeant'),
(5, 3, 'B', 'Bomb'),
(5, 4, 'B', 'Lieutenant'),
(5, 5, NULL, NULL),
(5, 6, NULL, NULL),
(5, 7, 'R', 'Scout'),
(5, 8, 'R', 'Scout'),
(5, 9, 'R', 'Miner'),
(5, 10, 'R', 'Bomb'),
(6, 1, 'B', 'Miner'),
(6, 2, 'B', 'Spy'),
(6, 3, 'B', 'General'),
(6, 4, 'B', 'Captain'),
(6, 5, NULL, NULL),
(6, 6, NULL, NULL),
(6, 7, 'R', 'Scout'),
(6, 8, 'R', 'Scout'),
(6, 9, 'R', 'Major'),
(6, 10, 'R', 'Miner'),
(7, 1, 'B', 'Scout'),
(7, 2, 'B', 'Flag'),
(7, 3, 'B', 'Bomb'),
(7, 4, 'B', 'Major'),
(7, 5, NULL, NULL),
(7, 6, NULL, NULL),
(7, 7, 'R', 'Marshal'),
(7, 8, 'R', 'Colonel'),
(7, 9, 'R', 'Major'),
(7, 10, 'R', 'Flag'),
(8, 1, 'B', 'Sergeant'),
(8, 2, 'B', 'Scout'),
(8, 3, 'B', 'Bomb'),
(8, 4, 'B', 'Bomb'),
(8, 5, NULL, NULL),
(8, 6, NULL, NULL),
(8, 7, 'R', 'Captain'),
(8, 8, 'R', 'Scout'),
(8, 9, 'R', 'Captain'),
(8, 10, 'R', 'Miner'),
(9, 1, 'B', 'Miner'),
(9, 2, 'B', 'Major'),
(9, 3, 'B', 'Miner'),
(9, 4, 'B', 'Colonel'),
(9, 5, NULL, NULL),
(9, 6, 'R', 'Sergeant'),
(9, 7, NULL, NULL),
(9, 8, 'R', 'Lieutenant'),
(9, 9, 'R', 'Scout'),
(9, 10, 'R', 'Bomb'),
(10, 1, 'B', 'Captain'),
(10, 2, 'B', 'Scout'),
(10, 3, 'B', 'Lieutenant'),
(10, 4, 'B', 'Sergeant'),
(10, 5, NULL, NULL),
(10, 6, NULL, NULL),
(10, 7, 'R', 'Lieutenant'),
(10, 8, 'R', 'Scout'),
(10, 9, 'R', 'Bomb'),
(10, 10, 'R', 'Sergeant');

-- --------------------------------------------------------

--
-- Table structure for table `board_empty`
--

CREATE TABLE `board_empty` (
  `x` tinyint(1) NOT NULL,
  `y` tinyint(1) NOT NULL,
  `piece_color` enum('B','R') DEFAULT NULL,
  `piece` enum('Flag','Bomb','Spy','Scout','Miner','Sergeant','Lieutenant','Captain','Major','Colonel','General','Marshal') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `board_empty`
--

INSERT INTO `board_empty` (`x`, `y`, `piece_color`, `piece`) VALUES
(1, 1, 'B', 'Miner'),
(1, 2, 'B', 'Scout'),
(1, 3, 'B', 'Scout'),
(1, 4, 'B', 'Lieutenant'),
(1, 5, NULL, NULL),
(1, 6, NULL, NULL),
(1, 7, 'R', 'Lieutenant'),
(1, 8, 'R', 'Scout'),
(1, 9, 'R', 'Bomb'),
(1, 10, 'R', 'Sergeant'),
(2, 1, 'B', 'Captain'),
(2, 2, 'B', 'Miner'),
(2, 3, 'B', 'Colonel'),
(2, 4, 'B', 'Scout'),
(2, 5, NULL, NULL),
(2, 6, NULL, NULL),
(2, 7, 'R', 'Sergeant'),
(2, 8, 'R', 'Lieutenant'),
(2, 9, 'R', 'Captain'),
(2, 10, 'R', 'Bomb'),
(3, 1, 'B', 'Scout'),
(3, 2, 'B', 'Captain'),
(3, 3, 'B', 'Bomb'),
(3, 4, 'B', 'Bomb'),
(3, 5, NULL, NULL),
(3, 6, NULL, NULL),
(3, 7, 'R', 'Captain'),
(3, 8, 'R', 'Colonel'),
(3, 9, 'R', 'Major'),
(3, 10, 'R', 'Miner'),
(4, 1, 'B', 'Lieutenant'),
(4, 2, 'B', 'Major'),
(4, 3, 'B', 'Sergeant'),
(4, 4, 'B', 'Marshal'),
(4, 5, NULL, NULL),
(4, 6, NULL, NULL),
(4, 7, 'R', 'General'),
(4, 8, 'R', 'Spy'),
(4, 9, 'R', 'Bomb'),
(4, 10, 'R', 'Miner'),
(5, 1, 'B', 'Scout'),
(5, 2, 'B', 'Sergeant'),
(5, 3, 'B', 'Bomb'),
(5, 4, 'B', 'Lieutenant'),
(5, 5, NULL, NULL),
(5, 6, NULL, NULL),
(5, 7, 'R', 'Scout'),
(5, 8, 'R', 'Scout'),
(5, 9, 'R', 'Miner'),
(5, 10, 'R', 'Bomb'),
(6, 1, 'B', 'Miner'),
(6, 2, 'B', 'Spy'),
(6, 3, 'B', 'General'),
(6, 4, 'B', 'Captain'),
(6, 5, NULL, NULL),
(6, 6, NULL, NULL),
(6, 7, 'R', 'Scout'),
(6, 8, 'R', 'Scout'),
(6, 9, 'R', 'Major'),
(6, 10, 'R', 'Miner'),
(7, 1, 'B', 'Scout'),
(7, 2, 'B', 'Flag'),
(7, 3, 'B', 'Bomb'),
(7, 4, 'B', 'Major'),
(7, 5, NULL, NULL),
(7, 6, NULL, NULL),
(7, 7, 'R', 'Marshal'),
(7, 8, 'R', 'Colonel'),
(7, 9, 'R', 'Major'),
(7, 10, 'R', 'Flag'),
(8, 1, 'B', 'Sergeant'),
(8, 2, 'B', 'Scout'),
(8, 3, 'B', 'Bomb'),
(8, 4, 'B', 'Bomb'),
(8, 5, NULL, NULL),
(8, 6, NULL, NULL),
(8, 7, 'R', 'Captain'),
(8, 8, 'R', 'Scout'),
(8, 9, 'R', 'Captain'),
(8, 10, 'R', 'Miner'),
(9, 1, 'B', 'Miner'),
(9, 2, 'B', 'Major'),
(9, 3, 'B', 'Miner'),
(9, 4, 'B', 'Colonel'),
(9, 5, NULL, NULL),
(9, 6, NULL, NULL),
(9, 7, 'R', 'Sergeant'),
(9, 8, 'R', 'Lieutenant'),
(9, 9, 'R', 'Scout'),
(9, 10, 'R', 'Bomb'),
(10, 1, 'B', 'Captain'),
(10, 2, 'B', 'Scout'),
(10, 3, 'B', 'Lieutenant'),
(10, 4, 'B', 'Sergeant'),
(10, 5, NULL, NULL),
(10, 6, NULL, NULL),
(10, 7, 'R', 'Lieutenant'),
(10, 8, 'R', 'Scout'),
(10, 9, 'R', 'Bomb'),
(10, 10, 'R', 'Sergeant');

-- --------------------------------------------------------

--
-- Table structure for table `game_status`
--

CREATE TABLE `game_status` (
  `status` enum('not active','initialized','started','ended','aborded') NOT NULL DEFAULT 'not active',
  `p_turn` enum('R','B') DEFAULT NULL,
  `result` enum('B','W','D') DEFAULT NULL,
  `last_change` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `game_status`
--

INSERT INTO `game_status` (`status`, `p_turn`, `result`, `last_change`) VALUES
('started', 'R', NULL, '2024-01-11 19:18:44');

--
-- Triggers `game_status`
--
DELIMITER $$
CREATE TRIGGER `game_status_update` BEFORE UPDATE ON `game_status` FOR EACH ROW BEGIN
		SET NEW.last_change = NOW();
	END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `user_name` varchar(20) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `piece_color` enum('B','R') DEFAULT NULL,
  `token` varchar(100) DEFAULT NULL,
  `last_action` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`id`, `user_name`, `password`, `piece_color`, `token`, `last_action`) VALUES
(37, 'blackkk', '', 'B', '5b74e09594a99079b658a40f29ed10ed', '2024-01-11 19:18:37'),
(38, 'redd', '', 'R', '610ca58477884f630d109a383488fa26', '2024-01-11 19:18:34');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `board`
--
ALTER TABLE `board`
  ADD PRIMARY KEY (`x`,`y`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_name` (`user_name`),
  ADD UNIQUE KEY `user_name_2` (`user_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
