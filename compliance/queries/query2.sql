SELECT bucket(age by 10 align middle), count(*), min(height), max(height)
FROM users
WHERE active = true
GROUP BY 1