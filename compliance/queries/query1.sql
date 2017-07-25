SELECT bucket(age by 10)
FROM users
WHERE active = true
GROUP BY bucket(age by 10)