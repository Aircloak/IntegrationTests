SELECT
  hour(changes.date),
  bucket(minute(changes.date) by 30 align middle) as minute_bracket,
  count(*)
FROM drafts_changes
GROUP BY 1, 2
ORDER BY 1, 2