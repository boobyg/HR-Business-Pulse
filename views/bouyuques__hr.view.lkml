# The name of this view in Looker is "Bouyuques Hr"
view: bouyuques__hr {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `looker-demo-347209.ecomm.Bouyuques  HR` ;;

  # No primary key is defined for this view. In order to join this view in an Explore,
  # define primary_key: yes on a dimension that has no repeated values.

    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "String Field 0" in Explore.

  dimension: ratio_des_effectifs_par_filière {
    type: string
    sql: ${TABLE}.string_field_0 ;;
  }
  measure: count {
    type: count
  }
}
