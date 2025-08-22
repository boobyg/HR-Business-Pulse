include: "/models/**/*.model.lkml"
  view: order_facts {
    derived_table: {
      explore_source: hr_data1 {
        column: order_id {field: hr_data1.order_id_no_actions }
        column: items_in_order { field: hr_data1.count }
        column: order_amount { field: hr_data1.total_sale_price }
        column: order_cost { field: inventory_items.total_cost }
        column: user_id {field: hr_data1.user_id }
        column: created_at {field: hr_data1.created_raw}
        column: order_gross_margin {field: hr_data1.total_gross_margin}
        derived_column: order_sequence_number {
          sql: RANK() OVER (PARTITION BY user_id ORDER BY created_at) ;;
        }
      }
      datagroup_trigger: ecommerce_etl
    }

#    dimension: order_item_id {
      dimension: order_id {
      type: number
      hidden: no
      primary_key: yes
      sql: ${TABLE}.order_id ;;
    }

#    dimension_group: delivered
#  {
#    timeframes: [raw, time, date, week,month, year]
#      sql:  ${TABLE}.delivered   ;;
#    }

    dimension: items_in_order {
      type: number
      sql: ${TABLE}.items_in_order ;;
    }

    dimension: order_amount {
      type: number
      value_format_name: usd
      sql: ${TABLE}.order_amount ;;
    }

    dimension: order_cost {
      type: number
      value_format_name: usd
      sql: ${TABLE}.order_cost ;;
    }

    dimension: order_gross_margin {
      type: number
      value_format_name: usd
    }

    dimension: order_sequence_number {
      type: number
      sql: ${TABLE}.order_sequence_number ;;
    }

    dimension: is_first_purchase {
      type: yesno
      sql: ${order_sequence_number} = 1 ;;
    }
  }
