#include "xgpio.h"
#include "xparameters.h"
#include <stdlib.h>
#include "xil_io.h"        /* Xil_Out32: write a 32-bit register */
#include "xil_printf.h"    /* xil_printf over the UART           */


#define SEG7_BASE      0x44A00000u
#define SEG7_CTL       (SEG7_BASE + 0x000u)   /* bit 0: enable          */
#define SEG7_VAL       (SEG7_BASE + 0x004u)   /* 4 digits, 4 bits each  */
#define SEG7_DIM       (SEG7_BASE + 0x008u)   /* brightness 0..15       */

/* ----------------------------------------------------------------
 * LED controller (ahb)
 * ---------------------------------------------------------------- */
#define LED_BASE       0x44A10000u
#define LED_INT_MASK   (LED_BASE + 0x004u)    /* 1 = interrupt masked   */
#define LED_CTL        (LED_BASE + 0x010u)    /* 16 LED enable bits     */
#define LED_CFG        (LED_BASE + 0x014u)

/* GPIO bits: btnC = bit 6, sw0..sw3 = bits 2..5 */
#define BTN_C          (1u << 6)


//for 7 seg
void display(u32 d3, u32 d2, u32 d1, u32 d0)
{
    u32 val = (d0 & 0xFu)
            | ((d1 & 0xFu) << 4)
            | ((d2 & 0xFu) << 8)
            | ((d3 & 0xFu) << 12);

    Xil_Out32(SEG7_VAL, val);
   
}


//for led
void config(u32 frequency, u32 duty)
{
    Xil_Out32(LED_CFG, ((frequency & 0xFFFFu) << 8) | (duty & 0xFFu));
}


//for randomization
u32 dice()
{
    return (u32)(rand() % 6) + 1u;
}


//for rolling: en bit 0 = sw0 ... bit 3 = sw3, disabled dice show 0
void roll_dice(u32 en)
{
    u32 d0 = (en & 1u) ? dice() : 0u;
    u32 d1 = (en & 2u) ? dice() : 0u;
    u32 d2 = (en & 4u) ? dice() : 0u;
    u32 d3 = (en & 8u) ? dice() : 0u;

    display(d3, d2, d1, d0);
}


int main()
{
    XGpio gpio;
    u32 value;
    u32 version;
    u32 result;
    u32 last;
    XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_BASEADDR);
    XGpio_SetDataDirection(&gpio, 1, 0xFFFFFFFF);   //all inputs
    XGpio_SetDataDirection(&gpio, 2, 0xFFFFFFFF); // channel 2
    Xil_Out32(SEG7_DIM, 0xFu);   //full brightness
    Xil_Out32(SEG7_CTL, 1u);     //display on
    display(0, 0, 0, 0);

    while(1) {
        value = XGpio_DiscreteRead(&gpio, 1);   //read switches and buttons
        version = XGpio_DiscreteRead(&gpio, 2); 

        if ((value & BTN_C)&& (version == 1)) 
        {
            roll_dice((value >> 2) & 0xFu);     //sw0..sw3 as mask because deb_out has it in this order
        }                                       //{sw[15], btnC, sw[3], sw[2], sw[1], sw[0], btnD, btnU}
    
        if ((last & BTN_C) && !(value & BTN_C))
         {
            result = Xil_In32(SEG7_VAL);        //read the shown digits back
            xil_printf("The values are %d %d %d %d\r\n",
                       (result >> 12) & 0xFu,   //die 4 (sw3, leftmost)
                       (result >> 8)  & 0xFu,   //die 3 (sw2)
                       (result >> 4)  & 0xFu,   //die 2 (sw1)
                        result        & 0xFu);  //die 1 (sw0, rightmost)
        }

        last = value;
    }
}