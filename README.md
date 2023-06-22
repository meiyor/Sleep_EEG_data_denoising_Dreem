# Sleep_EEG_data_denoising_Dreem

In the following READme we will describe the steps any user needs to follow to run the denoising and artifact rejection for the EEG large trials collected in the **Sleep** study at [**Filbey's Lab**](https://labs.utdallas.edu/filbeylab/) and using the [**Dreem**](https://dreem.com/) ambulatory device. These EEG trials were collected while participants, who are consumers of cannabis and controls (non-consumers), are in different sleeping stages.
 
## 1) Installing and Preparing Requirements

The first step consist in download a version of **Matlab>=R2021a** go to the [**Mathworks**](https://www.mathworks.com/downloads/#) login with your username and password and download the version of **Matlab** corresponding to your operating system. Follow the steps of the installation guide [**here**](https://www.mathworks.com/help/pdf_doc/install/install_guide.pdf) for any operating system, **please install the Wavelet Toolbox** include it in the package for Matlab installation. The subsequent steps is downloading and installing [**EEGLab**](https://sccn.ucsd.edu/eeglab/download.php) and a version **EEGlab>=14.1.1**.  Submit your request and download the EEGlab main folder in your main Matlab folder. You/user can do it adding it as a **addpath**.

```matlab
   >> addpath(genpath('where_EEGlab_is_located'));
```
Now, you/user need to install four required EEGlab **plugins** in EEGlab opening the command **eeglab** and do it manually, or adding the .m files inside each plugin folder in the folder **plugins** in the **EEGlab** directory. Please install the following plugins from the EEGlab [**plugins webpage**](https://sccn.ucsd.edu/eeglab/plugin_uploader/plugin_list_all.php) 

- [**clean_rawdata2.3**](https://github.com/sccn/clean_rawdata)
- [**Biosig3.3.0**](https://biosig.sourceforge.net/download.html)
- [**PrepPipeline0.55.3**](http://vislab.github.io/EEG-Clean-Tools/)
- [**ADJUST1.1.1**](https://www.nitrc.org/projects/adjust/)

When the plugins are already installed or located in the **plugins** folder inside the EEGlab root folder, you/user can add the new files into the Matlab path repeating the same command described above.  


```matlab
   >> addpath(genpath('where_EEGlab_is_located'));
```
To avoid errors with the octave functions of the **EEGlab** folder you/user need to remove th octave functions from the EEGlab functions folder. You/user can follow this matlab command to remove the octave functions and subdirectories.


```matlab
   >> rmpath(genpath('where_EEGlab_is_located/functions/octavefunc'));
```
For detecting SWS in the subsequent execution you/user need to donwload and install the [**swa-matlab**](https://github.com/Mensen/swa-matlab) toolbox. Add the **swa-matlab** folder in the Matlab path. For avoiding errors in the following executions, especially in the detectors, use the **swa-matlab** folder added in this repository.

Due to the amount of channels on each Dreem trial is only four, we need to change a couple of lines in the ADJUST plugins files. 1) First in the file **EM.m** add the following lines from the line 84 of the **EM.m** code.

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
2) In the file **compute_GD_feat.m** you/user need to substitute the lines 60 and 61 in the code, for the following lines, due to the few amount of channels used in this project **4**.
   
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

You/user must download the data from the [**Dreem portal**](https://dreem-viewer.rythm.co/login) login web page, use the username **Sleepproject_stagni01@dreem.com** and the password **HUpd<3**. This will show you/user the EEG data and the text-hypnograms collected for each particular subject in the **Sleep** study. In this portal interface you/user can select a trial for a particular subject, the system will tell you/user the code of the trial, the device that was used to collect the data, and the duration of the trial. The process to select the EEG data from the trial is first clicking on the trial and after that in the **Download** button and choose **EDF** as shown in the portal interface.

<img src="https://github.com/meiyor/Sleep_EEG_data_denoising_Dreem/blob/main/images/dreem_portal_edf.jpg" width="900" height="400">

This will download all the EEG data as **.edf** file that's why the **Biosig3.3.0** plugin must be included in the subsequent executions. Now you must download the hypnogram as text as the following screen is showing. 

<img src="https://github.com/meiyor/Sleep_EEG_data_denoising_Dreem/blob/main/images/dreem_portal_hypnogram.jpg" width="900" height="400">

Both files **.edf** and **.txt** will have the same trial-code and the time duration as strings joined as a name. In the **data** folder of this repository we added a couple of examples of **.edf** and **.txt** such as **Sleepproject_c038_2023-03-18T02-21-19[05-00].edf** and **Sleepproject_c038_2023-03-19T00-09-10[05-00].edf** and its corresponding hypnograms **Sleepproject_c038_2023-03-18T02-21-19[05-00]_hypnogram.txt** and ****Sleepproject_c038_2023-03-19T00-09-10[05-00]_hypnogram.txt****.

## 3) Executing code

The first step is to convert the hypnogram from a .txt file to a .mat file where two variables **label_vec** and **time_s** are created to synchronize, where in the timepoints across the entire trial, a sleep-stage start to occur. The stages that can occur across the trials are **'SLEEP-S0'**, **'SLEEP-S1'**, **'SLEEP-S2'**, **'SLEEP-S3'**, **'SLEEP-REM'**, and **'SLEEP-MT'**. We describe this stages as integers in the code, such as, **0**, **1**, **2**, **3**, **4**, and **-1** respectively. This **'SLEEP-MT'** stage corresponds to a movement stage and not any sleep-stage, therefore this is removed from the analysis in this code repository. Therefore, to transform the hypnogram from from a .txt file to a .mat file where two variables we need to run the following command.

```matlab
   >> hypnogram_read('Sleepproject_c038_2023-03-19T00-09-10[05-00].edf')
```
The previous command will generate a file **Sleepproject_c038_2023-03-19T00-09-10[05-00]_hypnogram.mat**. This file will be necessary to run the EEG data processing and change the filter parameters depending on the sleeping-stage the analysis is across the trial. This is guideline of course, in time domain, to change those corresponding parameters. This parameters are changed in the file **remove_artifact_sleep_inv.m**.

Now in order to run the code for processing the EEG data, transform it to unipolar and start to denoise it from distortions and artifacts, we need to run the **windowing_sleep_EEG.m**. After the hypnogram **.mat** file is generated you/user must run the following Matlab command. The **windowing_sleep_EEG.m** function will generate the data output or interim as an array with size **4 channels x trial samples-length**. The four channels taken into account in this analysis and in these sleep study trials are **F7**, **F8**, **O1**, and **O2**.

```matlab
   >> [Sal_filtered,Sal,Result]=windowing_sleep_EEG('Sleepproject_c038_2023-03-19T00-09-10[05-00].edf',4,2,0,250);
```
The first parameter of this command is the name of the .edf file - this file must have the hypnogram calculated and associated with the name of the file a-priori, the second parameter is the length of the window that the denoising process is done,- We suggest to use **4 seconds**, the third parameter is the overlap in seconds - We suggest to use  **2 seconds**, the fourth parameter is the time-offset that the process wil use to start doing the denoising, by default it is **0 seconds** but the user can change it for his/her convinience, and the fifth parameter is the sampling-frequency of these sleep trials which is **250Hz***.

This process can take a while depending the length of the trial, therefore, it is possible to put a debug point in the middle of the execution and run the **spindle** or the **sws** detection from a interim denoised signal depending what the user wants to measure.

## 4) Detecting Sleep Spindles and SWS

 In this step we will assume that the **start_param** and **end_param** are the start and end time, **in seconds**, that will be analyzed by the **spindles** and **sws** detectors. These parameters needs to be defined by the hypnogram after the output result is given by the **windowing_sleep_EEG.m** function. The user must define these parameters to evaluate the detectors having the enough amount of signal denoised from the previous step. Take into account that these start and end parameters must be defined by the hypnogram stages start and end respectively. Now, first assume **Sal** as the resulting denoised EEG output then we can define the time-domain vector using the **linspace** command in Matlab.  

```matlab
   >> times=linspace(start_param,end_param,length(squeeze(Sal(1,start_param*250:end_param*250))));
```
From this point, we can detect 1) **sleep spindles** using the **Wavelet-based method** defined in [**SpindleTool**](https://github.com/nsrr/SpindleTool). We modified this code to make the detection more efficient and more adaptable to the resulting signals obtained in **Sal**, with **4** channels and a variable **sample-length**. Now, we can execute the code defined in the file **sleep_spindle_detector_wavelet.m** following the next Matlab command and we can calculate/define the **duration** and **density** per minute of the sleep spindles between the **start_param** and **end_param**.

```matlab
   >> [timespindles,durspindles,MINS,DENS,time_SS,dur_SS,dens_SS]=sleep_spindle_detector_wavelet(Sal(:,start_param*250:end_param*250),times,250,4,0,4,0.3,0.5,11);
```

The parameters in this function are defined and taken from the function comment section. Here we explained all the input parameters in sequence:

 - **data**: an array composed between channels **(in this case four- 4) x sample-length** and it is the fraction of EEG data you/user want to use to infer where are the sleep spindles.
 - **time**: this is an array of size **sample-length** having the equivalences in time where the EEG data is defined. This array should be the same length as the size 2 of the EEG data, in this case the data input parameter.
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

 - **data**: an array composed of channels (in this case four- 4) x samples-length and it is the fraction of EEG data you/user want to use to infer where are the sleep spindles.
 - **time**: this is an array of size samples-length having the equivalences in time where the EEG data is defined. This array should be the same length as the size 2 of the EEG data, in this case the **data input parameter.
 - **fs**: sampling frequency being 250Hz for this particular case
 - **sel_plot**: 0 if you/user don't want to plot the **SWS** detected holded on your EEG data, and 1 if you/user want to plot the **SWS** detected holded on your input EEG data plotted as well.

The output parameters of this SWS detection function are listed here:
- **SW**: structure containing the **SWS** canonical representation calculated from the 4 channels and the swa-matlab toolbox.
-  **incidence**: this is a number representing the number of **SWS** detected per minute across the EEG input given for analysis.

If you/user wants to plot the **SWS** canonical output with the detected **SWS** plotted on hold, you/user can use the following Matlab command. This occurs when the **sel_plot** parameter is 1.

```matlab
   >> [SW,incidence]=detect_sws(Sal(:,start_param*250:end_param*250),times,250,1);
```
Follow the steps as they are reported in this READme file and guide yourself/herself/himself with the comments and hints written in the code to do an easy and practical replication of the EEG denoising process. If any issue is presented during the evaluation of this process please open an issue in this repository or contact me at [**juan.mayortorres@utdallas.edu**](juan.mayortorres@utdallas.edu).
