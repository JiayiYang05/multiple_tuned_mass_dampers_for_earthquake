function multiple_absorbers(num_absorbers_cases, N, m, k, abs_mass_percentage, mode)
    if mode == "impulse"
        all_disp_cell = impulse_frequency_response(num_absorbers_cases, N, m, k, abs_mass_percentage);
    else
        all_disp_cell = absorber_frequency_response(num_absorbers_cases, N, m, k, abs_mass_percentage);
    end

    plot_frequency_response(all_disp_cell, num_absorbers_cases, mode);
    
end

