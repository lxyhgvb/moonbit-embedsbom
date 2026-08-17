///|
test "end_to_end_pipeline" {
  let ok = run_integration_pipeline()
  assert_true(ok)
}
