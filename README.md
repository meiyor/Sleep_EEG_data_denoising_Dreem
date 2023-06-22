# Sleep_EEG_data_denoising-Dreem
In the following READme we will describe the steps any user needs to follow to run the denoising and artifact rejection for the EEG large trials collected in the **Sleep** study at [**Filbey's Lab**](https://labs.utdallas.edu/filbeylab/) and using the [**Dreem**](https://dreem.com/) ambulatory device. These EEG trials were collected while participants, who are consumers of cannabis and controls (non-consumers), are in different sleeping stages.
 
**1) Installing Requirements**

The first step consist in download a version of **Matlab>=R2021a** go to the [**Mathworks**](https://www.mathworks.com/downloads/#) login with your username and password and download the version of **Matlab** corresponding to your operating system. Follow the steps of the installation guide [**here**](https://www.mathworks.com/help/pdf_doc/install/install_guide.pdf) for any operating system, **please install the Wavelet Toolbox** include it in the package for Matlab installation. The subsequent steps is downloading and installing [**EEGLab**](https://sccn.ucsd.edu/eeglab/download.php) and a version **EEGlab>=14.1.1**.  Submit your request and download the EEGlab main folder in your main Matlab folder. You can do it adding it as a **addpath**.

```matlab
   >> addpath(genpath('where_EEGlab_is_located'));
```
Now you need to install four required EEGlab **plugins** in EEGlab opening the command **eeglab** and do it manually, or adding the .m files inside each plugin folder in the folder **plugins** in the **EEGlab** directory. Please install the following plugins from the EEGlab [**plugins webpage**](https://sccn.ucsd.edu/eeglab/plugin_uploader/plugin_list_all.php) 

- [**clean_rawdata2.3**](https://github.com/sccn/clean_rawdata)
- [**Biosig3.3.0**](https://biosig.sourceforge.net/download.html)
- [**PrepPipeline0.55.3**](http://vislab.github.io/EEG-Clean-Tools/)
- [**ADJUST1.1.1**](https://www.nitrc.org/projects/adjust/)

When the plugins are already installed or located in the **plugins** folder inside the EEGlab root folder, you can add the new files into the Matlab path repeating the same command described above.  


```matlab
   >> addpath(genpath('where_EEGlab_is_located'));
```
**2) Download data**

You must download the data from the [**Dreem portal**](https://dreem-viewer.rythm.co/login) login web page, use the username **Sleepproject_stagni01@dreem.com** and the password **HUpd<3**. This will show you the EEG data and the text-hypnograms collected for each particular subject in the **Sleep** study. In this portal interface you can select a trial for a particular subject, the system will tell you the code of the trial, the device that was used to collect the data, and the duration of the trial. The process to select the EEG data from the trial is first clicking on the trial and after that in the **Download** button and choose **EDF** as shown in the portal interface.

