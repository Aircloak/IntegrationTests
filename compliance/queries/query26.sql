SELECT
  date_trunc('day', changes.date)
FROM drafts_changes
GROUP BY 1