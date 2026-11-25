#include "xgpio.h"
#include "xparameters.h"
#include "xil_io.h"

#define LED_BASE 0x44A10000U


int main()
{
    XGpio gpio;
    u32 value;
    Xil_Out32(LED_BASE + 0x014, (1000 << 8) | 100);
    
    // Turn all on
    //Xil_Out32(LED_BASE + 0x010, 0xFFFFU);
    XGpio_Initialize(&gpio, XPAR_AXI_GPIO_0_BASEADDR);

    // Set config 0x14


    while(1) {
        XGpio_SetDataDirection(&gpio, 1, 0xFFFFFFFF);
        value = XGpio_DiscreteRead(&gpio, 1);

        Xil_Out32(LED_BASE + 0x010, value);

        //XGpio_SetDataDirection(&gpio, 1, 0x00000000);
        //XGpio_DiscreteWrite(&gpio, 1, value);
    } 
}