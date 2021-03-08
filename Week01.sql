
/*Part - - Error Codes
Exercise 1:
Goal: Here we use users table to pull a list of user email addresses. Edit the query to pull email
addresses, but only for non-deleted users.*/

SELECT 
  id AS user_id
 ,email_address 
 FROM dsv1069.users
 WHERE deleted_at IS NULL;



--Exercise 2:
----Goal: Use the items table to count the number of items for sale in each category

SELECT 
  category
  ,COUNT(id) AS item_count
 FROM dsv1069.items
 GROUP BY category
 ORDER BY item_count DESC
 


--Exercise 3:
----Goal: Select all of the columns from the result when you JOIN the users table to the orders table

SELECT *
 FROM dsv1069.orders
 JOIN dsv1069.users
ON orders.user_id = user_id


--Exercise 4:
----Goal: Check out the query below. This is not the right way to count the number of viewed_item
--events. Determine what is wrong and correct the error.

SELECT 
COUNT(DISTINCT event_id) AS events
FROM dsv1069.events
WHERE event_name  = 'view_itens'



--Exercise 5:
----Goal:Compute the number of items in the items table which have been ordered. The query
--below runs, but it isn’t right. Determine what is wrong and correct the error or start from scratch.

SELECT 
COUNT(DISTINCT orders.item_id) AS item_count
FROM dsv1069.orders



--Exercise 6:
----Goal: For each user figure out IF a user has ordered something, and when their first purchase
--was. The query below doesn’t return info for any of the users who haven’t ordered anything.

SELECT 
users.id AS users_id
,MIN(orders.paid_at) AS min_paid_at
FROM dsv1069.users LEFT OUTER JOIN dsv1069.orders
ON orders.user_id = users.id 
GROUP BY users.id




--Exercise 7:
----Goal: Figure out what percent of users have ever viewed the user profile page, but this query
--isn’t right. Check to make sure the number of users adds up, and if not, fix the query.

SELECT 
(CASE WHEN first_view IS NULL THEN false
      ELSE true END) AS has_viewed_profile_page,
COUNT(user_id) AS users
FROM (
     SELECT 
      users.id AS user_id
     ,MIN(event_time) AS first_view
     FROM dsv1069.users
     LEFT OUTER JOIN dsv1069.events
          ON events.user_id = users.id
          AND events.event_name = 'view_user_profile'
          GROUP BY users.id)
          first_profile_views
          GROUP BY 
          (CASE WHEN first_view IS NULL THEN false
          ELSE true END)

-- Part 2 - Flexible Data

--Exercise 1:
--Goal: Write a query to format the view_item event into a table with the appropriate columns

SELECT 
  event_id
 ,event_time 
 ,user_id
 ,platform
 (CASE WHEN parameter_name = 'item_id'
      THEN CAST(parameter_value AS INT)
      ELSE NULL END) AS item_id
FROM dsv1069.events 
WHERE event_name = 'view_item'
ORDER BY event_id

--Exercise 2:
--Goal: Write a query to format the view_item event into a table with the appropriate columns

SELECT 
  event_id
 ,event_time 
 ,user_id
 ,platform
 (CASE WHEN parameter_name = 'item_id'
      THEN parameter_value
      ELSE NULL END) AS item_id,
      (CASE WHEN parameter_name = 'referrer'
      THEN parameter_value
      ELSE NULL END) AS referrer
FROM dsv1069.events 
WHERE event_name = 'view_item'
ORDER BY event_id

--Exercise 3:
--Goal: Use the result from the previous exercise, but make sure

SELECT 
  event_id
 ,event_time 
 ,user_id
 ,platform
 MAX(CASE WHEN parameter_name = 'item_id'
      THEN parameter_value
      ELSE NULL END) AS item_id,
     MAX (CASE WHEN parameter_name = 'referrer'
      THEN parameter_value
      ELSE NULL END) AS referrer
FROM dsv1069.events 
WHERE event_name = 'view_item'
GROUP BY event_id
        ,event_time 
        ,user_id
        ,platform
ORDER BY event_id

-- Part 3 - Unreliable Data + Nulls

--Exercise 1: Using any methods you like determine if you can you trust this events table

SELECT 
 date(event_time) AS date
 ,COUNT(*) AS rows
FROM dsv1069.events_201701
GROUP BY (event_time)

--Exercise 2:
--Using any methods you like, determine if you can you trust this  table. (HINT: When did
--we start recording events on mobile)

SELECT 
 date(event_time) AS date
 ,plataform
 ,COUNT(*) 
FROM dsv1069.events_ex2
GROUP BY (event_time)
          ,plataform

--Exercise 3: Imagine that you need to count item views by category. You found this table
--item_views_by_category_temp - should you use it to answer your question? NO

SELECT SUM (view_events) AS event_count
FROM dsv.1069.item_views_by_category_temp

SELECT COUNT(DISTINCT event_id) AS event_count
FROM dsv.1069.events
WHERE event_name = 'view_item'

--Exercise 4: Using any methods you like, decide if this table is ready to be used as a source of
--truth.

SELECT
	date(event_time) AS date
	,COUNT(*) AS row_count
	,COUNT(event_id) event_count
	,COUNT(user_id) AS user_count
FROM dsv.1069.raw_events
GROUP BY
	date(event_time);

SELECT *
FROM dsv.1069.raw_events
WHERE event_time < '2014-01-01';

SELECT
	date(event_time) AS date
	,platform
	,COUNT(user_id) AS user_count
FROM dsv.1069.raw_events
GROUP BY
	date(event_time)
	,platform;

--Exercise 5: Is this the right way to join orders to users? Is this the right way this join.

