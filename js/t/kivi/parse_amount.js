QUnit.test("kivi.parse_amount function German number style with thousand separator", function( assert ) {
  kivi.setup_formats({ numbers: '1.000,00' });

  assert.equal(kivi.parse_amount('10,00'), 10, '10,00');
  assert.equal(kivi.parse_amount('10,'), 10, '10,');
  assert.equal(kivi.parse_amount('1010,00'), 1010, '1010,00');
  assert.equal(kivi.parse_amount('1010,'), 1010, '1010,');
  assert.equal(kivi.parse_amount('1.010,00'), 1010, '1.010,00');
  assert.equal(kivi.parse_amount('1.010,'), 1010, '1.010,');
  assert.equal(kivi.parse_amount('9.080.070.060.050.040.030.020.010,00'), 9080070060050040030020010, '9.080.070.060.050.040.030.020.010,00');
  assert.equal(kivi.parse_amount('9.080.070.060.050.040.030.020.010,'), 9080070060050040030020010, '9.080.070.060.050.040.030.020.010,');

  assert.equal(kivi.parse_amount('10,98'), 10.98, '10,98');
  assert.equal(kivi.parse_amount('1010,98'), 1010.98, '1010,98');
  assert.equal(kivi.parse_amount('1.010,98'), 1010.98, '1.010,98');

  assert.equal(kivi.parse_amount('10,987654321'), 10.987654321, '10,987654321');
  assert.equal(kivi.parse_amount('1010,987654321'), 1010.987654321, '1010,987654321');
  assert.equal(kivi.parse_amount('1.010,987654321'), 1010.987654321, '1.010,987654321');
});

QUnit.test("kivi.parse_amount function German number style without thousand separator", function( assert ) {
  kivi.setup_formats({ numbers: '1000,00' });

  assert.equal(kivi.parse_amount('10,00'), 10, '10,00');
  assert.equal(kivi.parse_amount('10,'), 10, '10,');
  assert.equal(kivi.parse_amount('1010,00'), 1010, '1010,00');
  assert.equal(kivi.parse_amount('1010,'), 1010, '1010,');
  assert.equal(kivi.parse_amount('1.010,00'), 1010, '1.010,00');
  assert.equal(kivi.parse_amount('1.010,'), 1010, '1.010,');
  assert.equal(kivi.parse_amount('9.080.070.060.050.040.030.020.010,00'), 9080070060050040030020010, '9.080.070.060.050.040.030.020.010,00');
  assert.equal(kivi.parse_amount('9.080.070.060.050.040.030.020.010,'), 9080070060050040030020010, '9.080.070.060.050.040.030.020.010,');

  assert.equal(kivi.parse_amount('10,98'), 10.98, '10,98');
  assert.equal(kivi.parse_amount('1010,98'), 1010.98, '1010,98');
  assert.equal(kivi.parse_amount('1.010,98'), 1010.98, '1.010,98');

  assert.equal(kivi.parse_amount('10,987654321'), 10.987654321, '10,987654321');
  assert.equal(kivi.parse_amount('1010,987654321'), 1010.987654321, '1010,987654321');
  assert.equal(kivi.parse_amount('1.010,987654321'), 1010.987654321, '1.010,987654321');
});

QUnit.test("kivi.parse_amount function English number style with thousand separator", function( assert ) {
  kivi.setup_formats({ numbers: '1,000.00' });

  assert.equal(kivi.parse_amount('10.00'), 10, '10.00');
  assert.equal(kivi.parse_amount('10.'), 10, '10.');
  assert.equal(kivi.parse_amount('1010.00'), 1010, '1010.00');
  assert.equal(kivi.parse_amount('1010.'), 1010, '1010.');
  assert.equal(kivi.parse_amount('1,010.00'), 1010, '1,010.00');
  assert.equal(kivi.parse_amount('1,010.'), 1010, '1,010.');
  assert.equal(kivi.parse_amount('9,080,070,060,050,040,030,020,010.00'), 9080070060050040030020010, '9,080,070,060,050,040,030,020,010.00');
  assert.equal(kivi.parse_amount('9,080,070,060,050,040,030,020,010.'), 9080070060050040030020010, '9,080,070,060,050,040,030,020,010.');

  assert.equal(kivi.parse_amount('10.98'), 10.98, '10.98');
  assert.equal(kivi.parse_amount('1010.98'), 1010.98, '1010.98');
  assert.equal(kivi.parse_amount('1,010.98'), 1010.98, '1,010.98');

  assert.equal(kivi.parse_amount('10.987654321'), 10.987654321, '10.987654321');
  assert.equal(kivi.parse_amount('1010.987654321'), 1010.987654321, '1010.987654321');
  assert.equal(kivi.parse_amount('1,010.987654321'), 1010.987654321, '1,010.987654321');
});

QUnit.test("kivi.parse_amount function English number style without thousand separator", function( assert ) {
  kivi.setup_formats({ numbers: '1000.00' });

  assert.equal(kivi.parse_amount('10.00'), 10, '10.00');
  assert.equal(kivi.parse_amount('10.'), 10, '10.');
  assert.equal(kivi.parse_amount('1010.00'), 1010, '1010.00');
  assert.equal(kivi.parse_amount('1010.'), 1010, '1010.');
  assert.equal(kivi.parse_amount('1,010.00'), 1010, '1,010.00');
  assert.equal(kivi.parse_amount('1,010.'), 1010, '1,010.');
  assert.equal(kivi.parse_amount('9,080,070,060,050,040,030,020,010.00'), 9080070060050040030020010, '9,080,070,060,050,040,030,020,010.00');
  assert.equal(kivi.parse_amount('9,080,070,060,050,040,030,020,010.'), 9080070060050040030020010, '9,080,070,060,050,040,030,020,010.');

  assert.equal(kivi.parse_amount('10.98'), 10.98, '10.98');
  assert.equal(kivi.parse_amount('1010.98'), 1010.98, '1010.98');
  assert.equal(kivi.parse_amount('1,010.98'), 1010.98, '1,010.98');

  assert.equal(kivi.parse_amount('10.987654321'), 10.987654321, '10.987654321');
  assert.equal(kivi.parse_amount('1010.987654321'), 1010.987654321, '1010.987654321');
  assert.equal(kivi.parse_amount('1,010.987654321'), 1010.987654321, '1,010.987654321');
});
