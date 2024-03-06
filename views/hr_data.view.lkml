view: hr_data {
  sql_table_name: looker-private-demo.ecomm.order_items ;;

  ########## IDs, Foreign Keys, Counts ###########

  #comment

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    value_format: "00000"
  }

  dimension: inventory_item_id {
    label: "Employee ID"
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }




  measure: order_count {
    view_label: "Employee Count"
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [user_id, users.name, users.email, order_id, created_date]
    }


  dimension: order_id_no_actions {
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: order_id {
    label: "Case ID"
    type: number
    sql: ${TABLE}.order_id ;;
    action: {
      label: "Send this to slack channel"
      url: "https://hooks.zapier.com/hooks/catch/1662138/tvc3zj/"
      param: {
        name: "user_dash_link"
 #       value: "/dashboards/ayalascustomerlookupdb?Email={{ users.email._value}}"
      }
      form_param: {
        name: "Message"
        type: textarea
        default: "Hey,
        Could you check out case  #{{value}}. It's saying its {{status._value}},
        but the employee is reaching out to us about it.
        ~{{ _user_attributes.first_name}}"
      }
      form_param: {
        name: "Recipient"
        type: select
        default: "zevl"
        option: {
          name: "zevl"
          label: "Zev"
        }
        option: {
          name: "slackdemo"
          label: "Slack Demo User"
        }
      }
      form_param: {
        name: "Channel"
        type: select
        default: "cs"
        option: {
          name: "cs"
          label: "Employee Support"
        }
        option: {
          name: "general"
          label: "General"
        }
      }
    }
    action: {
      label: "Create Help Form"
      url: "https://hooks.zapier.com/hooks/catch/2813548/oosxkej/"
      form_param: {
        name: "Order ID"
        type: string
        default: "{{ order_id._value }}"
      }

      form_param: {
        name: "Name"
        type: string
        default: "{{ users.name._value }}"
      }

      form_param: {
        name: "Email"
        type: string
        default: "{{ _user_attributes.email }}"
      }

      form_param: {
        name: "Item"
        type: string
        default: "{{ products.item_name._value }}"
      }

      form_param: {
        name: "ID"
        type: string
        default: "{{ hr_data.sale_price._rendered_value }}"
      }

      form_param: {
        name: "Comments"
        type: string
        default: " Hi {{ users.first_name._value }}, thanks for your business!"
      }
    }
    value_format: "00000"
  }

  ########## Time Dimensions ##########

  dimension_group: returned {
    label: "Resigned"
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.returned_at ;;

  }

  dimension_group: shipped {
    label: "Last Promotion"
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.shipped_at AS TIMESTAMP) ;;

  }

  dimension_group: delivered {
    label: "Retired"
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.delivered_at AS TIMESTAMP) ;;

  }

  dimension_group: created {
    label: "Hired Date"
    type: time
    timeframes: [ year, hour, date, week, month,raw, week_of_year,month_name]
    sql: ${TABLE}.created_at ;;

  }

  dimension: reporting_period {
    group_label: "Reporting Date"
    sql: CASE
        WHEN EXTRACT(YEAR from ${created_raw}) = EXTRACT(YEAR from CURRENT_TIMESTAMP())
        AND ${created_raw} < CURRENT_TIMESTAMP()
        THEN 'This Year to Date'

      WHEN EXTRACT(YEAR from ${created_raw}) + 1 = EXTRACT(YEAR from CURRENT_TIMESTAMP())
      AND CAST(FORMAT_TIMESTAMP('%j', ${created_raw}) AS INT64) <= CAST(FORMAT_TIMESTAMP('%j', CURRENT_TIMESTAMP()) AS INT64)
      THEN 'Last Year to Date'

      END
      ;;
  }
