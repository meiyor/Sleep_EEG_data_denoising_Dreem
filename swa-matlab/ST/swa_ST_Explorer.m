%% GUI for Exploring Travelling Waves
%% Version History
% 2.0 14.2.14
% ___ include CWT waves in the individual plot
% ___ option to see background waves

function swa_ST_Explorer(varargin)
DefineInterface

function DefineInterface
%% Create Figure

% Dual monitors creates an issue in Linux environments whereby the two
% screens are seen as one long screen, so always use first one
sd = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment.getScreenDevices;
if length(sd) > 1
    bounds = sd(2).getDefaultConfiguration.getBounds;
    figPos = [bounds.x bounds.y bounds.width bounds.height];
else
    bounds = sd(1).getDefaultConfiguration.getBounds;
    figPos = [bounds.x bounds.y bounds.width bounds.height];
end

handles.Figure = figure(...
    'Name',         'Travelling Waves:',...
    'NumberTitle',  'off',...
    'Color',        'w',...
    'MenuBar',      'none',...
    'Units',        'pixels',...
    'Outerposition',figPos);

%% Menus
handles.menu.File = uimenu(handles.Figure, 'Label', 'File');
handles.menu.LoadData = uimenu(handles.menu.File,...
    'Label', 'Load Data',...
    'Accelerator', 'L');
set(handles.menu.LoadData, 'Callback', {@menu_LoadData});

handles.menu.SaveData = uimenu(handles.menu.File,...
    'Label', 'Save Data',...
    'Accelerator', 'S');
set(handles.menu.SaveData, 'Callback', {@menu_SaveData});

%% Status Bar
handles.StatusBar = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Status Updates',...
    'Units',    'normalized',...
    'Position', [0 0 1 0.03],...
    'FontName', 'Century Gothic',...
    'FontSize', 10);

handles.java.StatusBar = findjobj(handles.StatusBar);
handles.java.StatusBar.setVerticalAlignment(javax.swing.SwingConstants.CENTER);
handles.java.StatusBar.setHorizontalAlignment(javax.swing.SwingConstants.LEFT);

%% Slider Spinner and Delete Button
[handles.java.Slider,handles.Slider] = javacomponent(javax.swing.JSlider);
set(handles.Slider,...
    'Parent',   handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.05 0.72 0.32 0.05]);
% >> handles.java.Slider.set [then tab complete to find available methods]
handles.java.Slider.setBackground(javax.swing.plaf.ColorUIResource(1,1,1))
set(handles.java.Slider, 'MouseReleasedCallback',{@SliderUpdate, handles.Figure});

[handles.java.Spinner,handles.Spinner] = javacomponent(javax.swing.JSpinner);
set(handles.Spinner,...
    'Parent',   handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.38 0.72 0.05 0.05]);
% Set the font and size (Found through >>handles.java.Slider.Font)
handles.java.Spinner.setFont(javax.swing.plaf.FontUIResource('Century Gothic', 0, 25))
handles.java.Spinner.getEditor().getTextField().setHorizontalAlignment(javax.swing.SwingConstants.CENTER)
set(handles.java.Spinner, 'StateChangedCallback', {@SpinnerUpdate, handles.Figure});

handles.pb_Delete = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   'X',...
    'Units',    'normalized',...
    'Position', [0.43 .72 0.02 0.05],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.pb_Delete, 'Callback', {@pb_Delete_Callback});

%% Channel Set ComboBoxes
[handles.java.ChannelBox1,handles.ChannelBox1] = javacomponent(javax.swing.JComboBox);
set(handles.ChannelBox1,...
    'Parent',   handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.02 0.90 0.03 0.02]);
set(handles.java.ChannelBox1, 'ActionPerformedCallback', {@SpinnerUpdate, handles.Figure});

[handles.java.ChannelBox2,handles.ChannelBox2] = javacomponent(javax.swing.JComboBox);
set(handles.ChannelBox2,...
    'Parent',   handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.02 0.825 0.03 0.02]);  
set(handles.java.ChannelBox2, 'ActionPerformedCallback', {@SpinnerUpdate, handles.Figure});

