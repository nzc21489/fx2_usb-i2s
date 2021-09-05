; USB Audio Class 2.0

.module DEV_DSCR 

DSCR_DEVICE_TYPE=1
DSCR_CONFIG_TYPE=2
DSCR_STRING_TYPE=3
DSCR_INTERFACE_TYPE=4
DSCR_ENDPOINT_TYPE=5
DSCR_DEVQUAL_TYPE=6


DSCR_DEVICE_LEN=18
DSCR_CONFIG_LEN=9
DSCR_INTRFC_LEN=9
DSCR_ENDPNT_LEN=7
DSCR_DEVQUAL_LEN=10

ENDPOINT_TYPE_CONTROL=0
ENDPOINT_TYPE_ISO=1
ENDPOINT_TYPE_BULK=2
ENDPOINT_TYPE_INT=3

    .globl	_dev_dscr, _dev_qual_dscr, _highspd_dscr, _fullspd_dscr, _dev_strings, _dev_strings_end, _freq_dscr, _user_dscr

    .area	DSCR_AREA	(ABS)
	.org 0x1800

_dev_dscr:
	.db	0x12                    		;; Descriptor length
	.db	0x01      						;; Decriptor type
	.dw	0x0002							;; Specification Version (BCD)
	.db	0x0EF  							;; Device class
	.db	0x02							;; Device sub-class
	.db	0x01							;; Device sub-sub-class
	.db	64								;; Maximum packet size
	.dw	0x0000 							;; Vendor ID
	.dw	0x0000 							;; Product ID (Sample Device)
	.dw	0x0802							;; Product version ID
	.db	1								;; Manufacturer string index
	.db	2								;; Product string index
	.db	0								;; Serial number string index
	.db	1								;; Number of configurations
dev_dscr_end:

_dev_qual_dscr:
	.db	DSCR_DEVQUAL_LEN                   	;; Descriptor length
	.db	DSCR_DEVQUAL_TYPE					;; Decriptor type
	.dw	0x0002								;; Specification Version (BCD)
	.db	0xEF								;; Device class
	.db	0x02								;; Device sub-class
	.db	0x01								;; Device sub-sub-class
	.db	64									;; Maximum packet size
	.db	1									;; Number of configurations
	.db	0									;; Reserved
dev_qualdscr_end:

_highspd_dscr:
	.db	DSCR_CONFIG_LEN											;; Descriptor length
	.db	DSCR_CONFIG_TYPE										;; Descriptor type
	.db	(highspd_dscr_end - _highspd_dscr) % 256				;; Total Length (LSB)
	.db	(highspd_dscr_end - _highspd_dscr) / 256				;; Total Length (MSB)
	.db	2														;; Number of interfaces
	.db	1														;; Configuration number
	.db	0														;; Configuration string
	.db	0xC0      												;; Attributes (b7 - buspwr, b6 - selfpwr, b5 - rwu)
	.db	50														;; Power requirement (div 2 ma)***************

;; IAD Descriptor
	.db	0x08                ;; Descriptor length
	.db	0x0B       			;; Descriptor type
	.db	0					;; Zero-based index of this interface
	.db	2					;; Number of interfaces
	.db	1					;; FunctionClass
	.db	0x00				;; Interface sub class
	.db	0x20				;; FunctionProtocol
	.db	0					;; Function

;; clock sourece unit(18)
;; EP86 in interrupt 6bytes/packet 4ms
	.db	0x09           		;; Descriptor length
	.db	0x04       			;; Descriptor type
	.db	0					;; Zero-based index of this interface
	.db	0					;; Alternate setting
	.db	1					;; Number of end points 
	.db	0x01				;; Interface class
	.db	0x01				;; Interface sub class
	.db	0x20				;; Interface sub sub class
	.db	0					;; Interface descriptor string index
	
;; Audio Control Interface Header Descriptor 2.0
	.db	0x09           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	01   				;; bDescriptorSubtype
	.db	0					;; bcdADC
	.db	2					;; bcdADC
	.db	0x0A				;; bCategory 
	.db	0x00				;; (pro-audio)
	.db	0x01				;; wTotalLength
	.db	0					;; bmControls
	
