%inputs to getSigm: subject number (XZ), each session for each subject (outpt), and
%session length (sz)
%outputs from  are session length (could probably replace with sz),
%likelihood values for each trial for spatial (SPlike), shape (SHlike), and
%color (COlike), and the trial number where each phase starts (Phases)
function [ShSpatial, ShAltern, ShShape, ShColor] = getSigm_shuffled(outpt,XZ,Phases, trialsperphase,Sessionlength)
    ShSpatial = {};
    ShAltern = {};
    ShShape = {};
    ShColor = {};

    st = [28 29 30]; %specific sessions to run shuffle on (could generate random sessions here, probalby would be better)

    for j = 1:length(st)
        SL = Sessionlength{1,XZ}{1,st(j)};
        phase = Phases{1,XZ}{1,st(j)}(:,:);
        for l = 1:100 %need to move up to 100 ultimately, but it takes a while to run
            session = cell2table(outpt{1,XZ}{st(j)}); 
            spatial = categorical(session.Var2);
            shape = categorical(session.Var3);
            color = categorical(session.Var4);
            stim = [spatial, shape, color]; %categorical variable

            b = length(phase);
            trials = {};
            random = {};
            for i = 1:(b-1)
                idx = trialsperphase{1,XZ}{st(j)}(i+1); %number of trials
                %randomizes order of indices -- need to apply indices to each range of trial numbers in a given phase
                tstidx = (phase(i)) : (phase(i+1));
                trials{i} = tstidx;
                random{i} = randperm(idx);
            end
            finalphase = phase(end) : SL;
            trials = [trials, finalphase];
            id2 = SL - phase(end) + 1;
            random = [random, randperm(id2)];
            
            shuffle = {};

            for k = 1:b
                shuffle{k} = trials{k}(random{k});
            end

            shuf = horzcat(shuffle{:}).';
            shufstim = stim(shuf,:); 
            
            shufspatial = shufstim(:,1);
            shufshape = shufstim(:,2);
            shufcolor = shufstim(:,3);

            spatialcons  = zeros(SL,1); %initializes matrix for the consecutive for loop below
            %This produces a logical where 1 indicates 2 consecutive choices

            for p = 1:(SL - 1)
                spatialcons(p) = [logical(shufspatial(p) == shufspatial(p+1))];
            end
            
            %calculate the number of consecutive choices along a single dimension -
            %this goes into sigmoidal to influence "strength of evidence"
            spcons  = spatialcons.';%some function below requires this to be in column, rather than row format
            isp     = cumsum([true diff(spcons)~=0]);                               % index the sections
            cssp    = arrayfun(@(a) cumsum(spcons(isp==a)), 1:isp(end), 'un', 0);    % cumsum each section
            Sp      = cat(2,cssp{:});                                            % concatenate the cells
            
            %Run sigmoidal function for likelihood values, adjusting on the basis of
            %how many consecutive choices have been made
            SigmSP = 0.5+((1./(1+exp(-(Sp-6))))./2);
            SigmSP = SigmSP.';
            
            % sess_1_spatialcons index values where this = 0 and in Sigm, replace those
            % indexed values with 1-prev value. This is our method of "penalizing" the
            % algorithm when a consistent behavior is interrupted
            spsig       = [0;SigmSP(1:end-1)];
            invsp       = 1-spsig; % inverse likelihood, shifted down by one cell
            rst         = spatialcons == 0; % indexes trials where consecutive streak ends
            SigmSP(rst) = invsp(rst); % on trials where non-consistent choices are made, 
            shSPlike{l} = SigmSP;
            % replace likelihood with the inverse of the previous likelihood
    
    %Repeating spatial strategy calculations for alternating strategy
            spatialalt  = zeros(SL,1);
            for p = 1:(SL-1)
                spatialalt(p) = [logical(shufspatial(p) ~= shufspatial(p+1))];
            end
            %This alternating strategy is currently calculated by asking for
            %runs of trials where the animal is explicitly NOT choosing the
            %same side consecutively
    
            %calculate the number of consecutive choices along a single dimension -
            %this goes into sigmoidal to influence "strength of evidence"
            spalt  = spatialalt.';%some function below requires this to be in column, rather than row format
            ispa     = cumsum([true diff(spalt)~=0]);                               % index the sections
            csspa    = arrayfun(@(a) cumsum(spalt(ispa==a)), 1:ispa(end), 'un', 0);    % cumsum each section
            Spa      = cat(2,csspa{:});                                            % concatenate the cells
            
            %Run sigmoidal function for likelihood values, adjusting on the basis of
            %how many consecutive choices have been made
            SigmSPa = 0.5+((1./(1+exp(-(Spa-6))))./2);
            SigmSPa = SigmSPa.';
            
            % sess_1_spatialcons index values where this = 0 and in Sigm, replace those
            % indexed values with 1-prev value. This is our method of "punishing" the
            % algorithm when a consistent behavior is interrupted
            spasig       = [0;SigmSPa(1:end-1)];
            invspa       = 1-spasig; % inverse likelihood, shifted down by one cell
            rspa         = spatialalt == 0; % indexes trials where consecutive streak ends
            SigmSPa(rspa) = invspa(rspa); % on trials where non-consistent choices are made, 
            shSPalike{l} = SigmSPa;
    
        % From here, the above code is just repeated for shape and color calculations
            shapecons    = zeros(SL,1); %initializes matrix for the consecutive for loop below
            
            %This produces a logical where 1 indicates 2 consecutive choices
            for p = 1:(SL - 1)
                shapecons(p) = [logical(shufshape(p) == shufshape(p+1))];
            end
            
            %calculate the number of consecutive choices along a single dimension -
            %this goes into sigmoidal to influence "strength of evidence"
            shcons  = shapecons.';%some function below requires this to be in column, rather than row format
            ish     = cumsum([true diff(shcons)~=0]);                               % index the sections
            cssh    = arrayfun(@(a) cumsum(shcons(ish==a)), 1:ish(end), 'un', 0);    % cumsum each section
            Sh      = cat(2,cssh{:});                                            % concatenate the cells
            
            %Run sigmoidal function for likelihood values, adjusting on the basis of
            %how many consecutive choices have been made
            SigmSH = 0.5+((1./(1+exp(-(Sh-6))))./2);
            SigmSH = SigmSH.';
            
            shsig = [0;SigmSH(1:end-1)];
            invsh = 1-shsig; % inverse likelihood, shifted down by one cell
            
            rsh = shapecons == 0; % indexes trials where consecutive streak ends
            
            SigmSH(rsh) = invsh(rsh); % on trials where non-consistent choices are made, 
            shSHlike{l} = SigmSH;
            % replace likelihood with the inverse of the previous likelihood
        
            colorcons    = zeros(SL,1); %initializes matrix for the consecutive for loop below
            %This produces a logical where 1 indicates 2 consecutive choices
            for p = 1:(SL - 1)
                colorcons(p) = [logical(shufcolor(p) == shufcolor(p+1))];
            end
            
            %calculate the number of consecutive choices along a single dimension -
            %this goes into sigmoidal to influence "strength of evidence"
            cocons  = colorcons.';%some function below requires this to be in column, rather than row format
            ico     = cumsum([true diff(cocons)~=0]);                               % index the sections
            csco    = arrayfun(@(a) cumsum(cocons(ico==a)), 1:ico(end), 'un', 0);    % cumsum each section
            Co      = cat(2,csco{:});                                            % concatenate the cells
            
            %Run sigmoidal function for likelihood values, adjusting on the basis of
            %how many consecutive choices have been made
            SigmCO = 0.5+((1./(1+exp(-(Co-6))))./2);
            SigmCO = SigmCO.';
            
            cosig       = [0;SigmCO(1:end-1)];
            invco       = 1-cosig; % inverse likelihood, shifted down by one cell
            rco         = colorcons == 0; % indexes trials where consecutive streak ends
            SigmCO(rco) = invco(rco); % on trials where non-consistent choices are made,
            shCOlike{l} = SigmCO;
            % replace likelihood with the inverse of the previous likelihood
        end
        ShSpatial{j} = [shSPlike{:}];
        ShAltern{j} = [shSPalike{:}];
        ShShape{j} = [shSHlike{:}];
        ShColor{j} = [shCOlike{:}];
    end
end