%% Plot Titles and Export Button
handles.Title_SWPlot = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Individual Wave',...
    'Units',    'normalized',...
    'Position', [0.05 .68 0.4 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
handles.Ex_SWPlot = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.43 .68 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_SWPlot, 'Callback', @edit_SWPlot)


handles.Title_Origins = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Origins Map',...
    'Units',    'normalized',...
    'Position', [0.05 .38 0.2 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
handles.Ex_Origins = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.23 .38 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_Origins, 'Callback', @pb_XOrigins_Callback)


handles.Title_Density = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'String',   'Density Map',...
    'Units',    'normalized',...
    'Position', [0.25 .38 0.2 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
handles.Ex_Density = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.43 .38 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_Density, 'Callback', @pb_XDensity_Callback)


handles.Title_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'text',...    
    'Units',    'normalized',...
    'Position', [0.5 .73 0.45 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
[handles.java.PlotBox,handles.PlotBox] = javacomponent(javax.swing.JComboBox);
set(handles.PlotBox,...
    'Parent',   handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.65 0.73 0.15 0.02]);
handles.java.PlotBox.setModel(javax.swing.DefaultComboBoxModel({'Delay Map', 'Involvement Map'}));
handles.java.PlotBox.setFont(javax.swing.plaf.FontUIResource('Century Gothic', 0, 14));
set(handles.java.PlotBox, 'ActionPerformedCallback', {@SliderUpdate, handles.Figure});
handles.Ex_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'pushbutton',...    
    'String',   '+',...
    'Units',    'normalized',...
    'Position', [0.93 .73 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Ex_Delay, 'Callback', @pb_XDelay_Callback)

%% Checkboxes for Delay
handles.Surface_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',...
    'BackgroundColor', 'w',...
    'String',   'Surface',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.5 0.08 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Surface_Delay, 'Callback', @UpdateDelay2);

handles.Channels_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',...    
    'BackgroundColor', 'w',...
    'String',   'Channels',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.6 0.08 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Channels_Delay, 'Callback',  @UpdateDelay2);

handles.Origins_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',... 
    'BackgroundColor', 'w',...
    'String',   'Origins',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.7 0.08 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Origins_Delay, 'Callback',  @UpdateDelay2);

handles.Streams_Delay = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',... 
    'BackgroundColor', 'w',...
    'String',   'Streams',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.8 0.08 0.1 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
set(handles.Streams_Delay, 'Callback',  @UpdateDelay2);

% Checkboxes for wave plot
handles.theta_Cb = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',...
    'BackgroundColor', 'w',...
    'String',   '<html>&#952</html>',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.05 .4 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);
% set(handles.Surface_Delay, 'Callback', @UpdateDelay2);

handles.alpha_Cb = uicontrol(...
    'Parent',   handles.Figure,...   
    'Style',    'checkbox',...
    'BackgroundColor', 'w',...
    'String',   '<html>&#945</html>',...
    'Value',    1,...
    'Units',    'normalized',...
    'Position', [0.07 .4 0.02 0.02],...
    'FontName', 'Century Gothic',...
    'FontSize', 11);