;; Audio Control Input Terminal Descriptor 2.0
	.db	0x11           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x02   				;; bDescriptorSubtype (Input Terminal 2.0)
	.db	0x01				;; bTerminalID
	.db	0x01				;; wTerminalType (USB streaming)
	.db	0x01				;; wTerminalType (USB streaming)
	.db	0x00				;; bAssocTerminal
	.db	0x12				;; bCSourceID
	.db	0x00				;; bNrChannels
    .db	0x00           		;; bmChannelConfig
	.db	0x00       			;; bmChannelConfig
	.db	0x00   				;; bmChannelConfig
	.db	0x00				;; bmChannelConfig
	.db	0x00				;; bmChannelConfig
	.db	0x40				;; bmControls
	.db	0x00				;; bmControls
	.db	0x00				;; iTerminal

;; Audio Control Output Terminal Descriptor 2.0
	.db	0x0C           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	03   				;; bDescriptorSubtype (Output Terminal 2.0)
	.db	7					;; bTerminalID
	.db	1					;; wTerminalType (Speaker)
	.db	0x03				;; wTerminalType (Speaker)
	.db	0x00				;; bAssocTerminal
	.db	0x0D				;; bSourceID
	.db	0x12           		;; bCSourceID
    .db	0x04           		;; bmControls
	.db	0x00       			;; bmControls
	.db	0x00   				;; iTerminal
	
	
;; Audio Control Feature Unit Descriptor 2.0
	.db	0x12           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x06   				;; bDescriptorSubtype (Audio Interface Descriptor)
	.db	0x0D           		;; bUnitID
	.db	0x01				;; bSourceID
	.db	0x00				;; bmaControls[0]
	.db	0x00				;; bmaControls[0]
	.db	0x00				;; bmaControls[0]
	.db	0x00				;; bmaControls[0]
    .db	0x00           		;; bmaControls[1]
	.db	0x00       			;; bmaControls[1]
	.db	0x00   				;; bmaControls[1]
	.db	0x00				;; bmaControls[1]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; iFeature 

;; Audio Control Clock Source Unit Descriptor 2.0
	.db	0x08           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x0A   				;; bDescriptorSubtype (Clock Source 2.0)
	.db	0x12           		;; bClockID
	.db	0x03				;; bmAttributes
	.db	0x07				;; bmControls
	.db	0x00				;; bAssocTerminal
	.db	0x00				;; iClockSource

;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType
	.db	0x86   				;; bEndpointAddress (Direction=IN EndpointID=6)
	.db	0x03           		;; bmAttributes (TransferType=Interrupt)
	.db	0x06				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x04				;; bInterval



;; interface 1 of (0,1,2)
;; audio streaming 16bit
;; Interface Descriptor
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x01   				;; bInterfaceNumber
	.db	0x00           		;; bAlternateSetting
	.db	0x00				;; bNumEndpoints (Default Control Pipe only)
	.db	0x01				;; bInterfaceClass 0x01 (Audio)
	.db	0x02				;; bInterfaceSubClass (Audio Streaming)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x04				;; iInterface (String Descriptor 4)

;; interface 1 of (0,1,2)      Alternate 1 of (0.1,2.3)
;; audio streaming 16bit
;; Interface Descriptor
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x01   				;; bInterfaceNumber
	.db	0x01           		;; bAlternateSetting
	.db	0x02				;; bNumEndpoints (2 Endpoints)
	.db	0x01				;; bInterfaceClass (Audio)
	.db	0x02				;; bInterfaceSubClass (Audio Streaming)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x00				;; iInterface (No String Descriptor)
	
;; Audio Streaming Interface Descriptor 2.0
	.db	0x10           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x01   				;; bDescriptorSubtype (AS General)
	.db	0x01           		;; bTerminalLink
	.db	0x05				;; bmControls
	.db	0x01				;; bFormatType (FORMAT_TYPE_I)
	.db	0x01				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00           		;; bmFormats (PCM)
	.db	0x02       			;; bNrChannels (2 channels)
	.db	0x03   				;; bmChannelConfig (FL, FR)
	.db	0x00           		;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; iChannelNames (No String Descriptor)

;; Audio Streaming Format Type Descriptor 2.0
	.db	0x06           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x02   				;; bDescriptorSubtype (Format Type)
	.db	0x01           		;; bFormatType (FORMAT_TYPE_I)
	.db	0x02				;; bSubslotSize
	.db	0x10				;; bBitResolution (16 bits)

	
