
--
-- Cấu trúc bảng cho bảng `tbl_notify`
--

CREATE TABLE `tbl_notify` (
  `notify_id` bigint(21) NOT NULL,
  `notify_stt` int(1) DEFAULT 0,
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
