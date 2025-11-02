function minimum_mass(N, m, k)   
    % Find minimum mass for 90% reduction
    target_reduction = 0.9;
    original_response = 0.00967331;  % No absorbers
    target_response = original_response * target_reduction;
    
    % Binary search for minimum mass
    min_mass = 0;
    max_mass = 0.5 * N * m;  % Search up to 50% of structural mass
    
    for iter = 1:20
        test_mass = (min_mass + max_mass) / 2;
        test_mass_percentage = test_mass / (N * m);
        
        all_disp_cell = absorber_frequency_response(1000, N, m, k, test_mass_percentage);
        max_response = max(all_disp_cell{1});
        
        if max_response <= target_response
            max_mass = test_mass;  % Can use less mass
        else
            min_mass = test_mass;  % Need more mass
        end
    end
    min_mass_percentage = min_mass / (N * m);
    fprintf('Minimum mass percentage for 90%% reduction: %.3f%%\n', min_mass_percentage * 100);
end