%% Create Axes
handles.ax_Butterfly(1) = axes(...
    'Parent', handles.Figure,...
    'Position', [0.05 0.875 0.9 0.075],...
    'NextPlot', 'add',...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

handles.ax_Butterfly(2) = axes(...
    'Parent', handles.Figure,...
    'Position', [0.05 0.8 0.9 0.075],...
    'NextPlot', 'add',...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Ytick', []);

handles.ax_SWPlot = axes(...
    'Parent', handles.Figure,...
    'Position', [0.05 0.4 0.4 0.3],...
    'FontName', 'Century Gothic',...
    'NextPlot', 'add',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', []);

handles.ax_Origins = axes(...
    'Parent', handles.Figure,...
    'Position', [0.05 0.1 0.2 0.3],...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

handles.ax_Density = axes(...
    'Parent', handles.Figure,...
    'Position', [0.25 0.1 0.2 0.3],...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

handles.ax_Delay = axes(...
    'Parent', handles.Figure,...
    'Position', [0.5 0.1 0.45 0.65],...
    'NextPlot', 'add',...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box', 'off',...
    'Xtick', [],...
    'Ytick', []);

%% Context Menus
handles.menu.ButterflyContext = uicontextmenu;
handles.menu.UIContext_YReverse = uimenu(handles.menu.ButterflyContext,...
    'Label',    'Negative Down',...
    'Callback', {@Butterfly_Context, 'normal'});
handles.menu.UIContext_YReverse = uimenu(handles.menu.ButterflyContext,...
    'Label',    'Negative Up',...
    'Callback', {@Butterfly_Context, 'reverse'});
set(handles.ax_Butterfly, 'uicontextmenu', handles.menu.ButterflyContext);
set(handles.ax_SWPlot, 'uicontextmenu', handles.menu.ButterflyContext);

%% Make Figure Visible and Maximise
jFrame = get(handle(handles.Figure),'JavaFrame');
jFrame.setMaximized(true);   % to maximize the figure

guidata(handles.Figure, handles);

function menu_LoadData(hObject, ~)
handles = guidata(hObject);

[swaFile, swaPath] = uigetfile('*.mat', 'Please Select the Results File');
if swaFile == 0
    set(handles.StatusBar, 'String', 'Information: No File Selected');
    return;
end

set(handles.StatusBar, 'String', 'Busy: Loading Data'); drawnow;
load ([swaPath,swaFile]);

if ~exist('ST', 'var')
    set(handles.StatusBar, 'String', 'Information: No SW structure in file');
    return;
end

% Check for data present or external file
if ischar(Data.Raw)
    set(handles.StatusBar, 'String', 'Busy: Loading Data');
    fid = fopen(fullfile(swaPath, Data.Raw));
    Data.Raw = fread(fid, Info.Recording.dataDim, 'single');
    fclose(fid);
end

set(handles.Figure, 'Name', ['Travelling Waves: ', swaFile]);

% Set the ComboBoxes
model1 = javax.swing.DefaultComboBoxModel({Info.Electrodes.labels});
model2 = javax.swing.DefaultComboBoxModel({Info.Electrodes.labels});

handles.java.ChannelBox1.setModel(model1);
handles.java.ChannelBox1.setEditable(true);
handles.java.ChannelBox2.setModel(model2);
handles.java.ChannelBox2.setEditable(true);

% handles.java.ChannelBox1.getSelectedIndex() % Gets the value (setSele...)

%% Set the handles
handles.Info    = Info;
handles.SW      = ST;
handles.Data    = Data;

%% Set Slider and Spinner Values
handles.java.Slider.setValue(1);
handles.java.Slider.setMinimum(1);
handles.java.Slider.setMaximum(length(ST));
handles.java.Slider.setMinorTickSpacing(5);
handles.java.Slider.setMajorTickSpacing(20);
handles.java.Slider.setPaintTicks(true);
% handles.java.Slider.setPaintLabels(false);
% handles.java.Slider.setPaintLabels(true);

% handles.java.Spinner.setValue(1);

%% Draw Initial Plots
% Origins & Delay Plot
handles = update_SWOriginsMap(handles, 0);

% Colormap
colormap(flipud(hot))

set(handles.StatusBar, 'String', 'Idle');
% Update handles structure
guidata(hObject, handles);
handles.java.Spinner.setValue(1);


function menu_SaveData(hObject, ~)
handles = guidata(hObject);

[saveName,savePath] = uiputfile('*.mat');

if saveName == 0; return; end

Data = handles.Data;
Info = handles.Info;
ST   = handles.SW;

save([savePath, saveName], 'Data', 'Info', 'ST', '-mat');


%% Update Controls
function SpinnerUpdate(~,~,hObject)
handles = guidata(hObject); % Needs to be like this because slider is a java object

if handles.java.Spinner.getValue() == 0
    handles.java.Spinner.setValue(1);
    return;
elseif handles.java.Spinner.getValue() > length(handles.SW)
    handles.java.Spinner.setValue(length(handles.SW));
    return;    
end

handles.java.Slider.setValue(handles.java.Spinner.getValue())

% handles = update_SWOriginsMap(handles);
handles = update_SWPlot(handles);
handles = update_SWDelay(handles, 0);
handles = update_ButterflyPlot(handles);


guidata(hObject, handles);

function SliderUpdate(~,~,Figure)
handles = guidata(Figure); % Needs to be like this because slider is a java object

handles.java.Spinner.setValue(handles.java.Slider.getValue())

handles = update_ButterflyPlot(handles);
% handles = update_SWOriginsMap(handles);
handles = update_SWPlot(handles);
handles = update_SWDelay(handles, 0);

guidata(handles.Figure, handles);


%% Plot Controls
function handles = update_ButterflyPlot(handles)
% initial plot then update the yData in a loop (faster than replot)
nSW = handles.java.Spinner.getValue();
Ch1 = handles.java.ChannelBox1.getSelectedIndex()+1; %plus one because of 0indexing in Java
Ch2 = handles.java.ChannelBox2.getSelectedIndex()+1;

win = round(10*handles.Info.Recording.sRate); % ten seconds on each side of the wave

range = round((handles.SW(nSW).Ref_NegativePeak-win):(handles.SW(nSW).Ref_NegativePeak+win));
range(range<1)=[]; %eliminate negative values in case SW is early in the data
xaxis = range./handles.Info.Recording.sRate;

sPeaks = [handles.SW.Ref_NegativePeak]./handles.Info.Recording.sRate;

%Initial Plot (50 times takes 1.67s)
if ~isfield(handles, 'lines_Butterfly') %
 
    handles.lines_Butterfly(1) = plot(handles.ax_Butterfly(1), xaxis, handles.Data.Raw(Ch1,range)', 'k');
    handles.lines_Butterfly(2) = plot(handles.ax_Butterfly(2), xaxis, handles.Data.Raw(Ch2,range)', 'k');
    
    set(handles.ax_Butterfly,...
        'YLim', [-50,50],...
        'XLim', [xaxis(1), xaxis(end)]);
    
    handles.zoomline(1) = line([handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate-0.5, handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate-0.5],[-200, 200], 'color', [0.4 0.4 0.4], 'linewidth', 2, 'Parent', handles.ax_Butterfly(1));
    handles.zoomline(2) = line([handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate+.5, handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate+0.5],[-200, 200], 'color', [0.4 0.4 0.4], 'linewidth', 2, 'Parent', handles.ax_Butterfly(1));
    
    % Just plot all the arrows already
    handles.arrows_Butterfly = text(sPeaks, ones(1, length(sPeaks))*30, '\downarrow', 'FontSize', 20, 'HorizontalAlignment', 'center', 'Clipping', 'on', 'Parent', handles.ax_Butterfly(1));

% Re-plotting (50 times takes 0.3s)
else
    set(handles.lines_Butterfly, 'xData', xaxis);
    set(handles.lines_Butterfly(1), 'yData', handles.Data.Raw(Ch1,range)');
    set(handles.lines_Butterfly(2), 'yData', handles.Data.Raw(Ch2,range)');

    set(handles.ax_Butterfly,...
        'XLim', [xaxis(1), xaxis(end)]);
    
    set(handles.zoomline(1), 'xData', [handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate-0.5, handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate-0.5]);
    set(handles.zoomline(2), 'xData', [handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate+0.5, handles.SW(nSW).Ref_NegativePeak/handles.Info.Recording.sRate+0.5]);
end

function handles = update_SWPlot(handles)
nSW = handles.java.Spinner.getValue();
win = round(0.5*handles.Info.Recording.sRate);

range = handles.SW(nSW).Ref_NegativePeak-win:handles.SW(nSW).Ref_NegativePeak+win;
range(range<1) = [];

if ~isfield(handles, 'SWPlot') % in case plot doesn't already exist
    cla(handles.ax_SWPlot);
    
    handles.SWPlot.All      = plot(handles.ax_SWPlot, handles.Data.Raw(:,range)','Color', [0.6 0.6 0.6], 'linewidth', 0.5, 'Visible', 'off');
    handles.SWPlot.Ref      = plot(handles.ax_SWPlot, handles.Data.STRef(handles.SW(nSW).Ref_Region(1), range)','Color', 'r', 'linewidth', 3);
    
    handles.SWPlot.CWT(1)   = plot(handles.ax_SWPlot, handles.Data.CWT{1}(handles.SW(nSW).Ref_Region(1),range)','Color', 'b', 'linewidth', 2);
    handles.SWPlot.CWT(2)   = plot(handles.ax_SWPlot, handles.Data.CWT{2}(handles.SW(nSW).Ref_Region(1),range)','Color', 'g', 'linewidth', 2);
    
    set(handles.SWPlot.All(handles.SW(nSW).Channels_Active), 'Color', [0.6 0.6 0.6], 'LineWidth', 1, 'Visible', 'on');
%     set(handles.SWPlot.All(handles.SW(nSW).Travelling_Delays<1), 'Color', 'b', 'LineWidth', 2, 'Visible', 'on');
    
    set(handles.ax_SWPlot, 'XLim', [1, win*2+1])
    
else
    for i = 1:size(handles.Data.Raw,1) % faster than total replot...
         set(handles.SWPlot.All(i),...
             'yData', handles.Data.Raw(i,range),...
             'Color', [0.6 0.6 0.6], 'linewidth', 0.5, 'Visible', 'off');
    end
    set(handles.SWPlot.All(handles.SW(nSW).Channels_Active), 'Color', [0.6 0.6 0.6], 'LineWidth', 1, 'Visible', 'on');
%     set(handles.SWPlot.All(handles.SW(nSW).Travelling_Delays<1), 'Color', 'b', 'LineWidth', 2, 'Visible', 'on');
    set(handles.SWPlot.Ref, 'yData', handles.Data.STRef(handles.SW(nSW).Ref_Region(1),range));
    
    % Check theta and alpha checkboxes
    if get(handles.theta_Cb, 'value')
        set(handles.SWPlot.CWT(1), 'yData', handles.Data.CWT{1}(handles.SW(nSW).Ref_Region(1),range));
    else
        set(handles.SWPlot.CWT(1), 'yData', []);       
    end
    if get(handles.alpha_Cb, 'value')
        set(handles.SWPlot.CWT(2), 'yData', handles.Data.CWT{2}(handles.SW(nSW).Ref_Region(1),range));
    else
        set(handles.SWPlot.CWT(2), 'yData', []);             
    end
    
    % Find the absolute maximum value and round to higher 10, then add 10 for space
    dataMax = ceil(abs(max(max(handles.Data.Raw(handles.SW(nSW).Channels_Active, range))))/10)*10+10;
    set(handles.ax_SWPlot, 'YLim', [-dataMax, dataMax])

end

function handles = update_SWDelay(handles, nFigure)
nSW = handles.java.Spinner.getValue();

if nFigure ~= 1; cla(handles.ax_Delay); end

% Plot the Delay Map...
if handles.java.PlotBox.getSelectedIndex()+1 == 1;

    if ~isempty(handles.SW(nSW).Travelling_DelayMap)
        H = swa_Topoplot...
            (handles.SW(nSW).Travelling_DelayMap, handles.Info.Electrodes,...
            'NewFigure',        nFigure                             ,...
            'Axes',             handles.ax_Delay                    ,...
            'NumContours',      20                                  ,...
            'PlotContour',      1                                   ,...
            'PlotSurface',      get(handles.Surface_Delay,  'value'),...
            'PlotChannels',     get(handles.Channels_Delay, 'value'),...
            'PlotStreams',      get(handles.Streams_Delay,  'value'),...
            'Streams',          handles.SW(nSW).Travelling_Streams);
    else % if there is no delay map make one!
        H = swa_Topoplot...
            ([], handles.Info.Electrodes,...
            'Data',             handles.SW(nSW).Travelling_Delays   ,...
            'GS',               handles.Info.Parameters.Travelling_GS,...
            'NewFigure',        nFigure                             ,...
            'Axes',             handles.ax_Delay                    ,...
            'NumContours',      10                                  ,...
            'PlotContour',      1                                   ,...
            'PlotSurface',      get(handles.Surface_Delay,  'value'),...
            'PlotChannels',     get(handles.Channels_Delay, 'value'),...
            'PlotStreams',      get(handles.Streams_Delay,  'value'),...
            'Streams',          handles.SW(nSW).Travelling_Streams);
    end
    
    if get(handles.Origins_Delay, 'Value') == 1 && exist('H', 'var')
        if isfield(H, 'Channels')
            set(H.Channels(handles.SW(nSW).Travelling_Delays<2),...
                'String',           'o'         ,...
                'FontSize',         12          );
        end
    end

% Or plot the involvement map (peak 2 peak amplitudes for active channels
elseif handles.java.PlotBox.getSelectedIndex()+1 == 2;
    
    H = swa_Topoplot...
        ([], handles.Info.Electrodes,...
        'Data',             handles.SW(nSW).Channels_Peak2PeakAmp,...
        'GS',               handles.Info.Parameters.Travelling_GS,...
        'NewFigure',        nFigure                             ,...
        'Axes',             handles.ax_Delay                    ,...
        'NumContours',      10                                  ,...
        'PlotContour',      1                                   ,...
        'PlotSurface',      get(handles.Surface_Delay,  'value'),...
        'PlotChannels',     get(handles.Channels_Delay, 'value'),...
        'PlotStreams',      get(handles.Streams_Delay,  'value'),...
        'Streams',          handles.SW(nSW).Travelling_Streams);
    
%     cla(handles.ax_Delay);
%     axes(handles.ax_Delay);
%     ept_Topoplot(handles.SW(nSW).Channels_Peak2PeakAmp,handles.Info.Electrodes,...
%         'NewFigure', nFigure,...
%         'PlotSurface',  get(handles.Surface_Delay,  'value'),...
%         'PlotContour',1, 'NumContours', 10,...
%         'PlotChannels', get(handles.Channels_Delay,  'value'));
%     colormap(flipud(hot));
    
end

function handles = update_SWOriginsMap(handles, nFigure)

handles.Origins = zeros(size(handles.Data.Raw,1),1);
handles.Totals  = zeros(size(handles.Data.Raw,1),1);
for i = 1:length(handles.SW)
    handles.Origins(handles.SW(i).Travelling_Delays<1)  = handles.Origins(handles.SW(i).Travelling_Delays<1) + 1;
    handles.Totals(handles.SW(i).Channels_Active)       = handles.Totals(handles.SW(i).Channels_Active) +1;
end

% set(handles.Figure,'CurrentAxes',handles.ax_Origins)
% ept_Topoplot(handles.Origins,handles.Info.Electrodes, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);
H = swa_Topoplot(...
    [], handles.Info.Electrodes,...
    'Data',             handles.Origins                     ,...
    'GS',               handles.Info.Parameters.Travelling_GS,...
    'NewFigure',        nFigure                             ,...
    'Axes',             handles.ax_Origins                  ,...
    'NumContours',      4                                   ,...
    'PlotSurface',      1                                   );

% set(handles.Figure,'CurrentAxes',handles.ax_Density)
% ept_Topoplot(handles.Totals,handles.Info.Electrodes, 'Axes', handles.ax_Density, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);
H = swa_Topoplot(...
    [], handles.Info.Electrodes,...
    'Data',             handles.Totals                      ,...
    'GS',               handles.Info.Parameters.Travelling_GS,...
    'NewFigure',        nFigure                             ,...
    'Axes',             handles.ax_Density                  ,...
    'NumContours',      4                                   ,...
    'PlotSurface',      1                                   );


%% Push Buttons
function pb_XOrigins_Callback(hObject, eventdata)
handles = guidata(hObject);
ept_Topoplot(handles.Origins,handles.Info.Electrodes, 'NewFigure', 1, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);

function pb_XDensity_Callback(hObject, eventdata)
handles = guidata(hObject);
ept_Topoplot(handles.Totals,handles.Info.Electrodes, 'NewFigure', 1, 'NumContours', 4, 'PlotSurface', 1, 'PlotContour',0);

function pb_XDelay_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
update_SWDelay(handles, 1);


function pb_Delete_Callback(hObject, eventdata)
handles = guidata(hObject);

handles.SW(handles.java.Spinner.getValue())=[];

handles.java.Slider.setMaximum(length(handles.SW));

% Update the Origins and Density Maps with new values
handles = update_SWOriginsMap(handles, 0);
colormap(flipud(hot));

guidata(hObject, handles);
SpinnerUpdate([],[], hObject);


function edit_SWPlot(hObject, ~)
handles = guidata(hObject);
nSW = handles.java.Spinner.getValue();
win = round(0.5*handles.Info.Recording.sRate);

range = round((handles.SW(nSW).Ref_NegativePeak-win):(handles.SW(nSW).Ref_NegativePeak+win));
range(range<1) = [];
xaxis = range./handles.Info.Recording.sRate;

%% Prepare Figure
SW_Handles.Figure = figure(...
    'Name',         'Edit Detected Wave',...
    'NumberTitle',  'off',...
    'Color',        'w',...
    'MenuBar',      'none',...
    'Units',        'pixels',...
    'Outerposition',[200 200 900 600]);

SW_Handles.Axes = axes(...
    'Parent',   SW_Handles.Figure,...
    'Position', [0.05 0.05 0.92 0.9],...
    'NextPlot', 'add',...
    'FontName', 'Century Gothic',...
    'FontSize', 8,...
    'box',      'off',...
    'XLim',     [xaxis(1), xaxis(end)],...
    'YDir',     get(handles.ax_SWPlot, 'YDir'));

%% Add buttons
iconZoom = fullfile(matlabroot,'/toolbox/matlab/icons/tool_zoom_in.png');
iconArrow = fullfile(matlabroot,'/toolbox/matlab/icons/tool_pointer.png'); 
iconTravel = fullfile(matlabroot,'/toolbox/matlab/icons/tool_text_arrow.png'); 

% Just add javacomponent buttons...
[j_pbArrow,SW_Handles.pb_Arrow] = javacomponent(javax.swing.JButton);
set(SW_Handles.pb_Arrow,...
    'Parent',   SW_Handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.80 0.05 0.05 0.07]);
% >> j_pbZoom.set [then tab complete to find available methods]
j_pbArrow.setIcon(javax.swing.ImageIcon(iconArrow))
set(j_pbArrow, 'ToolTipText', 'Select Channel'); 
set(j_pbArrow, 'MouseReleasedCallback', 'zoom off');

[j_pbZoom,SW_Handles.pb_Zoom] = javacomponent(javax.swing.JButton);
set(SW_Handles.pb_Zoom,...
    'Parent',   SW_Handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.85 0.05 0.05 0.07]);
% >> j_pbZoom.set [then tab complete to find available methods]
j_pbZoom.setIcon(javax.swing.ImageIcon(iconZoom))
set(j_pbZoom, 'ToolTipText', 'Zoom Mode'); 
set(j_pbZoom, 'MouseReleasedCallback', 'zoom on');

[j_pbTravel,SW_Handles.pb_Travel] = javacomponent(javax.swing.JButton);
set(SW_Handles.pb_Travel,...
    'Parent',   SW_Handles.Figure,...      
    'Units',    'normalized',...
    'Position', [0.92 0.05 0.05 0.07]);
% >> j_pbZoom.set [then tab complete to find available methods]
j_pbTravel.setIcon(javax.swing.ImageIcon(iconTravel))
set(j_pbTravel, 'ToolTipText', 'Recalculate Travelling'); 
set(j_pbTravel, 'MouseReleasedCallback', {@UpdateTravelling, handles.Figure});

%% Plot the data with the reference negative peak centered %
SW_Handles.Plot_Ch = plot(SW_Handles.Axes,...
     xaxis, handles.Data.Raw(:,range)',...
    'Color', [0.8 0.8 0.8],...
    'LineWidth', 0.5,...
    'LineStyle', ':');
set(SW_Handles.Plot_Ch, 'ButtonDownFcn', {@Channel_Selected, handles.Figure, SW_Handles});
set(SW_Handles.Plot_Ch(handles.SW(nSW).Channels_Active), 'Color', [0.6 0.6 0.6], 'LineWidth', 1, 'LineStyle', '-');
% set(SW_Handles.Plot_Ch(handles.SW(nSW).Travelling_Delays<1), 'Color', 'b', 'LineWidth', 2, 'LineStyle', '-');

handles.SWPlot.Ref = plot(SW_Handles.Axes,...
    xaxis, handles.Data.STRef(handles.SW(nSW).Ref_Region(1),range)',...
    'Color', 'r',...
    'LineWidth', 3);

handles.SWPlot.CWT = plot(SW_Handles.Axes,...
    xaxis, handles.Data.CWT{1}(handles.SW(nSW).Ref_Region(1), range)',...
    'Color', 'b',...
    'LineWidth', 3);



function Channel_Selected(hObject, ~ , FigureHandle, SW_Handles)
handles = guidata(FigureHandle);
% a = get(handles.Figure, 'SelectionType');

nSW = handles.java.Spinner.getValue();
nCh = find(SW_Handles.Plot_Ch == hObject);

if ~handles.SW(nSW).Channels_Active(nCh)
    handles.SW(nSW).Channels_Active(nCh) = true;
    set(SW_Handles.Plot_Ch(nCh), 'Color', [0.6 0.6 0.6], 'LineWidth', 1, 'LineStyle', '-')
    set(handles.SWPlot.All(nCh), 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'LineStyle', '-', 'Visible', 'on')
else
    handles.SW(nSW).Channels_Active(nCh) = false;
    set(SW_Handles.Plot_Ch(nCh), 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5, 'LineStyle', ':')
    set(handles.SWPlot.All(nCh), 'Color', [0.6 0.6 0.6], 'LineWidth', 0.5, 'LineStyle', '-', 'Visible', 'off')
end

guidata(handles.Figure, handles);

function UpdateTravelling(hObject, ~ , FigureHandle)
handles = guidata(FigureHandle);

nSW = handles.java.Spinner.getValue();

% Recalculate the Travelling_Delays parameter before running...
Window = round(handles.Info.Parameters.Channels_WinSize*handles.Info.Recording.sRate);
wData = (handles.SW(nSW).CWT_NegativePeak-Window):(handles.SW(nSW).CWT_NegativePeak+Window);  

Data.REM = handles.Data.Raw(handles.SW(nSW).Channels_Active, wData);

FreqRange   = handles.Info.Parameters.CWT_hPass:handles.Info.Parameters.CWT_lPass;
Scale_theta  = swa_frq2scal(FreqRange, 'morl', 1/handles.Info.Recording.sRate);    % Own Function!

Channels_Theta = zeros(size(Data.REM));
WaitHandle = waitbar(0,'Please wait...', 'Name', 'Calculating Wavelets');
for i = 1:size(Data.REM,1)
    waitbar(i/size(Data.REM,1),WaitHandle,sprintf('Channel %d of %d',i, size(Data.REM,1)))
    Channels_Theta(i,:) = mean(cwt(Data.REM(i,:),Scale_theta,'morl'));
end
delete(WaitHandle);

[Ch_Min, Ch_Id] = min(Channels_Theta, [],2);

handles.SW(nSW).Travelling_Delays = nan(size(handles.Data.Raw,1),1);
handles.SW(nSW).Travelling_Delays(handles.SW(nSW).Channels_Active) = Ch_Id-min(Ch_Id);

[handles.Info, handles.SW] = swa_FindSTTravelling(handles.Info, handles.SW, nSW);

handles = update_SWDelay(handles, 0);
guidata(handles.Figure, handles);


function Butterfly_Context(hObject, ~, Direction)
handles = guidata(hObject);
set(handles.ax_Butterfly,   'YDir', Direction)
set(handles.ax_SWPlot,      'YDir', Direction)



%% Check Boxes
function UpdateDelay2(hObject, eventdata)
handles = guidata(hObject);
update_SWDelay(handles, 0);
