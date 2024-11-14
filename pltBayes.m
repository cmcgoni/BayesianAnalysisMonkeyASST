%inputs to pltBayes: posterior values (norm_), the trial number where each
%phase starts, and the number of sessions you wish to graph from each
%subject (numsess)
function pltBayes(normSP,normSPa, normSH,normCO,Phases,XZ,numsess,sz,session)
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
        xline(Phases{1,XZ}{1,n+7},'-',labels(1:A));
        ylabel('b-value');
        xlabel('trial');
        title(['Subject',sprintf('%d',XZ) 'Session',sprintf('%d',n+session)]); %want to add in titling with the actual subject ID rather than just the ##
        hold off;
    end
end