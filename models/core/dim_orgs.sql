WITH orgs AS (
--prod
    SELECT
        org_id
        , MIN(event_timestamp) AS created_at
    FROM {{ ref('signed_in') }}
    GROUP BY 1

-- --dev
--    SELECT
--         org_id
--         , org_name
--         , employee_range
--         , created_at
--     FROM {{ ref('org_created') }}
)

, user_count AS (
    SELECT
        org_id
        , count(distinct user_id) AS num_users
    FROM {{ ref('user_created') }}
    GROUP BY 1
)

, subscriptions AS (
    SELECT
        org_id
        , event_timestamp AS sub_created_at
        , plan as sub_plan
        , price as sub_price
    FROM {{ ref('subscription_created') }}
)


SELECT
    orgs.org_id
    , created_at
    , num_users
    , to_timestamp(sub_created_at) as sub_created_at
    , sub_plan
    , sub_price
FROM orgs
LEFT JOIN user_count on orgs.org_id = user_count.org_id
LEFT JOIN subscriptions on orgs.org_id = subscriptions.org_id
