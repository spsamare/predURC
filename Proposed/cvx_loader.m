cur_dir = pwd;
if isunix
    cd('/home/ssamarak/support/cvx');
else
    cd('C:\Users\ssamarak\My Work\MATLAB\cvx');
end
cvx_setup;
cd(cur_dir);