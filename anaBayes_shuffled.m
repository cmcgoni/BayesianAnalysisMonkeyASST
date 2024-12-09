%inputs to anaBayes: all of the above (likelihood, phases, and total
%session length
%outputs from anaBayes: normalized posteriors, or b-values, for spatial
%(normSP), shape (normSH), and color (normCO) strategies
function [ShSpPost, ShSpaPost, ShShPost, ShCoPost, ci] = anaBayes_shuffled(XZ, Sessionlength, ShSpatial, ShAltern, ShShape, ShColor, Phases)
%Annotate inputs and outputs%
    ShSpPost = {};
    ShSpaPost = {};
    ShShPost = {};
    ShCoPost = {};
    
    st = [28 29 30];

    for m = 1:length(st)
        for l = 1:100
            SL = Sessionlength{1,XZ}{1,st(m)};
            phasestart = Phases{1,XZ}{1,st(m)};
            SigmSP = ShSpatial{1,XZ}{1,m}(:,l);
            SigmSPa = ShAltern{1,XZ}{1,m}(:,l);
            SigmSH = ShShape{1,XZ}{1,m}(:,l);
            SigmCO = ShColor{1,XZ}{1,m}(:,l);
    
            posteriorSP                 = zeros(SL,1);
            posteriorSP(phasestart)     = 0.5;
            noSP                        = zeros(SL,1);
            noSP(phasestart)            = 0.25;
    
            posteriorSPa                = zeros(SL,1);
            posteriorSPa(phasestart)   = 0.5;
            noSPa                       = zeros(SL,1);
            noSPa(phasestart)          = 0.25;
            
            posteriorSH             = zeros(SL,1);
            posteriorSH(phasestart) = 0.5;
            noSH                  = zeros(SL,1);
            noSH(phasestart)      = 0.25;
            
            posteriorCO             = zeros(SL,1);
            posteriorCO(phasestart) = 0.5;
            noCO                  = zeros(SL,1);
            noCO(phasestart)      = 0.25;
            
            for k = 1:SL %I don't think this yet accounts for the fact that color isn't an option in SD/SR
                if ismember(k,phasestart) %skip iteration of for loop at each of these trials where a new phase begins
                    continue
                end
                posteriorSP(k)  = SigmSP(k) * noSP(k-1);
                posteriorSPa(k) = SigmSPa(k) * noSP(k-1);
                posteriorSH(k)  = SigmSH(k) * noSH(k-1);
                posteriorCO(k)  = SigmCO(k) * noCO(k-1);
                noSP(k)       = posteriorSP(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
                noSPa(k)      = posteriorSPa(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
                noSH(k)       = posteriorSH(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
                noCO(k)       = posteriorCO(k) / (posteriorSP(k) + posteriorSPa(k) + posteriorSH(k) + posteriorCO(k));
            end
        ShSp{l} = noSP;
        ShSpa{l} = noSPa;
        ShSh{l} = noSH;
        ShCo{l} = noCO;
        end

        ShSpPost{m} = cell2mat(ShSp);
        ShSpaPost{m} = cell2mat(ShSpa);
        ShShPost{m} = cell2mat(ShSh);
        ShCoPost{m} = cell2mat(ShCo);

        for i = 1:SL
            v = ShSpPost{m}(i,:).';
            d = fitdist(v, "Normal");
            b = paramci(d);
            f(i) = b(2,1);
        end
        ci{m} = f;
    end
end