//==================================================================================================
// PulseRain Technology, LLC
//
// Demonstration for Lattice MACHXO3D Breakout Board
// 
// Using Ctrl-U to compile and upload this sketch,
// then use Ctrl-Shift-M to open Serial Monitor
//
// Adjust DIP-SW 1 and 2 for LED pattern.
// Adjust DIP-SW 3 and 4 for LED refreshing rate.
//==================================================================================================

void setup() {
    uint32_t i;
    uint32_t *p;

    GPIO_P0 = 0xAA;
    delay (2000);
    Serial.println ("==================================================================");
    Serial.println (" PulseRain Technology, RISC-V Demo for Lattice MachXO3D, Ver 1.0\n");
    Serial.println (" Usage: Adjust DIP-SW 1 and 2 for LED pattern.");
    Serial.println ("        Adjust DIP-SW 3 and 4 for LED refreshing rate.");
    Serial.println ("==================================================================");
    
}

uint8_t rotate (uint8_t led)
{
    return (((led >> 1) & 0x7F) | ((led & 1) << 7));
}

void loop() {

  uint32_t i, j;
  static uint32_t t = GPIO_P0;
  static uint32_t n = 0;
  
  static uint8_t led = 1;
  uint8_t led_proxy;

  uint32_t k;
  
  k = t;
  t = GPIO_P0;



  led_proxy = led;
  
  for (i = 0; i < (t & 3); ++i) {
      k = led;
      for (j = 0; j < (i + 1); ++j) {
          k = rotate (k);
      } // for j

      led_proxy |= k;
      
  } // for i

  led = rotate (led);
   
  
  Serial.print (n++);
  Serial.print (", SW = 0x");
  Serial.println (t, HEX);

  delay (200 * ((t >> 2) & 3) + 200);

  GPIO_P0 = ~led_proxy;

}
