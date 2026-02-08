using System;
using System.Drawing;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

using Emgu.CV;
using Emgu.CV.Structure;

using FTD2XX_NET;
using FT_HANDLE = System.UInt32;

namespace VICON_APP
{
    public class Camera : Form
    {
        // Logger scope
        public enum Logtype
        {
            start = 0,
            USB_connected,
            USB_disconnected,
            USB_not_found,
            USB_error,
            info,
            debug
        };

        private static string[] Logmsg = new string[]
        {
                "CAMERA INIT:",
                "CAMERA CONNECTED:",
                "CAMERA DISCONNECTED:",
                "CAMERA NOT FOUND:",
                "CAMERA ERROR:",
                "CAMERA INFO:",
                ""
        };

        // FTDI scope
        public static string name = "UM232H-B";
        public static bool fData, fConnected, fFaces, fSnap;
        public static UInt32 image_width = 640;             // VGA image
        public static UInt32 image_height = 480;            // VGA image
        public static UInt32 buffer_size = image_width * image_height;
        public static UInt32 read_timeout_ms = 66;
        public static UInt32 write_timeout_ms = 1;
        public static byte latency_timer = 2;
        public static string serialNumber, description, portName;
        protected FT_HANDLE m_hPort;
        FTDI FTDIDevice = new FTDI();
        FTDI.FT_STATUS ftStatus = FTDI.FT_STATUS.FT_OTHER_ERROR;

        // Data stream scope
        protected bool fRead;
        private byte[] buffer_rx = new Byte[1];
        private byte[] buffer_tx = new Byte[buffer_size];

        // Auxiliary global variables
        UInt32 nframe = 0;
        UInt32 dwRet = 1;
        UInt32 TxBytes = 0;
        UInt32 RxBytes = 0;

        // Context information variables
        long tic, toc;
        int fps = 0;

        // Image acquisition variables
        Image<Gray, Byte> frame;
        GCHandle pinnedArray;
        IntPtr pointer;
        public static Bitmap Image = new Bitmap(640, 480);

        // Face detection variables
        CascadeClassifier classifier = new CascadeClassifier(@System.IO.Directory.GetCurrentDirectory().ToString() + "\\haarcascade_frontalface_default.xml");

        // Threads scope
        protected Thread pThreadRead;

        // FTDI Connection
        public bool Connect()
        {
            UInt32 numDevs = 0;

            ftStatus = FTDIDevice.GetNumberOfDevices(ref numDevs);
            if (ftStatus == FTDI.FT_STATUS.FT_OK)
            {
                if (numDevs == 0)
                {
                    Logger(Logtype.USB_not_found, Camera.name);
                    return false;
                }
                var FTDIDeviceList = new FTD2XX_NET.FTDI.FT_DEVICE_INFO_NODE[numDevs];
                ftStatus = FTDIDevice.GetDeviceList(FTDIDeviceList);
                for (UInt32 i = 0; i < numDevs; i++)
                {
                    // Open first device that matches FTDI description
                    if (Camera.name == FTDIDeviceList[i].Description.ToString())
                    {
                        serialNumber = FTDIDeviceList[i].SerialNumber;
                        Logger(Logtype.start, "Device index: " + i.ToString());
                        Logger(Logtype.start, "Device ID: " + String.Format("{0:x}", FTDIDeviceList[i].ID));
                        Logger(Logtype.start, "Device serial number: " + FTDIDeviceList[i].SerialNumber.ToString());
                        Logger(Logtype.start, "Device description: " + FTDIDeviceList[i].Description.ToString());
                        break;
                    }
                }
                if ((ftStatus == FTDI.FT_STATUS.FT_OK) && (serialNumber != null))
                {
                    ftStatus = FTDIDevice.OpenBySerialNumber(serialNumber);
                    if (ftStatus == FTDI.FT_STATUS.FT_OK)
                    {
                        // Reset the device
                        ftStatus = FTDIDevice.ResetDevice();
                        if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Reset Device" + Convert.ToString(ftStatus));
                        // Set latency
                        ftStatus = FTDIDevice.SetLatency(latency_timer);
                        if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Set Latency Timer " + Convert.ToString(ftStatus));
                        // Set RTS/CTS flow control
                        ftStatus = FTDIDevice.SetFlowControl(FTDI.FT_FLOW_CONTROL.FT_FLOW_RTS_CTS, 0, 0);
                        if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Set Flow Control " + Convert.ToString(ftStatus));
                        // Set read and write timeouts
                        ftStatus = FTDIDevice.SetTimeouts(read_timeout_ms, write_timeout_ms);
                        if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Set Timeouts " + Convert.ToString(ftStatus));
                        // Set buffer size to 64KB
                        ftStatus = FTDIDevice.InTransferSize(65536);
                        if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Set Buffer size " + Convert.ToString(ftStatus));
                        // Flush USB buffers
                        ftStatus = FTDIDevice.Purge(FTDI.FT_PURGE.FT_PURGE_RX | FTDI.FT_PURGE.FT_PURGE_TX);
                        if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Purge Buffers" + Convert.ToString(ftStatus));
                        // Get port connection
                        ftStatus = FTDIDevice.GetCOMPort(out portName);
                        // Connection successful
                        Logger(Logtype.USB_connected, Camera.name + " - " + serialNumber.ToString() + " (" + portName + ")");
                        // Launch read thread
                        fRead = false;
                        pThreadRead = new Thread(new ThreadStart(ReadThread));
                        pThreadRead.Start();
                        return true;
                    }
                    else Logger(Logtype.USB_error, "Failed To Open Port" + Convert.ToString(ftStatus));
                    return false;
                }
                else
                {
                    Logger(Logtype.USB_not_found, "Error list devices. " + Camera.name + "not found");
                    return false;
                }
            }
            else
            {
                Logger(Logtype.USB_error, ftStatus.ToString());
                return false;
            }
        }

