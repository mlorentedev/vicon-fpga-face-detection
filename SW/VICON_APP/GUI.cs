using System;
using System.Windows.Forms;

namespace VICON_APP
{
    public partial class GUI : Form
    {
        Camera camera = new Camera();

        // INIT METHOD
        public GUI()
        {
            InitializeComponent();
            if (Camera.fConnected == true) connectButton.Text = "Disconnect";
            else connectButton.Text = "Connect";
        }

        // CONNECT BUTTON
        private void ConnectButton_Click(object sender, EventArgs e)
        {
            if (connectButton.Text == "Connect")
            {
                Camera.fConnected = camera.Connect();
                if (Camera.fConnected == true)
                {
                    connectButton.Text = "Disconnect";
                    startButton.Enabled = true;
                    snapButton.Enabled = false;
                    faceDetection.Enabled = true;
                }
                else
                {
                    startButton.Enabled = false;
                    snapButton.Enabled = false;
                    faceDetection.Enabled = false;
                    connectButton.Text = "Connect";
                }
            }
            else
            {
                camera.Disconnect();
                startButton.Enabled = false;
                snapButton.Enabled = false;
                faceDetection.Enabled = false;
                connectButton.Text = "Connect";
            }
        }

        // START ACQUISITION BUTTON
        private void StartButton_Click(object sender, EventArgs e)
        {
            if (startButton.Text == "Start")
            {
                Camera.fData = true;
                snapButton.Enabled = true;
                startButton.Text = "Stop";
                Camera.Logger(Camera.Logtype.info, "Data acquisition started");
            }
            else
            {
                Camera.fData = false;
                snapButton.Enabled = false;
                startButton.Text = "Start";
                Camera.Logger(Camera.Logtype.info, "Data acquisition stopped");
            }
        }

        // SNAP IMAGE BUTTON
        private void SnapButton_Click(object sender, EventArgs e)
        {
            snapButton.Enabled = false;
            Camera.fSnap = true;
            System.Windows.Forms.SaveFileDialog dialog = new System.Windows.Forms.SaveFileDialog();
            dialog.Filter = "Image Format (*.bmp)|.bmp";
            if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
            {
                int width = Convert.ToInt32(Camera.Image.Width);
                int height = Convert.ToInt32(Camera.Image.Height);
                Camera.Image.Save(dialog.FileName, System.Drawing.Imaging.ImageFormat.Bmp);
            }
            Camera.fSnap = false;
            snapButton.Enabled = true;
        }

        // About information
        private void AboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("VICON APP v0.0.2\n\nManuel Lorente Almán\n\nMaster en Sistemas Electrónicos para Entornos Inteligentes\n\nUniversidad de Málaga", "About");
        }

        // Face detection enable
        private void FaceDetection_Click(object sender, EventArgs e)
        {
            Camera.fFaces = faceDetection.Checked;
            if (faceDetection.Checked == true)
            {
                Camera.Logger(Camera.Logtype.info, "Face detection started");
            }
            else
            {
                Camera.Logger(Camera.Logtype.info, "Face detection stopped");
            }
        }
    }
}
