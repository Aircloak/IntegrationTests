SELET 
  home.city,
  count(*)
FROM addresses
WHERE home.city = work.city
GROUP BY home.city