%inputs to getSigm: subject number (XZ), each session for each subject (outpt), and
%session length (sz)
%outputs from  are session length (could probably replace with sz),
%likelihood values for each trial for spatial (SPlike), shape (SHlike), and
%color (COlike), and the trial number where each phase starts (Phases)
function [Sessionlength, SPlike, SPalike, SHlike, COlike, Phases, trialsperphase] = getSigm(outpt,sz,XZ,dates)
    Sessionlength = {};
    SPlike = {};
    SPalike = {};
    SHlike = {};
    COlike = {};
    Phases = {};
    trialsperphase = {};
    
    for j = 1:length(dates{1,XZ})  %loop through number of sessions
        session             = cell2table(outpt{1,XZ}{1,j}); %isolates session j
        sess_1_spatial      = categorical(session.Var2); %isolates spatial strategy    
        SL                  = sz{1,XZ}(1,j); %pulls number of trials in session
        Sessionlength{j}    = SL;
        if SL < 3
            continue
        end
        sess_1_spatialcons  = zeros(SL,1); %initializes matrix for the consecutive for loop below
        
        %This produces a logical where 1 indicates 2 consecutive choices
        for b = 1:(SL-1)
            sess_1_spatialcons(b) = [logical(sess_1_spatial(b) == sess_1_spatial(b+1))];
        end
        
        %calculate the number of consecutive choices along a single dimension -
        %this goes into sigmoidal to influence "strength of evidence"
        spcons  = sess_1_spatialcons.';%some function below requires this to be in column, rather than row format
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
        rst         = sess_1_spatialcons == 0; % indexes trials where consecutive streak ends
        SigmSP(rst) = invsp(rst); % on trials where non-consistent choices are made, 
        SPlike{j} = SigmSP;
        % replace likelihood with the inverse of the previous likelihood

%Repeating spatial strategy calculations for alternating strategy
        sess_1_spatialalt  = zeros(SL,1);
        for b = 1:(SL-1)
            sess_1_spatialalt(b) = [logical(sess_1_spatial(b) ~= sess_1_spatial(b+1))];
        end
        %This alternating strategy is currently calculated by asking for
        %runs of trials where the animal is explicitly NOT choosing the
        %same side consecutively

        %calculate the number of consecutive choices along a single dimension -
        %this goes into sigmoidal to influence "strength of evidence"
        spalt  = sess_1_spatialalt.';%some function below requires this to be in column, rather than row format
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
        rspa         = sess_1_spatialalt == 0; % indexes trials where consecutive streak ends
        SigmSPa(rspa) = invspa(rspa); % on trials where non-consistent choices are made, 
        SPalike{j} = SigmSPa;

