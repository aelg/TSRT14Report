function [sm] = create_tdoa1(sensor_pos, target_init_pos, sensor_varianc, covariance_matrix)
%CREATE_TDOA1 creates a signalmod for with tdoa1 option
% only one target in 2 dimensions

nr_of_sensors = length(sensor_pos)/2;

% Sensor model
sm = exsensor('tdoa1', nr_of_sensors, 1, 2);
sm.x0 = [target_init_pos]; % [m]
sm.th = sensor_pos;

% Kovariansmatris
sm.pe = ndist(sensor_varianc, covariance_matrix) ; % där R är kovariansmatrisen och mu en vektor av sensorernas varians
end

