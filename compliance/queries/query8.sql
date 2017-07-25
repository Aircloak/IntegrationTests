-- NOTE: Because of duplicate column names because of projection,
-- this query isn't going to produce the null-result set that should
-- be expected.
SELECT 
  extract_matches(all_words_combined, '\w+') as word,
  count(*)
FROM (
  SELECT id, concat(title, concat(' ', content)) as all_words_combined
  FROM notes
) combined_words LEFT OUTER JOIN (
  SELECT id
  FROM notes
  WHERE title || ' ' || content ILIKE 'air'
  GROUP BY id
) air_users ON combined_words.id = air_users.id LEFT OUTER JOIN (
  SELECT id
  FROM notes
  WHERE title || ' ' || content ILIKE 'aid'
  GROUP BY id  
) aid_users ON combined_words.id = aid_users.id
WHERE
  air_users.id IS NULL and 
  aid_users.id IS NULL and
  word IN ('aid', 'air')
GROUP BY word
ORDER BY count(*) DESC