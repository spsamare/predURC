function [ ...
    Cache_decisions, ...
    Quality_val ...
    ] = CacheSolver( ...
    los_duration, ...
    initial_state, ...
    blocked_duration ...
    )

global max_rate quality_scaler buffer_capacity available_frames

total_duration = los_duration + blocked_duration;

cvx_begin quiet
    variable control_var(total_duration,los_duration)
% %optimization
    maximize( ones(1,total_duration)*log( 1 + quality_scaler*(control_var*ones(los_duration,1) + initial_state) )/total_duration  )
%  %constraints
    subject to
    for t = 1:los_duration
        ones(1,total_duration)*control_var(:,t) <= max_rate;
        zeros(total_duration,1) <= control_var(:,t) <= max_rate*ones(total_duration,1);
        window_size = min(total_duration-t,available_frames-1);
        ones(1,window_size+1)*control_var(t:t+window_size,t) == ones(1,total_duration)*control_var(:,t);
        ones(1,total_duration-t+1)*(initial_state(t:end) + control_var(t:end,1:t)*ones(t,1)) <= buffer_capacity;
    end
cvx_end

Cache_decisions = control_var;
% Cache_decisions(control_var<=0) = 0;
Quality_val = ones(1,total_duration)*log( 1 + quality_scaler*(control_var*ones(los_duration,1) + initial_state) )/total_duration;
end