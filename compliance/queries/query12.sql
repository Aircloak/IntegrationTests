SELECT
  second(changes.date),
  count(*)
FROM drafts_changes
GROUP BY 1
ORDER BY 1