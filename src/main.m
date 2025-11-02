syms w;
m = 1.83; % mass of one floor
L = 0.2; % length
N = 3; % number of degrees of freedom
b = 0.08; % width
E = 210E9; % Young's Modulus
d = 0.001; % thickness
I = b*d*d*d/12; % second moment of area
k = (24*E*I)/(L*L*L); % static stiffness for each floor

num_absorbers_cases = [0, 1, 10, 100, 1000];  % Number of absorbers to test
abs_mass_percentage = 0.1;

% find_optimal_para(100, N, m, k, abs_mass_percentage)

multiple_absorbers(num_absorbers_cases, N, m, k, abs_mass_percentage, "sin");

% minimum_mass(N, m, k);
