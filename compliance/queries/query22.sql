SELECT count(*)
FROM addresses
WHERE 
  home.postal_code >= 0 and home.postal_code < 50000 and
  work.postal_code >= 50000 and work.postal_code < 100000