;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x04   				;; bEndpointAddress (Direction=OUT EndpointID=4)
	.db	0x05           		;; bmAttributes (TransferType=Isochronous  SyncType=Asynchronous  EndpointType=Data)
	.db	0x90				;; wMaxPacketSize
	.db	0x01				;; wMaxPacketSize
	.db	0x01				;; bInterval
	
;; Audio Data Endpoint Descriptor
	.db	0x08           		;; bLength
	.db	0x25       			;; bDescriptorType (Audio Endpoint Descriptor)
	.db	0x01   				;; bDescriptorSubtype (General)
	.db	0x00           		;; bmAttributes
	.db	0x00				;; bLockDelayUnits
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay

;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x82   				;; bEndpointAddress (Direction=IN EndpointID=2)
	.db	0x11           		;; bmAttributes (TransferType=Isochronous  SyncType=None  EndpointType=Feedback)
	.db	0x04				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x04				;;bInterval

;; interface 1 of (0,1,2) Alternate 2 of (0.1,2.3)
;; audio streaming 24bit
;; Interface Descriptor
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x01   				;; bInterfaceNumber
	.db	0x02           		;; bAlternateSetting
	.db	0x02				;; bNumEndpoints (2 Endpoints)
	.db	0x01				;; bInterfaceClass (Audio)
	.db	0x02				;; bInterfaceSubClass (Audio Streaming)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x00				;; iInterface (No String Descriptor)

;; Audio Streaming Interface Descriptor 2.0
	.db	0x10           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x01   				;; bDescriptorSubtype (AS General)
	.db	0x01           		;; bTerminalLink
	.db	0x05				;; bmControls
	.db	0x01				;; bFormatType (FORMAT_TYPE_I)
	.db	0x01				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00           		;; bmFormats (PCM)
	.db	0x02       			;; bNrChannels (2 channels)
	.db	0x03   				;; bmChannelConfig (FL, FR)
	.db	0x00           		;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; iChannelNames (No String Descriptor)
	
;; Audio Streaming Format Type Descriptor 2.0
	.db	0x06           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x02   				;; bDescriptorSubtype(Format Type)
	.db	0x01           		;; bFormatType (FORMAT_TYPE_I)
	.db	0x03				;; bSubslotSize
	.db	0x18				;; bBitResolution (24 bits)

;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x04   				;; bEndpointAddress (Direction=OUT EndpointID=4)
	.db	0x05           		;; bmAttributes (TransferType=Isochronous  SyncType=Asynchronous  EndpointType=Data)
	.db	0x90				;; wMaxPacketSize
	.db	0x01				;; wMaxPacketSize
	.db	0x01				;; bInterval 0x01 (1 ms)
	
;; Audio Data Endpoint Descriptor
	.db	0x08           		;; bLength
	.db	0x25       			;; bDescriptorType (Audio Endpoint Descriptor)
	.db	0x01   				;; bDescriptorSubtype (General)
	.db	0x00           		;; bmAttributes
	.db	0x00				;; bLockDelayUnits
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	
;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x82   				;; bEndpointAddress (Direction=IN EndpointID=2)
	.db	0x11           		;; bmAttributes (TransferType=Isochronous  SyncType=None  EndpointType=Feedback)
	.db	0x04				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x04				;; bInterval (4 ms)

;; interface 1 of (0,1,2) Alternate 3 of (0.1,2.3)
;; audio streaming 32bit
;; Interface Descriptor
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x01   				;; bInterfaceNumber
	.db	0x03           		;; bAlternateSetting
	.db	0x02				;; bNumEndpoints (2 Endpoints)
	.db	0x01				;; bInterfaceClass (Audio)
	.db	0x02				;; bInterfaceSubClass (Audio Streaming)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x00				;; iInterface (No String Descriptor)
	
;; Audio Streaming Interface Descriptor 2.0
    .db	0x10           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x01   				;; bDescriptorSubtype (AS General)
	.db	0x01           		;; bTerminalLink
	.db	0x05				;; bmControls
	.db	0x01				;; bFormatType (FORMAT_TYPE_I)
	.db	0x01				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00           		;; bmFormats (PCM)
	.db	0x02       			;; bNrChannels (2 channels)
	.db	0x03   				;; bmChannelConfig (FL, FR)
	.db	0x00           		;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; iChannelNames (No String Descriptor)
	
