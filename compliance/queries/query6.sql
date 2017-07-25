SELECT
  extract_matches(content, '\w+') as word,
  count(*)
FROM notes
GROUP BY word
HAVING length(word) < 4 and count(*) > 150
ORDER BY count(*) DESC