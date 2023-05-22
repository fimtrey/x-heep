/*
                              *******************
******************************* C SOURCE FILE *******************************
**                            *******************                          **
**                                                                         **
** project  : x-heep                                                       **
** filename : i2s.c                                                        **
** date     : 18/04/2023                                                   **
**                                                                         **
*****************************************************************************
**                                                                         **
** Copyright (c) EPFL contributors.                                        **
** All rights reserved.                                                    **
**                                                                         **
*****************************************************************************

*/

/***************************************************************************/
/***************************************************************************/

/**
* @file   i2s.c
* @date   08/05/2023
* @author Tim Frey
* @brief  HAL of the I2S peripheral
*
*/


/****************************************************************************/
/**                                                                        **/
/*                             MODULES USED                                 */
/**                                                                        **/
/****************************************************************************/


#include "i2s.h"
#include "i2s_structs.h"


/****************************************************************************/
/**                                                                        **/
/*                           EXPORTED FUNCTIONS                             */
/**                                                                        **/
/****************************************************************************/


// i2s base functions
bool i2s_init(uint16_t div_value, i2s_word_length_t word_length)
{
  // already on ?
  if (i2s_is_init()) {
    // ERROR
    return false;
  }


  // write clock divider value to register
  i2s_peri->CLKDIVIDX = div_value;

  // write word_length to register
  uint32_t control = i2s_peri->CONTROL;
  bitfield_field32_write(control, I2S_CONTROL_DATA_WIDTH_FIELD, word_length);

  // enable base modules
  control |= (
    (1 << I2S_CONTROL_EN_WS_BIT)    // enable WS gen
    + (1 << I2S_CONTROL_EN_BIT)     // enable SCK
    + (1 << I2S_CONTROL_EN_IO_BIT)  // connect signals to IO
  );
  i2s_peri->CONTROL = control;

  return true;
}

void i2s_terminate() 
{
  i2s_peri->CONTROL &= ~(
    (1 << I2S_CONTROL_EN_WS_BIT)    // disable WS gen
    + (1 << I2S_CONTROL_EN_BIT)     // disable SCK
    + (1 << I2S_CONTROL_EN_IO_BIT)  // disable IO
  );
}

bool i2s_is_init() 
{
  return (i2s_peri->CONTROL & I2S_CONTROL_EN_BIT);
}

//
// RX Channel
//

bool i2s_rx_start(i2s_channel_sel_t channels)
{
  if (! i2s_is_init()) {
    return false;
  }

  // check overflow before changing state
  bool overflow = i2s_rx_overflow(); 

  i2s_rx_stop();

  if (channels == I2S_DISABLE) {
    // no channels selected -> disable
    return true;
  }

  // check if overflow has occurred
  if (overflow) {
    // overflow bit is going to be reset by rx channel if the sck is running
    while (i2s_rx_overflow()) ; // wait for one SCK rise - this might take some time as the SCK can be much slower
    
  }
  
  // cdc_2phase FIFO is not clearable, so we have to empty the FIFO manually
  // note: this uses much less resources
  while (i2s_rx_data_available()) {
    i2s_rx_read_data(); // read to empty FIFO
  }

  // now we can start the selected rx channels
  i2s_peri->CONTROL |= (channels << I2S_CONTROL_EN_RX_OFFSET);
  return true;
}

void i2s_rx_stop()
{
  // disable rx channel
  i2s_peri->CONTROL &= ~(I2S_CONTROL_EN_RX_MASK << I2S_CONTROL_EN_RX_OFFSET);  // disable rx
}


bool i2s_rx_data_available()
{
  // read data ready bit from STATUS register
  return (i2s_peri->STATUS & (1 << I2S_STATUS_RX_DATA_READY_BIT));
}

uint32_t i2s_rx_read_data()
{
  // read RXDATA register
  return i2s_peri->RXDATA;
}

bool i2s_rx_overflow()
{
  // read overflow bit from STATUS register
  return (i2s_peri->STATUS & (1 << I2S_STATUS_RX_OVERFLOW_BIT));
}


//
// RX Watermark
//
void i2s_rx_enable_watermark(uint16_t watermark, bool interrupt_en)
{
  // set watermark (= max of counter) triggers an interrupt if enabled
  i2s_peri->WATERMARK = watermark;

  uint32_t control = i2s_peri->CONTROL;
  // enable/disable interrupt
  control = bitfield_bit32_write(control, I2S_CONTROL_INTR_EN_BIT, interrupt_en);
  // enable counter
  control |= (1 << I2S_CONTROL_EN_WATERMARK_BIT); 
  i2s_peri->CONTROL = control;
}

void i2s_rx_disable_watermark()
{
  // disable interrupt and disable watermark counter
  i2s_peri->CONTROL &= ~((1 << I2S_CONTROL_INTR_EN_BIT) + (1 << I2S_CONTROL_EN_WATERMARK_BIT));
}

uint16_t i2s_rx_read_waterlevel()
{
  // read WATERLEVEL register
  return (uint16_t) i2s_peri->WATERLEVEL;
}

void    i2s_rx_reset_waterlevel(void)
{
  // set "reset watermark" bit in CONTROL register
  i2s_peri->CONTROL |= (1 << I2S_CONTROL_RESET_WATERMARK_BIT);
}



/****************************************************************************/
/**                                                                        **/
/*                                 EOF                                      */
/**                                                                        **/
/****************************************************************************/
