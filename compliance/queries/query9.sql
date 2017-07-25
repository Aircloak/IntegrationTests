SELECT
  year(changes.date) as year,
  month(changes.date) as month,
  median(length(changes.change)),  
  count(*)
FROM drafts_changes
GROUP BY year, month
ORDER BY year ASC, month ASC