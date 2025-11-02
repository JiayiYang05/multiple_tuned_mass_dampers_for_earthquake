function all_disp_cell = impulse_frequency_response(num_absorbers_cases, N, m, k, abs_mass_percentage)

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

        % Den Hartog optimal tuning
        mu = total_absorber_mass / (N * m);
        opt_freq_ratio = 1 / (1 + mu);

        if num_abs == 1
            freq_ratios = opt_freq_ratio;
        else
            bandwidth = 0.08 + 0.05 * log(num_abs);  % Increases with absorber count
            freq_ratios = opt_freq_ratio * (1 + bandwidth).^linspace(-1, 1, num_abs);
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

        % IMPULSE RESPONSE CALCULATION
        % Create initial conditions for impulse response
        % Impulse at floor 1 is equivalent to initial velocity
        initial_velocity = zeros(N_total, 1);
        initial_velocity(1) = 1;  % Unit impulse at floor 1
        initial_displacement = zeros(N_total, 1);
        
        % Time vector for simulation
        t_end = 100;  % Sufficient time to observe response
        dt = 0.1;     % Time step
        t = 0:dt:t_end;
        
        % Initialize displacement response matrix
        disp_response = zeros(N_total, length(t));
        
        % Solve using modal superposition
        % Transform initial conditions to modal coordinates
        q0_dot = V' * M * initial_velocity;   % Initial modal velocity
        q0 = V' * M * initial_displacement;   % Initial modal displacement
        
        % Calculate response in modal coordinates
        for i = 1:length(t)
            for mode = 1:N_total
                omega_n = freqs_case(mode);
                if omega_n > 0  % Avoid division by zero for rigid body modes
                    % Modal response for impulse (zero initial displacement)
                    q_mode = (q0_dot(mode) / omega_n) * sin(omega_n * t(i));
                    disp_response(:, i) = disp_response(:, i) + V(:, mode) * q_mode;
                end
            end
        end
        
        % Calculate frequency response using FFT
        fs = 1/dt;  % Sampling frequency
        
        % Apply windowing to reduce spectral leakage
        window_length = length(t);
        window = 0.5 * (1 - cos(2*pi*(0:window_length-1)/(window_length-1)));  % Manual Hanning window
        
        % Apply window to each floor's response
        windowed_response = zeros(size(disp_response(1:N, :)));
        for floor_idx = 1:N
            windowed_response(floor_idx, :) = disp_response(floor_idx, :) .* window;
        end
        
        % Compute FFT
        nfft = 2^nextpow2(length(t));  % Next power of 2 for efficiency
        fft_response = fft(windowed_response, nfft, 2);
        frequencies = (0:nfft-1) * fs / nfft;
        
        % Take magnitude and only keep positive frequencies
        positive_freq_idx = 1:floor(nfft/2)+1;
        freq_response_mag = abs(fft_response(:, positive_freq_idx));
        frequencies = frequencies(positive_freq_idx);
        
        % Store frequency response (magnitude vs frequency)
        all_disp_cell{case_idx} = [frequencies; freq_response_mag];
    end
end