function all_disp_cell = absorber_frequency_response(num_absorbers_cases, N, m, k, abs_mass_percentage)

    % Store original system matrices
    M_original = m*eye(N); % create the mass matrix
    K_original = k*[2 -1 0;-1 2 -1;0 -1 1]; % create the stiffness matrix

    total_absorber_mass = abs_mass_percentage * N * m;  % Total mass = 10% of structure mass

    % Initialize cell arrays to store results for each case
    all_disp_cell = cell(length(num_absorbers_cases), 1);

    for case_idx = 1:length(num_absorbers_cases)
        num_abs = num_absorbers_cases(case_idx);

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

        if num_abs == 1
            freq_ratios = opt_freq_ratio;
        else
            bandwidth = 0.1 + 0.05 * log(num_abs);  % Increases with absorber count
            % freq_ratios = linspace(1 - bandwidth/2, 1 + bandwidth/2, num_abs);
            freq_ratios = opt_freq_ratio * (1 + bandwidth).^linspace(-1, 1, num_abs);
            % freq_ratios = logspace(log10(1 - bandwidth/2), log10(1 + bandwidth/2), num_abs);

        end

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
        for w_val = 1:0.1:40
            B = K - ((w_val^2)*M); 
            % Create force vector with proper size
            force_vector = zeros(N_total, 1);
            force_vector(1) = 1;  % Force applied at floor 1

            % harmonic solution for unit force at floor 1
            disp_val = B \ force_vector;  % Use backslash instead of inv() for better numerical stability
            all_disp = [all_disp disp_val];
        end

        % Store results for this case (only store floor responses, not absorbers)
        all_disp_cell{case_idx} = all_disp(1:N, :);  % Only keep floor responses
    end
end

