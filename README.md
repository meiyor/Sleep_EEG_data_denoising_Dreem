# Sleep_EEG_data_denoising_Dreem

In the following READme we will describe the steps any user needs to follow to run the denoising and artifact rejection for the EEG large trials collected in the **Sleep** study at [**Filbey's Lab**](https://labs.utdallas.edu/filbeylab/) and using the [**Dreem**](https://dreem.com/) ambulatory device. These EEG trials were collected while participants, who are consumers of cannabis and controls (non-consumers), are in different sleeping stages.
 
## 1) Installing and Preparing Requirements

The first step consists in downloading a version of **Matlab>=R2021a** go to the [**Mathworks**](https://www.mathworks.com/downloads/#) login with your username and password and download the version of **Matlab** corresponding to your operating system. Follow the steps of the installation guide [**here**](https://www.mathworks.com/help/pdf_doc/install/install_guide.pdf) for any operating system, **please install the Wavelet Toolbox** include it in the package for Matlab installation. The subsequent steps is downloading and installing [**EEGLab**](https://sccn.ucsd.edu/eeglab/download.php) and a version **EEGlab>=14.1.1**.  Submit your request, download the EEGlab main folder and add it in your Matlab path. You/user can do this using the command **addpath**.

```matlab
   >> addpath(genpath('where_EEGlab_is_located'));
```
Now, you/user need to install four required EEGlab **plugins**. You can do it from the EEGlab opening command **eeglab**, or adding the .m files inside each plugin folder in the folder **plugins** located in the **EEGlab** directory. Please install the following EEGlab plugins from the **EEGlab** [**plugins webpage**](https://sccn.ucsd.edu/eeglab/plugin_uploader/plugin_list_all.php) 

- [**clean_rawdata2.3**](https://github.com/sccn/clean_rawdata)
- [**Biosig3.3.0**](https://biosig.sourceforge.net/download.html)
- [**PrepPipeline0.55.3**](http://vislab.github.io/EEG-Clean-Tools/)
- [**ADJUST1.1.1**](https://www.nitrc.org/projects/adjust/)

When the plugins are already installed or located in the **plugins** folder inside the **EEGlab** root folder, you/user can add the new files into the Matlab path repeating the same command described previously.  


```matlab
   >> addpath(genpath('where_EEGlab_is_located'));
```
To avoid errors with the **octave functions** of the **EEGlab** folder, you/user must remove th octave functions inside the **EEGlab** folder from the Matlab path. You/user can follow the following matlab command to remove the octave functions and subdirectories from the Matlab path. You/user need to also remove the **fieldtrip**, go to the **EEGlab** folder and remove the **fieldtrip** folder following a similar command described here. 


```matlab
   >> rmpath(genpath('where_EEGlab_is_located/functions/octavefunc'));
```
For detecting SWS in the subsequent execution you/user need to donwload and install the [**swa-matlab**](https://github.com/Mensen/swa-matlab) toolbox. Add the **swa-matlab** folder in the Matlab path. For avoiding errors in the following executions, especially in the detectors, use the **swa-matlab** folder added in this repository.

Due to the amount of channels on each Dreem trial is few, only four **4**, we need to change a couple of lines in the ADJUST plugins files. 1) First in the file **EM.m** add the following lines from the line 84 of the **EM.m** code.

```matlab
   if all(single(vec)==1.0)
    if alpha1==0
        train1=real(ones([1 len-length(train2)]));
    end;
    if alpha2==0
        train2=real(ones([1 len-length(train1)]));
    end;
    if alpha1==0 && alpha2==0
        train1=real(ones([1 2]));
        train2=real(ones([1 2]));
    end;
   end;
```
2) In the file **compute_GD_feat.m** you/user need to substitute the lines 60 and 61 in the code, for the following lines, due to the few amount of channels used in this project **4**. This function always expects to receive more than 10 channels for each EEG trial.
   
```matlab
  repchas=I(1:4); % list of 4 nearest channels to el
  weightchas=exp(-y(1:4)); % respective weights, computed wrt distance
```
3) In the file **ADJUST.m** change the following lines for the code reported here. For line 243 change the current line with the following line.
   
```matlab
  K(j,i)=kurt(real(EEG.icaact(i,:,j)));
```

Substitute the line 285 for the following line of code.

```matlab
  nuovaV=real(maxvar./meanvar);
```

## 2) Downloading data

You/user must download the data from the [**Dreem portal**](https://dreem-viewer.rythm.co/login) login web page, use the username **Sleepproject_stagni01@dreem.com** and the password **HUpd<3**. This will show you/user the EEG data and the text-hypnograms collected for each particular subject in the **sleep** study. In this portal interface you/user can select a trial for a particular subject, the system will tell you/user the code of the trial, the device that was used to collect the data, when the trial starts and ends, and the total duration of the trial. The process to select the EEG data from any trial consists in clicking on the trial to select it and subsequently click on the **Download** button and choose **EDF**. This process appears in the following image.

<img src="https://github.com/meiyor/Sleep_EEG_data_denoising_Dreem/blob/main/images/dreem_portal_edf.jpg" width="900" height="400">

This will download the EEG data for any particular trial as a **.edf** file, that's why the **Biosig3.3.0** plugin must be included for the subsequent executions. Now, you/user must download the hypnogram as text as the following image is showing. 

<img src="https://github.com/meiyor/Sleep_EEG_data_denoising_Dreem/blob/main/images/dreem_portal_hypnogram.jpg" width="900" height="400">

Both files **.edf** and **.txt** will have the same name composed of the trial-code and the time duration of the trial joined as strings. In the **data** folder of this repository we added a couple of examples of **.edf** and **.txt**, such as, **Sleepproject_c038_2023-03-18T02-21-19[05-00].edf** and **Sleepproject_c038_2023-03-19T00-09-10[05-00].edf** and its corresponding hypnograms **Sleepproject_c038_2023-03-18T02-21-19[05-00]_hypnogram.txt** and ****Sleepproject_c038_2023-03-19T00-09-10[05-00]_hypnogram.txt****.

## 3) Executing code

The first step is to convert the hypnogram from a .txt file to a .mat file. In this .mat file two variables named **label_vec** and **time_s** are created to synchronize when in the time a sleep-stage start to occur and when it ends. The stages that can occur across these **sleep** EEG trials are **'SLEEP-S0'**, **'SLEEP-S1'**, **'SLEEP-S2'**, **'SLEEP-S3'**, **'SLEEP-REM'**, and **'SLEEP-MT'**. We describe these stages as integers in the code, such as, **0**, **1**, **2**, **3**, **4**, and **-1** respectively. This **'SLEEP-MT'** stage corresponds to a movement stage and not any particular sleep-stage. Therefore, this **'SLEEP-MT'** stage is removed from the analysis reported in this code repository. To transform the hypnogram from from a .txt file to a .mat file we need to run the following command.

```matlab
   >> hypnogram_read('Sleepproject_c038_2023-03-19T00-09-10[05-00].edf')
```
The previous command will generate a file called **Sleepproject_c038_2023-03-19T00-09-10[05-00]_hypnogram.mat**. This file will be necessary to run the EEG data denoising and change the filter parameters depending on the sleeping-stage aligned to each particular time-window. This hypnogram is a guideline, in time domain, to change the filter parameters according to the sleep-stage corresponding to each time-window. The setting of these filter parameters is reported in the file **remove_artifact_sleep_inv.m** and you/user can see how the parameters selection is performed in the section of the Wavelet decomposition.

Now, in order to run the code for processing the EEG data, transform it to unipolar, and start to denoise it from distortions and artifacts, we need to execute the function written in the **windowing_sleep_EEG.m** file. The **windowing_sleep_EEG.m** function will generate a data denoised or output, or interim as an array with size **4 channels x samples-length**. The **samples-length** parameter is defined as the number of time-windows that has been processed by  **windowing_sleep_EEG.m** times **fs**. The four channels taken into account in this **sleep** study are **F7**, **F8**, **O1**, and **O2**. After the hypnogram **.mat** file is generated you/user must run the following Matlab command.

```matlab
   >> [Sal_filtered,Sal,Result]=windowing_sleep_EEG('Sleepproject_c038_2023-03-19T00-09-10[05-00].edf',4,2,0,250);
```
The input parameters for this function as described as follows: 1) The first parameter of this command is the name of the .edf file - this file must have the hypnogram calculated and associated with the name of the data-file using the **hypnogram_read.m** function. 2) The second parameter is the length of the window that the denoising process is done, we suggest to use **4 seconds**. 3) The third parameter is the overlap in seconds applied to each time-window - we suggest to use  **2 seconds**. 4) The fourth parameter is the time-offset that the process wil use to start doing the denoising, by default it is **0 seconds** but the you/user can change it for your/his/her convinience. 5) The fifth parameter is the sampling-frequency of these EEG trials which is **250Hz*** for this particular **sleep** study.

This denoising + artifact rejection process can take a while depending the length of the trial. Therefore, it is possible to put a debug point in the middle of the execution and run the **spindle** or the **SWS** detection from a interim denoised output depending what you/user wants to measure.

## 4) Detecting Sleep Spindles and SWS

 In this step we will assume that the **start_param** and **end_param** are the start and end time, **in seconds**, that will be analyzed by the **spindles** and **sws** detectors. These parameters needs to be defined by the hypnogram after the output result is given by the **windowing_sleep_EEG.m** function. The user must define these parameters to evaluate the detectors having the enough amount of signal denoised from the previous step. Take into account that these start and end parameters must be defined by the hypnogram stages start and end respectively. Now, first assume **Sal** as the resulting denoised EEG output. Then, we can define the time-domain vector using the **linspace** command in Matlab.  

```matlab
   >> times=linspace(start_param,end_param,length(squeeze(Sal(1,start_param*250:end_param*250))));
```
From this point, we can detect 1) **sleep spindles** using the **Wavelet-based method** defined in [**SpindleTool**](https://github.com/nsrr/SpindleTool). We modified this code to make the detection more efficient and more adaptable to the resulting signals obtained in **Sal**, with **4** channels and a variable **sample-length**. Now, we can execute the code defined in the file **sleep_spindle_detector_wavelet.m** following the next Matlab command and we can calculate/define the **duration** and **density** per minute of the sleep spindles between the **start_param** and **end_param**.

```matlab
   >> [timespindles,durspindles,MINS,DENS,time_SS,dur_SS,dens_SS]=sleep_spindle_detector_wavelet(Sal(:,start_param*250:end_param*250),times,250,4,0,4,0.3,0.5,11);
```

The parameters in this function are defined and taken from the function comment section. Here we explained all the input parameters in sequence:

 - **data**: an array composed between channels **(in this case four- 4) x samples-length** and it is the fraction of EEG data you/user want to use to infer the position and duration of the sleep spindles.
 - **time**: this is an array of size **samples-length** having the equivalences in time where the EEG data is defined. This array should be the same length as the size 2 of the EEG data, in this case the data input parameter.
 - **fs** : sampling frequency being 250Hz for this particular case
 - **nbchan**: four (4) for this particular case
 - **sel_plot**: 0 if you/user don't want to plot the spindles holded in your EEG data, and 1 if you/user want to plot the sleep spindles holded on your input data. 
 - **ch_sel_in**: The user must specify what channels the want to plot as numerical indeces [1, 2, 3 or 4], after the bipolar set is transformed to unipolar the indeces of the channels are {F7, F8, O1, O2}.
 - **time_c1**: time constrain 1 for the spindles detection suggested to define it in 0.3
 - **time_c2**: time constrain 2 for the spindles detection suggested to define it in 0.5
 - **center_freq**: define this center frequency between 11-13Hz define it following the convinience of the user
   
The output parameters for the spindle detection function are defined here in the following list:

 - **timespindles**: cell array with a size equal to number channels and for each channel we have a specific number of spindles detections. In this array we have the time where the **spindles** started in the time-domain vector.
 - **durspindles**: cell array with a size equal to number channels and for each channel we have a specific number of spindles detections. In this array we have the duration of **spindles** in seconds.
 - **MINS**: number of minutes that the data trial is taken in this analysis, this measure is taken for each channel.
 - **DENS**: Density of **spindles** detected per each minute across the trial, this measure is calculated for each channel.
 - **time_SS**: a sorted array grouping the **spindles** starting times detected for each channel. The array is sorted from low to high in seconds reporting the times where the **spindles** started.
 - **dur_SS**: a sorted array grouping the **spindles** duration times detected for each channel. The array is sorted from low to high in seconds reporting the **spindles** duration. The length of time_SS and dur_SS are equal.
 - **dens_SS**: a number representing the density of **spindles** detected per minute in the entire trial after grouping all the different **spindles** detected for each channel.

If you/user want to plot the desired channel parameter with the detected spindles plot on hold you/user can use the following Matlab command. This occurs when the **sel_plot** parameter is 1.

```matlab
   >> [timespindles,durspindles,MINS,DENS,time_SS,dur_SS,dens_SS]=sleep_spindle_detector_wavelet(Sal(:,start_param*250:end_param*250),times,250,4,1,4,0.3,0.5,11);
```
Now, for detecting **SWS** we used the [**swa-matlab**](https://github.com/Mensen/swa-matlab) toolbox with certain variations in the code to make it more adaptable to the data we have with **4** channels and a variable **sample-length**. The following command in Matlab will execute the detection of **SWS** between the **start_param** and **end_param**. This command will also report the canonical **SWS** output obtained from the **4** channels included in the analysis and the **incidence** or the density of **SWS** detected per minute - similar to the spindles detection.

```matlab
   >> [SW,incidence]=detect_sws(Sal(:,start_param*250:end_param*250),times,250,0);
```

The input parameters of this function are listed here as we have set them in the comments section of the corresponding code:

 - **data**: an array composed of channels (in this case four- 4) x **samples-length** and it is the fraction of EEG data you/user want to use to infer the position and duration of the sleep spindles.
 - **time**: this is an array of size **samples-length** having the equivalences in time where the EEG data is defined. This array should be the same length as the size 2 of the EEG data, in this case the **data** input parameter.
 - **fs**: sampling frequency being 250Hz for this particular case
 - **sel_plot**: 0 if you/user don't want to plot the **SWS** detected holded on your EEG data, and 1 if you/user want to plot the **SWS** detected holded on your input EEG data plotted as well.

The output parameters of this SWS detection function are listed here:
- **SW**: structure containing the **SWS** canonical representation calculated from the 4 channels and the swa-matlab toolbox.
-  **incidence**: this is a number representing the number of **SWS** detected per minute across the EEG input given for analysis.

If you/user wants to plot the **SWS** canonical output with the detected **SWS** plotted on hold, you/user can use the following Matlab command. This occurs when the **sel_plot** parameter is 1.

```matlab
   >> [SW,incidence]=detect_sws(Sal(:,start_param*250:end_param*250),times,250,1);
```
Follow the steps as they are reported in this READme and guide yourself/herself/himself with the comments and hints written in the code to do an easy and practical replication of the EEG denoising process. If any issue is presented during the evaluation of this process please open an issue in this repository or contact me at [**juan.mayortorres@utdallas.edu**](juan.mayortorres@utdallas.edu).
