if(!defined $sel) {
  require "t/selenium/AllTests.t";
  init_server("singlefileonly",$0);
  exit(0);
}
diag("Show customer/vendor types");

$sel->select_frame_ok("relative=up");
$sel->title_is("Lx-Office Version 2.4.3 - Selenium - " . $lxtest->{db});
$sel->click_ok("link=Kunden\-\/Lieferantentypen\ anzeigen");
$sel->wait_for_page_to_load_ok($lxtest->{timeout});
$sel->select_frame_ok("main_window");
$sel->click_ok("link=Gro�abnehmer");
$sel->wait_for_page_to_load_ok($lxtest->{timeout});
$sel->click_ok("action");
$sel->wait_for_page_to_load_ok($lxtest->{timeout});
$sel->click_ok("link=Kleink�ufer");
$sel->wait_for_page_to_load_ok($lxtest->{timeout});
$sel->click_ok("action");
$sel->wait_for_page_to_load_ok($lxtest->{timeout});
1;