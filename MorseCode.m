clc; clear global;

%Text to Speech using .NET
NET.addAssembly('System.Speech');
obj = System.Speech.Synthesis.SpeechSynthesizer;
obj.Volume = 100;
obj.Rate = 2;

% ---- __main__ ----
opt = 'Y';
while opt == 'Y'
clc;
prompt = {'Enter the Expression'};
dlgtitle = 'Morse Code Generator';
definput = {'Fcomm Project Morse Code'}; %default Input
dims = [1 80];
char1 = inputdlg(prompt,dlgtitle,dims,definput);
char1 = char(char1);
if isempty(char1)
    disp('No Input');
    obj.Rate = -1;
    Speak(obj, 'No Input was Given, would u like to enter again . Y for Yes and N for No');
    opt = char(input("Your choice : ", 's'));
    if opt == 'Y'
       continue;
    elseif opt == 'N'
        error('No Input was given');
    end
else
    break;
end
end

% ----- ENCODING -----
Mcode = encode(upper(char1)); 
Mcode1 = Mcode;
format= '---- ENCODING ---- \n The Morse Code of %s is equal to \n %s' ;
fprintf(format, char1, Mcode1)
Speak(obj, 'The Morse Code is');

pause(1);
obj.Rate = 1.5;


% ----- THE AUDIO PART OF ENCODING -----
%InputtsA = 'The Audio of the Morse Code that we Had is ';
%obj.Rate = -1;
%Speak(obj, InputtsA);
[MorseSound, cnt] = AudioMorse(Mcode1);
Audio = audioplayer(MorseSound, 15000);
pause(1);
play(Audio)
while isplaying(Audio)
    pause(0.00001);
end
% ----- DECODING -----
Output = decode(Mcode1);
format= ' \n\n---- DECODING ---- \n The Equivalent of %s is equal to %s / %s ';
fprintf(format, Mcode1, Output, lower(Output))
Inputts = 'The Equivalent of the above Morse Code is equal to';
obj.Rate = -2;
Speak(obj, Inputts); %VERBAL PART OF DECODING
Speak(obj, char(Output));

pause(1);

plot(MorseSound)
title('Morse Audio Lines');
xlabel('Thin lines = DOT and Thicker lines = DASH and Spaces after combination of lines = New letter and Bigger Spaces = New Word');
ylim([-inf inf]);
format = ' \n Total Dot and Dashes = %d ';
fprintf(format, cnt)

obj.Rate = 0;
pause(1);
Speak(obj, 'For the Reference Here is the Table of Morse Code of all Alphabets');

% ----- MORSE CODE TABLE ----- 
A_Z = [0:127];
for k = A_Z
    Mcode = encode(char(k));
    if Mcode ~= '*' 
        if Mcode ~='/'
         format = '\n %c (%d) / %c (%d) = %s';
         sprintf(format, char(k), k, char(k+32), k+32, Mcode)
        end
        continue;
    else
        continue;
    end
end


function M = morse_tree %The Main tree that we are using 
%level 4
h = {'H' {} {}};
v = {'V' {} {}};
f = {'F' {} {}}; %cell array
l = {'L' {} {}};
p = {'P' {} {}};
j = {'J' {} {}};
b = {'B' {} {}};  
x = {'X' {} {}};
c = {'C' {} {}};
y = {'Y' {} {}};
z = {'Z' {} {}};
q = {'Q' {} {}};

%level 3
s = {'S' h v};
u = {'U' f {}};
r = {'R' l {}};
w = {'W' p j};
d = {'D' b x};
k = {'K' c y};
g = {'G' z q};
o = {'O' {} {}};

%level 2
i = {'I' s u};
a = {'A' r w};
n = {'N' d k};
m = {'M' g o};

%level 1
e = {'E' i a};
t = {'T' n m};

%root
M = {' ' e t};

end

function Output = decode(Mc) %Function for Decoding 
  M = morse_tree;
  i=0;
  N = [];
  for k = 1:length(Mc)
      if Mc(k) == '.'
          M = M{2};
      elseif Mc(k) == '-'
          M = M{3};
      elseif Mc(k) == ' ' && (Mc(k-1) ~= '/' && Mc(k-1) ~= '*')
          i=i+1;
          N =[N M{1}];
          M = morse_tree;
          continue;
      elseif Mc(k) == '/'
          N = [N ' '];
          M = morse_tree;
          continue;
      end
      if isempty(M)
          continue;
      end
  end
  N = [N M{1}];
  Output = N;
            
end

function char4 = encode(char2)%Function for Encoding
  char4 = [];
  for i = 1:length(char2)
      k = 0;
      S = {morse_tree};
      D = {' '};
     while ~isempty(S)
      N = S{1};
      Mcode = D{1};
      S = S(2:end);
      D = D(2:end);
      if ~isempty(N)
          if N{1} == char2(i)
              k = 1;
             if char2(i) == ' '
                 char4 = [char4 ' /'];
                 continue;
             end
               char4 = [char4 Mcode];
               S = {};
               N = {};
          else
             S = { N{2} N{3} S{:}}; %DFS
             D = { [Mcode '.'] [Mcode '-'] D{:}}; 
          end
      end
     end
       if k == 0
        char4 = [char4 ' *'];
        continue;
      end
  end
  char4(1) = [];
  return;
end

function [MorseSound1, cnt1] = AudioMorse(Mcode2)% function for Audio of Morse Code

DotTimeInterval = sin(1:2500);

DashTimeInterval = sin(1:5800);

Pause = zeros(1,4000);

Space_hy_Pause = zeros(1,4500);

MorseSound1 = [];

cnt1 = 0;

for x = Mcode2
  if x == '.'
    cnt1 = cnt1+1;
    MorseSound1 = [MorseSound1 DotTimeInterval Pause];
  elseif x == '-'
    cnt1 = cnt1+1;
    MorseSound1 = [MorseSound1 DashTimeInterval Pause];
  elseif x == ' ' 
    MorseSound1 = [MorseSound1 Space_hy_Pause];
  elseif x == '/'
    MorseSound1 = [MorseSound1 Space_hy_Pause Pause]; 
 end
end
end