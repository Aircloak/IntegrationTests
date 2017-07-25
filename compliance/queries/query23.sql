SELECT
  date_trunc('quarter', changes.date)
FROM drafts_changes
GROUP BY 1