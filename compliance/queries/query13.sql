SELECT
  name,
  SUM(notes_count) as total_note_count,
  count(*) as user_count
FROM users INNER JOIN (
  SELECT id, count(*) as notes_count
  FROM notes
  GROUP BY 1
) as notes ON users.id = notes.id
GROUP BY 1
ORDER BY 1