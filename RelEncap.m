%% RelEncap.m: Calculates Relative Encapasulation Data from Compiled Data

% Notes: Post processing code. Calculations the relative encapsulation for the core intensity and total
% intensity data. Outputs various figures.

clear all
a = pwd;
cd ('Processed_mat')
load('Compiled_data_single.mat')

rel_encap = [];
rel_encapcore = [];
rel_encapCV = [];
encap_subbg = [];
dia_all = [];
redpx = [];

rel_encap = vertcat(rel_encap,encap./bgshapes(pos));
rel_encapcore = vertcat(rel_encapcore,encapcore./bgshapes(pos));
encap_subbg = vertcat(encap_subbg,encap-bgshapes(pos));
dia_all = vertcat(dia_all,dia);
redpx = vertcat(redpx,redpixels);

copynum = 5*10^(-12)*(4/3*pi*(dia_all./2).^3).*rel_encap .* (1/(634.4*10^6))...
    *6.02214*10^23;
cd(a)
mkdir 'Histograms by Size'
cd 'Histograms by Size'

bin = discretize(dia_all,0.5:1:max(dia_all)+1);

copynummean = [];
for i = 1:max(bin)
    copynumbin{i} = copynum(bin == i);
    copynummean(i) = mean(copynumbin{i});
    if i <= 25
        figure ('visible','off'); histogram(copynumbin{i},10, 'normalization','probability')
        xlabel('Copy #'); ylabel('Probability'); legend(strcat('N = ',num2str(length(copynumbin{i}))))
        set(gca,'fontsize', 14); 
        title(strcat('Copy Number Histogram: ',num2str(i),' \mum bin'))
        saveas(gcf, strcat('Copy Number Hist Bin#',num2str(i),'.png'))
        close
        figure('visible','off'); histogram(rel_encap(bin == i),10, 'normalization','probability')
        xlabel('Relative Enapsulation'); ylabel('Probability'); legend(strcat('N = ',num2str(length(copynumbin{i}))))
        set(gca,'fontsize', 14); 
        title(strcat('Relative Encapsulation Histogram: ',num2str(i),' \mum bin'))
        saveas(gcf, strcat('Rel encap Hist Bin#',num2str(i),'.png'))
        close
    end
end

cd(a); cd('Processed_Mat')

figure; boxplot(rel_encapcore,bin);
xlabel('Diameter bin (\mum)');
ylabel('Relative Encapsulation');

figure; histogram(rel_encap,0:0.1:max(rel_encap),'normalization','probability')
xlabel('Encapsulation Efficiency');
ylabel('Population Fraction');
title('Mean Intensity')

figure; histogram(rel_encapcore,0:0.1:max(rel_encapcore),'normalization','probability')
xlabel('Encapsulation Efficiency');
ylabel('Population Fraction');
title('Core Intensity')

outputFileNameMAT1 = 'Rel_Encap_Single.mat';
save(outputFileNameMAT1,'rel_encap','rel_encapcore','dia_all','bin','dia_true','copynumbin',...
    'copynummean','copynum');
cd(a);