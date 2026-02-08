import sys, os, time
import ftd2xx as ft

def main(description="UM232H-B"):
    """ Send/receive data from the FPGA using FIFO
        mode of the FT232H.
    """
    try:
        while True:
            # Get user input
            num_input = input('Enter an integer, GET, or EXIT: ')

            if num_input.upper() == 'EXIT':
                break
            else:
                # Create the usb list.
                num_devices = ft.createDeviceInfoList()
                if (num_devices == 0):
                    print("\tNo devices found")
                    sys.exit()
                print(f"\tFound {num_devices} devices")

                # Get the usb information for the usb with sync FIFO mode.
                device_info = None
                device_index = 0
                for index in range(0, num_devices):
                    device_info = ft.getDeviceInfoDetail(devnum = index, update = False)
                    if (device_info['description'] == description.encode()):
                        device_index = index
                        break
                if (device_info == None):
                    print(f"\tDevice {description} not found")
                    sys.exit()

                # Open usb and configure
                usb = ft.open(dev = device_index)
                usb.setLatencyTimer(2)                               	# Receive buffer timeout in msec        
                usb.setFlowControl(ft.defines.FLOW_RTS_CTS, 0, 0)    	# Flow control method
                usb.setTimeouts(100000, 3)                           	# Set timeout for read and write in ms
                usb.setUSBParameters(65536, 65536)                       	# Set transfer in/out size to 4096
                print(f"\tConnected to {description} usb - {device_info['serial'].decode()}")

                # Execute operation
                if num_input.upper() == 'GET':
                    bytes_received = usb.getQueueStatus()
                    try:
                        data = usb.read(bytes_received)
                        for _ in data:
                            print(f"\tData received: {hex(_)}")
                    except IndexError:
                        print("\tNo bytes in the transmit queue")
                else:
                    try:
                        num_int = int(num_input)
                    except ValueError:
                        print('\tError: To write to device, enter an integer between 0 and 255. Otherwise, enter GET to read from the device or EXIT to quit.')
                        usb.close()
                        continue
                    if num_int < 0 or num_int > 255:
                        print('\tError: Enter an integer between 0 and 255')
                        usb.close()
                        continue
                    usb.write(chr(num_int))
                    print(f'\tSent {chr(num_int)} to USB device')
                # Close port
                usb.close()                    
    except:
        print("\n\nSome error!")

if __name__ == "__main__":

	main()