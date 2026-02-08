namespace VICON_APP
{
    partial class GUI
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(GUI));
            this.connectButton = new System.Windows.Forms.Button();
            this.snapButton = new System.Windows.Forms.Button();
            logTextBox = new System.Windows.Forms.TextBox();
            this.logLabel = new System.Windows.Forms.Label();
            video = new System.Windows.Forms.PictureBox();
            this.videoLabel = new System.Windows.Forms.Label();
            this.faceDetection = new System.Windows.Forms.CheckBox();
            fpsLabel = new System.Windows.Forms.Label();
            framesLabel = new System.Windows.Forms.Label();
            this.mainMenu = new System.Windows.Forms.MenuStrip();
            this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.startButton = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(video)).BeginInit();
            this.mainMenu.SuspendLayout();
            this.SuspendLayout();
            // 
            // connectButton
            // 
            resources.ApplyResources(this.connectButton, "connectButton");
            this.connectButton.Name = "connectButton";
            this.connectButton.Text = "Connect";
            this.connectButton.UseVisualStyleBackColor = true;
            this.connectButton.Click += new System.EventHandler(this.ConnectButton_Click);
            // 
            // startButton
            // 
            resources.ApplyResources(this.startButton, "startButton");
            this.startButton.Name = "startButton";
            this.startButton.Text = "Start";
            this.startButton.Enabled = false;
            this.startButton.UseVisualStyleBackColor = true;
            this.startButton.Click += new System.EventHandler(this.StartButton_Click);
            // 
            // snapButton
            // 
            resources.ApplyResources(this.snapButton, "snapButton");
            this.snapButton.Name = "snapButton";
            this.snapButton.Text = "Snap";
            this.snapButton.Enabled = false;
            this.snapButton.UseVisualStyleBackColor = true;
            this.snapButton.Click += new System.EventHandler(this.SnapButton_Click);
            // 
            // logTextBox
            // 
            resources.ApplyResources(logTextBox, "logTextBox");
            logTextBox.Name = "logTextBox";
            logTextBox.Multiline = true;
            logTextBox.ReadOnly = true;
            logTextBox.Cursor = System.Windows.Forms.Cursors.No;
            logTextBox.ForeColor = System.Drawing.SystemColors.WindowText;
            // 
            // logLabel
            // 
            resources.ApplyResources(this.logLabel, "logLabel");
            this.logLabel.Text = "Output information";
            this.logLabel.Name = "logLabel";
            // 
            // video
            // 
            resources.ApplyResources(video, "video");
            video.Name = "video";
            video.TabStop = false;
            // 
            // videoLabel
            // 
            resources.ApplyResources(this.videoLabel, "videoLabel");
            this.videoLabel.Name = "videoLabel";
            // 
            // faceDetection
            // 
            resources.ApplyResources(this.faceDetection, "faceDetection");
            this.faceDetection.Name = "faceDetection";
            this.faceDetection.Enabled = false;
            this.faceDetection.UseVisualStyleBackColor = true;
            this.faceDetection.Click += new System.EventHandler(this.FaceDetection_Click);
            // 
            // fpsLabel
            // 
            resources.ApplyResources(fpsLabel, "fpsLabel");
            fpsLabel.Text = "";
            fpsLabel.Name = "fpsLabel";
            fpsLabel.AutoSize = true;
            // 
            // mainMenu
            // 
            this.mainMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.aboutToolStripMenuItem});
            resources.ApplyResources(this.mainMenu, "mainMenu");
            this.mainMenu.Name = "mainMenu";
            // 
            // aboutToolStripMenuItem
            // 
            this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
            resources.ApplyResources(this.aboutToolStripMenuItem, "aboutToolStripMenuItem");
            this.aboutToolStripMenuItem.Click += new System.EventHandler(this.AboutToolStripMenuItem_Click);
            // 
            // framesLabel
            // 
            resources.ApplyResources(framesLabel, "framesLabel");
            framesLabel.Text = "";
            framesLabel.Name = "framesLabel";
            framesLabel.AutoSize = true;
            // 
            // GUI
            // 
            resources.ApplyResources(this, "$this");
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.startButton);
            this.Controls.Add(this.faceDetection);
            this.Controls.Add(this.videoLabel);
            this.Controls.Add(this.snapButton);
            this.Controls.Add(this.logLabel);
            this.Controls.Add(this.connectButton);
            this.Controls.Add(this.mainMenu);
            this.Controls.Add(fpsLabel);
            this.Controls.Add(framesLabel);
            this.Controls.Add(video);
            this.Controls.Add(logTextBox);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Name = "GUI";
            ((System.ComponentModel.ISupportInitialize)(video)).EndInit();
            this.mainMenu.ResumeLayout(false);
            this.mainMenu.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        public System.Windows.Forms.Button connectButton;
        public System.Windows.Forms.Label logLabel;
        public System.Windows.Forms.Button startButton;
        public System.Windows.Forms.Button snapButton;
        public System.Windows.Forms.Label videoLabel;
        private System.Windows.Forms.CheckBox faceDetection;
        private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
        private System.Windows.Forms.MenuStrip mainMenu;
        public static System.Windows.Forms.TextBox logTextBox;
        public static System.Windows.Forms.PictureBox video;
        public static System.Windows.Forms.Label fpsLabel;
        public static System.Windows.Forms.Label framesLabel;
    }
}

