    % Batch_Run
Clear_data_Keep_debug;
disp('Batch run started.');
cvx_loader;

save('Start.mat');

% start_search = 0;


% for test_topology = fliplr(start_search:end_topology)
%     if exist(['Completed_' num2str(test_topology,'%03d') '.mat'],'file')
%         break;
%     end
% end
% start_topology = test_topology + 1;
% start_clock = clock;
% for Iter_count = 1:length(ITER)
%     disp(['SVRG version ' num2str(Iter_count) ' is started.']);
    end_topology = 25;
    start_topology = 1;
for TOPOLOGY = start_topology:end_topology
    disp(['Topology: ' num2str(TOPOLOGY)]);
    RANDOM_SEED = TOPOLOGY;
    %%
%     Set_Parameters;
%     iterations_SVRG = ITER(Iter_count);
    video_transmission_new;
    disp(['Topology ' num2str(TOPOLOGY) ' is done.']);
%     pause(3);
    clearvars -except TOPOLOGY
    %% delete and create
    if exist(['Completed_' num2str(TOPOLOGY-1,'%03d') '.mat'],'file')
        delete(['Completed_' num2str(TOPOLOGY-1,'%03d') '.mat']);
        pause(3);
    end
    save(['Completed_' num2str(TOPOLOGY,'%03d') '.mat'], 'TOPOLOGY' );
end
% end
disp('Batch run finished.');