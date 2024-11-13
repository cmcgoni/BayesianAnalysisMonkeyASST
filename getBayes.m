%input to getBayes: full data file for a single subject (x)
%output from getBayes are formatted single sessions (output) as well as the length
%in number of trials of each session (sz)
% for XY = 1:length(Subjects);
function [outpt,sz,rewards, dates] = getBayes(x)
%Annotate inputs and ouputs
    dates   = unique(x.Date);
    for i = 1:length(dates)
        dt              = x.Date == dates(i);
        cor             = x.Description == "CorrectStimLocation";
        inc             = x.Description == "IncorrectStimLocation";
        reward          = x.Description == "CorrectRespRatioMet";
        com             = dt + reward;
        id              = com > 1;
        ind             = [dt,cor,inc];
        combin          = dt + cor + inc;
        idx             = combin > 1; %a value of 2 means that the trial matches the date and is either a correct or incorrect response
        phase           = x.TestPhase(idx); 
%         b               = double(string(phase));
        c               = find(phase > 7,1);
        phase(c:end)    = [];
        side            = x.SelectedSide(idx);
        side(c:end)     = [];
        side1 = string(side);
        shape           = x.SelectedShape(idx);
        shape(c:end)    = [];
        shape1 = string(shape);
        color           = x.SelectedColor(idx);
        color(c:end)    = [];
        color1 = string(color);
%         corr            = cor(idx); 
%         corr            = categorical(corr);
%         corr(c:end)     = [];
%         correct         = renamecats(corr,["true" "false"],["correct" "incorrect"]); %I don't think this logical was used for anything, but I was maybe planning to use it for counting reward delivery
        A               = [phase,side1,shape1,color1]; %can add back "correct" if I comment out the above lines
        outpt{i}        = cellstr(A);
        sz(i)           = size(outpt{i},1); %for each session, isolate number of trials
        rewards{i}      = x.TrialNumber(id); %create variable containing the trial numbers only when the reward is delivered  
    end
end
% end