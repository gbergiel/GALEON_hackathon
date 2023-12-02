
test_cases = [1 2 3];
speeds = [];
for test = test_cases
    controls = 0 :0.05 : 12;
    itr = 0;
    for control = controls
        itr = itr + 1;
        setpoint_value = control;
        output = sim("collect_staic_data.slx");
        values = output.position.Data(output.position.Data >= 1 & output.position.Data < 2);
        speed = mean(values);
        if isnan(speed)
            speed = 0;
        end
        speeds(itr) = speed;
    end
    figure();
    plot(controls, speeds);
end
