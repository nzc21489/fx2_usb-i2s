#include <fx2regs.h>
#include <fx2macros.h>
#include <delay.h>
#include <autovector.h>
#include <lights.h>
#include <setupdat.h>
#include <eputils.h>
#include <gpif.h>

//--------------------- gpif ---------------------
const char __xdata WaveData[128] =     
{                                      
// Wave 0 
/* LenBr */ 0x01,     0x01,     0x01,     0x01,     0x01,     0x01,     0x01,     0x07,
/* Opcode*/ 0x02,     0x02,     0x02,     0x02,     0x02,     0x02,     0x02,     0x02,
/* Output*/ 0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,
/* LFun  */ 0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x3F,
// Wave 1 
/* LenBr */ 0x01,     0x01,     0x01,     0x01,     0x01,     0x01,     0x01,     0x07,
/* Opcode*/ 0x02,     0x02,     0x02,     0x02,     0x02,     0x02,     0x02,     0x02,
/* Output*/ 0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,
/* LFun  */ 0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x3F,
// Wave 2 
/* LenBr */ 0x01,     0x01,     0x01,     0x01,     0x01,     0x01,     0x01,     0x07,
/* Opcode*/ 0x02,     0x02,     0x02,     0x02,     0x02,     0x02,     0x02,     0x02,
/* Output*/ 0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,
/* LFun  */ 0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x3F,
// Wave 3 
/* LenBr */ 0x81,     0x04,     0x04,     0x03,     0x82,     0x01,     0x01,     0x07,
/* Opcode*/ 0x03,     0x02,     0x02,     0x06,     0x03,     0x02,     0x02,     0x02,
/* Output*/ 0x02,     0x00,     0x01,     0x00,     0x00,     0x00,     0x00,     0x00,
/* LFun  */ 0x36,     0x00,     0x00,     0x00,     0x36,     0x00,     0x00,     0x3F,
};
const char __xdata FlowStates[36] =   
{                                      
/* Wave 0 FlowStates */ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
/* Wave 1 FlowStates */ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
/* Wave 2 FlowStates */ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
/* Wave 3 FlowStates */ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
};
const char __xdata InitData[7] =                                   
{                                                                
/* Regs  */ 0xE0,0x10,0x00,0x00,0x8E,0x4E,0x00     
};
//------------------------------------------------

#define SYNCDELAY SYNCDELAY4
#define REARMVAL 0x80
#define REARM() EP2BCL = REARMVAL

#define bmSTRETCH 0x07

volatile __bit got_sud;

extern __code WORD dev_dscr;
extern __code WORD dev_qual_dscr;
extern __code WORD highspd_dscr;
extern __code WORD fullspd_dscr;
extern __code WORD dev_strings;
extern __code WORD freq_dscr;
extern __code WORD user_dscr;

#define VR_NAKALL_ON 0xD0
#define VR_NAKALL_OFF 0xD1

WORD pDeviceDscr;
WORD pDeviceQualDscr;
WORD pHighSpeedConfigDscr;
WORD pFullSpeedConfigDscr;
WORD pConfigDscr;
WORD pOtherConfigDscr;
WORD pStringDscr;
WORD pFreqDscr;

BOOL handle_get_interface(BYTE ifc, BYTE *alt_ifc);
BOOL handle_vendorcommand(BYTE cmd);
BOOL handle_set_interface(BYTE ifc, BYTE alt_ifc);
BYTE handle_get_configuration();
BOOL handle_set_configuration(BYTE cfg);

BYTE Configuration;    // Current configuration
BYTE AlternateSetting; // Alternate settings

volatile char count = 0;

volatile char freq_data = 0;
volatile char feedback_data[4] = {0x00, 0x00, 0x06, 0x00};

