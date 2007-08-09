diag("Add payment conditions");

if(!$sel->get_title("Lx-Office Version 2.4.3 - Selenium - " . $lxtest->{db})){
  require_ok("../../begin/B004Login.t");
}

$sel->select_frame_ok("relative=up");
$sel->click_ok("link=Zahlungskonditionen hinzuf�gen");
$sel->wait_for_page_to_load($lxtest->{timeout});
$sel->select_frame_ok("main_window");
$sel->type_ok("description", "Schnellzahler/Skonto");
$sel->type_ok("description_long", "Schnellzahler bekommen sofort ein Skonto von 3% gew�hrleistet");
$sel->type_ok("description_long_" . $lxtest->{lang_id}, "This is a test in elbisch");
$sel->type_ok("terms_netto", "100");
$sel->type_ok("percent_skonto", "3");
$sel->type_ok("terms_skonto", "97");
$sel->click_ok("action");
$sel->wait_for_page_to_load($lxtest->{timeout});
