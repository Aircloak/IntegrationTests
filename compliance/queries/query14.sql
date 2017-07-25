SELECT
  name,
  count(*)
FROM users INNER JOIN (
  SELECT id
  FROM notes
  WHERE title like '%air%'
  GROUP BY id
) notes_with_air ON users.id = notes_with_air.id
GROUP BY name