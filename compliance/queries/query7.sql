SELECT
  extract_match(content, 'air|aid') as special_word,
  count(*)
FROM notes
WHERE special_word IS NOT NULL
GROUP BY special_word
ORDER BY count(*) DESC