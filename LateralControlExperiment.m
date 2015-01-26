open_system('Platooning.slx')

speeds = int32(50:5:90) ;

for i=1:length(speeds)
    fprintf('Running %skph\n', num2str(speeds(i)));
    set_param('Platooning/Command Schedule/Speed1','Value', num2str(speeds(i)* 0.277777778));
    pause(1)
    sim('Platooning');
    save(['data/LateralControlAt' num2str(speeds(i)) 'kph.mat'],'Errors'); 
end