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
available_frames = 8;

% method_text = {'Myopic', 'Safe-Play','Prediction-Avg.', 'Prediction-Ins.', 'Ideal'};

global max_rate quality_scaler
max_rate = 5;
quality_scaler = 1;

buffer_capacity = max_rate*6;

%% channel generation
rng( RANDOM_SEED );

LOSdurations_all = wblrnd( 5, 3, ...
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

%% Myopic baseline
%{
control_decision_myopic = zeros( video_duration );
% receiver_buffer_HQ_myopic = zeros( video_duration, 1);

% receiver_exp_myopic = zeros( video_duration, 1);

for t = 1:video_duration
    % @TX
    if LOS_fractions_t(t)<1
    else
        control_decision_myopic(t,t) = max_rate;
    end
end
receiver_state_myopic = cumsum(control_decision_myopic,2);
receiver_exp_myopic = log( 1 + quality_scaler*receiver_state_myopic(:,end) );
losses_myopic = sum( receiver_state_myopic(:,end) == 0 );
%}

%% Safe Play
%{
control_decision_safe = zeros( video_duration );
this_LOS_duration = 0;


for t = 1:video_duration
    % @TX
    if LOS_fractions_t(t)<1
        this_LOS_duration = LOS_fractions_t(t);
    else
        this_LOS_duration = this_LOS_duration + LOS_fractions_t(t);
        
        duration_this = 1;
        duration_block = min(blocked_duration+1, video_duration+1-duration_this-t);
        
        this_initial_state = sum( ...
            control_decision_safe(t:(t+duration_this+duration_block-1),1:t), 2);
        [ this_cache_decisions, this_quality_val ] = CacheSolver( ...
            duration_this, this_initial_state, duration_block );
        %             temp_decision = this_cache_decisions(1:duration_this+duration_block,1);
        this_control_decision = this_cache_decisions.*(abs(this_cache_decisions)>val_threshold);
        
        
        control_decision_safe(t:(t+duration_this+duration_block-1),t) = ...
            this_control_decision(:,1); 
    end
    
    %     receiver_state_avgBased(:,t) = receiver_buffer_avgBased;
end

% @RX
receiver_state_safe = cumsum( control_decision_safe, 2);
receiver_exp_safe = log( 1 + quality_scaler*receiver_state_safe(:,end) );
losses_safe = sum( receiver_state_safe(:,end) == 0 );
%}

%% IDEAL
%{
control_decision_ideal = zeros( video_duration );

run_this = 1;
t = 1;
while run_this == 1
    this_los_duration = min( find( LOS_fractions_t(t:end)<1, 1)-1, video_duration-t+1);
    this_blocked_duration = min( ...
        find(LOS_fractions_t(t+this_los_duration:end)==1,1)-1, ...
        video_duration+1-this_los_duration-t);
    
    this_initial_state = sum( ...
        control_decision_ideal(t:(t+this_los_duration+this_blocked_duration-1),1:t), 2);
    [ this_cache_decisions, this_quality_val ] = CacheSolver( ...
        this_los_duration, this_initial_state, this_blocked_duration );
    control_decision_ideal(t:(t+this_los_duration+this_blocked_duration-1), ...
        t:(t+this_los_duration+this_blocked_duration-1)) = ...
        [this_cache_decisions.*(abs(this_cache_decisions)>val_threshold) ...
        zeros(length(this_initial_state), this_blocked_duration)];
%     control_decision_ideal(t:(t+this_los_duration+this_blocked_duration-1), ...
%         t:(t+this_los_duration+this_blocked_duration-1)) = ...
%         [[this_cache_decisions - tril(this_cache_decisions,-this_los_duration-1)...
%         - triu(this_cache_decisions,1)] ...
%         zeros(length(this_initial_state), this_blocked_duration)];
    t = t + this_los_duration + this_blocked_duration;
    run_this = (t<=video_duration);
end

% @RX
receiver_state_ideal = cumsum( control_decision_ideal, 2);
receiver_exp_ideal = log( 1 + quality_scaler*receiver_state_ideal(:,end) );
losses_ideal = sum( receiver_state_ideal(:,end) == 0 );

%}

%% Average-based
%{
% receiver_buffer_avgBased = zeros( video_duration, 1);
% receiver_state_avgBased = zeros( video_duration );

duration_los_avg = weibull_scale*gamma(1 + 1/weibull_shape );
% duration_transmission_avg = ceil(duration_los_avg) + blocked_duration;
% allocation_per_frame = max_rate*duration_los_avg/duration_transmission_avg;

control_decision_avgBased = zeros( video_duration );
this_LOS_duration = 0;

this_control_decision = [];
duration_los_this = duration_los_avg;
for t = 1:video_duration
    % @TX
    if LOS_fractions_t(t)<1
        this_LOS_duration = LOS_fractions_t(t);
        duration_los_this = duration_los_avg;
        this_control_decision = [];
    else
        this_LOS_duration = this_LOS_duration + LOS_fractions_t(t);
        
        if isempty(this_control_decision)
            duration_this = max( min( floor( duration_los_this ), video_duration-t+1), 1);
            duration_block = min(blocked_duration+1, video_duration+1-duration_this-t);
            
            this_initial_state = sum( ...
                control_decision_avgBased(t:(t+duration_this+duration_block-1),1:t), 2);
            [ this_cache_decisions, this_quality_val ] = CacheSolver( ...
                duration_this, this_initial_state, duration_block );
%             temp_decision = this_cache_decisions(1:duration_this+duration_block,1);
            this_control_decision = this_cache_decisions.*(abs(this_cache_decisions)>val_threshold);
        else
            duration_los_this = 1;
            duration_this = duration_this - 1;
        end
        
        control_decision_avgBased(t:(t+duration_this+duration_block-1),t) = ...
            this_control_decision(:,1);
        
        this_control_decision(:,1) = [];
        this_control_decision(1,:) = [];
        
    end
    
%     receiver_state_avgBased(:,t) = receiver_buffer_avgBased;
end

%[receiver_exp_proposed log( 1 + quality_scaler*receiver_buffer_proposed ) LOS_fractions_t(1:video_duration)]
%[losses_proposed sum( receiver_buffer_proposed == 0 )]
%LOS_fractions_t(1:video_duration)<1

% @RX
receiver_state_avgBased = cumsum( control_decision_avgBased, 2);
receiver_exp_avgBased = log( 1 + quality_scaler*receiver_state_avgBased(:,end) );
losses_avgBased = sum( receiver_state_avgBased(:,end) == 0 );


%}

%% Proposed
%{}
% receiver_buffer_proposed = zeros( video_duration, 1);
% receiver_state_proposed = zeros( video_duration );
control_decision_proposed = zeros( video_duration );
% receiver_exp_proposed = zeros( video_duration, 1);
this_LOS_duration = 0;

for t = 1:video_duration
    % @TX
    if LOS_fractions_t(t)<1
        this_LOS_duration = LOS_fractions_t(t);
    else
        this_LOS_duration = this_LOS_duration + LOS_fractions_t(t);
        % predict duration
        % expected LOS duration
        predicted_duration = ...
            Cond_WBL_Moments(this_LOS_duration,...
            weibull_scale,weibull_shape,1);
        
%         los_probability = ...
%             exp( (this_LOS_duration./weibull_scale).^weibull_shape ...
%             - ((1+this_LOS_duration)./weibull_scale).^weibull_shape );
        los_probability = 1;
       
%         this_los_duration = min( find( LOS_fractions_t(t:end)<1, 1)-1, video_duration-t+1);
        duration_los = max( min( floor( predicted_duration*los_probability ), video_duration-t+1), 1);
        duration_block = min(blocked_duration+1, video_duration+1-duration_los-t);
        
        this_initial_state = sum( ...
            control_decision_proposed(t:(t+duration_los+duration_block-1),1:t), 2);
        [ this_cache_decisions, this_quality_val ] = CacheSolver( ...
            duration_los, this_initial_state, duration_block );
        temp_decision = this_cache_decisions(1:duration_los+duration_block,1);
        temp_decision = temp_decision.*(abs(temp_decision)>val_threshold);
        control_decision_proposed(t:(t+duration_los+duration_block-1),t) = ...
            temp_decision;
        
        
        
    end
    
end

% @RX
receiver_state_proposed = cumsum( control_decision_proposed, 2);
receiver_exp_proposed = log( 1 + quality_scaler*receiver_state_proposed(:,end) );
losses_proposed = sum( receiver_state_proposed(:,end) == 0 );

%}