;; Audio Streaming Format Type Descriptor 2.0
	.db	0x06           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x02   				;; bDescriptorSubtype (Format Type)
	.db	0x01           		;; bFormatType (FORMAT_TYPE_I)
	.db	0x04				;; bSubslotSize
	.db	0x20				;; bBitResolution (32 bits)
	
;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x04   				;; bEndpointAddress (Direction=OUT EndpointID=4)
	.db	0x05           		;; bmAttributes (TransferType=Isochronous  SyncType=Asynchronous  EndpointType=Data)
	.db	0x90				;; wMaxPacketSize
	.db	0x01				;; wMaxPacketSize
	.db	0x01				;; bInterval
	
;; Audio Data Endpoint Descriptor
	.db	0x08           		;; bLength
	.db	0x25       			;; bDescriptorType (Audio Endpoint Descriptor)
	.db	0x01   				;; bDescriptorSubtype (General)
	.db	0x00           		;; bmAttributes
	.db	0x00				;; bLockDelayUnits
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	
;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x82   				;; bEndpointAddress (Direction=IN EndpointID=2)
	.db	0x11           		;; bmAttributes (TransferType=Isochronous  SyncType=None  EndpointType=Feedback)
	.db	0x04				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x04				;; bInterval (4 ms)
highspd_dscr_end:

    .even
_fullspd_dscr:
;; Other Speed Configuration Descriptor
	.db	DSCR_CONFIG_LEN											;; Descriptor length
	.db	DSCR_CONFIG_TYPE										;; Descriptor type
	.db	(fullspd_dscr_end - _fullspd_dscr) % 256				;; Total Length (LSB)
	.db	(fullspd_dscr_end - _fullspd_dscr) / 256				;; Total Length (MSB)
	.db	3														;; Number of interfaces
	.db	1														;; Configuration number
	.db	0														;; Configuration string
	.db	0xC0      												;; Attributes (b7 - buspwr, b6 - selfpwr, b5 - rwu)
	.db	50														;; Power requirement (div 2 ma)

; IAD Descriptor
	.db	0x08           		;; bLength
	.db	0x0B       			;; bDescriptorType
	.db	0x00   				;; bFirstInterface
	.db	0x02           		;; bInterfaceCount
	.db	0x01				;; bFunctionClass (Audio)
	.db	0x00				;; bFunctionSubClass (undefined)
	.db	0x20				;;bFunctionProtocol (AF 2.0)
	.db	0x00				;; iFunction (No String Descriptor)
	
;; Interface Descriptor
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x00   				;; bInterfaceNumber
	.db	0x00           		;; bAlternateSetting
	.db	0x01				;; bNumEndpoints (1 Endpoint)
	.db	0x01				;; bInterfaceClass (Audio)
	.db	0x01				;; bInterfaceSubClass (Audio Control)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x00				;; iInterface (No String Descriptor)

;; Audio Control Interface Header Descriptor 2.0
	.db	0x09           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x01   				;; bDescriptorSubtype (Header 2.0)
	.db	0x00           		;; bcdADC (2.0)
	.db	0x02				;; bcdADC (2.0)
	.db	0x0A				;; bCategory (pro-audio)
	.db	0x00				;; wTotalLength
	.db	0x01				;; bmControls
	.db	0x00				;; bmControls

;; Audio Control Input Terminal Descriptor 2.0
	.db	0x11           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x02   				;; bDescriptorSubtype (Input Terminal 2.0)
	.db	0x01           		;; bTerminalID
	.db	0x01				;; wTerminalType (USB streaming)
	.db	0x01				;; wTerminalType (USB streaming)
	.db	0x00				;; bAssocTerminal
	.db	0x12				;; bCSourceID
	.db	0x00				;; bNrChannels (0 Channels)
	.db	0x00       			;; bmChannelConfig
	.db	0x00   				;; bmChannelConfig
	.db	0x00           		;; bmChannelConfig
	.db	0x00				;; bmChannelConfig
	.db	0x00				;; iChannelNames (No String Descriptor)
	.db	0x40				;; bmControls
	.db	0x00				;; bmControls
	.db	0x00				;; iTerminal (No String Descriptor)

; Audio Control Output Terminal Descriptor 2.0
	.db	0x0C           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x03   				;; bDescriptorSubtype (Output Terminal 2.0)
	.db	0x07           		;; bTerminalID
	.db	0x01				;; wTerminalType (Speaker)
	.db	0x03				;; wTerminalType (Speaker)
	.db	0x00           		;; bAssocTerminal
	.db	0x0D       			;; bSourceID
	.db	0x12   				;; bCSourceID
	.db	0x04           		;; 
	.db	0x00				;; 
	.db	0x00				;; iTerminal
	
