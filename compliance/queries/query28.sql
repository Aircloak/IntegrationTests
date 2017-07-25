SELECT
  date_trunc('minute', changes.date)
FROM drafts_changes
GROUP BY 1