%% plotting
%{
figure()
hold all
plot( 1:video_duration, 1.5*(LOS_fractions_t(1:video_duration)==1), 'bo');
plot( 1:video_duration, receiver_exp_myopic)
plot( 1:video_duration, receiver_exp_ideal)
plot( 1:video_duration, receiver_exp_proposed)
legend(['Channel state', method_text]);
grid on
%}

%% Calculations
% vals_myopic = [mean(receiver_exp_myopic) ...
%     losses_myopic/video_duration ...
%     ];
% vals_safe= [mean(receiver_exp_safe) ...
%     losses_safe/video_duration ...
%     ];
% vals_ideal = [mean(receiver_exp_ideal) ...
%     losses_ideal/video_duration ];
% vals_avgBased = [mean(receiver_exp_avgBased) ...
%     losses_avgBased/video_duration ...
%     ];
vals_proposed = [mean(receiver_exp_proposed) ...
    losses_proposed/video_duration ...
    ];
%
% disp('Myopic');disp(vals_myopic);
% disp('Safe');disp(vals_safe);
% disp('Avg');disp(vals_avgBased);
disp('Predict');disp(vals_proposed);
% disp('Ideal');disp(vals_ideal);
Save_data;
%%
%{
close all;
this_LOS_duration = 0:.1:10;
duration_Mean = ...
    Cond_WBL_Moments(this_LOS_duration,weibull_scale,weibull_shape,1);
duration_SD = sqrt(...
    Cond_WBL_Moments(this_LOS_duration,weibull_scale,weibull_shape,2) ...
    - duration_Mean.^2);
pobabilities = exp( (this_LOS_duration./weibull_scale).^weibull_shape ...
    - ((1+this_LOS_duration)./weibull_scale).^weibull_shape );
figure()
hold all
yyaxis left
fill([this_LOS_duration fliplr(this_LOS_duration)], ...
    [duration_Mean+duration_SD fliplr(duration_Mean-duration_SD)], ...
    [hex2dec('ED') hex2dec('B0') hex2dec('21')]/255 );
plot( this_LOS_duration, duration_Mean)
ylim([0 7]);
yyaxis right
plot( this_LOS_duration, pobabilities)
grid on
%}
%%
%{
fig_anim = figure();
max_val = max( [ max( receiver_buffer_myopic ); ...
    max( receiver_buffer_ideal ); max( receiver_buffer_proposed )] );
x_val_myopic = [0:(video_duration-1)]*3;
x_val_ideal = [0:(video_duration-1)]*3+1;
x_val_proposed = [0:(video_duration-1)]*3+2;
for i = 1:video_duration
    hold on;
    plot( 0:(video_duration-1), receiver_state_myopic(:,i), '-r');
    plot( 0:(video_duration-1), receiver_state_ideal(:,i), '-g');
    plot( 0:(video_duration-1), receiver_state_proposed(:,i), '-b');
%     stem( x_val_myopic, receiver_state_myopic(:,i), 'r');
%     stem( x_val_ideal, receiver_state_ideal(:,i), 'g');
%     stem( x_val_proposed, receiver_state_proposed(:,i), 'b');
    hold off;
    ylim([0 max_val]);
    pause(.1);
end
%}
%%
%{
figure()
hold all
line( [1 video_duration], buffer_capacity*[1 1]);
plot( sum(tril(receiver_state_myopic)) )
plot( sum(tril(receiver_state_safe)) )
plot( sum(tril(receiver_state_avgBased)) )
plot( sum(tril(receiver_state_proposed)) )
plot( sum(tril(receiver_state_ideal)) )
legend(['Capacity' method_text])
%%
close all;
figure()
myMethod = tril(receiver_state_ideal);
myDist = 0;
for t = 2:(video_duration-myDist)
% plot(t:(t+myDist), myMethod(t:(t+myDist),t));
plot( myMethod(:,t) );
ylim([0 max(max(myMethod))]);
pause(.1);
end

%%
close all
figure();
% plot( sum(tril(receiver_state_avgBased) > 0)  )
hold all
line( [1 video_duration], available_frames*[1 1]);
plot( sum(tril(receiver_state_myopic)> 0 ))
plot( sum(tril(receiver_state_safe)> 0) )
plot( sum(tril(receiver_state_avgBased)> 0) )
plot( sum(tril(receiver_state_proposed)> 0) )
plot( sum(tril(receiver_state_ideal)> 0) )
legend(['Limit' method_text])
%%
close all
figure()
stem( LOS_fractions_t(1:video_duration) < 1 )
%}