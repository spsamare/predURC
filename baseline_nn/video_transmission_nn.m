% Video transmission

% Clear_data_Keep_debug;
% RANDOM_SEED = 1;

%% parameters
% global blocked_duration
blocked_duration = 2;
% for LOS duration
weibull_scale = 5;
weibull_shape = 3;

val_threshold = 10^(-9);

% t = 0:.1:10;
% plot( t, wblpdf(t, weibull_scale, weibull_shape));

LOSevent_realizations = 150;

video_duration = 500;%iterations_DUR;%200;
global buffer_capacity available_frames
available_frames = 4;

% method_text = {'Myopic', 'Safe-Play','Prediction-Avg.', 'Prediction-Ins.', 'Ideal'};

global max_rate quality_scaler
max_rate = 5;
quality_scaler = 1;

buffer_capacity = max_rate*6;

%% channel generation
rng( RANDOM_SEED );

LOSdurations_all = wblrnd( weibull_scale, weibull_shape, ...
    [LOSevent_realizations 1]);

LOS_fractions_t = [];
time_val = 0;
remain_val = 0;
for i = 1:LOSevent_realizations
    temp_val = LOSdurations_all(i) + remain_val - 1;
    LOS_fractions_t = [ LOS_fractions_t; ...
        1-remain_val; ones( floor(temp_val), 1)];
    remain_val = mod(temp_val,1);
    if remain_val > 0
        LOS_fractions_t = [ LOS_fractions_t; ...
            remain_val; zeros(blocked_duration-1, 1)];
    else
        LOS_fractions_t = [ LOS_fractions_t; ...
            zeros(blocked_duration, 1)];
    end
    
end



%% NN
%{}
load('trainedWeights1.mat');
durations_all = [LOSdurations_all((end-49):end); LOSdurations_all];
duration_los_nn = 0;%weibull_scale*gamma(1 + 1/weibull_shape );

control_decision_nn = zeros( video_duration );
this_LOS_duration = 0;

this_control_decision = [];
duration_los_this = predict2( Theta1, Theta2, Theta3, (durations_all(1:50))');
%--------------
event_counter = 0;
new_blocking = 1; 
for t = 1:video_duration
    % @TX
    if LOS_fractions_t(t)<1
        this_LOS_duration = LOS_fractions_t(t);
        if new_blocking==1
            event_counter = event_counter + 1;
            % NN based LOS duration prediction
            test_input = (durations_all((1+event_counter):(50+event_counter)))';
            
            my_predict = predict2( Theta1, Theta2, Theta3, ...
                test_input);
            
            duration_los_this = my_predict;
            new_blocking = 0;
        end
        this_control_decision = [];
    else
        this_LOS_duration = this_LOS_duration + LOS_fractions_t(t);
        new_blocking = 1;
        
        if isempty(this_control_decision)
            duration_this = max( min( floor( duration_los_this ), video_duration-t+1), 1);
            duration_block = min(blocked_duration+1, video_duration+1-duration_this-t);
            
            this_initial_state = sum( ...
                control_decision_nn(t:(t+duration_this+duration_block-1),1:t), 2);
            [ this_cache_decisions, this_quality_val ] = CacheSolver( ...
                duration_this, this_initial_state, duration_block );
%             temp_decision = this_cache_decisions(1:duration_this+duration_block,1);
            this_control_decision = this_cache_decisions.*(abs(this_cache_decisions)>val_threshold);
        else
            duration_los_this = 1;
            duration_this = duration_this - 1;
        end
        
        control_decision_nn(t:(t+duration_this+duration_block-1),t) = ...
            this_control_decision(:,1);
        
        this_control_decision(:,1) = [];
        this_control_decision(1,:) = [];
        
    end
    
%     receiver_state_nn(:,t) = receiver_buffer_nn;
end

%[receiver_exp_proposed log( 1 + quality_scaler*receiver_buffer_proposed ) LOS_fractions_t(1:video_duration)]
%[losses_proposed sum( receiver_buffer_proposed == 0 )]
%LOS_fractions_t(1:video_duration)<1

% @RX
receiver_state_nn = cumsum( control_decision_nn, 2);
receiver_exp_nn = log( 1 + quality_scaler*receiver_state_nn(:,end) );
losses_nn = sum( receiver_state_nn(:,end) == 0 );


%}

%% Calculations
vals_nn = [mean(receiver_exp_nn) ...
    losses_nn/video_duration ...
    ];

%
disp('GP');disp(vals_nn);

Save_data_nn;
