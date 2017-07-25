SELECT
  weekday(changes.date) as weekday,
  day(changes.date) as day,
  median(length(changes.change)),  
  count(*)
FROM drafts_changes
GROUP BY weekday, 2
ORDER BY 1, day