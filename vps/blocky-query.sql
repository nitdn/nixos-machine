select request_ts, client_name, question_name, answer
from log_entries
order by request_ts desc limit 10;
