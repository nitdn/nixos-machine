-- SPDX-FileCopyrightText: 2025 Nitesh Kumar Debnath <nitkdnath@gmail.com>
--
-- SPDX-License-Identifier: GPL-3.0-or-later
select
  request_ts,
  client_name,
  question_name,
  answer
from
  log_entries
order by
  request_ts desc
limit
  10;
