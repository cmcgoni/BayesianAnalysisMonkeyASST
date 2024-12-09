%inputs to pltBayes: posterior values (norm_), the trial number where each
%phase starts, and the number of sessions you wish to graph from each
%subject (numsess)
function pltBayes_shuffled(normSP,normSH,normCO,Phases,XZ,numsess,ci)
     for n = 1:numsess %choose sessions to plot. 131 total sessions per subject in this cohort. ~40 of them are in pre-drinking period
        figure;
        %plot(normSP{1,XZ}{1,n},'displayname','spatial strategy');
        hold on;
        %plot(normSPa{1,XZZ}{1,n},'displayname','alternation strategy');
        %plot(normSH{1,XZ}{1,n},'displayname','shape strategy','k');
        %plot(normCO{1,XZ}{1,n},'displayname','color strategy','k');
        yline(0.6,'--','displayname','strategy threshold','r');
        yline(ci{1,XZ}{1,n},'--','displayname','shuffled','k')
        legend('location','northeastoutside');
        %labels = {'SD','SR','CD','CR','IDS','IDR','EDS','EDR'};
        %A = numel(Phases{1,XZ}{1,n});
        %xline(Phases{1,XZ}{1,n},'-',labels(1:A));
        ylabel('b-value');
        xlabel('trial');
        title(['Subject',sprintf('%d',XZ) 'Session',sprintf('%d',n)]); %want to add in titling with the actual subject ID rather than just the ##
        hold off;
    end
end