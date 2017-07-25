SELECT
  date_trunc('month', changes.date)
FROM drafts_changes
GROUP BY 1