void communication(unsigned char pre_data, char *got_data)
{
    unsigned char j = 0;
    unsigned char i = 0;
    long send_data = pre_data;
    send_data |= freq_data;

    switch (AlternateSetting)
    {
    case 0: // mute
        send_data |= (0b00 << 5);
        break;
    case 1: // 16 bit
        send_data |= (0b01 << 5);
        break;
    case 2: // 24 bit
        send_data |= (0b10 << 5);
        break;
    case 3: // 32 bit
        send_data |= (0b11 << 5);
        break;
    default:
        send_data |= (0b00 << 5);
    }

    for (j = 0; j < 4; j++)
    {
        got_data[j] = 0;
        for (i = 0; i < 8; i++)
        {
            PA1 = 0;
            if (j == 0)
            {
                if (((send_data >> i) & 1) == 0)
                {
                    PA0 = 0;
                }
                else
                {
                    PA0 = 1;
                }
            }
            else
            {
                PA0 = 0;
            }

            PA1 = 1;

            if (PA2 == 1)
            {
                got_data[j] |= (1 << i);
            }

            PA3 = 1;
        }
    }
}


// Device request parser
void SetupCommand(void)
{
    int i;

    // Clear feature endpoint 86
    if (SETUPDAT[0] == 2 && SETUPDAT[1] == 1 && SETUPDAT[2] == 0 && SETUPDAT[3] == 0 && SETUPDAT[4] == 0x86 && SETUPDAT[5] == 0)
    {
        // RESET FIFO
        FIFORESET = 0x80;
        SYNCDELAY;
        FIFORESET = 0x86; // reset EP6
        SYNCDELAY;
        FIFORESET = 0x00;
        SYNCDELAY;
        INPKTEND = 0x86; // ARM FIFO
        SYNCDELAY;
        INPKTEND = 0x86;
        SYNCDELAY;
    }
    // Set smpl freq
    else if (SETUPDAT[0] == 0x21 && SETUPDAT[1] == 0x01 && SETUPDAT[2] == 0 && SETUPDAT[3] == 1 && SETUPDAT[4] == 0 && SETUPDAT[5] == 0x12 && SETUPDAT[6] == 4)
    {
        EP0BCH = 0;
        SYNCDELAY;
        EP0BCL = 0; // Clear bytecount to allow new data recieve
        SYNCDELAY;
        while (EP0CS & bmEPBUSY)
            ;

        freq_data = 0;
        if (EP0BUF[0] == 128 && EP0BUF[1] == 187 && EP0BUF[2] == 0 && EP0BUF[3] == 0) //48000
        {
            freq_data |= (0b000 << 2);
        }
        else if (EP0BUF[0] == 0 && EP0BUF[1] == 119 && EP0BUF[2] == 1 && EP0BUF[3] == 0) //96000
        {
            freq_data |= (0b010 << 2);
        }
        else if (EP0BUF[0] == 0 && EP0BUF[1] == 238 && EP0BUF[2] == 2 && EP0BUF[3] == 0) //192000
        {
            freq_data |= (0b100 << 2);
        }
        else if (EP0BUF[0] == 0 && EP0BUF[1] == 220 && EP0BUF[2] == 5 && EP0BUF[3] == 0) //384000
        {
            freq_data |= (0b110 << 2);
        }
        else if (EP0BUF[0] == 68 && EP0BUF[1] == 172 && EP0BUF[2] == 0 && EP0BUF[3] == 0) //44100
        {
            freq_data |= (0b001 << 2);
        }
        else if (EP0BUF[0] == 136 && EP0BUF[1] == 88 && EP0BUF[2] == 1 && EP0BUF[3] == 0) //88200
        {
            freq_data |= (0b011 << 2);
        }
        else if (EP0BUF[0] == 16 && EP0BUF[1] == 177 && EP0BUF[2] == 2 && EP0BUF[3] == 0) //176400
        {
            freq_data |= (0b101 << 2);
        }
        else if (EP0BUF[0] == 32 && EP0BUF[1] == 98 && EP0BUF[2] == 5 && EP0BUF[3] == 0) //352800
        {
            freq_data |= (0b111 << 2);
        }

        FIFORESET = 0x80; // activate NAK-ALL to avoid race conditions
        SYNCDELAY;
        EP4FIFOCFG = 0x00; //switching to manual mode
        SYNCDELAY;
        FIFORESET = 0x84; // Reset FIFO 4
        SYNCDELAY;
        OUTPKTEND = 0X84; //OUTPKTEND done twice as EP4 is double buffered by default
        SYNCDELAY;
        OUTPKTEND = 0X84;
        SYNCDELAY;
        EP4FIFOCFG = 0x10; //switching to auto mode
        SYNCDELAY;
        FIFORESET = 0x00; //Release NAKALL
        SYNCDELAY;

        // send bit/frequency
        if (PA2 == 0)
        {
            char buff[4];
            communication(0b10, buff);
        }
    }
    // Set HID IDLE
    else if (SETUPDAT[0] == 0x21 && SETUPDAT[1] == 0x0A && SETUPDAT[2] == 0 && SETUPDAT[3] == 0 && SETUPDAT[4] == 2 && SETUPDAT[5] == 0)
    {
    }
    // GET STATUS
    else if (SETUPDAT[0] == 0x80 && SETUPDAT[1] == 0 && SETUPDAT[2] == 0 && SETUPDAT[3] == 0 && SETUPDAT[4] == 0 && SETUPDAT[5] == 0 && SETUPDAT[6] == 2 && SETUPDAT[7] == 0)
    {
        EP0BUF[0] = 0;
        EP0BUF[1] = 0;
        SYNCDELAY;
        EP0BCH = SETUPDAT[7];
        SYNCDELAY;
        EP0BCL = SETUPDAT[6];
        SYNCDELAY;
    }
    // Get TE_CONNECTOR_CONTROL of output terminal in the interface0  --> UAC2.0 5.2.5.4.2
    else if (SETUPDAT[0] == 0xA1 && SETUPDAT[1] == 1 && SETUPDAT[2] == 0 && SETUPDAT[3] == 2 && SETUPDAT[4] == 0 && SETUPDAT[5] == 7 && SETUPDAT[6] == 6)
    {
        EP0BUF[0] = 2; // channel number
        EP0BUF[1] = 3; // front L and front R
        EP0BUF[2] = 0;
        EP0BUF[3] = 0;
        EP0BUF[4] = 0;
        EP0BUF[5] = 0; // string descriptor
        SYNCDELAY;
        EP0BCH = SETUPDAT[7];
        SYNCDELAY;
        EP0BCL = SETUPDAT[6];
        SYNCDELAY;
    }
    // Get smpl freq valid
    else if (SETUPDAT[0] == 0xA1 && SETUPDAT[1] == 0x01 && SETUPDAT[2] == 0 && SETUPDAT[3] == 2 && SETUPDAT[4] == 0 && SETUPDAT[5] == 0x12 && SETUPDAT[6] == 1)
    {
        EP0BUF[0] = TRUE;
        EP0BUF[1] = 0x00;
        SYNCDELAY;
        EP0BCH = SETUPDAT[7];
        SYNCDELAY;
        EP0BCL = SETUPDAT[6];
        SYNCDELAY;
    }
    // Get current smpl freq
    else if (SETUPDAT[0] == 0xA1 && SETUPDAT[1] == 0x01 && SETUPDAT[2] == 0 && SETUPDAT[3] == 1 && SETUPDAT[4] == 0 && SETUPDAT[5] == 0x12 && SETUPDAT[6] == 4)
    {
        EP0BUF[0] = 0;
        EP0BUF[1] = 0;
        EP0BUF[2] = 0;
        EP0BUF[3] = 0;

        SYNCDELAY;
        EP0BCH = SETUPDAT[7];
        SYNCDELAY;
        EP0BCL = SETUPDAT[6];
        SYNCDELAY;
    }
    // Get_REPORT HID
    else if (SETUPDAT[0] == 0xA1 && SETUPDAT[1] == 0x01 && SETUPDAT[2] == 0 && SETUPDAT[3] == 1 && SETUPDAT[4] == 2 && SETUPDAT[5] == 0 && SETUPDAT[6] == 16)
    {
        for (i = 0; i < 16; i++)
        {
            EP0BUF[i] = 0;
        }
        SYNCDELAY;
        EP0BCH = 0;
        SYNCDELAY;
        EP0BCL = 16;
        SYNCDELAY;
    }
    // Audio class MUTE ctl
    else if (SETUPDAT[0] == 0xA1 && SETUPDAT[1] == 0x01 && SETUPDAT[2] == 0 && SETUPDAT[3] == 1 && SETUPDAT[4] == 0 && SETUPDAT[5] == 0x0D && SETUPDAT[6] == 1)
    {
        EP0BUF[0] = 0;
        SYNCDELAY;
        EP0BCH = 0;
        SYNCDELAY;
        EP0BCL = 1;
        SYNCDELAY;
    }
    // Get freq range
    else if (SETUPDAT[0] == 0xA1 && SETUPDAT[1] == 0x02 && SETUPDAT[2] == 0 && SETUPDAT[3] == 1 && SETUPDAT[4] == 0 && SETUPDAT[5] == 0x12)
    {
        SUDPTRH = MSB(pFreqDscr);
        SYNCDELAY;
        SUDPTRL = LSB(pFreqDscr);
        SYNCDELAY;
    }
    else
    {
        handle_setupdata();
    }

    // Acknowledge handshake phase of device request
    EP0CS |= bmHSNAK;
}