;; Audio Control Feature Unit Descriptor 2.0
	.db	0x12           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x06   				;; bDescriptorSubtype (Feature Unit 2.0)
	.db	0x0D           		;; bUnitID
	.db	0x01				;; bSourceID
	.db	0x03				;; bmaControls[0]
	.db	0x00				;; bmaControls[0]
	.db	0x00				;; bmaControls[0]
	.db	0x00				;; bmaControls[0]
    .db	0x00           		;; bmaControls[1]
	.db	0x00       			;; bmaControls[1]
	.db	0x00   				;; bmaControls[1]
	.db	0x00           		;; bmaControls[1]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; bmaControls[2]
	.db	0x00				;; iFeature (No String Descriptor)

;; Audio Control Clock Source Unit Descriptor 2.0
	.db	0x08           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x0A   				;; bDescriptorSubtype (Clock Source 2.0)
	.db	0x12           		;; bClockID
	.db	0x03				;; bmAttributes
	.db	0x07				;; bmControls
	.db	0x00				;; bAssocTerminal
	.db	0x00				;; iClockSource (No String Descriptor)

;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x8F   				;; bEndpointAddress (Direction=IN EndpointID=15)
	.db	0x03           		;; bmAttributes (TransferType=Interrupt)
	.db	0x06				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x01				;; bInterval (1 ms)
	
;; Interface Descriptor
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x01   				;; bInterfaceNumber
	.db	0x00           		;; bAlternateSetting
	.db	0x00				;; bNumEndpoints (Default Control Pipe only)
	.db	0x01				;; bInterfaceClass (Audio)
	.db	0x02				;; bInterfaceSubClass (Audio Streaming)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x04				;; iInterface (String Descriptor 4)

;; Interface Descriptor;
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x01   				;; bInterfaceNumber
	.db	0x01           		;; bAlternateSetting
	.db	0x02				;; bNumEndpoints (2 Endpoints)
	.db	0x01				;; bInterfaceClass (Audio)
	.db	0x02				;; bInterfaceSubClass (Audio Streaming)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x00				;; iInterface (No String Descriptor)
	
;; Audio Streaming Interface Descriptor 2.0
    .db	0x10           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x01   				;; bDescriptorSubtype (AS General)
	.db	0x01           		;; bTerminalLink
	.db	0x05				;; bmControls
	.db	0x01				;; bFormatType
	.db	0x01				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00           		;; bmFormats (PCM)
	.db	0x02       			;; bNrChannels (2 channels)
	.db	0x03   				;; bmChannelConfig (FL, FR)
	.db	0x00           		;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; iChannelNames (No String Descriptor)
	
;; Audio Streaming Format Type Descriptor 2.0
	.db	0x06           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x02   				;; bDescriptorSubtype (Format Type)
	.db	0x01           		;; bFormatType (FORMAT_TYPE_I)
	.db	0x02				;; bSubslotSize (2 bytes)
	.db	0x10				;; bBitResolution (16 bits)
	
;; Endpoint Descriptor
    .db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x05   				;; bEndpointAddress (Direction=OUT EndpointID=5)
	.db	0x05           		;; bmAttributes (TransferType=Isochronous  SyncType=Asynchronous  EndpointType=Data)
	.db	0xC8				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x01				;; bInterval

;; Audio Data Endpoint Descriptor
	.db	0x08           		;; bLength
	.db	0x25       			;; bDescriptorType (Audio Endpoint Descriptor)
	.db	0x01   				;; bDescriptorSubtype (General)
	.db	0x00           		;; bmAttributes
	.db	0x00				;; bLockDelayUnits
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	
;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x85   				;; bEndpointAddress (Direction=IN EndpointID=5)
	.db	0x11           		;; bmAttributes (TransferType=Isochronous  SyncType=None  EndpointType=Feedback)
	.db	0x03				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x01				;; bInterval (1 ms)

