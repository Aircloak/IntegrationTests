SELECT 
  length(title) as title_length,
  name,
  count(*)
FROM users INNER JOIN notes ON users.id = notes.id
GROUP BY title_length, name