########## Financial Information ##########

  dimension: sale_price {
    type: number
    hidden: yes
    value_format_name: eur
    sql: ${TABLE}.sale_price ;;
  }

  measure: Salary{
    type: sum
  label: "Salary"
  value_format_name: eur_0
  sql: ${sale_price} ;;
  }

  dimension: gross_margin {
    type: number
    hidden: yes

    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

measure: Benefits {
  type: sum
  label: "Benefits"
  value_format_name: eur_0
  sql: ${gross_margin} ;;
}

  dimension: item_gross_margin_percentage {
    label: "Salary percentile"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/nullif(0,${sale_price}) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    label: "Salary group"
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000,100000]
    style: interval
  }

  measure: total_sale_price {
    label: "Total Salary"
    type: sum
    value_format_name: eur
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    label: "Overal percentile "
    type: sum
    value_format_name: percent_2
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  #POP
  dimension: current_date_range_d {
    hidden: yes
    type: date
    view_label: "_PoP"
    label: "1. Current Date Range"
    description: "Select the current date range you are interested in. Make sure any other filter on Event Date covers this period, or is removed."
    sql: ${created_raw};;
  }
#   filter: current_date_range {
#     hidden: no
#     type: date
#     view_label: "_PoP"
#     label: "1. Current Date Range"
#     description: "Select the current date range you are interested in. Make sure any other filter on Event Date covers this period, or is removed."
#     sql:    ${created_raw} --IS NOT NULL ;;
# #    sql: ${current_date_range_d}  IS NOT NULL ;;
#  }
  filter: current_date_range {
    type: date
    view_label: "_PoP"
    label: "1. Current Date Range"
    description: "Select the current date range you are interested in. Make sure any other filter on Event Date covers this period, or is removed."
    sql: ${created_raw} IS NOT NULL ;;
    convert_tz: no
  }


  dimension: compare_to {
    hidden:yes
    view_label: "_PoP"
    description: "Select the templated previous period you would like to compare to. Must be used with Current Date Range filter"
    label: "2. Compare To:"
    sql: "Period";;
  }

  parameter: compare_to_p {
    hidden: no
    view_label: "_PoP"
    description: "Select the templated previous period you would like to compare to. Must be used with Current Date Range filter"
    label: "2. Compare To:"
    type: unquoted
    allowed_value: {
      label: "Previous Period"
      value: "Period"
    }
    allowed_value: {
      label: "Previous Week"
      value: "Week"
    }
    allowed_value: {
      label: "Previous Month"
      value: "Month"
    }
    allowed_value: {
      label: "Previous Quarter"
      value: "Quarter"
    }
    allowed_value: {
      label: "Previous Year"
      value: "Year"
    }
    default_value: "Period"

  }


  dimension: days_in_period {
    hidden:  yes
    view_label: "_PoP"
    description: "Gives the number of days in the current period date range"
    type: number
    sql: DATE_DIFF(DATE({% date_start current_date_range %}), DATE({% date_end current_date_range %}), DAY) ;;
  }

  dimension: period_2_start {
    hidden:  yes
    view_label: "_PoP"
    description: "Calculates the start of the previous period"
    type: date
    sql:
        {% if compare_to_p._parameter_value == "Period" %}
        DATE_ADD(DATE({% date_start current_date_range %}), INTERVAL ${days_in_period} DAY)
        {% else %}
        DATE_SUB(DATE({% date_start current_date_range %}), INTERVAL 1 {% parameter compare_to %})
        {% endif %};;
    convert_tz: no
  }

  dimension: period_2_end {
    hidden:  yes
    view_label: "_PoP"
    description: "Calculates the end of the previous period"
    type: date
    sql:
        {% if compare_to_p._parameter_value == "Period" %}
        DATE_SUB(DATE({% date_start current_date_range %}), INTERVAL 1 DAY)
        {% else %}
        DATE_SUB(DATE_SUB(DATE({% date_end current_date_range %}), INTERVAL 1 DAY), INTERVAL 1 {% parameter compare_to %})
        {% endif %};;
    convert_tz: no
  }


  dimension: day_in_period {
    hidden: yes
    description: "Gives the number of days since the start of each period. Use this to align the event dates onto the same axis, the axes will read 1,2,3, etc."
    type: number
    sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${created_raw} {% endcondition %}
            THEN DATE_DIFF(DATE({% date_start current_date_range %}), ${created_date}, DAY) + 1
            WHEN ${created_date} between ${period_2_start} and ${period_2_end}
            THEN DATE_DIFF(${period_2_start}, ${created_date}, DAY) + 1
            END
        {% else %} NULL
        {% endif %}
        ;;
  }

  dimension: period_filtered_measures {
    hidden: yes
    description: "We just use this for the filtered measures"
    type: string
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN ${created_date} between ${period_2_start} and ${period_2_end} THEN 'last'
                WHEN {% condition current_date_range %} ${created_raw} {% endcondition %} THEN 'this'
                END
            {% else %} NULL {% endif %} ;;
  }

  # Filtered measures
  measure: current_period_margin {
    label: "Current percentile PoP"
    view_label: "_PoP"
    type: sum
    sql: ${gross_margin} ;;
    filters: [period_filtered_measures: "this"]
    value_format_name: eur_0
  }

  measure: previous_period_margin {
    view_label: "Previous percentile PoP"
    type: sum
    sql:${gross_margin};;
    filters: [period_filtered_measures: "last"]
    value_format_name: eur_0
  }

  ## ------- HIDING FIELDS  FROM ORIGINAL VIEW FILE  -------- ##

  dimension_group: pop_parameters_day { type: time timeframes: [date,raw] hidden: yes}
  dimension: ytd_only {hidden:yes}
  dimension: mtd_only {hidden:yes}
  dimension: wtd_only {hidden:yes}

  dimension_group: date_in_period {
    description: "Use this as your grouping dimension when comparing periods. Aligns the previous periods onto the current period"
    label: "Current Period"
    type: time
    #  sql: DATE_ADD( DATE({% date_start current_date_range %}), INTERVAL -(${day_in_period} - 1) DAY) ;;

    sql: DATE_SUB(DATE({% date_start current_date_range %}), INTERVAL (${day_in_period} - 1) DAY)  ;;
    view_label: "_PoP"
    timeframes: [
      date,
      hour_of_day,
      day_of_week,
      day_of_week_index,
      day_of_month,
      day_of_year,
      week_of_year,
      month,
      month_name,
      month_num,
      year]
  }

  dimension: period {
    view_label: "_PoP"
    label: "Period"
    description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period' or 'Previous Period'"
    type: string
    order_by_field: order_for_period
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN {% condition current_date_range %} TIMESTAMP(${created_raw}) {% endcondition %}
                --THEN 'This {% parameter compare_to %}'
                  THEN 'This Period'  --#bg to display in LS Pro
                WHEN ${created_date} between ${period_2_start} and ${period_2_end}
                --THEN 'Last {% parameter compare_to %}'
                  THEN 'Last Period'  --#bg to display in LS Pro
                END
            {% else %}
                NULL
            {% endif %}
            ;;
  }

  dimension: order_for_period {
    hidden: no
    type: number
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN {% condition current_date_range %} TIMESTAMP(${created_raw}) {% endcondition %}
                THEN 1
                WHEN ${created_date} between ${period_2_start} and ${period_2_end}
                THEN 2
                END
            {% else %}
                NULL
            {% endif %}
            ;;
  }


# end POP



  dimension: user_country {
    type: string
    sql: ${users.country};;
  }

  measure: ancienette_moyenne_2022  {
    type: average_distinct
    sql: 15 ;;
  }
  measure: ancienette_moyenne_2021  {
    type: average_distinct
    sql: 14 ;;
  }
  measure: age_moyenne_2022  {
    type: average_distinct
    value_format_name: decimal_1
    sql: ${age};;
    filters: [users.created_year: "2022"]
    }

  measure: age_moyenne_2021  {
  type: average_distinct
    value_format_name: decimal_1
    sql: ${age};;
    filters: [users.created_year: "2021"]
  }

  measure: taux_de_cadre_en_2022{
    type: average_distinct
    value_format_name: percent_0
    sql: 95;;

  }

  measure: taux_de_cadre_en_2021{
    type: average_distinct
    value_format_name: percent_0
    sql: 96;;

  }

  dimension: age {
    type: number
    sql: ${users.age} ;;
  }

  dimension: employee_age_tier {
    type: tier
    tiers: [0, 25, 35, 45, 55, 65]
    sql: ${age} ;;
    style: integer
  }

##################### end test parrameteres #########################

  set: detail {
    fields: [order_id,  created_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
  set: return_detail {
    fields: [id, order_id,  created_date, returned_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
}
