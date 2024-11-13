%input to getBayes: full data file for a single subject (x)
%output from getBayes are formatted single sessions (output) as well as the length
%in number of trials of each session (sz)
% for XY = 1:length(Subjects);
function [outpt,sz] = getBayes(x)
%Annotate inputs and ouputs
    x       = x(2:end,:);
    dates   = unique(x.Date);

    for i = 1:length(dates)
        dt              = x.Date == dates(i);
        cor             = x.Description == "CorrectStimLocation";
        inc             = x.Description =="IncorrectStimLocation";
        ind             = [dt,cor,inc];
        combin          = dt + cor + inc;
        idx             = combin > 1; %a value of 2 means that the trial matches the date and is either a correct or incorrect response
        phase           = x.TestPhase(idx); 
        b               = double(string(phase));
        c               = find(b > 7,1);
        phase(c:end)    = [];
        side            = x.SelectedSide(idx);
        side(c:end)     = [];
        shape           = x.SelectedShape(idx);
        shape(c:end)    = [];
        color           = x.SelectedColor(idx);
        color(c:end)    = [];
        %Working to create a logical in the total trials (defined by idx)
        %where correct trials (identified in cor) happen
        corr            = cor(idx); 
        corr            = categorical(corr);
        corr(c:end)     = [];
        correct         = renamecats(corr,["true" "false"],["correct" "incorrect"]);
        outpt{i}        = cellstr([phase,side,shape,color, correct]);
        sz(i)           = size(outpt{i},1); %for each session, isolate number of trials
    end
end
% end