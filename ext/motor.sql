-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Dec 11, 2021 at 05:21 PM
-- Server version: 10.4.18-MariaDB-1:10.4.18+maria~bionic
-- PHP Version: 8.0.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `motor`
--

-- --------------------------------------------------------

--
-- Table structure for table `channels`
--

CREATE TABLE `channels` (
  `id` int(11) NOT NULL,
  `name` varchar(11) NOT NULL,
  `description` text NOT NULL,
  `public` tinyint(1) NOT NULL DEFAULT 1,
  `staff` tinyint(1) NOT NULL DEFAULT 0,
  `read_only` tinyint(1) NOT NULL DEFAULT 0,
  `auto_join` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `channels`
--

INSERT INTO `channels` (`id`, `name`, `description`, `public`, `staff`, `read_only`, `auto_join`) VALUES
(1, '#motor', 'Hello, World!', 1, 0, 0, 1),
(2, '#osu', 'Osu chat', 1, 0, 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `friends`
--

CREATE TABLE `friends` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `friend_id` int(11) NOT NULL,
  `since` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `uname` varchar(15) NOT NULL,
  `usafe` varchar(15) NOT NULL,
  `passhash` varchar(64) NOT NULL DEFAULT '0',
  `privileges` int(11) NOT NULL,
  `country` varchar(2) NOT NULL,
  `lat` float NOT NULL,
  `lon` float NOT NULL,
  `registered` float NOT NULL,
  `latest_update` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`id`, `uname`, `usafe`, `passhash`, `privileges`, `country`, `lat`, `lon`, `registered`, `latest_update`) VALUES
(1, 'Louise', 'louise', 'no', 6, 'DK', 0, 0, 0, 0),

-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

CREATE TABLE `stats` (
  `id` int(11) NOT NULL,
  `r_score_std` bigint(20) NOT NULL DEFAULT 0,
  `r_score_taiko` bigint(20) NOT NULL DEFAULT 0,
  `r_score_catch` bigint(20) NOT NULL DEFAULT 0,
  `r_score_mania` bigint(20) NOT NULL DEFAULT 0,
  `t_score_std` bigint(20) NOT NULL DEFAULT 0,
  `t_score_taiko` bigint(20) NOT NULL DEFAULT 0,
  `t_score_catch` bigint(20) NOT NULL DEFAULT 0,
  `t_score_mania` bigint(20) NOT NULL DEFAULT 0,
  `pp_std` mediumint(9) NOT NULL DEFAULT 0,
  `pp_taiko` mediumint(9) NOT NULL DEFAULT 0,
  `pp_catch` mediumint(9) NOT NULL DEFAULT 0,
  `pp_mania` mediumint(9) NOT NULL DEFAULT 0,
  `p_count_std` int(11) NOT NULL DEFAULT 0,
  `p_count_taiko` int(11) NOT NULL DEFAULT 0,
  `p_count_catch` int(11) NOT NULL DEFAULT 0,
  `p_count_mania` int(11) DEFAULT 0,
  `acc_std` float NOT NULL DEFAULT 0,
  `acc_taiko` float NOT NULL DEFAULT 0,
  `acc_catch` float NOT NULL DEFAULT 0,
  `acc_mania` float NOT NULL DEFAULT 0,
  `level_std` int(11) NOT NULL DEFAULT 0,
  `level_taiko` int(11) NOT NULL DEFAULT 0,
  `level_catch` int(11) NOT NULL DEFAULT 0,
  `level_mania` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `stats`
--

INSERT INTO `stats` (`id`, `r_score_std`, `r_score_taiko`, `r_score_catch`, `r_score_mania`, `t_score_std`, `t_score_taiko`, `t_score_catch`, `t_score_mania`, `pp_std`, `pp_taiko`, `pp_catch`, `pp_mania`, `p_count_std`, `p_count_taiko`, `p_count_catch`, `p_count_mania`, `acc_std`, `acc_taiko`, `acc_catch`, `acc_mania`, `level_std`, `level_taiko`, `level_catch`, `level_mania`) VALUES
(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),

--
-- Indexes for dumped tables
--

--
-- Indexes for table `channels`
--
ALTER TABLE `channels`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `friends`
--
ALTER TABLE `friends`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `stats`
--
ALTER TABLE `stats`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `channels`
--
ALTER TABLE `channels`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `friends`
--
ALTER TABLE `friends`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `stats`
--
ALTER TABLE `stats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
