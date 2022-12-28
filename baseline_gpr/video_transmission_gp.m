% Video transmission

% Clear_data_Keep_debug;
% RANDOM_SEED = 1;

%% parameters
% global blocked_duration
blocked_duration = 2;
% for LOS duration
weibull_shape = 9;
weibull_scale = 5*gamma(1+1/3)/gamma(1+1/9);

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



%% GPR
%{}

duration_los_gp = 0;%weibull_scale*gamma(1 + 1/weibull_shape );

control_decision_gp = zeros( video_duration );
this_LOS_duration = 0;

this_control_decision = [];
duration_los_this = duration_los_gp;
%--------------
event_counter = 0;
history_len = 10;
meanfunc = @meanConst; hyp.mean = 0;
covfunc = {@covMaterniso, 3}; ell = 1/4; sf = 1; hyp.cov = log([ell; sf]);
likfunc = @likGauss; sn = 0.1; hyp.lik = log(sn);
new_blocking = 1; 
for t = 1:video_duration
    % @TX
    if LOS_fractions_t(t)<1
        this_LOS_duration = LOS_fractions_t(t);
        if new_blocking==1
            event_counter = event_counter + 1;
            % GRP based LOS duration prediction
            this_history = min( history_len, event_counter);
            train_input = ((event_counter+1-this_history):event_counter)';
            train_output = LOSdurations_all(train_input);
            this_hyp = minimize(hyp, @gp, -100, @infGaussLik, ...
                meanfunc, covfunc, likfunc, train_input, train_output);
            
            next_val = event_counter+1;
            [my_predict s2] = gp(this_hyp, @infGaussLik, meanfunc, covfunc, ...
                likfunc, train_input, train_output, next_val);
            
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
                control_decision_gp(t:(t+duration_this+duration_block-1),1:t), 2);
            [ this_cache_decisions, this_quality_val ] = CacheSolver( ...
                duration_this, this_initial_state, duration_block );
%             temp_decision = this_cache_decisions(1:duration_this+duration_block,1);
            this_control_decision = this_cache_decisions.*(abs(this_cache_decisions)>val_threshold);
        else
            duration_los_this = 1;
            duration_this = duration_this - 1;
        end
        
        control_decision_gp(t:(t+duration_this+duration_block-1),t) = ...
            this_control_decision(:,1);
        
        this_control_decision(:,1) = [];
        this_control_decision(1,:) = [];
        
    end
    
%     receiver_state_gp(:,t) = receiver_buffer_gp;
end

%[receiver_exp_proposed log( 1 + quality_scaler*receiver_buffer_proposed ) LOS_fractions_t(1:video_duration)]
%[losses_proposed sum( receiver_buffer_proposed == 0 )]
%LOS_fractions_t(1:video_duration)<1

% @RX
receiver_state_gp = cumsum( control_decision_gp, 2);
receiver_exp_gp = log( 1 + quality_scaler*receiver_state_gp(:,end) );
losses_gp = sum( receiver_state_gp(:,end) == 0 );


%}

%% Calculations
vals_gp = [mean(receiver_exp_gp) ...
    losses_gp/video_duration ...
    ];

%
disp('GP');disp(vals_gp);

Save_data_gp;
