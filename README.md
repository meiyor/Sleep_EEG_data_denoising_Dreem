# Sleep_EEG_data_denoising-Dreem
In the following READme we will describe the steps any user needs to follow to run the denoising and artifact rejection for the EEG large trials collected in the **Sleep** study at [**Filbey's Lab**](https://labs.utdallas.edu/filbeylab/) and using the [**Dreem**](https://dreem.com/) ambulatory device. These EEG trials were collected while participants, who are consumers of cannabis and controls (non-consumers), are in different sleeping stages.
 
**1) Installing and Preparing Requirements**

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
To avoid errors with the octave functions of the **EEGlab** folder you need to remove th octave functions from the EEGlab functions folder. You can follow this matlab command to remove the octave functions and subdirectories.


```matlab
   >> rmpath(genpath('where_EEGlab_is_located/functions/octavefunc'));
```

Due to the amount of channels in each Dreem trial is only four we need to change a couple of lines in the 

**2) Download data**

You must download the data from the [**Dreem portal**](https://dreem-viewer.rythm.co/login) login web page, use the username **Sleepproject_stagni01@dreem.com** and the password **HUpd<3**. This will show you the EEG data and the text-hypnograms collected for each particular subject in the **Sleep** study. In this portal interface you can select a trial for a particular subject, the system will tell you the code of the trial, the device that was used to collect the data, and the duration of the trial. The process to select the EEG data from the trial is first clicking on the trial and after that in the **Download** button and choose **EDF** as shown in the portal interface.

<img src="https://github.com/meiyor/Sleep_EEG_data_denoising_Dreem/blob/main/images/dreem_portal_edf.jpg" width="900" height="400">

This will download all the EEG data as **.edf** file that's why the **Biosig3.3.0** plugin must be included in the subsequent executions. Now you must download the hypnogram as text as the following screen is showing. 

<img src="https://github.com/meiyor/Sleep_EEG_data_denoising_Dreem/blob/main/images/dreem_portal_edf.jpg" width="900" height="400">

Both files **.edf** and **.txt** will have the same trial code and the time duration as name. In the **data** folder of this repository I added a couple of examples of **.edf** and **.txt** such as **Sleepproject_c038_2023-03-18T02-21-19[05-00].edf** and **Sleepproject_c038_2023-03-19T00-09-10[05-00].edf** and its corresponding hypnograms **Sleepproject_c038_2023-03-18T02-21-19[05-00]_hypnogram.txt** and ****Sleepproject_c038_2023-03-19T00-09-10[05-00]_hypnogram.txt****
