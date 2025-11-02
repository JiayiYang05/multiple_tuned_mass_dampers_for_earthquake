function plot_frequency_response(all_disp_cell, num_absorbers_cases, mode)
    if mode == "impulse"
        N = 3;
        
        num_cases = length(num_absorbers_cases);
        
        % Calculate subplot dimensions
        if num_cases <= 3
            rows = 1;
            cols = num_cases;
        else
            rows = 2;
            cols = ceil(num_cases / 2);
        end
        
        figure;
        colors = lines(N); % Different colors for each floor
        
        for case_idx = 1:num_cases
            % Extract frequency response data
            response_data = all_disp_cell{case_idx};
            frequencies = response_data(1, :);
            magnitude_response = response_data(2:end, :);
            
            % Plot each floor's response
            subplot(rows, cols, case_idx);
            hold on;
            grid on;
            
            for floor_idx = 1:N
                plot(frequencies, magnitude_response(floor_idx, :), ...
                     'LineWidth', 1.5, 'DisplayName', sprintf('Floor %d', floor_idx), ...
                     'Color', colors(floor_idx, :));
            end
            
            title(sprintf('%d Absorber(s)', num_absorbers_cases(case_idx)));
            xlabel('Frequency (Hz)');
            ylabel('Magnitude');
            xlim([0, 10]); % Adjust based on your frequency range
            if case_idx == 1
                legend('Location', 'best');
            end
            set(gca, 'YScale', 'log'); % Log scale often better for frequency response
        end
        
        sgtitle('Frequency Response to Impulse Excitation');
        
        % Plot comparison of top floor response for all cases
        figure;
        hold on;
        grid on;
        
        case_colors = lines(num_cases);
        for case_idx = 1:num_cases
            response_data = all_disp_cell{case_idx};
            frequencies = response_data(1, :);
            magnitude_response = response_data(2:end, :);
            
            % Plot top floor response
            plot(frequencies, magnitude_response(N, :), ...
                 'LineWidth', 2, 'DisplayName', sprintf('%d Absorber(s)', num_absorbers_cases(case_idx)), ...
                 'Color', case_colors(case_idx, :));
        end
        
        title('Top Floor Frequency Response - Comparison');
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        xlim([0, 10]);
        legend('Location', 'best');
        set(gca, 'YScale', 'log');
    else
        w_array = 1:0.1:40;
        freq_Hz = w_array./(2*pi);
    
        for case_idx = 1:length(num_absorbers_cases)
            figure;
            all_disp = all_disp_cell{case_idx};
            plot(freq_Hz,abs(all_disp),'-');
            xlabel('Frequency (Hz)');
            ylabel('Displacement');
            title(['Frequency Response - Linear Plot / Num of Absorbers = ' num2str(num_absorbers_cases(case_idx))]);
            legend('Floor 1', 'Floor 2', 'Floor 3');
            grid on;
        end
    end
end