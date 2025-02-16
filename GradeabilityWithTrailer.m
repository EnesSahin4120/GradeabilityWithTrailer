%Mechanical parameters
friction_coefficient = 0.7;
mass_vehicle = 13200;
torque_split = 0.5;
gravity = 9.81;

%Length parameters
length_rear_axle_to_cg = 2.551;
length_front_axle_to_cg = 2.123;
length_rear_axle_to_hitch = 0.47;
length_trailer_cg_to_hitch = 2;
length_trailer_cg_to_trailer_axle = 1.75;

%Height parameters
height_cg = 1.8;
height_hitch = 1.55;
height_trailer_cg = 1.67;

%Compute with given parameters
wheelbase = length_front_axle_to_cg + length_rear_axle_to_cg;
length_trailer_axle_to_hitch = length_trailer_cg_to_hitch + length_trailer_cg_to_trailer_axle;
weight_vehicle = mass_vehicle * gravity;

mass_trailer_range = linspace(4500, 35000, 100);
weight_trailer_range = mass_trailer_range * gravity;

% Compute max grade angles for FWD, RWD, and AWD
max_grade_angle_fwd = zeros(size(mass_trailer_range));
max_grade_angle_rwd = zeros(size(mass_trailer_range));
max_grade_angle_awd = zeros(size(mass_trailer_range));

for i = 1:length(mass_trailer_range)
    weight_trailer = weight_trailer_range(i);
    weight_ratio = weight_trailer / weight_vehicle;

    numerator_fwd = length_rear_axle_to_cg / wheelbase - weight_ratio * (length_rear_axle_to_hitch / wheelbase) * (length_trailer_cg_to_trailer_axle / length_trailer_axle_to_hitch);
    denominator_fwd = 1.0 + friction_coefficient * (height_cg / wheelbase) + weight_ratio * ...
                      (1.0 + friction_coefficient * (height_hitch / wheelbase) + friction_coefficient * (length_rear_axle_to_hitch / wheelbase) * ((height_hitch - height_trailer_cg) / length_trailer_axle_to_hitch));

    numerator_rwd = length_front_axle_to_cg / wheelbase + weight_ratio * ((wheelbase + length_rear_axle_to_hitch) / wheelbase) * (length_trailer_cg_to_trailer_axle / length_trailer_axle_to_hitch);
    denominator_rwd = 1.0 - friction_coefficient * (height_cg / wheelbase) + weight_ratio * ...
                      (1.0 - friction_coefficient * (height_hitch / wheelbase) - friction_coefficient * ((wheelbase + length_rear_axle_to_hitch) / wheelbase) * ((height_hitch - height_trailer_cg) / length_trailer_axle_to_hitch));

    max_grade_fwd = atan(friction_coefficient * numerator_fwd / denominator_fwd) * (180 / pi);
    max_grade_rwd = atan(friction_coefficient * numerator_rwd / denominator_rwd) * (180 / pi);

    weight_awd = torque_split * numerator_fwd / denominator_fwd + (1 - torque_split) * numerator_rwd / denominator_rwd;
    max_grade_awd = atan(friction_coefficient * weight_awd) * (180 / pi);

    max_grade_angle_fwd(i) = max_grade_fwd;
    max_grade_angle_rwd(i) = max_grade_rwd;
    max_grade_angle_awd(i) = max_grade_awd;
end

figure;
hold on;
grid on;
plot(mass_trailer_range, max_grade_angle_fwd, 'r-', 'LineWidth', 2); 
plot(mass_trailer_range, max_grade_angle_rwd, 'g--', 'LineWidth', 2);
plot(mass_trailer_range, max_grade_angle_awd, 'b-.', 'LineWidth', 2);

xlabel('\bf Trailer Mass (Kg)', 'Color', 'k', 'FontSize', 9);
ylabel('\bf Max Grade Angle (Degrees)', 'Color', 'k', 'FontSize', 9);
title('\bf Gradeability for Heavy Truck with Trailer', 'FontSize', 12);
legend('FWD', 'RWD', 'AWD');
hold off;