void main()
{
    REVCTL = 3;

    got_sud = FALSE;

    // renumerate
    RENUMERATE_UNCOND();

    SETCPUFREQ(CLK_48M);
    SETIF48MHZ();

    USE_USB_INTS();
    ENABLE_SUDAV();
    ENABLE_SOF();
    ENABLE_HISPEED();
    ENABLE_USBRESET();

    gpif_init(WaveData, InitData); // init GPIF
    gpif_setflowstate(FlowStates, 0);

    // EPx configuration
    // [7]ON
    // [6]DIR     0:out   1:in
    // [5:4]TYPE   01:ISO 10:BULK 11:INT
    // [3]SIZE 0:512  1:1024
    // [2]
    // [1:0]FIFO COUNT    00:4  10:2    11:3
    EP1OUTCFG = 0xB0; // 1011_0000 interrupt
    SYNCDELAY;
    EP1INCFG = 0xB0; // 1011_0000 interrupt
    SYNCDELAY;

    EP2CFG = 0xD2; // 1101_0010  in Isochronous 512byte double, feedback
    SYNCDELAY;
    EP4CFG = 0x92; // 1001_0010 out Isochronous 512byte double, audio stream

    SYNCDELAY;
    EP6CFG = 0xF2; // 1111_0010  in interrupt 512byte double, control
    SYNCDELAY;
    EP8CFG = 0xF2; // 1111_0010  in interrupt 512byte double, not used
    SYNCDELAY;

    // RESET FIFO
    FIFORESET = 0x80;
    SYNCDELAY;
    FIFORESET = 0x82; // reset EP2
    SYNCDELAY;
    FIFORESET = 0x84; // reset EP4
    SYNCDELAY;
    FIFORESET = 0x86; // reset EP6
    SYNCDELAY;
    FIFORESET = 0x88; // reset EP8
    SYNCDELAY;
    FIFORESET = 0x00;
    SYNCDELAY;

    // ARM FIFO EP4
    OUTPKTEND = 0x84;
    SYNCDELAY;
    OUTPKTEND = 0x84;
    SYNCDELAY;

    // ARM FIFO
    INPKTEND = 0x82;
    SYNCDELAY;
    INPKTEND = 0x82;
    SYNCDELAY;
    INPKTEND = 0x86;
    SYNCDELAY;
    INPKTEND = 0x86;
    SYNCDELAY;
    INPKTEND = 0x88;
    SYNCDELAY;
    INPKTEND = 0x88;
    SYNCDELAY;

    // arm EPOUT
    EP1OUTBC = 0x40; // arm EP1 OUT by writing to the byte count
    SYNCDELAY;
    EP4BCL = 0x80; // arm EP2 OUT by writing byte count w/skip.
    SYNCDELAY;

    // EPx FIFO CONFIG
    // [7]
    // [6] FULL FLAG
    // [5] EMPTY FLAG
    // [4] AUTOOUT       1:No CPU involvement
    // [3] AUTOIN
    // [2] ZEROLENIN
    // [1]
    // [0] WORDWIDE     0:8bit PB[7:0]
    EP2FIFOCFG = 0x00; // [3]AUTOIN=0, [2]ZEROLEN=0
    SYNCDELAY;
    EP4FIFOCFG = 0x10; // [4]AUTOOUT=1, [2]ZEROLEN=0
    SYNCDELAY;
    EP6FIFOCFG = 0x00; // [3]AUTOIN=0, [2]ZEROLEN=0
    SYNCDELAY;
    EP8FIFOCFG = 0x00; // [3]AUTOIN=0, [2]ZEROLEN=0
    SYNCDELAY;

    // EPx AUTOLENGTH    Auto-commit 512-byte packets
    EP2AUTOINLENH = 0x02;
    SYNCDELAY;
    EP2AUTOINLENL = 0x00;
    SYNCDELAY;
    EP6AUTOINLENH = 0x02;
    SYNCDELAY;
    EP6AUTOINLENL = 0x00;
    SYNCDELAY;
    EP8AUTOINLENH = 0x02;
    SYNCDELAY;
    EP8AUTOINLENL = 0x00;
    SYNCDELAY;

    // auto pointer increment
    AUTOPTRSETUP |= 7; // APTREN=1
    SYNCDELAY;

    // connect to gpif
    EP4GPIFFLGSEL = 1; // GPIF FIFOFlag is empty
    SYNCDELAY;

    // start EP4
    EP2GPIFTRIG = 0x00; //
    EP6GPIFTRIG = 0x00; //
    EP8GPIFTRIG = 0x00; //
    EP4GPIFTRIG = 0xFF; // start ep4
    SYNCDELAY;

    OEA = 0x3; // PA0, PA1 output
    PA1 = 1;

    pDeviceDscr = (WORD)&dev_dscr;
    pDeviceQualDscr = (WORD)&dev_qual_dscr;
    pHighSpeedConfigDscr = (WORD)&highspd_dscr;
    pFullSpeedConfigDscr = (WORD)&fullspd_dscr;
    pStringDscr = (WORD)&dev_strings;
    pFreqDscr = (WORD)&freq_dscr;

    INTSETUP |= (bmAV2EN | bmAV4EN); // Enable INT 2 & 4 autovectoring

    PORTACFG = 0;
    SYNCDELAY;

    // EPx INTERRUPT
    EPIE = 0x00;
    SYNCDELAY;

    USBCS &= ~bmDISCON;

    CKCON = (CKCON & (~bmSTRETCH)); // Set stretch

    EA = 1; // Enable interrupts

    while (TRUE)
    {
        if (got_sud)
        {
            SetupCommand();
            got_sud = FALSE;
        }

        if (PA2 == 1)
        {
            communication(0b01, feedback_data);
        }

        // feedback
        if (count >= 8 * 4)
        {
            count = 0;
            EP2FIFOBUF[0] = feedback_data[0];
            EP2FIFOBUF[1] = feedback_data[1];
            EP2FIFOBUF[2] = feedback_data[2];
            EP2FIFOBUF[3] = feedback_data[3];

            SYNCDELAY;
            EP2BCH = 0;
            SYNCDELAY;
            EP2BCL = 4;
            SYNCDELAY;
        }
    }
}