        // FTDI Disconnection
        public void Disconnect()
        {
            // Stop acquisition variables
            Camera.fConnected = false;
            Camera.fData = false;
            GUI.video.Image = null;
            GUI.fpsLabel.Text = "";
            GUI.framesLabel.Text = "";
            // Stop read thread
            fRead = false;
            Thread.Sleep(1000);
            pThreadRead.Interrupt();
            pThreadRead.Abort();
            // Reset and close USB device
            FTDIDevice.ResetDevice();
            FTDIDevice.Close();
            Logger(Logtype.USB_disconnected, Camera.name + " - " + serialNumber.ToString() + " (" + portName + ")");
        }

        // FTDI READING THREAD
        private void ReadThread()
        {
            while (true)
            {
                while (Camera.fData == true)
                {
                    if (fRead == true)
                    {
                        // Get number of bytes to be read
                        ftStatus = FTDIDevice.GetRxBytesAvailable(ref RxBytes);
                        if (ftStatus != FTDI.FT_STATUS.FT_OK)
                        {
                            pThreadRead.Abort();
                        }
                        if (RxBytes > 0)
                        {
                            ftStatus = FTDIDevice.Read(buffer_tx, buffer_size, ref dwRet);
                            if (ftStatus == FTDI.FT_STATUS.FT_OK)
                            {
                                GUIUpdate();
                            }
                        }
                    }
                    else
                    {
                        // Send dummy data to enable acquisition
                        buffer_rx[0] = 0;
                        ftStatus = FTDIDevice.Purge(FTDI.FT_PURGE.FT_PURGE_RX | FTDI.FT_PURGE.FT_PURGE_TX);
                        if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Purge Buffers " + Convert.ToString(ftStatus));
                        ftStatus = FTDIDevice.GetTxBytesWaiting(ref TxBytes);
                        if ((ftStatus == FTDI.FT_STATUS.FT_OK) && (TxBytes == 0))
                        {
                            ftStatus = FTDIDevice.Write(buffer_rx, 1, ref dwRet);
                            if (ftStatus != FTDI.FT_STATUS.FT_OK) Logger(Logtype.USB_error, "Failed To Write " + Convert.ToString(ftStatus));
                            else
                            {
                                fRead = true;
                                // Only refresh FPS every 5 frames to optimize the algorithm
                                if (nframe % 5 == 0) tic = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
                            }
                        }
                        else Logger(Logtype.USB_error, Convert.ToString(ftStatus));
                    }
                }
                fRead = false;
                GUI.video.Image = null;
            }
        }

        // Need to make logTextBox static in designer code to remove one potential error
        public static void Logger(Logtype index, string data = null)
        {
            GUI.logTextBox.Invoke((MethodInvoker)delegate
            {
                if (data == null) GUI.logTextBox.AppendText(Logmsg[(int)index] + "\r\n");
                else GUI.logTextBox.AppendText(Logmsg[(int)index] + " " + data.ToString() + "\r\n");
            });
        }

        // GUI update function
        private void GUIUpdate()
        {
            GUI.video.Invoke((MethodInvoker)delegate
            {
                fRead = false;
                pinnedArray = GCHandle.Alloc(buffer_tx, GCHandleType.Pinned);
                pointer = pinnedArray.AddrOfPinnedObject();
                frame = new Image<Gray, Byte>(640, 480, 640, pointer);
                pinnedArray.Free();
                if (frame != null && Camera.fFaces == true)
                {
                    var faces = classifier.DetectMultiScale(frame, 1.25, 4);
                    foreach (var face in faces) frame.Draw(face, new Gray(double.MaxValue), 2);
                }
                if (fSnap == true) Image = frame.ToBitmap();
                else
                {
                    GUI.video.Image = frame.ToBitmap();
                }
                // Only refresh FPS every 5 frames to optimize the algorithm
                if (nframe % 5 == 0)
                {
                    toc = tic;
                    tic = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
                }
                fps = (int)(1000 / (tic - toc));
                nframe++;
                GUI.fpsLabel.Text = (fps.ToString() + " FPS");
                GUI.framesLabel.Text = ("Frame #" + nframe.ToString());
            });
        }
    }
}
