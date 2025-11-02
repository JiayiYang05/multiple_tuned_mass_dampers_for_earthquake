function find_optimal_para(num_abs, N, m, k, abs_mass_percentage)
    test_bandwidth = linspace(0.01,0.1,10);
    
     % Store original system matrices
    M_original = m*eye(N); % create the mass matrix
    K_original = k*[2 -1 0;-1 2 -1;0 -1 1]; % create the stiffness matrix

    total_absorber_mass = abs_mass_percentage * N * m;  % Total mass = 10% of structure mass

    % Initialize cell arrays to store results for each case
    all_disp_cell = cell(length(test_bandwidth), 1);


    % Start with original matrices
    M = M_original;
    K = K_original;

    % Calculate individual absorber properties
    m_abs = total_absorber_mass / num_abs;  % Mass per absorber

    % Create modified mass and stiffness matrices
    M = blkdiag(M, m_abs * eye(num_abs));

    % Expand stiffness matrix to include absorbers
    K = blkdiag(K, zeros(num_abs));

    % Calculate first natural frequency for original system
    [V_orig, D_orig] = eig(K_original, M_original);
    freqs_orig = sqrt(diag(D_orig));
    first_nat_freq = freqs_orig(1);

    % % Randomized tuning
    % freq_ratios = 0.95 + 0.1 * randn(num_abs,1);

    % Den Hartog optimal tuning
    mu = total_absorber_mass / (N * m);
    opt_freq_ratio = 1 / (1 + mu);

    for id = 1:length(test_bandwidth)
        bandwidth_factor = test_bandwidth(id); % Adaptive bandwidth
        % Geometric progression around optimal frequency
        freq_ratios = opt_freq_ratio * (1 + bandwidth_factor).^linspace(-1, 1, num_abs);


        for i = 1:num_abs
            k_abs = m_abs * (first_nat_freq * freq_ratios(i))^2;

            % Connect absorber to top floor (degree of freedom N)
            K(N, N) = K(N, N) + k_abs;
            K(N, N+i) = -k_abs;
            K(N+i, N) = -k_abs;
            K(N+i, N+i) = k_abs;
        end

        [V,D] = eig(K,M);

        % Update N_total to include absorbers
        N_total = N + num_abs;

        % Calculate natural frequencies for this system
        freqs_case = zeros(N_total, 1);
        for imode=1:N_total
          freqs_case(imode) = sqrt(D(imode,imode));
        end

        % Calculate frequency response functions
        all_disp = [];
        for w_val = 1:0.5:130
            B = K - ((w_val^2)*M); 
            % Create force vector with proper size
            force_vector = zeros(N_total, 1);
            force_vector(1) = 1;  % Force applied at floor 1

            % harmonic solution for unit force at floor 1
            disp_val = B \ force_vector;  % Use backslash instead of inv() for better numerical stability
            all_disp = [all_disp disp_val];
        end

        % Store results for this case (only store floor responses, not absorbers)
        all_disp_cell{id} = all_disp(1:N, :);  % Only keep floor responses
    end
    plot_frequency_response(all_disp_cell, test_bandwidth);
end
