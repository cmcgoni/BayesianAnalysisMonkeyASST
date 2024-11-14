%inputs to anaBayes: all of the above (likelihood, phases, and total
%session length
%outputs from anaBayes: normalized posteriors, or b-values, for spatial
%(normSP), shape (normSH), and color (normCO) strategies
function [normSP,normSPa, normSH,normCO,propSP,propSPa,propSH,propCO] = anaBayes(XZ, Sessionlength, SPlike, SPalike, SHlike, COlike, Phases,dates)
%Annotate inputs and outputs%
    normSP = {};
    normSH = {};
    normSPa = {};
    normCO = {};

    for m = 1:length(dates{1,XZ})
        SL = Sessionlength{1,XZ}{1,m};
        phasestart = Phases{1,XZ}{1,m};
        SigmSP = SPlike{1,XZ}{1,m};
        SigmSPa = SPalike{1,XZ}{1,m};
        SigmSH = SHlike{1,XZ}{1,m};
        SigmCO = COlike{1,XZ}{1,m};

        posteriorSP = zeros(SL,1);
        posteriorSP(1)          = 0.5;
        posteriorSP(phasestart) = 0.5;
        noSP                  = zeros(SL,1);
        noSP(phasestart)      = 0.25;

        posteriorSPa = zeros(SL,1);
        posteriorSPa(1)         = 0.5;
        posteriorSPa(phasestart) = 0.5;
        noSPa                  = zeros(SL,1);
        noSPa(phasestart)      = 0.25;
        
        posteriorSH             = zeros(SL,1);
        posteriorSH(1)          = 0.5;    
        posteriorSH(phasestart) = 0.5;
        noSH                  = zeros(SL,1);
        noSH(phasestart)      = 0.25;
        
        posteriorCO             = zeros(SL,1);
        posteriorCO(1)             = 0.5;
        posteriorCO(phasestart) = 0.5;
        noCO                  = zeros(SL,1);
        noCO(phasestart)      = 0.25;
        
        for k = 2:SL
            if ismember(k,phasestart) %skip iteration of for loop at each of these trials where a new phase begins
                continue
            end
            posteriorSP(k)  = SigmSP(k) * noSP(k-1);
            posteriorSPa(k)  = SigmSPa(k) * noSPa(k-1);
            posteriorSH(k)  = SigmSH(k) * noSH(k-1);
            posteriorCO(k)  = SigmCO(k) * noCO(k-1);
            noSP(k)       = posteriorSP(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
            noSPa(k)      = posteriorSPa(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
            noSH(k)       = posteriorSH(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
            noCO(k)       = posteriorCO(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
        end
    normSP{m} = noSP;
    normSPa{m} = noSPa;
    normSH{m} = noSH;
    normCO{m} = noCO;
    propSP{m} = sum(normSP{m}>0.6)./SL;
    propSPa{m} = sum(normSPa{m}>0.6)./SL;
    propSH{m} = sum(normSH{m}>0.6)./SL;
    propCO{m} = sum(normCO{m}>0.6)./SL;
    end
end