BOOL handle_get_descriptor()
{
    switch (SETUPDAT[3])
    {
    case DSCR_DEVICE_TYPE: // 1    Get Descriptor Device
        SUDPTRH = MSB(pDeviceDscr);
        SYNCDELAY;
        SUDPTRL = LSB(pDeviceDscr);
        SYNCDELAY;
        break;

    case DSCR_DEVQUAL_TYPE: // 6    Get Device Qualifier
            SUDPTRH = MSB(pDeviceQualDscr);
            SYNCDELAY;
            SUDPTRL = LSB(pDeviceQualDscr);
            SYNCDELAY;
        break;

    case DSCR_CONFIG_TYPE: //  2   Get Descriptor Configuration
        SUDPTRH = MSB(pHighSpeedConfigDscr);
        SYNCDELAY;
        SUDPTRL = LSB(pHighSpeedConfigDscr);
        SYNCDELAY;
        break;

    case DSCR_OTHERSPD_TYPE: //  7    Other Speed Configuration
        SUDPTRH = MSB(pFullSpeedConfigDscr);
        SYNCDELAY;
        SUDPTRL = LSB(pFullSpeedConfigDscr);
        SYNCDELAY;
        break;

    default:
    }
    return FALSE;
}

BOOL handle_vendorcommand(BYTE cmd)
{
    BYTE tmp;
    switch (cmd)
    {
    case VR_NAKALL_ON:
        tmp = FIFORESET;
        tmp |= bmNAKALL;
        SYNCDELAY;
        FIFORESET = tmp;
        break;
    case VR_NAKALL_OFF:
        tmp = FIFORESET;
        tmp &= ~bmNAKALL;
        SYNCDELAY;
        FIFORESET = tmp;
        break;
    default:
        return TRUE;
    }
    return FALSE;
}

