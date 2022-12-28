filename = [...
    'results_' ...
    'Top_' num2str(RANDOM_SEED, '%03d') ...
    '.mat'...
    ];

% save( filename, ...
%     'total_agents', ...
%     'pd_CEN', ...
%     'cost_CEN', ...
%     'pd_ASYNC', ...
%     'cost_ASYNC', ...
%     'iterations_SVRG' ...
%     );


% save( filename, ...
%     'video_duration', ...
%     'vals_myopic', ...
%     'vals_proposed' ...
%     );

% 
save( filename, ...
    'video_duration', ...
    'control_decision_avgBased', ...
    'control_decision_ideal', ....
    'control_decision_myopic', ....
    'control_decision_proposed', ...
    'control_decision_safe', ...
    'vals_myopic', ...
    'vals_safe', ...
    'vals_avgBased', ...
    'vals_ideal', ...
    'vals_proposed' ...
    );