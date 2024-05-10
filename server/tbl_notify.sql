-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: localhost:3306
-- Thời gian đã tạo: Th5 09, 2024 lúc 07:10 PM
-- Phiên bản máy phục vụ: 10.5.24-MariaDB-cll-lve-log
-- Phiên bản PHP: 8.1.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `vkccpjijhosting_plminhphu`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_notify`
--

CREATE TABLE `tbl_notify` (
  `notify_id` bigint(21) NOT NULL,
  `notify_stt` int(1) DEFAULT 0 COMMENT '0-created/1-sending/2-trash',
  `notify_phone` varchar(250) DEFAULT NULL,
  `notify_email` varchar(250) DEFAULT NULL,
  `notify_content` varchar(250) DEFAULT NULL,
  `notify_created` int(6) DEFAULT 0,
  `notify_updated` int(6) DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `tbl_notify`
--
ALTER TABLE `tbl_notify`
  ADD PRIMARY KEY (`notify_id`),
  ADD UNIQUE KEY `notify_phone` (`notify_phone`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `tbl_notify`
--
ALTER TABLE `tbl_notify`
  MODIFY `notify_id` bigint(21) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