BOOL handle_get_interface(BYTE ifc, BYTE *alt_ifc)
{
    *alt_ifc = AlternateSetting;
    return TRUE;
}

BOOL handle_set_interface(BYTE ifc, BYTE alt_ifc)
{
    AlternateSetting = alt_ifc;

    EP4AUTOINLENH = 0x02; // set AUTOIN commit length to 512 bytes
    SYNCDELAY;
    EP4AUTOINLENL = 0x00;
    SYNCDELAY;
    FIFORESET = 0x80; // activate NAK-ALL to avoid race conditions
    SYNCDELAY;
    EP4FIFOCFG = 0x00; //switching to manual mode
    SYNCDELAY;
    FIFORESET = 0x84; // Reset FIFO 4
    SYNCDELAY;
    OUTPKTEND = 0X84; //OUTPKTEND done twice as EP4 is double buffered by default
    SYNCDELAY;
    OUTPKTEND = 0X84;
    SYNCDELAY;
    EP4FIFOCFG = 0x10; //switching to auto mode
    SYNCDELAY;
    FIFORESET = 0x00; //Release NAKALL
    SYNCDELAY;

    return TRUE;
}

BYTE handle_get_configuration()
{
    return Configuration;
}

BOOL handle_set_configuration(BYTE cfg)
{
    Configuration = cfg;
    return TRUE;
}

void sudav_isr() __interrupt SUDAV_ISR
{
    got_sud = TRUE;
    CLEAR_SUDAV();
}

void sof_isr() __interrupt SOF_ISR __using 1
{
    count++;
    CLEAR_SOF();
}

void usbreset_isr() __interrupt USBRESET_ISR
{
    handle_hispeed(FALSE);
    CLEAR_USBRESET();
}
void hispeed_isr() __interrupt HISPEED_ISR
{
    handle_hispeed(TRUE);
    CLEAR_HISPEED();
}