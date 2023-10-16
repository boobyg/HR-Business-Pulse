view: repeat_purchase_facts {
  derived_table: {
    datagroup_trigger: ecommerce_etl
    sql: SELECT
      hr_data.order_id as order_id
      , hr_data.created_at
      , COUNT(DISTINCT repeat_hr_data.id) AS number_subsequent_orders
      , MIN(repeat_hr_data.created_at) AS next_order_date
      , MIN(repeat_hr_data.order_id) AS next_order_id
    FROM looker-private-demo.ecomm.hr_data as hr_data
    LEFT JOIN looker-private-demo.ecomm.hr_data repeat_hr_data
      ON hr_data.user_id = repeat_hr_data.user_id
      AND hr_data.created_at < repeat_hr_data.created_at
    GROUP BY 1, 2
     ;;
  }

  dimension: order_id {
    type: number
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: next_order_id {
    type: number
    hidden: yes
    sql: ${TABLE}.next_order_id ;;
  }

  dimension: has_subsequent_order {
    type: yesno
    sql: ${next_order_id} > 0 ;;
  }

  dimension: number_subsequent_orders {
    type: number
    sql: ${TABLE}.number_subsequent_orders ;;
  }

  dimension_group: next_order {
    type: time
    timeframes: [raw, date]
    hidden: yes
    sql: CAST(${TABLE}.next_order_date AS TIMESTAMP) ;;
  }
}