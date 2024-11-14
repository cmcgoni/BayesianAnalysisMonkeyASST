%inputs to pltBayes: posterior values (norm_), the trial number where each
%phase starts, and the number of sessions you wish to graph from each
%subject (numsess)
function pltBayes(normSP,normSPa, normSH,normCO,Phases,XZ,numsess,sz,session,propSP,propSPa,propSH,propCO)
     for n = 1:numsess %choose sessions to plot. 131 total sessions per subject in this cohort. ~40 of them are in pre-drinking period
        if sz{1,XZ}(n+session) <3
            continue
        end
        figure;
        plot(normSP{1,XZ}{1,n+session},'displayname','spatial strategy');
        hold on;
        plot(normSPa{1,XZ}{1,n+session},'displayname','alternation strategy');
        plot(normSH{1,XZ}{1,n+session},'displayname','shape strategy');
        plot(normCO{1,XZ}{1,n+session},'displayname','color strategy');
        yline(0.6,'--','displayname','strategy threshold');
        legend('location','northeastoutside');
        labels = {'SD','SR','CD','CR','IDS','IDR','EDS','EDR'};
        A = numel(Phases{1,XZ}{1,n+session});
        xline(Phases{1,XZ}{1,n+session},'-',labels(1:A));
        ylabel('b-value');
        xlabel('trial');
        title(['Subject',sprintf('%d',XZ) 'Session',sprintf('%d',n+session)]); %want to add in titling with the actual subject ID rather than just the ##
        hold off;
        %proportion graphs
        figure;
        propSP{1,XZ}(38:end) = [];
        propSPa{1,XZ}(38:end) = [];
        propSH{1,XZ}(38:end) = [];
        propCO{1,XZ}(38:end) = [];
        monkey = [cell2mat(propSP{1,XZ});cell2mat(propSPa{1,XZ});cell2mat(propSH{1,XZ});cell2mat(propCO{1,XZ})];
        nostrat = [];
        for i = 1:width(monkey)
            nostrat(i) = 1-(sum(monkey(:,i)));
        end
        final = [monkey;nostrat];
        bar(final.','stacked');
        hold on;
        legend('spatial','alternation','shape',' color','no strategy');
        ylabel('proportion');
        xlabel('session');
        title(['Subject',sprintf('%d',XZ)]);
%         set(gca, 'YScale', 'log'); %Set log scale for y-axis to minimize the visual overwhelm of the no strategy proportion
        hold off;
    end
end