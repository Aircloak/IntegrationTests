SELECT
  date_trunc('hour', changes.date)
FROM drafts_changes
GROUP BY 1