%%For win-based strategies, I need to create a new variable that counts up
%each three trials with correct responses and we are interested in what
%happens immediately after those trials (would it follow that a win-shift
%strategy would be identical to a lose-stay strategy? I don't think so, but
%what value would we provide for trials where there was an incorrect
%choice? Just a zero because they can't be exhibiting that strategy on
%those particular trials?
    %% From here, the above code is just repeated for shape and color calculations
        sess_1_shape        = categorical(session.Var3); %isolates shape strategy
        sess_1_shapecons    = zeros(SL,1); %initializes matrix for the consecutive for loop below
        
        %This produces a logical where 1 indicates 2 consecutive choices
        for b = 1:(SL-1)
            sess_1_shapecons(b) = [logical(sess_1_shape(b) == sess_1_shape(b+1))];
        end
        
        %calculate the number of consecutive choices along a single dimension -
        %this goes into sigmoidal to influence "strength of evidence"
        shcons  = sess_1_shapecons.';%some function below requires this to be in column, rather than row format
        ish     = cumsum([true diff(shcons)~=0]);                               % index the sections
        cssh    = arrayfun(@(a) cumsum(shcons(ish==a)), 1:ish(end), 'un', 0);    % cumsum each section
        Sh      = cat(2,cssh{:});                                            % concatenate the cells
        
        %Run sigmoidal function for likelihood values, adjusting on the basis of
        %how many consecutive choices have been made
        SigmSH = 0.5+((1./(1+exp(-(Sh-6))))./2);
        SigmSH = SigmSH.';
        
        shsig = [0;SigmSH(1:end-1)];
        invsh = 1-shsig; % inverse likelihood, shifted down by one cell
        
        rsh = sess_1_shapecons == 0; % indexes trials where consecutive streak ends
        
        SigmSH(rsh) = invsh(rsh); % on trials where non-consistent choices are made, 
        SHlike{j} = SigmSH;
        % replace likelihood with the inverse of the previous likelihood
    
        sess_1_color        = categorical(session.Var4); %isolates color strategy
        sess_1_colorcons    = zeros(SL,1); %initializes matrix for the consecutive for loop below
        
        %This produces a logical where 1 indicates 2 consecutive choices
        for b = 1:(SL-1)
            sess_1_colorcons(b) = [logical(sess_1_color(b) == sess_1_color(b+1))];
        end
        
        %calculate the number of consecutive choices along a single dimension -
        %this goes into sigmoidal to influence "strength of evidence"
        cocons  = sess_1_colorcons.';%some function below requires this to be in column, rather than row format
        ico     = cumsum([true diff(cocons)~=0]);                               % index the sections
        csco    = arrayfun(@(a) cumsum(cocons(ico==a)), 1:ico(end), 'un', 0);    % cumsum each section
        Co      = cat(2,csco{:});                                            % concatenate the cells
        
        %Run sigmoidal function for likelihood values, adjusting on the basis of
        %how many consecutive choices have been made
        SigmCO = 0.5+((1./(1+exp(-(Co-6))))./2);
        SigmCO = SigmCO.';
        
        cosig       = [0;SigmCO(1:end-1)];
        invco       = 1-cosig; % inverse likelihood, shifted down by one cell
        rco         = sess_1_colorcons == 0; % indexes trials where consecutive streak ends
        SigmCO(rco) = invco(rco); % on trials where non-consistent choices are made,
        COlike{j} = SigmCO;
        % replace likelihood with the inverse of the previous likelihood
    
        sess_1_phase = categorical(session.Var1); %isolates phase numbers
        sess_1_phase = double(sess_1_phase); %turns this categorical into a numerical array so I can use the find function
        
        SDidx   = find(sess_1_phase == 0, 1, 'first'); %stores the row/trial number where the each new phase begins
        SRidx   = find(sess_1_phase == 1, 1, 'first');
        CDidx   = find(sess_1_phase == 2, 1, 'first');
        CRidx   = find(sess_1_phase == 3, 1, 'first');
        IDSidx  = find(sess_1_phase == 4, 1, 'first');
        IDRidx  = find(sess_1_phase == 5, 1, 'first');
        EDSidx  = find(sess_1_phase == 6, 1, 'first');
        EDRidx  = find(sess_1_phase == 7, 1, 'first');

        phasestart = [SDidx;SRidx;CDidx;CRidx;IDSidx;IDRidx;EDSidx;EDRidx];
        Phases{j} = phasestart;

        SD = sum(sess_1_phase == 0);
        SR = sum(sess_1_phase == 1);
        CD = sum(sess_1_phase == 2);
        CR = sum(sess_1_phase == 3);
        IDS = sum(sess_1_phase == 4);
        IDR = sum(sess_1_phase == 5);   
        EDS = sum(sess_1_phase == 6);
        EDR = sum(sess_1_phase == 7);

        trials = [SD, SR, CD, CR, IDS, IDR, EDS, EDR];
        trialsperphase{j} = trials;



%Win strategies
%         sess_win = categorical(session.Var4);
%         cidx = ismember(sess_win, "correct");
%         for p = 1:(length(cidx)-1)
%             winstay(p) = sess_1_spatial(p) == sess_1_spatial(p+1);
%         end
%         Winstay{p} = winstay;
    end
end