;; Interface Descriptor
	.db	0x09           		;; bLength
	.db	0x04       			;; bDescriptorType (Interface Descriptor)
	.db	0x01   				;; bInterfaceNumber
	.db	0x02           		;; bAlternateSetting
	.db	0x02				;; bNumEndpoints (2 Endpoints)
	.db	0x01				;; bInterfaceClass (Audio)
	.db	0x02				;; bInterfaceSubClass (Audio Streaming)
	.db	0x20				;; bInterfaceProtocol (Device Protocol Version 2.0)
	.db	0x00				;; iInterface (No String Descriptor)

;; Audio Streaming Interface Descriptor 2.0
    .db	0x10           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x01   				;; bDescriptorSubtype (AS General)
	.db	0x01           		;; bTerminalLink
	.db	0x05				;; bmControls
	.db	0x01				;; bFormatType (FORMAT_TYPE_I)
	.db	0x01				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00				;; bmFormats (PCM)
	.db	0x00           		;; bmFormats (PCM)
	.db	0x02       			;; bNrChannels (2 channels)
	.db	0x03   				;; bmChannelConfig (FL, FR)
	.db	0x00           		;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; bmChannelConfig (FL, FR)
	.db	0x00				;; iChannelNames (No String Descriptor)


;; Audio Streaming Format Type Descriptor 2.0
	.db	0x06           		;; bLength
	.db	0x24       			;; bDescriptorType (Audio Interface Descriptor)
	.db	0x02   				;; bDescriptorSubtype(Format Type)
	.db	0x01           		;; bFormatType (FORMAT_TYPE_I)
	.db	0x03				;; bSubslotSize
	.db	0x18				;; bBitResolution (24 bits)

;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x05   				;; bEndpointAddress (Direction=OUT EndpointID=5)
	.db	0x05           		;; bmAttributes (TransferType=Isochronous  SyncType=Asynchronous  EndpointType=Data)
	.db	0x2C				;; wMaxPacketSize
	.db	0x01				;; wMaxPacketSize
	.db	0x01				;; bInterval (1 ms)

	
;;----- Audio Data Endpoint Descriptor-----
	.db	0x08           		;; bLength
	.db	0x25       			;; bDescriptorType (Audio Endpoint Descriptor)
	.db	0x01   				;; bDescriptorSubtype (General)
	.db	0x00           		;; bmAttributes
	.db	0x00				;; bLockDelayUnits
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay
	.db	0x00				;; wLockDelay

;; Endpoint Descriptor
	.db	0x07           		;; bLength
	.db	0x05       			;; bDescriptorType (Endpoint Descriptor)
	.db	0x85   				;; bEndpointAddress (Direction=IN EndpointID=5)
	.db	0x11           		;; bmAttributes (TransferType=Isochronous  SyncType=None  EndpointType=Feedback)
	.db	0x03				;; wMaxPacketSize
	.db	0x00				;; wMaxPacketSize
	.db	0x01				;; bInterval (1 ms)

fullspd_dscr_end:   

.even
_dev_strings:
 _string0:
 	.db	string0end-_string0		;len
	.db	DSCR_STRING_TYPE
	.db	0x09,0x04     ; who knows
string0end:

_string1:
    .db string1end-_string1
    .db DSCR_STRING_TYPE
	.ascii 'n'
	.db 0x00
	.ascii 'z'
	.db	0x00
	.ascii 'c'
	.db	0x00
	.ascii '2'
	.db	0x00
	.ascii '1'
	.db	0x00
	.ascii '4'
	.db	0x00
	.ascii '8'
	.db	0x00
    .ascii '9'
	.db	0x00
string1end:

_string2:
    .db string2end-_string2
    .db DSCR_STRING_TYPE
	.ascii 'F'
	.db	0x00
	.ascii 'X'
	.db	0x00
	.ascii '2'
	.db	0x00
	.ascii ' '
	.db	0x00
	.ascii 'U'
	.db	0x00
	.ascii 'S'
	.db	0x00
	.ascii 'B'
	.db	0x00
	.ascii '-'
	.db	0x00
	.ascii 'I'
	.db	0x00
	.ascii '2'
	.db	0x00
	.ascii 'S'
	.db	0x00
string2end:

