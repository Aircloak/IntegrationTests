SELECT
  date_trunc('second', changes.date)
FROM drafts_changes
GROUP BY 1