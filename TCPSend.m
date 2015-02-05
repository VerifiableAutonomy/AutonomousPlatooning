function TCPSend(block)
%STCPIPSB Underlying S-Function for the ICT TCPIP Send block. 
%
%    STCPIPSB(BLOCK) is the underlying S-Function for the ICT TCPIP Send
%    block. 

%    SS 03/25/07
%    Copyright 2007-2011 The MathWorks, Inc.
  

% The setup method is used to setup the basic attributes of the
% S-function such as ports, parameters, etc. Do not add any other
% calls to the main body of the function.  
setup(block);

%endfunction

%% Function: setup ===================================================
%   Set up the S-function block's basic characteristics such as:
%   - Input ports
%   - Dialog parameters
%   - Options
% 
function setup(block)

    % Parameters: 
    % 1:Host, 
    % 2:Port, 
    % 3:EnableBlockingMode, 
    % 4:Timeout, 

    % Register number of ports
    block.NumInputPorts = 1;

    % Register parameters
    block.NumDialogPrms = 5;
    block.DialogPrmsTunable = {'Nontunable', 'Tunable', 'Nontunable', ...
                             'Nontunable', 'Nontunable'};

    % Register sample times, Inherit sample time.
    block.SampleTimes = [-1 0];

    % Setup port properties to be inherited or dynamic
    block.SetPreCompInpPortInfoToDynamic;

    % Override input port properties
    for idx = 1:block.NumInputPorts,
      block.InputPort(idx).Complexity   = 0;  % Real
      block.InputPort(idx).DirectFeedthrough = true; % Access inputs in Outputs function        
    end

    % Specify if Accelerator should use TLC or call back into
    % MATLAB file
    block.SetAccelRunOnTLC(false);
    block.SetSimViewingDevice(true);% no TLC required    

    % Allow multi dimensional signal support. 
    block.AllowSignalsWithMoreThan2D = true;
    
    block.SupportsMultipleExecInstances = true;
    
    %% -----------------------------------------------------------------
    %% Register methods called at run-time
    %% -----------------------------------------------------------------

    %% 
    %% Start:
    %%   Functionality    : Called in order to initialize state and work
    %%                      area values
    block.RegBlockMethod('Start', @Start);

    %% 
    %% Outputs:
    %%   Functionality    : Called to generate block outputs in
    %%                      simulation step
    block.RegBlockMethod('Outputs', @Outputs);

    %% 
    %% Terminate:
    %%   Functionality    : Called at the end of simulation for cleanup
    %%
    block.RegBlockMethod('Terminate', @Terminate);

%endfunction

%% Start - Set up the environment by creating objects, initializing data.
function Start(block)

    % Check the data type at the input port. 
    if (block.InputPort(1).DatatypeID < 0) || (block.InputPort(1).DatatypeID > 7)
        error(message('instrument:instrumentblks:invaliddatatype', get_param( block.BlockHandle, 'Name' )));
    end
    
    % Check the sample time of the block to be not continuous.
    if (block.SampleTimes(1) == 0)
        error(message('instrument:instrumentblks:invalidinheritedsampletime', get_param( block.BlockHandle, 'Name' )));
    end
    
    % Check if the host specified is empty/invalid.
    [name address] = resolvehost(block.DialogPrm(1).Data);
    if ( isempty(name) && isempty(address) ) % Error out if empty.
        error(message('instrument:instrumentblks:hostinvalid'));
    end

    % Find if any underlying objects exist with the same host and 
    % port.
    inputParams = {'tcpip', block.DialogPrm(1).Data, block.DialogPrm(2).Data, ...
                    'ByteOrder', block.DialogPrm(5).Data};
    tcpipObj = instrumentslgate('privateslsfcncreatenetworkobject', ...
                            block, inputParams);

    % Set the UserData field so that it stays persistent during the
    % simulation. 
    set_param(block.BlockHandle, 'UserData', tcpipObj)

    % Set output buffer size on the object. 
    if ( block.InputPort(1).DataStorageSize > get(tcpipObj, 'OutputBufferSize') )
        % Close the object. 
        fclose(tcpipObj);
        % Set it on the object. 
        set(tcpipObj, 'OutputBufferSize', 10*block.InputPort(1).DataStorageSize);
    end
    
    % Set the timeout value on the object. 
    if strcmpi(block.DialogPrm(3).Data, 'on') % Blocking mode
        if (block.DialogPrm(4).Data > tcpipObj.Timeout) % Check if required timeout is more.
            tcpipObj.Timeout = block.DialogPrm(4).Data;
        end
    else % Non-blocking model
        % Do nothing. Any timeout value is fine as we do not block at all.
    end

    % Open the object
    if ~strcmp(get(tcpipObj, 'Status'), 'open')
        try %Try opening the object.
            fopen(tcpipObj);
        catch %#ok<CTCH>
            % Display error that port is invalid.
            error(message('instrument:instrumentblks:portinvalid', get_param( block.BlockHandle, 'Name' )));
        end
    end
%endfunction Start

%% Outputs - Generate block outputs at every timestep.
function Outputs(block)
    
    % Parameters: 
    % 1:Host, 
    % 2:Port, 
    % 3:EnableBlockingMode, 
    % 4:Timeout, 

    % Get the underlying object. 
    tcpipObj = get_param(block.BlockHandle, 'UserData');
    
    data = reshape(block.InputPort(1).Data, 1, numel(block.InputPort(1).Data));
    if strcmpi(block.DialogPrm(3).Data, 'on')
        fwrite(tcpipObj, data, block.InputPort(1).Datatype);
    else
        while ~strcmp(get(tcpipObj,'TransferStatus'),'idle')
            % Just wait until previous async fwrite is complete.
            pause(0.01);
        end
        fwrite(tcpipObj, data, block.InputPort(1).Datatype, 'async');
    end
%endfunction Outputs

%% Terminate - Clean up. 
function Terminate(block)

    % Call the terminate method for network objects. 
    instrumentslgate('privateslsfcnterminatenetworkobject', block, 'tcpip');

%endfunction Terminate