SELECT COUNT(*)
FROM dsv1069.orders
INNER JOIN dsv1069.users
ON orders.user_id = COALESCE(users.parent_user_id,users_id);
          

--Part 4 - Counting Users  

--Exercise 1: We’ll be using the users table to answer the question “How many new users are
--added each day?“. Start by making sure you understand the columns in the table.

SELECT 
  id
  ,parent_user_id
  ,merged_at
FROM dsv1069.users
ORDER BY parent_user_id ASC 

--Exercise 2: WIthout worrying about deleted user or merged users, count the number of users
--added each day.

SELECT 
   date(created_at) AS day
   ,COUNT(*) AS users
FROM dsv1069.users
    GROUP BY (created_at)


--Exercise 3: Consider the following query. Is this the right way to count merged or deleted
--users? If all of our users were deleted tomorrow what would the result look like?

SELECT 
   date(created_at) AS day
   ,COUNT(*) AS users
FROM dsv1069.users
WHERE deleted_at IS NULL
AND  (id <> parent_user_id OR parent_user_id IS NULL)
    GROUP BY (created_at)

--Exercise 4: Count the number of users deleted each day. Then count the number of users
--removed due to merging in a similar way.

SELECT 
   date(deleted_at) AS day
   ,COUNT(*) AS deleted_users
FROM dsv1069.users
WHERE deleted_at IS NOT NULL
    GROUP BY (deleted_at)

--Exercise 5: Use the pieces you’ve built as subtables and create a table that has a column for
--the date, the number of users created, the number of users deleted and the number of users
--merged that day.

SELECT 
  new.day, 
  new.new_users_added,
  deleted.deleted_users,
  merged.merged_users
FROM 
  (SELECT 
    date(created_at) AS day, 
    COUNT(*)         AS new_users_added
  FROM 
    dsv1069.users
  GROUP BY 
    date(created_at)
  ) new 
LEFT JOIN 
  (SELECT 
    date(deleted_at) AS day, 
    COUNT(*)         AS deleted_users
  FROM 
    dsv1069.users
  WHERE 
    deleted_at IS NOT NULL
  GROUP BY 
    date(deleted_at)
  ) deleted 
ON deleted.day = new.day
LEFT JOIN 
  (SELECT 
    date(merged_at) AS day, 
    COUNT(*)         AS merged_users
  FROM 
    dsv1069.users
  WHERE 
    id <> parent_user_id 
  AND 
    parent_user_id IS NOT NULL
  GROUP BY 
    date(merged_at)
  ) merged
ON merged.day = new.day
Menu
Mode Community
Monica Silva
HOME
Personal
Starred
My Work
My Explorations
Community
Mode Public Warehouse


--Exercise 6: Refine your query from #5 to have informative column names and so that null
--columns return 0.

SELECT 
  new.day, 
  new.new_added_users, 
  COALESCE(deleted.deleted_users,0) AS deleted_users,
  COALESCE(merged.merged_users,0)   AS merged_users,
  (new.new_added_users - COALESCE(deleted.deleted_users,0)- COALESCE(merged.merged_users,0)) 
    AS net_added_users
FROM 
  (SELECT 
    date(created_at) AS day, 
    COUNT(*)         AS new_added_users
  FROM 
    dsv1069.users 
  GROUP BY 
    date(created_at)
  ) new
LEFT OUTER JOIN 
  (SELECT 
    date(deleted_at) AS day, 
    COUNT(*)         AS deleted_users
  FROM 
    dsv1069.users 
  WHERE 
    deleted_at IS NOT NULL
  GROUP BY 
    date(deleted_at)
  ) deleted
ON deleted.day = new.day
LEFT OUTER JOIN 
  (SELECT 
    date(merged_at) AS day, 
    COUNT(*)         AS merged_users
  FROM 
    dsv1069.users 
  WHERE 
    merged_at IS NOT NULL
  AND 
    id <> parent_user_id
  GROUP BY 
    date(merged_at)
  ) merged
ON 
  merged.day = new.day

--Exercise 7:
--What if there were days where no users were created, but some users were deleted or merged.
--Does the previous query still work? No, it doesn’t. Use the dates_rollup as a backbone for this
--query, so that we won’t miss any dates.

SELECT 
  --new.day, 
  dates_rollup.date,
  new.new_added_users, 
  COALESCE(deleted.deleted_users,0) AS deleted_users,
  COALESCE(merged.merged_users,0)   AS merged_users,
  (new.new_added_users - COALESCE(deleted.deleted_users,0)- COALESCE(merged.merged_users,0)) 
    AS net_added_users
FROM
  dsv1069.dates_rollup 
LEFT OUTER JOIN 
  (SELECT 
    date(created_at) AS day, 
    COUNT(*)         AS new_added_users
  FROM 
    dsv1069.users 
  GROUP BY 
    date(created_at)
  ) new
ON 
  new.day = date(dates_rollup.date)
LEFT OUTER JOIN 
  (SELECT 
    date(deleted_at) AS day, 
    COUNT(*)         AS deleted_users
  FROM 
    dsv1069.users 
  WHERE 
    deleted_at IS NOT NULL
  GROUP BY 
    date(deleted_at)
  ) deleted
--ON deleted.day = new.day
ON deleted.day = date(dates_rollup.date)

LEFT OUTER JOIN 
  (SELECT 
    date(merged_at) AS day, 
    COUNT(*)         AS merged_users
  FROM 
    dsv1069.users 
  WHERE 
    merged_at IS NOT NULL
  AND 
    id <> parent_user_id
  GROUP BY 
    date(merged_at)
  ) merged
ON 
--  merged.day = new.day
 merged.day = date(dates_rollup.date)
								     