_string3:
    .db string3end-_string3
    .db DSCR_STRING_TYPE
	.ascii 'U'
	.db	0x00
	.ascii 'S'
	.db	0x00
	.ascii 'B'
	.db	0x00
	.ascii '2'
	.db	0x00
	.ascii '.'
	.db	0x00
	.ascii '0'
	.db	0x00
	.ascii ' '
	.db	0x00
	.ascii 'A'
	.db	0x00
	.ascii 'u'
	.db	0x00
	.ascii 'd'
	.db	0x00
	.ascii 'i'
	.db	0x00
	.ascii 'o'
	.db	0x00
	.ascii ' '
	.db	0x00
	.ascii 'D'
	.db	0x00
	.ascii 'e'
	.db	0x00
	.ascii 'v'
	.db	0x00
	.ascii 'i'
	.db	0x00
	.ascii 'c'
	.db	0x00
	.ascii 'e'
	.db	0x00
string3end:
    
_string4:	
    .db string4end-_string4
    .db DSCR_STRING_TYPE
	.ascii 'S'
	.db	0x00
	.ascii 'p'
	.db	0x00
	.ascii 'e'
	.db	0x00
	.ascii 'a'
	.db	0x00
	.ascii 'k'
	.db	0x00
	.ascii 'e'
	.db	0x00
	.ascii 'r'
	.db	0x00
string4end:

_dev_strings_end:

_user_dscr:
user_dscr:
    .dw 0x0000   ; just in case someone passes an index higher than the end to the firmware
user_dscr_end:

_freq_dscr:
freq_dscr:
	.db	0x08           		;; 
	.db	0x00       			;; 
	.db	0x44   				;; 
	.db	0xAC           		;; 
	.db	0x00				;; 
	.db	0x00				;; 
	.db	0x44				;;
	.db	0xAC				;; 
	.db	0x00           		;; 
	.db	0x00       			;; 
	.db	0x00   				;; 
	.db	0x00           		;; 
	.db	0x00				;; 
	.db	0x00				;; 
	.db	0x80				;;
	.db	0xBB				;; 
	
	.db	0x00           		;; 
	.db	0x00       			;; 
	.db	0x80   				;; 
	.db	0xBB           		;; 
	.db	0x00				;; 
	.db	0x00				;; 
	.db	0x00				;;
	.db	0x00				;; 
	.db	0x00           		;; 
	.db	0x00       			;; 
	.db	0x88   				;; 
	.db	0x58           		;; 
	.db	0x01				;; 
	.db	0x00				;; 
	.db	0x88				;;
	.db	0x58				;; 
	
	.db	0x01           		;; 
	.db	0x00       			;; 
	.db	0x00   				;; 
	.db	0x00           		;; 
	.db	0x00				;; 
	.db	0x00				;; 
	.db	0x00				;;
	.db	0x77				;; 
	.db	0x01           		;; 
	.db	0x00       			;; 
	.db	0x00   				;; 
	.db	0x77           		;; 
	.db	0x01				;; 
	.db	0x00				;; 
	.db	0x00				;;
	.db	0x00				;; 
	
	.db	0x00           		;; 
	.db	0x00       			;; 
	.db	0x10   				;; 
	.db	0xB1           		;; 
	.db	0x02				;; 
	.db	0x00				;; 
	.db	0x10				;;
	.db	0xB1				;; 
	.db	0x02           		;; 
	.db	0x00       			;; 
	.db	0x00   				;; 
	.db	0x00           		;; 
	.db	0x00				;; 
	.db	0x00				;; 
	.db	0x00				;;
	.db	0xEE				;; 
	
	.db	0x02           		;; 
	.db	0x00       			;; 
	.db	0x00   				;; 
	.db	0xEE           		;; 
	.db	0x02				;; 
	.db	0x00				;; 
	.db	0x00				;;
	.db	0x00				;; 
	.db	0x00           		;; 
	.db	0x00       			;; 
	.db	0x20   				;; 
	.db	0x62           		;; 
	.db	0x05				;; 
	.db	0x00				;; 
	.db	0x20				;;
	.db	0x62				;; 
	
	.db	0x05           		;; 
	.db	0x00       			;; 
	.db	0x00   				;; 
	.db	0x00           		;; 
	.db	0x00				;; 
	.db	0x00				;; 
	.db	0x00				;;
	.db	0xDC				;; 
	.db	0x05           		;; 
	.db	0x00       			;; 
	.db	0x00   				;; 
	.db	0xDC           		;; 
	.db	0x05				;; 
	.db	0x00				;; 
	.db	0x00				;;
	.db	0x00				;; 
	
	.db	0x00           		;; 
	.db	0x00       			;; 

freq_dscr_end:
