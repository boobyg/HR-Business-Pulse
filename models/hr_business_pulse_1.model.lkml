connection: "ecomm"
label: "HR Business Pulse"
include: "/views/**/*.view" # include all the views

############ Model Configuration #############

datagroup: ecommerce_etl {
  # sql_trigger: SELECT max(created_at) FROM ecomm.events ;;
  # max_cache_age: "24 hours"
  max_cache_age: "999999 hours"  #do not change will rebuild PDTs and generate errors
  sql_trigger: FALSE ;; #do not change will rebuild PDTs and generate errors
}

persist_with: ecommerce_etl
############ Base Explores #############

# explore: hr_data {
#   label: "(0) HR Data"
#   view_name: hr_data

# }

explore: hr_data1 {
  from: hr_data
  label: "(1) HR Data"
  access_filter: {
    field: distribution_centers.id
    user_attribute: distribution_center
    }
  join: order_facts {
    type: left_outer
    view_label: "Orders"
    relationship: many_to_one
    sql_on: ${order_facts.order_item_id} = ${hr_data1.order_id} ;;
  }

  join: inventory_items {
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${hr_data1.inventory_item_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${hr_data1.user_id} = ${users.id} ;;
  }

  join: user_order_facts {
    view_label: "Users"
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${hr_data1.user_id} ;;
  }

  join: products {
    type: left_outer
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }

  join: repeat_purchase_facts {
    relationship: many_to_one
    type: full_outer
    sql_on: ${hr_data1.order_id} = ${repeat_purchase_facts.order_id} ;;
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id} ;;
    relationship: many_to_one
  }
}
explore: bouyuques__hr{
  label: "(3)ratio_des_effectifs_par_filiere"

}


#########  Event Data Explores #########

explore: events {
  label: "(2) Web Event Data"

  join: sessions {
    type: left_outer
    sql_on: ${events.session_id} =  ${sessions.session_id} ;;
    relationship: many_to_one
  }


  join: users {
    type: left_outer
    sql_on: ${sessions.session_user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    type: left_outer
    sql_on: ${users.id} = ${user_order_facts.user_id} ;;
    relationship: one_to_one
    view_label: "Users"
  }
}

explore: sessions {
  label: "(3) Web Session Data"

  join: events {
    type: left_outer
    sql_on: ${sessions.session_id} = ${events.session_id} ;;
    relationship: one_to_many
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${users.id} = ${sessions.session_user_id} ;;
  }

  join: user_order_facts {
    type: left_outer
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${users.id} ;;
    view_label: "Users"
  }
}
