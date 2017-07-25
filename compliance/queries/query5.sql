SELECT median(num_addresses)
FROM (
  SELECT user_id, count(*) as num_addresses
  FROM addresses
  GROUP BY user_id
) per_user_addresses